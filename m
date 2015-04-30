Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1157F6B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 08:07:07 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so59841656wgy.2
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 05:07:06 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id bw17si3712906wjb.30.2015.04.30.05.07.04
        for <linux-mm@kvack.org>;
        Thu, 30 Apr 2015 05:07:05 -0700 (PDT)
Date: Thu, 30 Apr 2015 15:06:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 20/28] mm: differentiate page_mapped() from
 page_mapcount() for compound pages
Message-ID: <20150430120653.GD15874@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-21-git-send-email-kirill.shutemov@linux.intel.com>
 <554104B3.3030503@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <554104B3.3030503@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 29, 2015 at 06:20:03PM +0200, Jerome Marchand wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> > Let's define page_mapped() to be true for compound pages if any
> > sub-pages of the compound page is mapped (with PMD or PTE).
> > 
> > On other hand page_mapcount() return mapcount for this particular small
> > page.
> > 
> > This will make cases like page_get_anon_vma() behave correctly once we
> > allow huge pages to be mapped with PTE.
> > 
> > Most users outside core-mm should use page_mapcount() instead of
> > page_mapped().
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Tested-by: Sasha Levin <sasha.levin@oracle.com>
> > ---
> >  arch/arc/mm/cache_arc700.c |  4 ++--
> >  arch/arm/mm/flush.c        |  2 +-
> >  arch/mips/mm/c-r4k.c       |  3 ++-
> >  arch/mips/mm/cache.c       |  2 +-
> >  arch/mips/mm/init.c        |  6 +++---
> >  arch/sh/mm/cache-sh4.c     |  2 +-
> >  arch/sh/mm/cache.c         |  8 ++++----
> >  arch/xtensa/mm/tlb.c       |  2 +-
> >  fs/proc/page.c             |  4 ++--
> >  include/linux/mm.h         | 11 ++++++++++-
> >  mm/filemap.c               |  2 +-
> >  11 files changed, 28 insertions(+), 18 deletions(-)
> > 
> > diff --git a/arch/arc/mm/cache_arc700.c b/arch/arc/mm/cache_arc700.c
> > index 8c3a3e02ba92..1baa4d23314b 100644
> > --- a/arch/arc/mm/cache_arc700.c
> > +++ b/arch/arc/mm/cache_arc700.c
> > @@ -490,7 +490,7 @@ void flush_dcache_page(struct page *page)
> >  	 */
> >  	if (!mapping_mapped(mapping)) {
> >  		clear_bit(PG_dc_clean, &page->flags);
> > -	} else if (page_mapped(page)) {
> > +	} else if (page_mapcount(page)) {
> >  
> >  		/* kernel reading from page with U-mapping */
> >  		void *paddr = page_address(page);
> > @@ -675,7 +675,7 @@ void copy_user_highpage(struct page *to, struct page *from,
> >  	 * Note that while @u_vaddr refers to DST page's userspace vaddr, it is
> >  	 * equally valid for SRC page as well
> >  	 */
> > -	if (page_mapped(from) && addr_not_cache_congruent(kfrom, u_vaddr)) {
> > +	if (page_mapcount(from) && addr_not_cache_congruent(kfrom, u_vaddr)) {
> >  		__flush_dcache_page(kfrom, u_vaddr);
> >  		clean_src_k_mappings = 1;
> >  	}
> > diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
> > index 34b66af516ea..8f972fc8933d 100644
> > --- a/arch/arm/mm/flush.c
> > +++ b/arch/arm/mm/flush.c
> > @@ -315,7 +315,7 @@ void flush_dcache_page(struct page *page)
> >  	mapping = page_mapping(page);
> >  
> >  	if (!cache_ops_need_broadcast() &&
> > -	    mapping && !page_mapped(page))
> > +	    mapping && !page_mapcount(page))
> >  		clear_bit(PG_dcache_clean, &page->flags);
> >  	else {
> >  		__flush_dcache_page(mapping, page);
> > diff --git a/arch/mips/mm/c-r4k.c b/arch/mips/mm/c-r4k.c
> > index dd261df005c2..c4960b2d6682 100644
> > --- a/arch/mips/mm/c-r4k.c
> > +++ b/arch/mips/mm/c-r4k.c
> > @@ -578,7 +578,8 @@ static inline void local_r4k_flush_cache_page(void *args)
> >  		 * another ASID than the current one.
> >  		 */
> >  		map_coherent = (cpu_has_dc_aliases &&
> > -				page_mapped(page) && !Page_dcache_dirty(page));
> > +				page_mapcount(page) &&
> > +				!Page_dcache_dirty(page));
> >  		if (map_coherent)
> >  			vaddr = kmap_coherent(page, addr);
> >  		else
> > diff --git a/arch/mips/mm/cache.c b/arch/mips/mm/cache.c
> > index 7e3ea7766822..e695b28dc32c 100644
> > --- a/arch/mips/mm/cache.c
> > +++ b/arch/mips/mm/cache.c
> > @@ -106,7 +106,7 @@ void __flush_anon_page(struct page *page, unsigned long vmaddr)
> >  	unsigned long addr = (unsigned long) page_address(page);
> >  
> >  	if (pages_do_alias(addr, vmaddr)) {
> > -		if (page_mapped(page) && !Page_dcache_dirty(page)) {
> > +		if (page_mapcount(page) && !Page_dcache_dirty(page)) {
> >  			void *kaddr;
> >  
> >  			kaddr = kmap_coherent(page, vmaddr);
> > diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
> > index 448cde372af0..2c8e44aa536e 100644
> > --- a/arch/mips/mm/init.c
> > +++ b/arch/mips/mm/init.c
> > @@ -156,7 +156,7 @@ void copy_user_highpage(struct page *to, struct page *from,
> >  
> >  	vto = kmap_atomic(to);
> >  	if (cpu_has_dc_aliases &&
> > -	    page_mapped(from) && !Page_dcache_dirty(from)) {
> > +	    page_mapcount(from) && !Page_dcache_dirty(from)) {
> >  		vfrom = kmap_coherent(from, vaddr);
> >  		copy_page(vto, vfrom);
> >  		kunmap_coherent();
> > @@ -178,7 +178,7 @@ void copy_to_user_page(struct vm_area_struct *vma,
> >  	unsigned long len)
> >  {
> >  	if (cpu_has_dc_aliases &&
> > -	    page_mapped(page) && !Page_dcache_dirty(page)) {
> > +	    page_mapcount(page) && !Page_dcache_dirty(page)) {
> >  		void *vto = kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
> >  		memcpy(vto, src, len);
> >  		kunmap_coherent();
> > @@ -196,7 +196,7 @@ void copy_from_user_page(struct vm_area_struct *vma,
> >  	unsigned long len)
> >  {
> >  	if (cpu_has_dc_aliases &&
> > -	    page_mapped(page) && !Page_dcache_dirty(page)) {
> > +	    page_mapcount(page) && !Page_dcache_dirty(page)) {
> >  		void *vfrom = kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
> >  		memcpy(dst, vfrom, len);
> >  		kunmap_coherent();
> > diff --git a/arch/sh/mm/cache-sh4.c b/arch/sh/mm/cache-sh4.c
> > index 51d8f7f31d1d..58aaa4f33b81 100644
> > --- a/arch/sh/mm/cache-sh4.c
> > +++ b/arch/sh/mm/cache-sh4.c
> > @@ -241,7 +241,7 @@ static void sh4_flush_cache_page(void *args)
> >  		 */
> >  		map_coherent = (current_cpu_data.dcache.n_aliases &&
> >  			test_bit(PG_dcache_clean, &page->flags) &&
> > -			page_mapped(page));
> > +			page_mapcount(page));
> >  		if (map_coherent)
> >  			vaddr = kmap_coherent(page, address);
> >  		else
> > diff --git a/arch/sh/mm/cache.c b/arch/sh/mm/cache.c
> > index f770e3992620..e58cfbf45150 100644
> > --- a/arch/sh/mm/cache.c
> > +++ b/arch/sh/mm/cache.c
> > @@ -59,7 +59,7 @@ void copy_to_user_page(struct vm_area_struct *vma, struct page *page,
> >  		       unsigned long vaddr, void *dst, const void *src,
> >  		       unsigned long len)
> >  {
> > -	if (boot_cpu_data.dcache.n_aliases && page_mapped(page) &&
> > +	if (boot_cpu_data.dcache.n_aliases && page_mapcount(page) &&
> >  	    test_bit(PG_dcache_clean, &page->flags)) {
> >  		void *vto = kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
> >  		memcpy(vto, src, len);
> > @@ -78,7 +78,7 @@ void copy_from_user_page(struct vm_area_struct *vma, struct page *page,
> >  			 unsigned long vaddr, void *dst, const void *src,
> >  			 unsigned long len)
> >  {
> > -	if (boot_cpu_data.dcache.n_aliases && page_mapped(page) &&
> > +	if (boot_cpu_data.dcache.n_aliases && page_mapcount(page) &&
> >  	    test_bit(PG_dcache_clean, &page->flags)) {
> >  		void *vfrom = kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
> >  		memcpy(dst, vfrom, len);
> > @@ -97,7 +97,7 @@ void copy_user_highpage(struct page *to, struct page *from,
> >  
> >  	vto = kmap_atomic(to);
> >  
> > -	if (boot_cpu_data.dcache.n_aliases && page_mapped(from) &&
> > +	if (boot_cpu_data.dcache.n_aliases && page_mapcount(from) &&
> >  	    test_bit(PG_dcache_clean, &from->flags)) {
> >  		vfrom = kmap_coherent(from, vaddr);
> >  		copy_page(vto, vfrom);
> > @@ -153,7 +153,7 @@ void __flush_anon_page(struct page *page, unsigned long vmaddr)
> >  	unsigned long addr = (unsigned long) page_address(page);
> >  
> >  	if (pages_do_alias(addr, vmaddr)) {
> > -		if (boot_cpu_data.dcache.n_aliases && page_mapped(page) &&
> > +		if (boot_cpu_data.dcache.n_aliases && page_mapcount(page) &&
> >  		    test_bit(PG_dcache_clean, &page->flags)) {
> >  			void *kaddr;
> >  
> > diff --git a/arch/xtensa/mm/tlb.c b/arch/xtensa/mm/tlb.c
> > index 5ece856c5725..35c822286bbe 100644
> > --- a/arch/xtensa/mm/tlb.c
> > +++ b/arch/xtensa/mm/tlb.c
> > @@ -245,7 +245,7 @@ static int check_tlb_entry(unsigned w, unsigned e, bool dtlb)
> >  						page_mapcount(p));
> >  				if (!page_count(p))
> >  					rc |= TLB_INSANE;
> > -				else if (page_mapped(p))
> > +				else if (page_mapcount(p))
> >  					rc |= TLB_SUSPICIOUS;
> >  			} else {
> >  				rc |= TLB_INSANE;
> > diff --git a/fs/proc/page.c b/fs/proc/page.c
> > index 7eee2d8b97d9..e99c059339f6 100644
> > --- a/fs/proc/page.c
> > +++ b/fs/proc/page.c
> > @@ -97,9 +97,9 @@ u64 stable_page_flags(struct page *page)
> >  	 * pseudo flags for the well known (anonymous) memory mapped pages
> >  	 *
> >  	 * Note that page->_mapcount is overloaded in SLOB/SLUB/SLQB, so the
> > -	 * simple test in page_mapped() is not enough.
> > +	 * simple test in page_mapcount() is not enough.
> >  	 */
> > -	if (!PageSlab(page) && page_mapped(page))
> > +	if (!PageSlab(page) && page_mapcount(page))
> >  		u |= 1 << KPF_MMAP;
> >  	if (PageAnon(page))
> >  		u |= 1 << KPF_ANON;
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 33cb3aa647a6..8ddc184c55d6 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -909,7 +909,16 @@ static inline pgoff_t page_file_index(struct page *page)
> >   */
> >  static inline int page_mapped(struct page *page)
> >  {
> > -	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >= 0;
> > +	int i;
> > +	if (likely(!PageCompound(page)))
> > +		return atomic_read(&page->_mapcount) >= 0;
> > +	if (compound_mapcount(page))
> > +		return 1;
> > +	for (i = 0; i < hpage_nr_pages(page); i++) {
> > +		if (atomic_read(&page[i]._mapcount) >= 0)
> > +			return 1;
> > +	}
> > +	return 0;
> >  }
> 
> page_mapped() won't work with tail pages. Maybe I'm missing something
> that makes it impossible. Otherwise, have you checked that this
> condition is true for all call site?  Should we add some check at the
> beginning of the function? Something like:
> 
> VM_BUG_ON_PAGE(PageTail(page), page)?

Good catch. I will probably put compound_head() there. Thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
