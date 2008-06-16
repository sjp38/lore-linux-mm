Date: Mon, 16 Jun 2008 11:45:00 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [Patch](memory hotplug)Allocate usemap on the section with pgdat (take 2)
Message-ID: <20080616104500.GD2232@shadowen.org>
References: <20080614211216.76B0.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080614211216.76B0.E1E9C6FF@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: David Miller <davem@davemloft.net>, Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Tony Breeds <tony@bakeyournoodle.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Sat, Jun 14, 2008 at 09:22:44PM +0900, Yasunori Goto wrote:
> Hello.
> 
> I update the patch which was cause of regression at bootmem.
> This version allows normal allocation if alloc_bootmem_section() fails.
> So, previous regression will not occur.
> 
> I tested on my box. But it's not sparc, s390, nor powerpc.
> If there is any trouble by this patch, please let me know.
> 
> If no trouble, please apply.
> 
> Thanks.
> 
> ---
> 
> Usemaps are allocated on the section which has pgdat by this.
> 
> Because usemap size is very small, many other sections usemaps
> are allocated on only one page. If a section has usemap, it
> can't be removed until removing other sections.
> This dependency is not desirable for memory removing.
> 
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
> Change log of take 2.
>  - This feature becomes effective only when CONFIG_MEMORY_HOTREMOVE is on.
>    If hotremove is off, this feature is not necessary.
>  - Allow allocation on other section if alloc_bootmem_section() fails.
>    This avoids previous regression.
>  - Show message if allocation on same section fails.
> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> 
> ---
> 
>  mm/sparse.c |   77 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 76 insertions(+), 1 deletion(-)
> 
> Index: current/mm/sparse.c
> ===================================================================
> --- current.orig/mm/sparse.c	2008-06-14 19:03:23.000000000 +0900
> +++ current/mm/sparse.c	2008-06-14 20:41:39.000000000 +0900
> @@ -269,16 +269,91 @@
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
> +	/*
> +	 * Usemap's page can't be freed until freeing other sections
> +	 * which use it. And, pgdat has same feature.
> +	 * If section A has pgdat and section B has usemap for other
> +	 * sections (includes section A), both sections can't be removed,
> +	 * because there is the dependency each other.
> +	 * To solve above issue, this collects all usemap on the same section
> +	 * which has pgdat as much as possible.
> +	 */
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

The pgdat and usemap sections are node specific, but this repeat message
check is not, so if I add sections alternatly to node 0 and node 1 I
will recieve the warning for every addition?

> +
> +	usemap_nid = sparse_early_nid(__nr_to_section(usemap_snr));
> +	if (usemap_nid != nid) {
> +		printk("node %d must be removed before remove section %ld\n",
> +		       nid, usemap_snr);
> +		return;
> +	}
> +	/*
> +	 * There is a dependency deadlock.
> +	 * Some platforms allow un-removable section because they will just
> +	 * gather other removable sections for dynamic partitioning.
> +	 * Just notify un-removable section's number here.
> +	 */
> +	printk(KERN_INFO "section %ld and %ld", usemap_snr, pgdat_snr);
> +	printk(" can't be hotremoved due to dependency each other.\n");

This might be better worded as a circular dependancy.  Also it would be
nice to include the node perhaps:

	"Sections %ld and %ld (node %ld) have a circular dependancy on
	usemap and pgdat allocations"

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

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
