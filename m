Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 02A386B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 07:18:35 -0500 (EST)
Received: by wibhm9 with SMTP id hm9so3083283wib.2
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 04:18:34 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id b2si2741569wiy.18.2015.03.06.04.18.32
        for <linux-mm@kvack.org>;
        Fri, 06 Mar 2015 04:18:33 -0800 (PST)
Date: Fri, 6 Mar 2015 14:18:16 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 00/24] THP refcounting redesign
Message-ID: <20150306121816.GA27638@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <54F85233.1010006@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F85233.1010006@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 05, 2015 at 01:55:15PM +0100, Jerome Marchand wrote:
> On 03/04/2015 05:32 PM, Kirill A. Shutemov wrote:
> > Hello everybody,
> > 
> > It's bug-fix update of my thp refcounting work.
> > 
> > The goal of patchset is to make refcounting on THP pages cheaper with
> > simpler semantics and allow the same THP compound page to be mapped with
> > PMD and PTEs. This is required to get reasonable THP-pagecache
> > implementation.
> > 
> > With the new refcounting design it's much easier to protect against
> > split_huge_page(): simple reference on a page will make you the deal.
> > It makes gup_fast() implementation simpler and doesn't require
> > special-case in futex code to handle tail THP pages.
> > 
> > It should improve THP utilization over the system since splitting THP in
> > one process doesn't necessary lead to splitting the page in all other
> > processes have the page mapped.
> > 
> [...]
> > I believe all known bugs have been fixed, but I'm sure Sasha will bring more
> > reports.
> > 
> > The patchset also available on git:
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git thp/refcounting/v4
> > 
> 
> Hi Kirill,
> 
> I ran some ltp tests and it triggered two bugs:
> 

Could you test with the patch below?

diff --git a/arch/arc/mm/cache_arc700.c b/arch/arc/mm/cache_arc700.c
index 8c3a3e02ba92..1baa4d23314b 100644
--- a/arch/arc/mm/cache_arc700.c
+++ b/arch/arc/mm/cache_arc700.c
@@ -490,7 +490,7 @@ void flush_dcache_page(struct page *page)
 	 */
 	if (!mapping_mapped(mapping)) {
 		clear_bit(PG_dc_clean, &page->flags);
-	} else if (page_mapped(page)) {
+	} else if (page_mapcount(page)) {
 
 		/* kernel reading from page with U-mapping */
 		void *paddr = page_address(page);
@@ -675,7 +675,7 @@ void copy_user_highpage(struct page *to, struct page *from,
 	 * Note that while @u_vaddr refers to DST page's userspace vaddr, it is
 	 * equally valid for SRC page as well
 	 */
-	if (page_mapped(from) && addr_not_cache_congruent(kfrom, u_vaddr)) {
+	if (page_mapcount(from) && addr_not_cache_congruent(kfrom, u_vaddr)) {
 		__flush_dcache_page(kfrom, u_vaddr);
 		clean_src_k_mappings = 1;
 	}
diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index 34b66af516ea..8f972fc8933d 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -315,7 +315,7 @@ void flush_dcache_page(struct page *page)
 	mapping = page_mapping(page);
 
 	if (!cache_ops_need_broadcast() &&
-	    mapping && !page_mapped(page))
+	    mapping && !page_mapcount(page))
 		clear_bit(PG_dcache_clean, &page->flags);
 	else {
 		__flush_dcache_page(mapping, page);
diff --git a/arch/mips/mm/c-r4k.c b/arch/mips/mm/c-r4k.c
index 3f8059602765..b28bf185ef77 100644
--- a/arch/mips/mm/c-r4k.c
+++ b/arch/mips/mm/c-r4k.c
@@ -578,7 +578,8 @@ static inline void local_r4k_flush_cache_page(void *args)
 		 * another ASID than the current one.
 		 */
 		map_coherent = (cpu_has_dc_aliases &&
-				page_mapped(page) && !Page_dcache_dirty(page));
+				page_mapcount(page) &&
+				!Page_dcache_dirty(page));
 		if (map_coherent)
 			vaddr = kmap_coherent(page, addr);
 		else
diff --git a/arch/mips/mm/cache.c b/arch/mips/mm/cache.c
index 7e3ea7766822..e695b28dc32c 100644
--- a/arch/mips/mm/cache.c
+++ b/arch/mips/mm/cache.c
@@ -106,7 +106,7 @@ void __flush_anon_page(struct page *page, unsigned long vmaddr)
 	unsigned long addr = (unsigned long) page_address(page);
 
 	if (pages_do_alias(addr, vmaddr)) {
-		if (page_mapped(page) && !Page_dcache_dirty(page)) {
+		if (page_mapcount(page) && !Page_dcache_dirty(page)) {
 			void *kaddr;
 
 			kaddr = kmap_coherent(page, vmaddr);
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index 448cde372af0..2c8e44aa536e 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -156,7 +156,7 @@ void copy_user_highpage(struct page *to, struct page *from,
 
 	vto = kmap_atomic(to);
 	if (cpu_has_dc_aliases &&
-	    page_mapped(from) && !Page_dcache_dirty(from)) {
+	    page_mapcount(from) && !Page_dcache_dirty(from)) {
 		vfrom = kmap_coherent(from, vaddr);
 		copy_page(vto, vfrom);
 		kunmap_coherent();
@@ -178,7 +178,7 @@ void copy_to_user_page(struct vm_area_struct *vma,
 	unsigned long len)
 {
 	if (cpu_has_dc_aliases &&
-	    page_mapped(page) && !Page_dcache_dirty(page)) {
+	    page_mapcount(page) && !Page_dcache_dirty(page)) {
 		void *vto = kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
 		memcpy(vto, src, len);
 		kunmap_coherent();
@@ -196,7 +196,7 @@ void copy_from_user_page(struct vm_area_struct *vma,
 	unsigned long len)
 {
 	if (cpu_has_dc_aliases &&
-	    page_mapped(page) && !Page_dcache_dirty(page)) {
+	    page_mapcount(page) && !Page_dcache_dirty(page)) {
 		void *vfrom = kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
 		memcpy(dst, vfrom, len);
 		kunmap_coherent();
diff --git a/arch/sh/mm/cache-sh4.c b/arch/sh/mm/cache-sh4.c
index 51d8f7f31d1d..58aaa4f33b81 100644
--- a/arch/sh/mm/cache-sh4.c
+++ b/arch/sh/mm/cache-sh4.c
@@ -241,7 +241,7 @@ static void sh4_flush_cache_page(void *args)
 		 */
 		map_coherent = (current_cpu_data.dcache.n_aliases &&
 			test_bit(PG_dcache_clean, &page->flags) &&
-			page_mapped(page));
+			page_mapcount(page));
 		if (map_coherent)
 			vaddr = kmap_coherent(page, address);
 		else
diff --git a/arch/sh/mm/cache.c b/arch/sh/mm/cache.c
index f770e3992620..e58cfbf45150 100644
--- a/arch/sh/mm/cache.c
+++ b/arch/sh/mm/cache.c
@@ -59,7 +59,7 @@ void copy_to_user_page(struct vm_area_struct *vma, struct page *page,
 		       unsigned long vaddr, void *dst, const void *src,
 		       unsigned long len)
 {
-	if (boot_cpu_data.dcache.n_aliases && page_mapped(page) &&
+	if (boot_cpu_data.dcache.n_aliases && page_mapcount(page) &&
 	    test_bit(PG_dcache_clean, &page->flags)) {
 		void *vto = kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
 		memcpy(vto, src, len);
@@ -78,7 +78,7 @@ void copy_from_user_page(struct vm_area_struct *vma, struct page *page,
 			 unsigned long vaddr, void *dst, const void *src,
 			 unsigned long len)
 {
-	if (boot_cpu_data.dcache.n_aliases && page_mapped(page) &&
+	if (boot_cpu_data.dcache.n_aliases && page_mapcount(page) &&
 	    test_bit(PG_dcache_clean, &page->flags)) {
 		void *vfrom = kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
 		memcpy(dst, vfrom, len);
@@ -97,7 +97,7 @@ void copy_user_highpage(struct page *to, struct page *from,
 
 	vto = kmap_atomic(to);
 
-	if (boot_cpu_data.dcache.n_aliases && page_mapped(from) &&
+	if (boot_cpu_data.dcache.n_aliases && page_mapcount(from) &&
 	    test_bit(PG_dcache_clean, &from->flags)) {
 		vfrom = kmap_coherent(from, vaddr);
 		copy_page(vto, vfrom);
@@ -153,7 +153,7 @@ void __flush_anon_page(struct page *page, unsigned long vmaddr)
 	unsigned long addr = (unsigned long) page_address(page);
 
 	if (pages_do_alias(addr, vmaddr)) {
-		if (boot_cpu_data.dcache.n_aliases && page_mapped(page) &&
+		if (boot_cpu_data.dcache.n_aliases && page_mapcount(page) &&
 		    test_bit(PG_dcache_clean, &page->flags)) {
 			void *kaddr;
 
diff --git a/arch/xtensa/mm/tlb.c b/arch/xtensa/mm/tlb.c
index 5ece856c5725..35c822286bbe 100644
--- a/arch/xtensa/mm/tlb.c
+++ b/arch/xtensa/mm/tlb.c
@@ -245,7 +245,7 @@ static int check_tlb_entry(unsigned w, unsigned e, bool dtlb)
 						page_mapcount(p));
 				if (!page_count(p))
 					rc |= TLB_INSANE;
-				else if (page_mapped(p))
+				else if (page_mapcount(p))
 					rc |= TLB_SUSPICIOUS;
 			} else {
 				rc |= TLB_INSANE;
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 7eee2d8b97d9..e99c059339f6 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -97,9 +97,9 @@ u64 stable_page_flags(struct page *page)
 	 * pseudo flags for the well known (anonymous) memory mapped pages
 	 *
 	 * Note that page->_mapcount is overloaded in SLOB/SLUB/SLQB, so the
-	 * simple test in page_mapped() is not enough.
+	 * simple test in page_mapcount() is not enough.
 	 */
-	if (!PageSlab(page) && page_mapped(page))
+	if (!PageSlab(page) && page_mapcount(page))
 		u |= 1 << KPF_MMAP;
 	if (PageAnon(page))
 		u |= 1 << KPF_ANON;
diff --git a/mm/filemap.c b/mm/filemap.c
index 25bec2c3e7a3..da8f66067670 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -200,7 +200,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	if (PageSwapBacked(page))
 		__dec_zone_page_state(page, NR_SHMEM);
-	BUG_ON(page_mapped(page));
+	VM_BUG_ON_PAGE(page_mapped(page), page);
 
 	/*
 	 * At this point page must be either written or cleaned by truncate.
diff --git a/mm/rmap.c b/mm/rmap.c
index 7b8838f2c5d0..3361fe78fbe2 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1141,12 +1141,15 @@ static void page_remove_file_rmap(struct page *page)
 
 	memcg = mem_cgroup_begin_page_stat(page);
 
-	/* page still mapped by someone else? */
-	if (!atomic_add_negative(-1, &page->_mapcount))
+	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
+	if (unlikely(PageHuge(page))) {
+		/* hugetlb pages are always mapped with pmds */
+		atomic_dec(compound_mapcount_ptr(page));
 		goto out;
+	}
 
-	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
-	if (unlikely(PageHuge(page)))
+	/* page still mapped by someone else? */
+	if (!atomic_add_negative(-1, &page->_mapcount))
 		goto out;
 
 	/*
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
