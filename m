Date: Mon, 16 Jun 2008 22:22:53 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch](memory hotplug)Allocate usemap on the section with pgdat (take 2)
In-Reply-To: <20080616104500.GD2232@shadowen.org>
References: <20080614211216.76B0.E1E9C6FF@jp.fujitsu.com> <20080616104500.GD2232@shadowen.org>
Message-Id: <20080616220705.9EA7.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: David Miller <davem@davemloft.net>, Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Tony Breeds <tony@bakeyournoodle.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> > +static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
> > +{
> > +	unsigned long usemap_snr, pgdat_snr;
> > +	static unsigned long old_usemap_snr = NR_MEM_SECTIONS;
> > +	static unsigned long old_pgdat_snr = NR_MEM_SECTIONS;
> > +	struct pglist_data *pgdat = NODE_DATA(nid);
> > +	int usemap_nid;
> > +
> > +	usemap_snr = pfn_to_section_nr(__pa(usemap) >> PAGE_SHIFT);
> > +	pgdat_snr = pfn_to_section_nr(__pa(pgdat) >> PAGE_SHIFT);
> > +	if (usemap_snr == pgdat_snr)
> > +		return;
> > +
> > +	if (old_usemap_snr == usemap_snr && old_pgdat_snr == pgdat_snr)
> > +		/* skip redundant message */
> > +		return;
> > +
> > +	old_usemap_snr = usemap_snr;
> > +	old_pgdat_snr = pgdat_snr;
> 
> The pgdat and usemap sections are node specific, but this repeat message
> check is not, so if I add sections alternatly to node 0 and node 1 I
> will recieve the warning for every addition?

Yes. alloc_bootmem_section() may be failed, and usemap may be allocated on
other node. I would like to notice for its dependency case too.

> 
> > +
> > +	usemap_nid = sparse_early_nid(__nr_to_section(usemap_snr));
> > +	if (usemap_nid != nid) {
> > +		printk("node %d must be removed before remove section %ld\n",
> > +		       nid, usemap_snr);
> > +		return;
> > +	}
> > +	/*
> > +	 * There is a dependency deadlock.
> > +	 * Some platforms allow un-removable section because they will just
> > +	 * gather other removable sections for dynamic partitioning.
> > +	 * Just notify un-removable section's number here.
> > +	 */
> > +	printk(KERN_INFO "section %ld and %ld", usemap_snr, pgdat_snr);
> > +	printk(" can't be hotremoved due to dependency each other.\n");
> 
> This might be better worded as a circular dependancy.  Also it would be
> nice to include the node perhaps:
> 
> 	"Sections %ld and %ld (node %ld) have a circular dependancy on
> 	usemap and pgdat allocations"

Thanks. I'll change it.


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
