Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 358CE6B029D
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 11:04:49 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id k5so1420936wrk.17
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 08:04:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4sor5460623wrb.51.2018.01.08.08.04.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 08:04:47 -0800 (PST)
Date: Mon, 8 Jan 2018 17:04:44 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
References: <20171222084623.668990192@linuxfoundation.org>
 <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1515302062.6507.18.camel@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org


hi Kirill,

As Mike reported it below, your 5-level paging related upstream commit 
83e3c48729d9 and all its followup fixes:

 83e3c48729d9: mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y
 629a359bdb0e: mm/sparsemem: Fix ARM64 boot crash when CONFIG_SPARSEMEM_EXTREME=y
 d09cfbbfa0f7: mm/sparse.c: wrong allocation for mem_section

... still breaks kexec - and that now regresses -stable as well.

Given that 5-level paging now syntactically depends on having this commit, if we 
fully revert this then we'll have to disable 5-level paging as well.

Thanks,

	Ingo

* Mike Galbraith <efault@gmx.de> wrote:

> On Fri, 2017-12-22 at 09:45 +0100, Greg Kroah-Hartman wrote:
> > 4.14-stable review patch.  If anyone has any objections, please let me know.
> 
> FYI, this broke kdump, or rather the makedumpfile part thereof.
>  Forward looking wreckage is par for the kdump course, but...
> 
> > ------------------
> > 
> > From: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > 
> > commit 83e3c48729d9ebb7af5a31a504f3fd6aff0348c4 upstream.
> > 
> > Size of the mem_section[] array depends on the size of the physical address space.
> > 
> > In preparation for boot-time switching between paging modes on x86-64
> > we need to make the allocation of mem_section[] dynamic, because otherwise
> > we waste a lot of RAM: with CONFIG_NODE_SHIFT=10, mem_section[] size is 32kB
> > for 4-level paging and 2MB for 5-level paging mode.
> > 
> > The patch allocates the array on the first call to sparse_memory_present_with_active_regions().
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Andy Lutomirski <luto@amacapital.net>
> > Cc: Borislav Petkov <bp@suse.de>
> > Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> > Cc: Linus Torvalds <torvalds@linux-foundation.org>
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: linux-mm@kvack.org
> > Link: http://lkml.kernel.org/r/20170929140821.37654-2-kirill.shutemov@linux.intel.com
> > Signed-off-by: Ingo Molnar <mingo@kernel.org>
> > Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > 
> > ---
> >  include/linux/mmzone.h |    6 +++++-
> >  mm/page_alloc.c        |   10 ++++++++++
> >  mm/sparse.c            |   17 +++++++++++------
> >  3 files changed, 26 insertions(+), 7 deletions(-)
> > 
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -1152,13 +1152,17 @@ struct mem_section {
> >  #define SECTION_ROOT_MASK	(SECTIONS_PER_ROOT - 1)
> >  
> >  #ifdef CONFIG_SPARSEMEM_EXTREME
> > -extern struct mem_section *mem_section[NR_SECTION_ROOTS];
> > +extern struct mem_section **mem_section;
> >  #else
> >  extern struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
> >  #endif
> >  
> >  static inline struct mem_section *__nr_to_section(unsigned long nr)
> >  {
> > +#ifdef CONFIG_SPARSEMEM_EXTREME
> > +	if (!mem_section)
> > +		return NULL;
> > +#endif
> >  	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
> >  		return NULL;
> >  	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5651,6 +5651,16 @@ void __init sparse_memory_present_with_a
> >  	unsigned long start_pfn, end_pfn;
> >  	int i, this_nid;
> >  
> > +#ifdef CONFIG_SPARSEMEM_EXTREME
> > +	if (!mem_section) {
> > +		unsigned long size, align;
> > +
> > +		size = sizeof(struct mem_section) * NR_SECTION_ROOTS;
> > +		align = 1 << (INTERNODE_CACHE_SHIFT);
> > +		mem_section = memblock_virt_alloc(size, align);
> > +	}
> > +#endif
> > +
> >  	for_each_mem_pfn_range(i, nid, &start_pfn, &end_pfn, &this_nid)
> >  		memory_present(this_nid, start_pfn, end_pfn);
> >  }
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -23,8 +23,7 @@
> >   * 1) mem_section	- memory sections, mem_map's for valid memory
> >   */
> >  #ifdef CONFIG_SPARSEMEM_EXTREME
> > -struct mem_section *mem_section[NR_SECTION_ROOTS]
> > -	____cacheline_internodealigned_in_smp;
> > +struct mem_section **mem_section;
> >  #else
> >  struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT]
> >  	____cacheline_internodealigned_in_smp;
> > @@ -101,7 +100,7 @@ static inline int sparse_index_init(unsi
> >  int __section_nr(struct mem_section* ms)
> >  {
> >  	unsigned long root_nr;
> > -	struct mem_section* root;
> > +	struct mem_section *root = NULL;
> >  
> >  	for (root_nr = 0; root_nr < NR_SECTION_ROOTS; root_nr++) {
> >  		root = __nr_to_section(root_nr * SECTIONS_PER_ROOT);
> > @@ -112,7 +111,7 @@ int __section_nr(struct mem_section* ms)
> >  		     break;
> >  	}
> >  
> > -	VM_BUG_ON(root_nr == NR_SECTION_ROOTS);
> > +	VM_BUG_ON(!root);
> >  
> >  	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
> >  }
> > @@ -330,11 +329,17 @@ again:
> >  static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
> >  {
> >  	unsigned long usemap_snr, pgdat_snr;
> > -	static unsigned long old_usemap_snr = NR_MEM_SECTIONS;
> > -	static unsigned long old_pgdat_snr = NR_MEM_SECTIONS;
> > +	static unsigned long old_usemap_snr;
> > +	static unsigned long old_pgdat_snr;
> >  	struct pglist_data *pgdat = NODE_DATA(nid);
> >  	int usemap_nid;
> >  
> > +	/* First call */
> > +	if (!old_usemap_snr) {
> > +		old_usemap_snr = NR_MEM_SECTIONS;
> > +		old_pgdat_snr = NR_MEM_SECTIONS;
> > +	}
> > +
> >  	usemap_snr = pfn_to_section_nr(__pa(usemap) >> PAGE_SHIFT);
> >  	pgdat_snr = pfn_to_section_nr(__pa(pgdat) >> PAGE_SHIFT);
> >  	if (usemap_snr == pgdat_snr)
> > 
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
