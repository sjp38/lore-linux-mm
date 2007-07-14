Date: Sat, 14 Jul 2007 09:06:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/7] Generic Virtual Memmap support for SPARSEMEM
In-Reply-To: <20070714152058.GA12478@infradead.org>
Message-ID: <Pine.LNX.4.64.0707140905140.31138@schroedinger.engr.sgi.com>
References: <exportbomb.1184333503@pinky> <E1I9LJY-00006o-GK@hellhawk.shadowen.org>
 <20070714152058.GA12478@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Sat, 14 Jul 2007, Christoph Hellwig wrote:

> >  #elif defined(CONFIG_SPARSEMEM)
> 
> nice ifdef mess you have here.  and an sm-generic file should be something
> truely generic instead of a complete ifdef forest.  I think we'd be
> much better off duplicating the two lines above in architectures using
> it anyway.

Nope these all need to be arch independent otherwise we cannot consolidate 
the code. True these statements became very small with SPARSE_VIRTUAL but 
that is no reason to make an exception just for this new model.

> > +#ifndef CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP
> > +void __meminit vmemmap_verify(pte_t *pte, int node,
> > +				unsigned long start, unsigned long end)
> > +{
> > +	unsigned long pfn = pte_pfn(*pte);
> > +	int actual_node = early_pfn_to_nid(pfn);
> > +
> > +	if (actual_node != node)
> > +		printk(KERN_WARNING "[%lx-%lx] potential offnode "
> > +			"page_structs\n", start, end - 1);
> > +}
> 
> Given tht this function is a tiny noop please just put them into the
> arch dir for !CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP architectures
> and save yourself both the ifdef mess and the config option.

Then its no longer generic. You are ripping the basic framework of 
sparsemem apart.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
