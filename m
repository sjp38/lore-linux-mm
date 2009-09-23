Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 70B3C6B004D
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 15:56:50 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH] ksm: change default values to better fit into mainline kernel
Date: Wed, 23 Sep 2009 23:05:47 +0300
Message-Id: <1253736347-3779-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, aarcange@redhat.com, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

Now that ksm is in mainline it is better to change the default values
to better fit to most of the users.

This patch change the ksm default values to be:
ksm_thread_pages_to_scan = 100 (instead of 200)
ksm_thread_sleep_millisecs = 20 (like before)
ksm_run = KSM_RUN_STOP (instead of KSM_RUN_MERGE - meaning ksm is
                        disabled by default)
ksm_max_kernel_pages = nr_free_buffer_pages / 4 (instead of 2046)

The important aspect of this patch is: it disable ksm by default, and set
the number of the kernel_pages that can be allocated to be a reasonable
number.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/ksm.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 37cc373..f7edac3 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -30,6 +30,7 @@
 #include <linux/slab.h>
 #include <linux/rbtree.h>
 #include <linux/mmu_notifier.h>
+#include <linux/swap.h>
 #include <linux/ksm.h>
 
 #include <asm/tlbflush.h>
@@ -162,10 +163,10 @@ static unsigned long ksm_pages_unshared;
 static unsigned long ksm_rmap_items;
 
 /* Limit on the number of unswappable pages used */
-static unsigned long ksm_max_kernel_pages = 2000;
+static unsigned long ksm_max_kernel_pages;
 
 /* Number of pages ksmd should scan in one batch */
-static unsigned int ksm_thread_pages_to_scan = 200;
+static unsigned int ksm_thread_pages_to_scan = 100;
 
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
@@ -173,7 +174,7 @@ static unsigned int ksm_thread_sleep_millisecs = 20;
 #define KSM_RUN_STOP	0
 #define KSM_RUN_MERGE	1
 #define KSM_RUN_UNMERGE	2
-static unsigned int ksm_run = KSM_RUN_MERGE;
+static unsigned int ksm_run = KSM_RUN_STOP;
 
 static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
 static DEFINE_MUTEX(ksm_thread_mutex);
@@ -183,6 +184,11 @@ static DEFINE_SPINLOCK(ksm_mmlist_lock);
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL)
 
+static void __init ksm_init_max_kernel_pages(void)
+{
+	ksm_max_kernel_pages = nr_free_buffer_pages() / 4;
+}
+
 static int __init ksm_slab_init(void)
 {
 	rmap_item_cache = KSM_KMEM_CACHE(rmap_item, 0);
@@ -1667,6 +1673,8 @@ static int __init ksm_init(void)
 	struct task_struct *ksm_thread;
 	int err;
 
+	ksm_init_max_kernel_pages();
+
 	err = ksm_slab_init();
 	if (err)
 		goto out;
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
