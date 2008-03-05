Subject: Re: [PATCH] 2.6.25-rc3-mm1 - Mempolicy:  make
	dequeue_huge_page_vma() obey MPOL_BIND nodemask
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080305180322.GA9795@us.ibm.com>
References: <20080227214708.6858.53458.sendpatchset@localhost>
	 <20080227214734.6858.9968.sendpatchset@localhost>
	 <20080228133247.6a7b626f.akpm@linux-foundation.org>
	 <20080229145030.GD6045@csn.ul.ie> <1204300094.5311.50.camel@localhost>
	 <20080304180145.GB9051@csn.ul.ie> <1204733195.5026.20.camel@localhost>
	 <20080305180322.GA9795@us.ibm.com>
Content-Type: text/plain
Date: Wed, 05 Mar 2008 14:02:53 -0500
Message-Id: <1204743774.6244.6.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, agl@us.ibm.com, wli@holomorphy.com, clameter@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-03-05 at 10:03 -0800, Nishanth Aravamudan wrote:
> On 05.03.2008 [11:06:34 -0500], Lee Schermerhorn wrote:
> > PATCH Mempolicy - make dequeue_huge_page_vma() obey MPOL_BIND nodemask
> > 
> > dequeue_huge_page_vma() is not obeying the MPOL_BIND nodemask
> > with the zonelist rework.  It needs to search only zones in 
> > the mempolicy nodemask for hugepages.
> > 
> > Use for_each_zone_zonelist_nodemask() instead of
> > for_each_zone_zonelist().
> > 
> > Note:  this will bloat mm/hugetlb.o a bit until Mel reworks the
> > inlining of the for_each_zone... macros and helpers.
> > 
> > Added mempolicy helper function mpol_bind_nodemask() to hide
> > the details of mempolicy from hugetlb and to avoid
> > #ifdef CONFIG_NUMA in dequeue_huge_page_vma().
> > 
> > Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> >  include/linux/mempolicy.h |   13 +++++++++++++
> >  mm/hugetlb.c              |    4 +++-
> >  2 files changed, 16 insertions(+), 1 deletion(-)
> > 
> > Index: linux-2.6.25-rc3-mm1/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.25-rc3-mm1.orig/mm/hugetlb.c	2008-03-05 10:35:12.000000000 -0500
> > +++ linux-2.6.25-rc3-mm1/mm/hugetlb.c	2008-03-05 10:37:09.000000000 -0500
> > @@ -99,8 +99,10 @@ static struct page *dequeue_huge_page_vm
> >  					htlb_alloc_mask, &mpol);
> >  	struct zone *zone;
> >  	struct zoneref *z;
> > +	nodemask_t *nodemask = mpol_bind_nodemask(mpol);
> 
> We get this mpol from huge_zonelist(). Would it perhaps make sense to
> pass the nodemask as a parameter, too, to huge_zonelist(), rather than
> adding mpol_bind_nodemask()? This is the only user of it in-tree.

Nish:

I thought of that.  I didn't go that way because I'd either need to pass
a [pointer to a pointer to] a nodemask in addition to the [pointer to a
pointer to] the mpol, so that I can release the reference on the mpol
after the allocation is finished; or I'd need to copy the nodemask
[which can get pretty big] in the allocation path.  I wanted to avoid
both of those.  I suppose I could be convinced that one or the other of
those options is better than the single use helper function.  What do
you think?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
