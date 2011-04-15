Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 96030900089
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:39:10 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3FHEpud026090
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:14:51 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3FHcQCG029248
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:38:36 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3FHcOCa015281
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:38:24 -0600
Subject: [RFC][PATCH 2/3] track numbers of pagetable pages
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 15 Apr 2011 10:38:23 -0700
References: <20110415173821.62660715@kernel>
In-Reply-To: <20110415173821.62660715@kernel>
Message-Id: <20110415173823.EA7A7473@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>


Now that we have the mm in the constructor and destructor, it's
simple to to bump a counter.  Add the counter to the mm and use
the existing MM_* counter infrastructure.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/include/linux/mm.h       |    2 ++
 linux-2.6.git-dave/include/linux/mm_types.h |    1 +
 2 files changed, 3 insertions(+)

diff -puN include/linux/mm.h~track-pagetable-pages include/linux/mm.h
--- linux-2.6.git/include/linux/mm.h~track-pagetable-pages	2011-04-15 10:37:10.768832396 -0700
+++ linux-2.6.git-dave/include/linux/mm.h	2011-04-15 10:37:10.780832393 -0700
@@ -1245,12 +1245,14 @@ static inline pmd_t *pmd_alloc(struct mm
 static inline void pgtable_page_ctor(struct mm_struct *mm, struct page *page)
 {
 	pte_lock_init(page);
+	inc_mm_counter(mm, MM_PTEPAGES);
 	inc_zone_page_state(page, NR_PAGETABLE);
 }
 
 static inline void pgtable_page_dtor(struct mm_struct *mm, struct page *page)
 {
 	pte_lock_deinit(page);
+	dec_mm_counter(mm, MM_PTEPAGES);
 	dec_zone_page_state(page, NR_PAGETABLE);
 }
 
diff -puN include/linux/mm_types.h~track-pagetable-pages include/linux/mm_types.h
--- linux-2.6.git/include/linux/mm_types.h~track-pagetable-pages	2011-04-15 10:37:10.772832395 -0700
+++ linux-2.6.git-dave/include/linux/mm_types.h	2011-04-15 10:37:10.780832393 -0700
@@ -200,6 +200,7 @@ enum {
 	MM_FILEPAGES,
 	MM_ANONPAGES,
 	MM_SWAPENTS,
+	MM_PTEPAGES,
 	NR_MM_COUNTERS
 };
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
