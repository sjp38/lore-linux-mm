Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6F16C6B006A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 03:11:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n677sXGp029990
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Jul 2009 16:54:33 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C42AF45DE5D
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:54:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 90C8B45DE4E
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:54:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C16D1DB803F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:54:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A38F1DB803C
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:54:32 +0900 (JST)
Date: Tue, 7 Jul 2009 16:52:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/4] introduce pte_zero()
Message-Id: <20090707165249.785298cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

initializng zero_page_pfn is not clean yet...

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Add some helper functions for supporing zero-page again.
This patch itself adss some tiny functions but no behavior change.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm.h |   20 ++++++++++++++++++++
 mm/memory.c        |    8 ++++++++
 2 files changed, 28 insertions(+)

Index: zeropage-trial/include/linux/mm.h
===================================================================
--- zeropage-trial.orig/include/linux/mm.h
+++ zeropage-trial/include/linux/mm.h
@@ -822,6 +822,26 @@ static inline int handle_mm_fault(struct
 }
 #endif
 
+/*
+ * ZERO page is used for read-only(never write) private page mapping. It's not
+ * usually used but sometimes useful at maping /dev/zero or at scanning
+ * sparsely used big private memory or at calculation.with sparse matrix where
+ * most of entries are zero. ZERO page is not refcounted and exists as
+ * PG_reserved page. zero_page_pfn is pfn of ZERO_PAGE(0).
+ */
+
+extern unsigned long zero_page_pfn;
+static inline int pte_zero(pte_t pte)
+{
+	return (pte_pfn(pte) == zero_page_pfn);
+}
+
+static inline int page_is_zero(struct page *page)
+{
+	return page == ZERO_PAGE(0);
+}
+
+
 extern int make_pages_present(unsigned long addr, unsigned long end);
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
 
Index: zeropage-trial/mm/memory.c
===================================================================
--- zeropage-trial.orig/mm/memory.c
+++ zeropage-trial/mm/memory.c
@@ -106,6 +106,14 @@ static int __init disable_randmaps(char 
 }
 __setup("norandmaps", disable_randmaps);
 
+unsigned long zero_page_pfn __read_mostly;
+static int __init zeropage_init(void)
+{
+	zero_page_pfn = page_to_pfn(ZERO_PAGE(0));
+	return 0;
+}
+__initcall(zeropage_init);
+
 
 /*
  * If a p?d_bad entry is found while walking page tables, report

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
