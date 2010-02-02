From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 01/11] readahead: limit readahead size for small devices
Date: Tue, 02 Feb 2010 23:28:36 +0800
Message-ID: <20100202153316.375570078@intel.com>
References: <20100202152835.683907822@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NcKmu-00054Z-Hb
	for glkm-linux-mm-2@m.gmane.org; Tue, 02 Feb 2010 16:35:37 +0100
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D223D6B009B
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 10:35:27 -0500 (EST)
Content-Disposition: inline; filename=readahead-size-for-tiny-device.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

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
take disk size as a max readahead size hint. We use a formula that
generates the following concrete limits:

        disk size    readahead size
     (scale by 4)      (scale by 2)
               2M            	 4k
               8M                8k
              32M               16k
             128M               32k
             512M               64k
               2G              128k
               8G              256k
              32G              512k
             128G             1024k

The formula is determined on the following data, collected by script:

	#!/bin/sh

	# please make sure BDEV is not mounted or opened by others
	BDEV=sdb

	for rasize in 4 16 32 64 128 256 512 1024 2048
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

SSD 80G Intel x25-M SSDSA2M080

	rasize	first run time/throughput	second run time/throughput
	------------------------------------------------------------------
	  4k	3.40038 s,	123 MB/s	3.42842 s,	122 MB/s
	  8k	2.7362 s,	153 MB/s	2.74528 s,	153 MB/s
	 16k	2.59808 s,	161 MB/s	2.58728 s,	162 MB/s
	 32k	2.50488 s,	167 MB/s	2.49138 s,	168 MB/s
	 64k	2.12861 s,	197 MB/s	2.13055 s,	197 MB/s
	128k	1.92905 s,	217 MB/s	1.93176 s,	217 MB/s
	256k	1.75896 s,	238 MB/s	1.78963 s,	234 MB/s
	512k	1.67357 s,	251 MB/s	1.69112 s,	248 MB/s
	  1M	1.62115 s,	259 MB/s	1.63206 s,	257 MB/s
==>	  2M	1.56204 s,	269 MB/s	1.58854 s,	264 MB/s
	  4M	1.57949 s,	266 MB/s	1.57426 s,	266 MB/s

Note that ==> points to the readahead size that yields plateau throughput.

SSD 30G SanDisk SATA 5000

	  4k	14.1593 s,	29.6 MB/s	14.1699 s,	29.6 MB/s	14.1782 s,	29.6 MB/s
	  8k	8.05231 s,	52.1 MB/s	8.04463 s,	52.1 MB/s	8.04758 s,	52.1 MB/s
	 16k	6.81751 s,	61.5 MB/s	6.81564 s,	61.5 MB/s	6.8146 s,	61.5 MB/s
	 32k	6.24176 s,	67.2 MB/s	6.2438 s,	67.2 MB/s	6.24645 s,	67.1 MB/s
	 64k	5.87828 s,	71.4 MB/s	5.87858 s,	71.3 MB/s	5.87481 s,	71.4 MB/s
	128k	5.71649 s,	73.4 MB/s	5.71804 s,	73.4 MB/s	5.72055 s,	73.3 MB/s
==>	256k	5.62466 s,	74.6 MB/s	5.62304 s,	74.6 MB/s	5.62114 s,	74.6 MB/s
	512k	5.61532 s,	74.7 MB/s	5.62098 s,	74.6 MB/s	5.61818 s,	74.7 MB/s
	  1M	5.50888 s,	76.1 MB/s	5.6204 s,	74.6 MB/s	5.62281 s,	74.6 MB/s

USB stick 32G Teclast CoolFlash idVendor=1307, idProduct=0165

	  4k	53.1635 s,	7.9 MB/s 	53.155 s,	7.9 MB/s 	53.107 s,	7.9 MB/s
	  8k	23.4061 s,	17.9 MB/s	23.3955 s,	17.9 MB/s	23.4222 s,	17.9 MB/s
	 16k	17.1077 s,	24.5 MB/s	17.0909 s,	24.5 MB/s	17.0875 s,	24.5 MB/s
	 32k	14.6029 s,	28.7 MB/s	14.5913 s,	28.7 MB/s	14.5951 s,	28.7 MB/s
	 64k	14.5483 s,	28.8 MB/s	14.5344 s,	28.9 MB/s	14.5333 s,	28.9 MB/s
==>	128k	13.7497 s,	30.5 MB/s	13.7364 s,	30.5 MB/s	13.731 s,	30.5 MB/s
	256k	13.5521 s,	30.9 MB/s	13.5415 s,	31.0 MB/s	13.5554 s,	30.9 MB/s
	512k	13.5414 s,	31.0 MB/s	13.5631 s,	30.9 MB/s	13.5654 s,	30.9 MB/s
	  1M	13.574 s,	30.9 MB/s	13.5686 s,	30.9 MB/s	13.5667 s,	30.9 MB/s

USB stick 4G SanDisk  Cruzer idVendor=0781, idProduct=5151

	  4k	65.3449 s,	6.4 MB/s 	65.3759 s,	6.4 MB/s 	65.3405 s,	6.4 MB/s
	  8k	31.2002 s,	13.4 MB/s	31.1914 s,	13.4 MB/s	31.6836 s,	13.2 MB/s
	 16k	23.5281 s,	17.8 MB/s	23.4705 s,	17.9 MB/s	23.5859 s,	17.8 MB/s
	 32k	19.6786 s,	21.3 MB/s	19.719 s,	21.3 MB/s	19.7548 s,	21.2 MB/s
	 64k	19.6219 s,	21.4 MB/s	19.6125 s,	21.4 MB/s	19.594 s,	21.4 MB/s
==>	128k	18.021 s,	23.3 MB/s	18.0527 s,	23.2 MB/s	18.0694 s,	23.2 MB/s
	256k	17.978 s,	23.3 MB/s	17.6483 s,	23.8 MB/s	17.9324 s,	23.4 MB/s
	512k	17.659 s,	23.8 MB/s	17.9403 s,	23.4 MB/s	17.986 s,	23.3 MB/s
	  1M	17.9437 s,	23.4 MB/s	18.0634 s,	23.2 MB/s	17.9469 s,	23.4 MB/s

USB stick 2G idVendor=0204, idProduct=6025 SerialNumber: 08082005000113

	  4k	62.6246 s,	6.7 MB/s 	60.5872 s,	6.9 MB/s 	62.2581 s,	6.7 MB/s
	  8k	35.7505 s,	11.7 MB/s	35.764 s,	11.7 MB/s	35.7396 s,	11.7 MB/s
	 16k	33.7949 s,	12.4 MB/s	33.8041 s,	12.4 MB/s	33.8015 s,	12.4 MB/s
-->	 32k	31.3851 s,	13.4 MB/s	31.381 s,	13.4 MB/s	31.3784 s,	13.4 MB/s
	 64k	31.3478 s,	13.4 MB/s	31.3494 s,	13.4 MB/s	31.3486 s,	13.4 MB/s
==>	128k	30.7384 s,	13.6 MB/s	30.7337 s,	13.6 MB/s	30.728 s,	13.6 MB/s
	256k	30.5439 s,	13.7 MB/s	30.544 s,	13.7 MB/s	30.5433 s,	13.7 MB/s
	512k	30.5408 s,	13.7 MB/s	30.543 s,	13.7 MB/s	30.5447 s,	13.7 MB/s
	  1M	30.5919 s,	13.7 MB/s	30.5893 s,	13.7 MB/s	30.5939 s,	13.7 MB/s

Anyone has 512/128MB USB stick? Anyway you get satisfiable performance
with >= 32k readahead size.

Tested-by: Linus Torvalds <torvalds@linux-foundation.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 block/genhd.c |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

--- linux.orig/block/genhd.c	2010-01-21 21:17:16.000000000 +0800
+++ linux/block/genhd.c	2010-01-22 17:09:34.000000000 +0800
@@ -518,6 +518,7 @@ void add_disk(struct gendisk *disk)
 	struct backing_dev_info *bdi;
 	dev_t devt;
 	int retval;
+	unsigned long size;
 
 	/* minors == 0 indicates to use ext devt from part0 and should
 	 * be accompanied with EXT_DEVT flag.  Make sure all
@@ -551,6 +552,23 @@ void add_disk(struct gendisk *disk)
 	retval = sysfs_create_link(&disk_to_dev(disk)->kobj, &bdi->dev->kobj,
 				   "bdi");
 	WARN_ON(retval);
+
+	/*
+	 * limit readahead size for small devices
+	 *        disk size    readahead size
+	 *               2M                4k
+	 *               8M                8k
+	 *              32M               16k
+	 *             128M               32k
+	 *             512M               64k
+	 *               2G              128k
+	 *               8G              256k
+	 *              32G              512k
+	 *             128G             1024k
+	 */
+	size = get_capacity(disk) >> 12;
+	size = 1UL << (ilog2(size) / 2);
+	bdi->ra_pages = min(bdi->ra_pages, size);
 }
 
 EXPORT_SYMBOL(add_disk);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
