Date: Mon, 18 Sep 2006 16:15:28 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Get rid of zone_table V2
Message-Id: <20060918161528.9714c30c.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0609181544420.29365@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
	<20060918132818.603196e2.akpm@osdl.org>
	<Pine.LNX.4.64.0609181544420.29365@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Sep 2006 15:51:25 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 18 Sep 2006, Andrew Morton wrote:
> 
> > On Mon, 18 Sep 2006 12:21:35 -0700 (PDT)
> > Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > The zone table is mostly not needed. If we have a node in the
> > > page flags then we can get to the zone via NODE_DATA() which
> > > is much more likely to be already in the cpu cache.
> > 
> > Adds a couple of hundred bytes of text to an x86 SMP build.  Any
> > idea why?  If it's things like page_zone() getting porkier then that's
> > a bit unfortunate - that's rather fastpath material.
> 
> In an SMP/UP configuration we do not need to do any lookup since 
> NODE_DATA() is constant. We calculate the address of the zone which may be 
> more code than a lookup.

So it looks like we've made UP and small SMP worse, while providing some
undescribed level of benefit to big NUMA?  Not a popular tradeoff, that.

We call page_zone() rather a lot, and looking at the proposed new version
is scary:


static inline enum zone_type page_zonenum(struct page *page)
{
	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
}

static inline unsigned long page_to_nid(struct page *page)
{
	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
}

static inline struct zone *page_zone(struct page *page)
{
	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
}

Not only does it add a whole bunch of pointer derefs and arithmetic (and a
probably unnecessary second indirection for page->flags), it also brings a
read of contig_page_data[] into the picture.


So...  it's not obvious to me that this is an aggregate improvement?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
