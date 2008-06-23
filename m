Date: Mon, 23 Jun 2008 21:49:34 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Patch](memory hotplug)Allocate usemap on the section with pgdat (take 3)
Message-ID: <20080623204934.GB1824@csn.ul.ie>
References: <20080616104500.GD2232@shadowen.org> <20080616220705.9EA7.E1E9C6FF@jp.fujitsu.com> <20080617195653.C200.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080617195653.C200.E1E9C6FF@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Badari Pulavarty <pbadari@us.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Tony Breeds <tony@bakeyournoodle.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (17/06/08 20:07), Yasunori Goto didst pronounce:
> 
> Here is take 3 for usemap allocation on pgdat section.
> 
> If there is any trouble, please let me know.
> 
> If no trouble, please apply.
> 
> Thanks.
> 

This boot-tested successfully on a few machines. I wasn't able to get
many machines but at first take, it seems ok.

> ---
> 
> Usemaps are allocated on the section which has pgdat by this.
> 
> Because usemap size is very small, many other sections usemaps
> are allocated on only one page. If a section has usemap, it
> can't be removed until removing other sections.
> This dependency is not desirable for memory removing.
> 

True. I have a report complaining that a node cannot be removed because
of some reserved pages at the start of the node. I have not looked
closely yet but it is possible that it is a page containing usemaps for
another section that is in there.

> Pgdat has similar feature. When a section has pgdat area, it 
> must be the last section for removing on the node.
> So, if section A has pgdat and section B has usemap for section A,
> Both sections can't be removed due to dependency each other.
> 
> To solve this issue, this patch collects usemap on same
> section with pgdat as much as possible.
> If other sections doesn't have any dependency, this section will
> be able to be removed finally.
> 
> Change log of take 3.
>  - Change dependency message and comment.
>   (Thanks! > Andy Whitcroft-san)
> 
> Change log of take 2.
>  - This feature becomes effective only when CONFIG_MEMORY_HOTREMOVE is on.
>    If hotremove is off, this feature is not necessary.
>  - Allow allocation on other section if alloc_bootmem_section() fails.
>    This removes previous regression.
>  - Show message if allocation on same section fails.
> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> 
> ---
> 
>  mm/sparse.c |   78 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 77 insertions(+), 1 deletion(-)
> 
> Index: current/mm/sparse.c
> ===================================================================
> --- current.orig/mm/sparse.c	2008-06-17 15:34:29.000000000 +0900
> +++ current/mm/sparse.c	2008-06-17 18:35:02.000000000 +0900
> @@ -269,16 +269,92 @@
>  }
>  #endif /* CONFIG_MEMORY_HOTPLUG */
>  
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +static unsigned long * __init
> +sparse_early_usemap_alloc_section(unsigned long pnum)
> +{
> +	unsigned long section_nr;
> +	struct mem_section *ms = __nr_to_section(pnum);
> +	int nid = sparse_early_nid(ms);
> + 	struct pglist_data *pgdat = NODE_DATA(nid);
> +

It's not a major deal but the only caller of
sparse_early_usemap_alloc_section() has the nid already. If you looked up
the pgdat there and passed it in, it would involve fewer lookups. Granted,
this is not performance critical or anything so it's not a major deal.

> +	/*
> +	 * Usemap's page can't be freed until freeing other sections
> +	 * which use it. And, pgdat has same feature.
> +	 * If section A has pgdat and section B has usemap for other
> +	 * sections (includes section A), both sections can't be removed,
> +	 * because there is the dependency each other.
> +	 * To solve above issue, this collects all usemap on the same section
> +	 * which has pgdat as much as possible.
> +	 */

The comment is a bit tricky to read. How about?

	/*
	 * A page may contain usemaps for other sections preventing the
	 * the page being freed and making a section unremovable while
	 * other sections referencing the usemap remain active. Similarly,
	 * a pgdat can prevent a section being removed. If section A
	 * contains a pgdat and section B contains the usemap, both
	 * sections become inter-dependent. This allocates usemaps
	 * from the same section as the pgdat where possible to avoid
	 * this problem.
	 */

> +	section_nr = pfn_to_section_nr(__pa(pgdat) >> PAGE_SHIFT);
> +	return alloc_bootmem_section(usemap_size(), section_nr);
> +}
> +
> +static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
> +{
> +	unsigned long usemap_snr, pgdat_snr;
> +	static unsigned long old_usemap_snr = NR_MEM_SECTIONS;
> +	static unsigned long old_pgdat_snr = NR_MEM_SECTIONS;
> +	struct pglist_data *pgdat = NODE_DATA(nid);
> +	int usemap_nid;
> +
> +	usemap_snr = pfn_to_section_nr(__pa(usemap) >> PAGE_SHIFT);
> +	pgdat_snr = pfn_to_section_nr(__pa(pgdat) >> PAGE_SHIFT);
> +	if (usemap_snr == pgdat_snr)
> +		return;
> +
> +	if (old_usemap_snr == usemap_snr && old_pgdat_snr == pgdat_snr)
> +		/* skip redundant message */
> +		return;
> +
> +	old_usemap_snr = usemap_snr;
> +	old_pgdat_snr = pgdat_snr;
> +
> +	usemap_nid = sparse_early_nid(__nr_to_section(usemap_snr));
> +	if (usemap_nid != nid) {
> +		printk("node %d must be removed before remove section %ld\n",
> +		       nid, usemap_snr);
> +		return;

no kernel log level here

> +	}
> +	/*
> +	 * There is a circular dependency.
> +	 * Some platforms allow un-removable section because they will just
> +	 * gather other removable sections for dynamic partitioning.
> +	 * Just notify un-removable section's number here.
> +	 */
> +	printk(KERN_INFO "Section %ld and %ld (node %d)",
> +	       usemap_snr, pgdat_snr, nid);
> +	printk(" have a circular dependency on usemap and pgdat allocations\n");

a follow-on printk like this should use KERN_CONT

> +}
> +#else
> +static unsigned long * __init
> +sparse_early_usemap_alloc_section(unsigned long pnum)
> +{
> +	return NULL;
> +}
> +
> +static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
> +{
> +}
> +#endif /* CONFIG_MEMORY_HOTREMOVE */
> +
>  static unsigned long *__init sparse_early_usemap_alloc(unsigned long pnum)
>  {
>  	unsigned long *usemap;
>  	struct mem_section *ms = __nr_to_section(pnum);
>  	int nid = sparse_early_nid(ms);
>  
> -	usemap = alloc_bootmem_node(NODE_DATA(nid), usemap_size());
> +	usemap = sparse_early_usemap_alloc_section(pnum);
>  	if (usemap)
>  		return usemap;
>  
> +	usemap = alloc_bootmem_node(NODE_DATA(nid), usemap_size());
> +	if (usemap) {
> +		check_usemap_section_nr(nid, usemap);
> +		return usemap;
> +	}
> +
>  	/* Stupid: suppress gcc warning for SPARSEMEM && !NUMA */
>  	nid = 0;
>  

Just a few minor things that need cleaning up there. Otherwise, the idea
seems sound.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
