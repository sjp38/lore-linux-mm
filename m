Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5354A6B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 07:59:57 -0400 (EDT)
Date: Mon, 3 Aug 2009 13:19:13 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 10/12] ksm: sysfs and defaults
In-Reply-To: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
Message-ID: <Pine.LNX.4.64.0908031318220.16754@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At present KSM is just a waste of space if you don't have CONFIG_SYSFS=y
to provide the /sys/kernel/mm/ksm files to tune and activate it.

Make KSM depend on SYSFS?  Could do, but it might be better to provide
some defaults so that KSM works out-of-the-box, ready for testers to
madvise MADV_MERGEABLE, even without SYSFS.

Though anyone serious is likely to want to retune the numbers to their
taste once they have experience; and whether these settings ever reach
2.6.32 can be discussed along the way.  

Save 1kB from tiny kernels by #ifdef'ing the SYSFS side of it.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/ksm.c |   26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

--- ksm9/mm/ksm.c	2009-08-02 13:50:41.000000000 +0100
+++ ksm10/mm/ksm.c	2009-08-02 13:50:48.000000000 +0100
@@ -163,18 +163,18 @@ static unsigned long ksm_pages_unshared;
 static unsigned long ksm_rmap_items;
 
 /* Limit on the number of unswappable pages used */
-static unsigned long ksm_max_kernel_pages;
+static unsigned long ksm_max_kernel_pages = 2000;
 
 /* Number of pages ksmd should scan in one batch */
-static unsigned int ksm_thread_pages_to_scan;
+static unsigned int ksm_thread_pages_to_scan = 200;
 
 /* Milliseconds ksmd should sleep between batches */
-static unsigned int ksm_thread_sleep_millisecs;
+static unsigned int ksm_thread_sleep_millisecs = 20;
 
 #define KSM_RUN_STOP	0
 #define KSM_RUN_MERGE	1
 #define KSM_RUN_UNMERGE	2
-static unsigned int ksm_run;
+static unsigned int ksm_run = KSM_RUN_MERGE;
 
 static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
 static DEFINE_MUTEX(ksm_thread_mutex);
@@ -506,6 +506,10 @@ static int unmerge_ksm_pages(struct vm_a
 	return err;
 }
 
+#ifdef CONFIG_SYSFS
+/*
+ * Only called through the sysfs control interface:
+ */
 static int unmerge_and_remove_all_rmap_items(void)
 {
 	struct mm_slot *mm_slot;
@@ -563,6 +567,7 @@ error:
 	spin_unlock(&ksm_mmlist_lock);
 	return err;
 }
+#endif /* CONFIG_SYSFS */
 
 static u32 calc_checksum(struct page *page)
 {
@@ -1464,6 +1469,11 @@ void __ksm_exit(struct mm_struct *mm,
 	}
 }
 
+#ifdef CONFIG_SYSFS
+/*
+ * This all compiles without CONFIG_SYSFS, but is a waste of space.
+ */
+
 #define KSM_ATTR_RO(_name) \
 	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
 #define KSM_ATTR(_name) \
@@ -1646,6 +1656,7 @@ static struct attribute_group ksm_attr_g
 	.attrs = ksm_attrs,
 	.name = "ksm",
 };
+#endif /* CONFIG_SYSFS */
 
 static int __init ksm_init(void)
 {
@@ -1667,16 +1678,17 @@ static int __init ksm_init(void)
 		goto out_free2;
 	}
 
+#ifdef CONFIG_SYSFS
 	err = sysfs_create_group(mm_kobj, &ksm_attr_group);
 	if (err) {
 		printk(KERN_ERR "ksm: register sysfs failed\n");
-		goto out_free3;
+		kthread_stop(ksm_thread);
+		goto out_free2;
 	}
+#endif /* CONFIG_SYSFS */
 
 	return 0;
 
-out_free3:
-	kthread_stop(ksm_thread);
 out_free2:
 	mm_slots_hash_free();
 out_free1:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
