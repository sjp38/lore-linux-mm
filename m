Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id ECB206B00C6
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 05:33:13 -0400 (EDT)
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <Pine.LNX.4.64.0909180857170.5404@sister.anvils>
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
	 <1253227412-24342-3-git-send-email-ngupta@vflare.org>
	 <1253256805.4959.8.camel@penberg-laptop>
	 <Pine.LNX.4.64.0909180809290.2882@sister.anvils>
	 <1253260528.4959.13.camel@penberg-laptop>
	 <Pine.LNX.4.64.0909180857170.5404@sister.anvils>
Date: Fri, 18 Sep 2009 12:33:11 +0300
Message-Id: <1253266391.4959.15.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Fri, 2009-09-18 at 08:59 +0100, Hugh Dickins wrote:
> On Fri, 18 Sep 2009, Pekka Enberg wrote:
> > 
> > The *hook* looks OK to me but set_swap_free_notify() looks like an ugly
> > hack. I don't understand why we're setting up the hook lazily in
> > ramzswap_read() nor do I understand why we need to look up struct
> > swap_info_struct with a bdev. Surely there's a cleaner way to do all
> > this? Probably somewhere in sys_swapon()?
> 
> Sounds like you have something in mind, may well be better,
> but please show us a patch...  (my mind is elsewhere!)

Hey, you tricked me into a world of pain! Here's a totally untested
patch that adds a "swapon" funciton to struct block_device_operations
that the ramzswap driver can implement to setup ->swap_free_notify_fn.

			Pekka

>From 41827c57196f7eae66701a6ae6565c226c0b7674 Mon Sep 17 00:00:00 2001
From: Nitin Gupta <ngupta@vflare.org>
Date: Fri, 18 Sep 2009 04:13:30 +0530
Subject: [PATCH] mm: swap slot free notifier

Currently, we have "swap discard" mechanism which sends a discard bio request
when we find a free cluster during scan_swap_map(). This callback can come a
long time after swap slots are actually freed.

This delay in callback is a great problem when (compressed) RAM [1] is used
as a swap device. So, this change adds a callback which is called as
soon as a swap slot becomes free. For above mentioned case of swapping
over compressed RAM device, this is very useful since we can immediately
free memory allocated for this swap page.

This callback does not replace swap discard support. It is called with
swap_lock held, so it is meant to trigger action that finishes quickly.
However, swap discard is an I/O request and can be used for taking longer
actions.

It is preferred to use this callback for ramzswap case even if discard
mechanism could be improved such that it can be called as often as required.
This is because, allocation of 'bio'(s) is undesirable since ramzswap always
operates under low memory conditions (its a swap device). Also, batching of
discard bio requests is not optimal since stale data can accumulate very
quickly in ramzswap devices, pushing system further into low memory state.

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/linux/blkdev.h |    2 ++
 include/linux/swap.h   |   16 ++++++++++++++++
 mm/swapfile.c          |    5 +++++
 3 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index e23a86c..688e024 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -27,6 +27,7 @@ struct scsi_ioctl_command;
 struct request_queue;
 struct elevator_queue;
 struct request_pm_state;
+struct swap_info_struct;
 struct blk_trace;
 struct request;
 struct sg_io_hdr;
@@ -1239,6 +1240,7 @@ struct block_device_operations {
 						unsigned long long);
 	int (*revalidate_disk) (struct gendisk *);
 	int (*getgeo)(struct block_device *, struct hd_geometry *);
+	int (*swapon)(struct block_device *, struct swap_info_struct *);
 	struct module *owner;
 };
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7c15334..6603009 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -8,6 +8,7 @@
 #include <linux/memcontrol.h>
 #include <linux/sched.h>
 #include <linux/node.h>
+#include <linux/blkdev.h>
 
 #include <asm/atomic.h>
 #include <asm/page.h>
@@ -20,6 +21,8 @@ struct bio;
 #define SWAP_FLAG_PRIO_MASK	0x7fff
 #define SWAP_FLAG_PRIO_SHIFT	0
 
+typedef void (swap_free_notify_fn) (struct block_device *, unsigned long);
+
 static inline int current_is_kswapd(void)
 {
 	return current->flags & PF_KSWAPD;
@@ -155,6 +158,7 @@ struct swap_info_struct {
 	unsigned int max;
 	unsigned int inuse_pages;
 	unsigned int old_block_size;
+	swap_free_notify_fn *swap_free_notify_fn;
 };
 
 struct swap_list_t {
@@ -297,6 +301,18 @@ extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 
+static inline int
+blkdev_swapon(struct block_device *bdev, struct swap_info_struct *sis)
+{
+	struct gendisk *disk = bdev->bd_disk;
+	int err = 0;
+
+	if (disk->fops->swapon)
+		err = disk->fops->swapon(bdev, sis);
+
+	return err;
+}
+
 /* linux/mm/thrash.c */
 extern struct mm_struct *swap_token_mm;
 extern void grab_swap_token(struct mm_struct *);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 74f1102..9d10f02 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -585,6 +585,8 @@ static int swap_entry_free(struct swap_info_struct *p,
 			swap_list.next = p - swap_info;
 		nr_swap_pages++;
 		p->inuse_pages--;
+		if (p->swap_free_notify_fn)
+			p->swap_free_notify_fn(p->bdev, offset);
 	}
 	if (!swap_count(count))
 		mem_cgroup_uncharge_swap(ent);
@@ -1845,6 +1847,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		if (error < 0)
 			goto bad_swap;
 		p->bdev = bdev;
+		error = blkdev_swapon(bdev, p);
+		if (error < 0)
+			goto bad_swap;
 	} else if (S_ISREG(inode->i_mode)) {
 		p->bdev = inode->i_sb->s_bdev;
 		mutex_lock(&inode->i_mutex);
-- 
1.5.6.3



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
