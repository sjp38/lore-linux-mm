Date: Wed, 28 May 2008 12:22:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 11/23] hugetlb: support larger than MAX_ORDER
Message-ID: <20080528102238.GF2630@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143453.269965000@nick.local0.net> <1211923418.12036.38.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1211923418.12036.38.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi-suse@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Tue, May 27, 2008 at 04:23:38PM -0500, Adam Litke wrote:
> On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> > @@ -549,6 +560,51 @@ static struct page *alloc_huge_page(stru
> >  	return page;
> >  }
> > 
> > +static __initdata LIST_HEAD(huge_boot_pages);
> > +
> > +struct huge_bootmem_page {
> > +	struct list_head list;
> > +	struct hstate *hstate;
> > +};
> > +
> > +static int __init alloc_bootmem_huge_page(struct hstate *h)
> > +{
> > +	struct huge_bootmem_page *m;
> > +	int nr_nodes = nodes_weight(node_online_map);
> > +
> > +	while (nr_nodes) {
> > +		m = __alloc_bootmem_node_nopanic(NODE_DATA(h->hugetlb_next_nid),
> > +					huge_page_size(h), huge_page_size(h),
> > +					0);
> > +		if (m)
> > +			goto found;
> > +		hstate_next_node(h);
> > +		nr_nodes--;
> > +	}
> > +	return 0;
> > +
> > +found:
> > +	BUG_ON((unsigned long)virt_to_phys(m) & (huge_page_size(h) - 1));
> > +	/* Put them into a private list first because mem_map is not up yet */
> > +	list_add(&m->list, &huge_boot_pages);
> > +	m->hstate = h;
> > +	return 1;
> > +}
> 
> At first I was pretty confused by how you are directly using the
> newly-allocated bootmem page to create a temporary list until the mem
> map comes up.  Clever.  I bet I would have understood right away if it

Just a note that Andi wrote it.


> were written like the following:
> 
> void *vaddr;
> struct huge_bootmem_page *m;
> 
> vaddr = __alloc_bootmem_node_nopanic(...);
> if (vaddr) {
> 	/*
> 	 * Use the beginning of this block to store some temporary
> 	 * meta-data until the mem_map comes up.
> 	 */
> 	m = (huge_bootmem_page *) vaddr;
> 	goto found;
> }
> 
> If you don't like that level of verbosity, could we add a comment just
> to make it immediately clear to the reader?


Yeah OK. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
