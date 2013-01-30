Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 517C46B0005
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 06:53:25 -0500 (EST)
Received: from mail-ie0-f179.google.com ([209.85.223.179])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1U0WEF-00022r-Re
	for linux-mm@kvack.org; Wed, 30 Jan 2013 11:53:24 +0000
Received: by mail-ie0-f179.google.com with SMTP id k13so1170253iea.24
        for <linux-mm@kvack.org>; Wed, 30 Jan 2013 03:53:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130128091039.GG6871@arwen.pp.htv.fi>
References: <20130128091039.GG6871@arwen.pp.htv.fi>
Date: Wed, 30 Jan 2013 19:53:22 +0800
Message-ID: <CACVXFVOATzTJq+-5M9j3G3y_WUrWKJt=naPkjkLwGDmT0H8gog@mail.gmail.com>
Subject: Re: Page allocation failure on v3.8-rc5
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbi@ti.com
Cc: Linux USB Mailing List <linux-usb@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>

On Mon, Jan 28, 2013 at 5:10 PM, Felipe Balbi <balbi@ti.com> wrote:
> Hi,
>
> The following page allocation failure triggers sometimes when I plug my
> memory card reader on a USB port.
>
>
> [850845.928795] usb 1-4: new high-speed USB device number 48 using ehci-pci
> [850846.300702] usb 1-4: New USB device found, idVendor=0bda, idProduct=0119
> [850846.300707] usb 1-4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
> [850846.300711] usb 1-4: Product: USB2.0-CRW
> [850846.300715] usb 1-4: Manufacturer: Generic
> [850846.300718] usb 1-4: SerialNumber: 20090815198100000
> [850846.302733] scsi86 : usb-storage 1-4:1.0
> [850847.304359] scsi 86:0:0:0: Direct-Access     Generic- SD/MMC           1.00 PQ: 0 ANSI: 0 CCS
> [850847.305734] sd 86:0:0:0: Attached scsi generic sg4 type 0
> [850848.456294] sd 86:0:0:0: [sdd] 7911424 512-byte logical blocks: (4.05 GB/3.77 GiB)
> [850848.457160] sd 86:0:0:0: [sdd] Write Protect is off
> [850848.457166] sd 86:0:0:0: [sdd] Mode Sense: 03 00 00 00
> [850848.458054] sd 86:0:0:0: [sdd] No Caching mode page present
> [850848.458060] sd 86:0:0:0: [sdd] Assuming drive cache: write through
> [850848.461502] sd 86:0:0:0: [sdd] No Caching mode page present
> [850848.461507] sd 86:0:0:0: [sdd] Assuming drive cache: write through
> [850848.461963] kworker/u:0: page allocation failure: order:4, mode:0x2000d0
> [850848.461969] Pid: 7122, comm: kworker/u:0 Tainted: G        W    3.8.0-rc4+ #206
> [850848.461972] Call Trace:
> [850848.461984]  [<ffffffff810d02a8>] ? warn_alloc_failed+0x116/0x128
> [850848.461991]  [<ffffffff810d31d9>] ? __alloc_pages_nodemask+0x6b5/0x751
> [850848.462000]  [<ffffffff81106297>] ? kmem_getpages+0x59/0x129
> [850848.462006]  [<ffffffff81106b88>] ? fallback_alloc+0x12f/0x1fc
> [850848.462013]  [<ffffffff811071c7>] ? kmem_cache_alloc_trace+0x87/0xf6
> [850848.462021]  [<ffffffff812a633c>] ? check_partition+0x28/0x1ac
> [850848.462027]  [<ffffffff812a60bd>] ? rescan_partitions+0xa4/0x27c
> [850848.462034]  [<ffffffff8113bcfb>] ? __blkdev_get+0x1ac/0x3d2
> [850848.462040]  [<ffffffff8113c0b1>] ? blkdev_get+0x190/0x2d8
> [850848.462046]  [<ffffffff8113b23f>] ? bdget+0x3b/0x12b
> [850848.462052]  [<ffffffff812a41a6>] ? add_disk+0x268/0x3e2
> [850848.462058]  [<ffffffff81382f3d>] ? sd_probe_async+0x11b/0x1cc
> [850848.462066]  [<ffffffff81055f74>] ? async_run_entry_fn+0xa2/0x173
> [850848.462072]  [<ffffffff81055ed2>] ? async_schedule+0x15/0x15
> [850848.462079]  [<ffffffff8104bb79>] ? process_one_work+0x172/0x2ca
> [850848.462084]  [<ffffffff8104b88a>] ? manage_workers+0x22a/0x23c
> [850848.462090]  [<ffffffff81055ed2>] ? async_schedule+0x15/0x15
> [850848.462096]  [<ffffffff8104bfa4>] ? worker_thread+0x11d/0x1b7
> [850848.462102]  [<ffffffff8104be87>] ? rescuer_thread+0x18c/0x18c
> [850848.462109]  [<ffffffff81050421>] ? kthread+0x86/0x8e
> [850848.462116]  [<ffffffff8105039b>] ? __kthread_parkme+0x60/0x60
> [850848.462125]  [<ffffffff814a306c>] ? ret_from_fork+0x7c/0xb0
> [850848.462132]  [<ffffffff8105039b>] ? __kthread_parkme+0x60/0x60

The allocation failure is caused by the big sizeof(struct parsed_partitions),
which is 64K in my 32bit box, could you test the blow patch to see
if it can fix the allocation failure?

--
diff --git a/block/partition-generic.c b/block/partition-generic.c
index f1d1451..043d0bd 100644
--- a/block/partition-generic.c
+++ b/block/partition-generic.c
@@ -525,7 +525,7 @@ rescan:
 			md_autodetect_dev(part_to_dev(part)->devt);
 #endif
 	}
-	kfree(state);
+	release_partitions(state);
 	return 0;
 }

diff --git a/block/partitions/check.c b/block/partitions/check.c
index bc90867..d89eef7 100644
--- a/block/partitions/check.c
+++ b/block/partitions/check.c
@@ -14,6 +14,7 @@
  */

 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <linux/ctype.h>
 #include <linux/genhd.h>

@@ -106,18 +107,43 @@ static int (*check_part[])(struct parsed_partitions *) = {
 	NULL
 };

+struct parsed_partitions *allocate_partitions(int nr)
+{
+	struct parsed_partitions *state;
+
+	state = kzalloc(sizeof(struct parsed_partitions), GFP_KERNEL);
+	if (!state)
+		return NULL;
+
+	state->parts = vzalloc(nr * sizeof(state->parts[0]));
+	if (!state->parts) {
+		kfree(state);
+		return NULL;
+	}
+
+	return state;
+}
+
+void release_partitions(struct parsed_partitions *state)
+{
+	vfree(state->parts);
+	kfree(state);
+}
+
 struct parsed_partitions *
 check_partition(struct gendisk *hd, struct block_device *bdev)
 {
 	struct parsed_partitions *state;
 	int i, res, err;

-	state = kzalloc(sizeof(struct parsed_partitions), GFP_KERNEL);
+	i = disk_max_parts(hd);
+	state = allocate_partitions(i);
 	if (!state)
 		return NULL;
+	state->limit = i;
 	state->pp_buf = (char *)__get_free_page(GFP_KERNEL);
 	if (!state->pp_buf) {
-		kfree(state);
+		release_partitions(state);
 		return NULL;
 	}
 	state->pp_buf[0] = '\0';
@@ -128,10 +154,9 @@ check_partition(struct gendisk *hd, struct
block_device *bdev)
 	if (isdigit(state->name[strlen(state->name)-1]))
 		sprintf(state->name, "p");

-	state->limit = disk_max_parts(hd);
 	i = res = err = 0;
 	while (!res && check_part[i]) {
-		memset(&state->parts, 0, sizeof(state->parts));
+		memset(state->parts, 0, state->limit * sizeof(state->parts[0]));
 		res = check_part[i++](state);
 		if (res < 0) {
 			/* We have hit an I/O error which we don't report now.
@@ -161,6 +186,6 @@ check_partition(struct gendisk *hd, struct
block_device *bdev)
 	printk(KERN_INFO "%s", state->pp_buf);

 	free_page((unsigned long)state->pp_buf);
-	kfree(state);
+	release_partitions(state);
 	return ERR_PTR(res);
 }
diff --git a/block/partitions/check.h b/block/partitions/check.h
index 52b1003..8323808 100644
--- a/block/partitions/check.h
+++ b/block/partitions/check.h
@@ -15,13 +15,15 @@ struct parsed_partitions {
 		int flags;
 		bool has_info;
 		struct partition_meta_info info;
-	} parts[DISK_MAX_PARTS];
+	} *parts;
 	int next;
 	int limit;
 	bool access_beyond_eod;
 	char *pp_buf;
 };

+extern void release_partitions(struct parsed_partitions *state);
+
 struct parsed_partitions *
 check_partition(struct gendisk *, struct block_device *);



Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
