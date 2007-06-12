Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
	 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
	 <20070611221036.GA14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
	 <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com>
	 <20070611231008.GD14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 12 Jun 2007 10:28:17 -0400
Message-Id: <1181658497.5592.26.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Mon, 2007-06-11 at 16:17 -0700, Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > +	if (nid < 0)
> > +		nid = first_node(node_populated_map);
> 
> nid == 1 means local node? Or why do we check for nid < 0?
> 
> 	if (nid == 1)
> 		 nid = numa_node_id();

That's not what it's doing.  alloc_fresh_huge_page() is an incremental
allocator.  Keeps track of where it left off using a static variable.
Because I changed it to scan a node map [the populated map], I needed to
fetch the "first_node()" the first time it's called.  Thus the initial
value of -1.  Thereafter, alloc_fresh_huge_page() just cycles around the
populated map.

> 
> ?
> > +	do {
> > +		page = alloc_pages_node(nid,
> > +				GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
> > +				HUGETLB_PAGE_ORDER);
> > +		nid = next_node(nid, node_populated_map);
> > +		if (nid >= nr_node_ids)
> > +			nid = first_node(node_populated_map);
> > +	} while (!page && nid != start_nid);
> 
> Looks good.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
