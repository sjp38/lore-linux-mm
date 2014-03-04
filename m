Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 427EE6B003B
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 21:49:17 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id r10so4498446pdi.16
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 18:49:16 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id bi5si12534036pbb.169.2014.03.03.18.49.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 18:49:16 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id ld10so4634394pab.12
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 18:49:16 -0800 (PST)
From: Pradeep Sawlani <pradeep.sawlani@gmail.com>
Subject: [PATCH RFC 1/1] ksm: check and skip page, if it is already scanned
Date: Mon,  3 Mar 2014 18:48:53 -0800
Message-Id: <1393901333-5569-2-git-send-email-pradeep.sawlani@gmail.com>
In-Reply-To: <1393901333-5569-1-git-send-email-pradeep.sawlani@gmail.com>
References: <1393901333-5569-1-git-send-email-pradeep.sawlani@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>
Cc: LKML <linux-kernel@vger.kernel.org>, MEMORY MANAGEMENT <linux-mm@kvack.org>, Dave Hansen <dave@sr71.net>, Arjan van de Ven <arjan@linux.intel.com>, Suri Maddhula <surim@amazon.com>, Matt Wilson <msw@amazon.com>, Anthony Liguori <aliguori@amazon.com>, Pradeep Sawlani <sawlani@amazon.com>

From: Pradeep Sawlani <sawlani@amazon.com>

On system like Android where most of the process are forked
from parent w/o execve, KSM can scan same page multiple times
in one scan cycle. There is no advantage in scanning same page
multiple times for merging. During testing with Android, it was
observed around 60% pages are skipped for each scan cycle.

Change-Id: I0cf01802f0b4d61fcab92558beb9e1c660dc9a77
Link: http://lkml.kernel.org/r/CAMrOTPgBtANS_ryRjan0-dTL97U7eRvtf3dCsss=Kn+Uk89fuA@mail.gmail.com
Signed-off-by: Pradeep Sawlani <sawlani@amazon.com>
---
 include/linux/page-flags.h |   11 +++++++++++
 mm/Kconfig                 |   10 ++++++++++
 mm/ksm.c                   |   33 +++++++++++++++++++++++++++++++--
 3 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 4dabf0f..af4462f 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -108,8 +108,15 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+#ifdef CONFIG_KSM_CHECK_PAGE
+	PG_ksm_scan0,		/* page has been scanned by even KSM cycle */
+#endif
 	__NR_PAGEFLAGS,
 
+#ifdef CONFIG_KSM_CHECK_PAGE
+	/* page has been scanned by odd KSM cycle */
+	PG_ksm_scan1 = PG_owner_priv_1,
+#endif
 	/* Filesystems */
 	PG_checked = PG_owner_priv_1,
 
@@ -209,6 +216,10 @@ PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 
 __PAGEFLAG(SlobFree, slob_free)
+#ifdef CONFIG_KSM_CHECK_PAGE
+CLEARPAGEFLAG(KsmScan0, ksm_scan0) TESTSETFLAG(KsmScan0, ksm_scan0)
+CLEARPAGEFLAG(KsmScan1, ksm_scan1) TESTSETFLAG(KsmScan1, ksm_scan1)
+#endif
 
 /*
  * Private page markings that may be used by the filesystem that owns the page
diff --git a/mm/Kconfig b/mm/Kconfig
index 3922002..984f67c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -246,6 +246,16 @@ config KSM
 	  until a program has madvised that an area is MADV_MERGEABLE, and
 	  root has set /sys/kernel/mm/ksm/run to 1 (if CONFIG_SYSFS is set).
 
+config KSM_CHECK_PAGE
+	bool "Check page before scanning"
+	depends on KSM
+	default n
+	help
+	  If enabled, this will check and skip if page is already scanned in
+	  same KSM scan cycle.
+	  This is useful in situation where you have parent and
+	  child process marking same area for KSM scanning.
+
 config DEFAULT_MMAP_MIN_ADDR
         int "Low address space to protect from user allocation"
 	depends on MMU
diff --git a/mm/ksm.c b/mm/ksm.c
index 47c8853..2edb9cb 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -558,7 +558,9 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 		 * than left over from before.
 		 */
 		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
+#ifndef CONFIG_KSM_CHECK_PAGE
 		BUG_ON(age > 1);
+#endif
 		if (!age)
 			rb_erase(&rmap_item->node, &root_unstable_tree);
 
@@ -1407,6 +1409,31 @@ next_mm:
 	return NULL;
 }
 
+static inline int is_page_scanned(struct page *page)
+{
+#ifdef CONFIG_KSM_CHECK_PAGE
+	/* page is already marked as ksm, so this will be simple merge */
+	if (PageKsm(page))
+		return 0;
+
+	if (ksm_scan.seqnr & 0x1) {
+		/* odd cycle */
+		/* clear even cycle bit */
+		ClearPageKsmScan0(page);
+		/* get old value and mark it scanned */
+		return TestSetPageKsmScan1(page);
+	} else {
+		/* even cycle */
+		/* clear odd cycle bit */
+		ClearPageKsmScan1(page);
+		/* get old value and mark it scanned */
+		return TestSetPageKsmScan0(page);
+	}
+#else
+	return 0;
+#endif
+}
+
 /**
  * ksm_do_scan  - the ksm scanner main worker function.
  * @scan_npages - number of pages we want to scan before we return.
@@ -1421,8 +1448,10 @@ static void ksm_do_scan(unsigned int scan_npages)
 		rmap_item = scan_get_next_rmap_item(&page);
 		if (!rmap_item)
 			return;
-		if (!PageKsm(page) || !in_stable_tree(rmap_item))
-			cmp_and_merge_page(page, rmap_item);
+		if (!PageKsm(page) || !in_stable_tree(rmap_item)) {
+			if (!is_page_scanned(page))
+				cmp_and_merge_page(page, rmap_item);
+		}
 		put_page(page);
 	}
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
