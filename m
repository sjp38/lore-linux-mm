Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDA52C3A5AB
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 04:59:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F284206DF
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 04:59:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F284206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AB116B0003; Thu,  5 Sep 2019 00:59:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15A286B0005; Thu,  5 Sep 2019 00:59:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 071CF6B0006; Thu,  5 Sep 2019 00:59:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0055.hostedemail.com [216.40.44.55])
	by kanga.kvack.org (Postfix) with ESMTP id D9D636B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 00:59:51 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 72F66180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 04:59:51 +0000 (UTC)
X-FDA: 75899664582.29.hands87_55ff25d1baf4b
X-HE-Tag: hands87_55ff25d1baf4b
X-Filterd-Recvd-Size: 8331
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 04:59:50 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2985CB60E;
	Thu,  5 Sep 2019 04:59:48 +0000 (UTC)
From: Davidlohr Bueso <dave@stgolabs.net>
To: akpm@linux-foundation.org
Cc: walken@google.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	dave@stgolabs.net,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH -next] mm: introduce vma_interval_tree_foreach_stab()
Date: Wed,  4 Sep 2019 21:59:35 -0700
Message-Id: <20190905045935.5228-1-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This documents better the nature of the stab lookup/query.

In addition, this is a step that will make the conversion
of interval tree nodes from [a,b] to [a,b[ easier to review.

For symmetry with vma_interval_tree, the anon equivalent is
also introduced, albeit a single user. This patch does not
change any semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/arm/mm/fault-armv.c   | 2 +-
 arch/arm/mm/flush.c        | 2 +-
 arch/nios2/mm/cacheflush.c | 2 +-
 arch/parisc/kernel/cache.c | 2 +-
 fs/dax.c                   | 2 +-
 include/linux/mm.h         | 6 ++++++
 kernel/events/uprobes.c    | 2 +-
 mm/hugetlb.c               | 4 ++--
 mm/khugepaged.c            | 2 +-
 mm/memory-failure.c        | 6 ++----
 10 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/arch/arm/mm/fault-armv.c b/arch/arm/mm/fault-armv.c
index ae857f41f68d..85bb69f1decb 100644
--- a/arch/arm/mm/fault-armv.c
+++ b/arch/arm/mm/fault-armv.c
@@ -143,7 +143,7 @@ make_coherent(struct address_space *mapping, struct vm_area_struct *vma,
 	 * cache coherency.
 	 */
 	flush_dcache_mmap_lock(mapping);
-	vma_interval_tree_foreach(mpnt, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach_stab(mpnt, &mapping->i_mmap, pgoff) {
 		/*
 		 * If this VMA is not in our MM, we can ignore it.
 		 * Note that we intentionally mask out the VMA
diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index 6d89db7895d1..b04384406c0f 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -249,7 +249,7 @@ static void __flush_dcache_aliases(struct address_space *mapping, struct page *p
 	pgoff = page->index;
 
 	flush_dcache_mmap_lock(mapping);
-	vma_interval_tree_foreach(mpnt, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach_stab(mpnt, &mapping->i_mmap, pgoff) {
 		unsigned long offset;
 
 		/*
diff --git a/arch/nios2/mm/cacheflush.c b/arch/nios2/mm/cacheflush.c
index 65de1bd6a760..8abe26b8e29d 100644
--- a/arch/nios2/mm/cacheflush.c
+++ b/arch/nios2/mm/cacheflush.c
@@ -79,7 +79,7 @@ static void flush_aliases(struct address_space *mapping, struct page *page)
 	pgoff = page->index;
 
 	flush_dcache_mmap_lock(mapping);
-	vma_interval_tree_foreach(mpnt, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach_stab(mpnt, &mapping->i_mmap, pgoff) {
 		unsigned long offset;
 
 		if (mpnt->vm_mm != mm)
diff --git a/arch/parisc/kernel/cache.c b/arch/parisc/kernel/cache.c
index a82b3eaa5398..c5f8aab749c1 100644
--- a/arch/parisc/kernel/cache.c
+++ b/arch/parisc/kernel/cache.c
@@ -348,7 +348,7 @@ void flush_dcache_page(struct page *page)
 	 * to flush one address here for them all to become coherent */
 
 	flush_dcache_mmap_lock(mapping);
-	vma_interval_tree_foreach(mpnt, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach_stab(mpnt, &mapping->i_mmap, pgoff) {
 		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
 		addr = mpnt->vm_start + offset;
 
diff --git a/fs/dax.c b/fs/dax.c
index 6bf81f931de3..f24c035defb7 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -781,7 +781,7 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
 	spinlock_t *ptl;
 
 	i_mmap_lock_read(mapping);
-	vma_interval_tree_foreach(vma, &mapping->i_mmap, index, index) {
+	vma_interval_tree_foreach_stab(vma, &mapping->i_mmap, index) {
 		struct mmu_notifier_range range;
 		unsigned long address;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 66f296181bcc..14c5eb514bfe 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2244,6 +2244,9 @@ struct vm_area_struct *vma_interval_tree_iter_next(struct vm_area_struct *node,
 	for (vma = vma_interval_tree_iter_first(root, start, last);	\
 	     vma; vma = vma_interval_tree_iter_next(vma, start, last))
 
+#define vma_interval_tree_foreach_stab(vma, root, start)		\
+	vma_interval_tree_foreach(vma, root, start, start)
+
 void anon_vma_interval_tree_insert(struct anon_vma_chain *node,
 				   struct rb_root_cached *root);
 void anon_vma_interval_tree_remove(struct anon_vma_chain *node,
@@ -2261,6 +2264,9 @@ void anon_vma_interval_tree_verify(struct anon_vma_chain *node);
 	for (avc = anon_vma_interval_tree_iter_first(root, start, last); \
 	     avc; avc = anon_vma_interval_tree_iter_next(avc, start, last))
 
+#define anon_vma_interval_tree_foreach_stab(vma, root, start)		\
+	anon_vma_interval_tree_foreach(vma, root, start, start)
+
 /* mmap.c */
 extern int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin);
 extern int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 94d38a39d72e..6a70dbe0b4b2 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -975,7 +975,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 
  again:
 	i_mmap_lock_read(mapping);
-	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach_stab(vma, &mapping->i_mmap, pgoff) {
 		if (!valid_vma(vma, is_register))
 			continue;
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ef37c85423a5..1a6b133ca66d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3643,7 +3643,7 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * __unmap_hugepage_range() is called as the lock is already held
 	 */
 	i_mmap_lock_write(mapping);
-	vma_interval_tree_foreach(iter_vma, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach_stab(iter_vma, &mapping->i_mmap, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
 			continue;
@@ -4844,7 +4844,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 		return (pte_t *)pmd_alloc(mm, pud, addr);
 
 	i_mmap_lock_write(mapping);
-	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
+	vma_interval_tree_foreach_stab(svma, &mapping->i_mmap, idx) {
 		if (svma == vma)
 			continue;
 
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 00cec6a127aa..a5536e7c4d4c 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1420,7 +1420,7 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 	pmd_t *pmd, _pmd;
 
 	i_mmap_lock_write(mapping);
-	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach_stab(vma, &mapping->i_mmap, pgoff) {
 		/*
 		 * Check vma->anon_vma to exclude MAP_PRIVATE mappings that
 		 * got written to. These VMAs are likely not worth investing
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 7ef849da8278..79934fd00146 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -451,8 +451,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 
 		if (!t)
 			continue;
-		anon_vma_interval_tree_foreach(vmac, &av->rb_root,
-					       pgoff, pgoff) {
+		anon_vma_interval_tree_foreach_stab(vmac, &av->rb_root, pgoff) {
 			vma = vmac->vma;
 			if (!page_mapped_in_vma(page, vma))
 				continue;
@@ -482,8 +481,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 
 		if (!t)
 			continue;
-		vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff,
-				      pgoff) {
+		vma_interval_tree_foreach_stab(vma, &mapping->i_mmap, pgoff) {
 			/*
 			 * Send early kill signal to tasks where a vma covers
 			 * the page but the corrupted page is not necessarily
-- 
2.16.4


