Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 80FBA6004A5
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 08:22:19 -0500 (EST)
Date: Thu, 4 Feb 2010 21:21:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/11] [RFC] 512K readahead size with thrashing safe
	readahead
Message-ID: <20100204132154.GA26442@localhost>
References: <20100202152835.683907822@intel.com> <20100202223803.GF3922@redhat.com> <20100203062756.GB22890@localhost> <20100203152454.GA17059@redhat.com> <20100203155845.GB17059@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100203155845.GB17059@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Clemens Ladisch <clemens@ladisch.de>
List-ID: <linux-mm.kvack.org>

Vivek,

> > I have got two paths to the HP EVA and got multipath device setup(dm-3). I
> > noticed with vanilla kernel read_ahead_kb=128 after boot but with your patches
> > applied it is set to 4. So looks like something went wrong with device
> > size/capacity detection hence wrong defaults. Manually setting
> > read_ahead_kb=512, got me better performance as compare to vanilla kernel.
> > 
> 
> I put a printk in add_disk and noticed that for multipath device
> get_capacity() is returning 0 and that's why ra_pages is being set
> to 1.

Good catch, Thanks!

It makes no sense to limit readahead size for multipath or other
compound devices. So we may just ignore the get_capacity() == 0 case,
as in the following updated patch.

Thanks,
Fengguang
---
readahead: limit readahead size for small devices

Linus reports a _really_ small & slow (505kB, 15kB/s) USB device,
on which blkid runs unpleasantly slow. He manages to optimize the blkid
reads down to 1kB+16kB, but still kernel read-ahead turns it into 48kB.

     lseek 0,    read 1024   => readahead 4 pages (start of file)
     lseek 1536, read 16384  => readahead 8 pages (page contiguous)

The readahead heuristics involved here are reasonable ones in general.
So it's good to fix blkid with fadvise(RANDOM), as Linus already did.

For the kernel part, Linus suggests:
  So maybe we could be less aggressive about read-ahead when the size of
  the device is small? Turning a 16kB read into a 64kB one is a big deal,
  when it's about 15% of the whole device!

This looks reasonable: smaller device tend to be slower (USB sticks as
well as micro/mobile/old hard disks).

Given that the non-rotational attribute is not always reported, we can
take disk size as a max readahead size hint. This patch uses a formula
that generates the following concrete limits:

        disk size    readahead size
     (scale by 4)      (scale by 2)
               1M                8k
               4M               16k
              16M               32k
              64M               64k
             256M              128k
               1G              256k
        --------------------------- (*)
               4G              512k
              16G             1024k
              64G             2048k
             256G             4096k

(*) Since the default readahead size is 512k, this limit only takes
effect for devices whose size is less than 4G.

The formula is determined on the following data, collected by script:

	#!/bin/sh

	# please make sure BDEV is not mounted or opened by others
	BDEV=sdb

	for rasize in 4 16 32 64 128 256 512 1024 2048 4096 8192
	do
		echo $rasize > /sys/block/$BDEV/queue/read_ahead_kb 
		time dd if=/dev/$BDEV of=/dev/null bs=4k count=102400
	done

The principle is, the formula shall not limit readahead size to such a
degree that will impact some device's sequential read performance.

The Intel SSD is special in that its throughput increases steadily with
larger readahead size. However it may take years for Linux to increase
its default readahead size to 2MB, so we don't take it seriously in the
formula.

SSD 80G Intel x25-M SSDSA2M080 (reported by Li Shaohua)

	rasize	1st run		2nd run
	----------------------------------
	  4k	123 MB/s	122 MB/s
	 16k  	153 MB/s	153 MB/s
	 32k	161 MB/s	162 MB/s
	 64k	167 MB/s	168 MB/s
	128k	197 MB/s	197 MB/s
	256k	217 MB/s	217 MB/s
	512k	238 MB/s	234 MB/s
	  1M	251 MB/s	248 MB/s
	  2M	259 MB/s	257 MB/s
==>	  4M	269 MB/s	264 MB/s
	  8M	266 MB/s	266 MB/s

Note that ==> points to the readahead size that yields plateau throughput.

SSD 22G MARVELL SD88SA02 MP1F (reported by Jens Axboe)

	rasize  1st             2nd
	--------------------------------
	  4k     41 MB/s         41 MB/s
	 16k     85 MB/s         81 MB/s
	 32k    102 MB/s        109 MB/s
	 64k    125 MB/s        144 MB/s
	128k    183 MB/s        185 MB/s
	256k    216 MB/s        216 MB/s
	512k    216 MB/s        236 MB/s
	1024k   251 MB/s        252 MB/s
	  2M    258 MB/s        258 MB/s
==>       4M    266 MB/s        266 MB/s
	  8M    266 MB/s        266 MB/s

SSD 30G SanDisk SATA 5000

	  4k	29.6 MB/s	29.6 MB/s	29.6 MB/s
	 16k	52.1 MB/s	52.1 MB/s	52.1 MB/s
	 32k	61.5 MB/s	61.5 MB/s	61.5 MB/s
	 64k	67.2 MB/s	67.2 MB/s	67.1 MB/s
	128k	71.4 MB/s	71.3 MB/s	71.4 MB/s
	256k	73.4 MB/s	73.4 MB/s	73.3 MB/s
==>	512k	74.6 MB/s	74.6 MB/s	74.6 MB/s
	  1M	74.7 MB/s	74.6 MB/s	74.7 MB/s
	  2M	76.1 MB/s	74.6 MB/s	74.6 MB/s

USB stick 32G Teclast CoolFlash idVendor=1307, idProduct=0165

	  4k	7.9 MB/s 	7.9 MB/s 	7.9 MB/s
	 16k	17.9 MB/s	17.9 MB/s	17.9 MB/s
	 32k	24.5 MB/s	24.5 MB/s	24.5 MB/s
	 64k	28.7 MB/s	28.7 MB/s	28.7 MB/s
	128k	28.8 MB/s	28.9 MB/s	28.9 MB/s
==>	256k	30.5 MB/s	30.5 MB/s	30.5 MB/s
	512k	30.9 MB/s	31.0 MB/s	30.9 MB/s
	  1M	31.0 MB/s	30.9 MB/s	30.9 MB/s
	  2M	30.9 MB/s	30.9 MB/s	30.9 MB/s

USB stick 4G SanDisk  Cruzer idVendor=0781, idProduct=5151

	  4k	6.4 MB/s 	6.4 MB/s 	6.4 MB/s
	 16k	13.4 MB/s	13.4 MB/s	13.2 MB/s
	 32k	17.8 MB/s	17.9 MB/s	17.8 MB/s
	 64k	21.3 MB/s	21.3 MB/s	21.2 MB/s
	128k	21.4 MB/s	21.4 MB/s	21.4 MB/s
==>	256k	23.3 MB/s	23.2 MB/s	23.2 MB/s
	512k	23.3 MB/s	23.8 MB/s	23.4 MB/s
	  1M	23.8 MB/s	23.4 MB/s	23.3 MB/s
	  2M	23.4 MB/s	23.2 MB/s	23.4 MB/s

USB stick 2G idVendor=0204, idProduct=6025 SerialNumber: 08082005000113

	  4k	6.7 MB/s 	6.9 MB/s 	6.7 MB/s
	 16k	11.7 MB/s	11.7 MB/s	11.7 MB/s
	 32k	12.4 MB/s	12.4 MB/s	12.4 MB/s
   	 64k	13.4 MB/s	13.4 MB/s	13.4 MB/s
	128k	13.4 MB/s	13.4 MB/s	13.4 MB/s
==>	256k	13.6 MB/s	13.6 MB/s	13.6 MB/s
	512k	13.7 MB/s	13.7 MB/s	13.7 MB/s
	  1M	13.7 MB/s	13.7 MB/s	13.7 MB/s
	  2M	13.7 MB/s	13.7 MB/s	13.7 MB/s

64 MB, USB full speed (collected by Clemens Ladisch)
Bus 003 Device 003: ID 08ec:0011 M-Systems Flash Disk Pioneers DiskOnKey

	4KB:    139.339 s, 376 kB/s
	16KB:   81.0427 s, 647 kB/s
	32KB:   71.8513 s, 730 kB/s
==>	64KB:   67.3872 s, 778 kB/s
	128KB:  67.5434 s, 776 kB/s
	256KB:  65.9019 s, 796 kB/s
	512KB:  66.2282 s, 792 kB/s
	1024KB: 67.4632 s, 777 kB/s
	2048KB: 69.9759 s, 749 kB/s

CC: Li Shaohua <shaohua.li@intel.com>
CC: Clemens Ladisch <clemens@ladisch.de>
Acked-by: Jens Axboe <jens.axboe@oracle.com>
Tested-by: Vivek Goyal <vgoyal@redhat.com>
Tested-by: Linus Torvalds <torvalds@linux-foundation.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 block/genhd.c |   24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

--- linux.orig/block/genhd.c	2010-02-03 20:40:37.000000000 +0800
+++ linux/block/genhd.c	2010-02-04 21:19:07.000000000 +0800
@@ -518,6 +518,7 @@ void add_disk(struct gendisk *disk)
 	struct backing_dev_info *bdi;
 	dev_t devt;
 	int retval;
+	unsigned long size;
 
 	/* minors == 0 indicates to use ext devt from part0 and should
 	 * be accompanied with EXT_DEVT flag.  Make sure all
@@ -551,6 +552,29 @@ void add_disk(struct gendisk *disk)
 	retval = sysfs_create_link(&disk_to_dev(disk)->kobj, &bdi->dev->kobj,
 				   "bdi");
 	WARN_ON(retval);
+
+	/*
+	 * Limit default readahead size for small devices.
+	 *        disk size    readahead size
+	 *               1M                8k
+	 *               4M               16k
+	 *              16M               32k
+	 *              64M               64k
+	 *             256M              128k
+	 *               1G              256k
+	 *        ---------------------------
+	 *               4G              512k
+	 *              16G             1024k
+	 *              64G             2048k
+	 *             256G             4096k
+	 * Since the default readahead size is 512k, this limit
+	 * only takes effect for devices whose size is less than 4G.
+	 */
+	if (get_capacity(disk)) {
+		size = get_capacity(disk) >> 9;
+		size = 1UL << (ilog2(size) / 2);
+		bdi->ra_pages = min(bdi->ra_pages, size);
+	}
 }
 
 EXPORT_SYMBOL(add_disk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
