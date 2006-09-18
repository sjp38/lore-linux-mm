Date: Mon, 18 Sep 2006 16:46:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table V2
In-Reply-To: <20060918161528.9714c30c.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609181642210.30206@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
 <20060918132818.603196e2.akpm@osdl.org> <Pine.LNX.4.64.0609181544420.29365@schroedinger.engr.sgi.com>
 <20060918161528.9714c30c.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Sep 2006, Andrew Morton wrote:

> > In an SMP/UP configuration we do not need to do any lookup since 
> > NODE_DATA() is constant. We calculate the address of the zone which may be 
> > more code than a lookup.
> 
> So it looks like we've made UP and small SMP worse, while providing some
> undescribed level of benefit to big NUMA?  Not a popular tradeoff, that.

We avoid one memory reference for SMP and UP and do an address calculation
instead.

> We call page_zone() rather a lot, and looking at the proposed new version
> is scary:

> static inline struct zone *page_zone(struct page *page)
> {
> 	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
> }
> 
> Not only does it add a whole bunch of pointer derefs and arithmetic (and a
> probably unnecessary second indirection for page->flags), it also brings a
> read of contig_page_data[] into the picture.

It only is a single pointer deref from the node_data array indexed by
the node. The node_zones ref is an address calculation since the 
node_zones is an array of zone and not a list of pointers to zones.

What do you mean by a read of contig_page_data?

NODE_DATA() is constant for the UP and SMP case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
