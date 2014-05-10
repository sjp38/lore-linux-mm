Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2FD6B0036
	for <linux-mm@kvack.org>; Sat, 10 May 2014 03:18:26 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lf10so2824166pab.20
        for <linux-mm@kvack.org>; Sat, 10 May 2014 00:18:26 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id yp8si4093406pac.6.2014.05.10.00.18.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 10 May 2014 00:18:25 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so4518879pdj.24
        for <linux-mm@kvack.org>; Sat, 10 May 2014 00:18:25 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 3/3] mm: rename mlocked_vma_newpage to newpage_in_mlocked_vma
Date: Sat, 10 May 2014 15:18:08 +0800
Message-Id: <7ab379a001bd44ed980a884f819178cffe7df577.1399705884.git.nasa4836@gmail.com>
In-Reply-To: <1d32d83e54542050dba3f711a8d10b1e951a9a58.1399705884.git.nasa4836@gmail.com>
References: <1d32d83e54542050dba3f711a8d10b1e951a9a58.1399705884.git.nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, riel@redhat.com, aarcange@redhat.com, nasa4836@gmail.com, fabf@skynet.be, zhangyanfei@cn.fujitsu.com, sasha.levin@oracle.com, mgorman@suse.de, oleg@redhat.com, n-horiguchi@ah.jp.nec.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, liwanp@linux.vnet.ibm.com, gorcunov@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

mlocked_vma_newpage is used to determine if a new page is mapped into
a *mlocked* vma. It is poorly named, so rename it to newpage_in_mlocked_vma.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/internal.h | 4 ++--
 mm/rmap.c     | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 20abafb..35efd79 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -183,7 +183,7 @@ static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
 	munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
 }
 
-extern int mlocked_vma_newpage(struct vm_area_struct *vma,
+extern int newpage_in_mlocked_vma(struct vm_area_struct *vma,
 				struct page *page);
 /*
  * must be called with vma's mmap_sem held for read or write, and page locked.
@@ -227,7 +227,7 @@ extern unsigned long vma_address(struct page *page,
 				 struct vm_area_struct *vma);
 #endif
 #else /* !CONFIG_MMU */
-static inline int mlocked_vma_newpage(struct vm_area_struct *v, struct page *p)
+static inline int newpage_in_mlocked_vma(struct vm_area_struct *v, struct page *p)
 {
 	return 0;
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index a9d02ef..9ff6915 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1014,7 +1014,7 @@ void do_page_add_anon_rmap(struct page *page,
  * pte is locked while calling page_add_new_anon_rmap(), so using a
  * light-weight version __mod_zone_page_state() would be OK.
  */
-int mlocked_vma_newpage(struct vm_area_struct *vma,
+int newpage_in_mlocked_vma(struct vm_area_struct *vma,
 					struct page *page)
 {
 	VM_BUG_ON_PAGE(PageLRU(page), page);
@@ -1050,7 +1050,7 @@ void page_add_new_anon_rmap(struct page *page,
 	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
 			hpage_nr_pages(page));
 	__page_set_anon_rmap(page, vma, address, 1);
-	if (!mlocked_vma_newpage(vma, page)) {
+	if (!newpage_in_mlocked_vma(vma, page)) {
 		SetPageActive(page);
 		lru_cache_add(page);
 	} else
-- 
2.0.0-rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
