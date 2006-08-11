Date: Fri, 11 Aug 2006 11:42:43 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
Message-Id: <20060811114243.49fa4390.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0608111112000.18296@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
	<20060810124137.6da0fdef.akpm@osdl.org>
	<Pine.LNX.4.64.0608102010150.12657@schroedinger.engr.sgi.com>
	<20060811110821.51096659.akpm@osdl.org>
	<Pine.LNX.4.64.0608111112000.18296@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, pj@sgi.com, jes@sgi.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Aug 2006 11:15:08 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 11 Aug 2006, Andrew Morton wrote:
> 
> > > I would rather avoid fiddling around with making __GFP_xxx conditional.
> > > We have seen  to what problems this could lead.
> > 
> > What problems?
> 
> I just cleaned out the #ifdefs from the __GFP_xx section because you 
> told me that some comparisions could go haywire. if __GFP_xx would be zero. See 
> our discussion recently on __GFP_DMA32.
> 
> F.e. Tests like (__GFP_DMA | __GFP_THISNODE) == __GFP_THISNODE
> would give wrong positives if __GFP_THISNODE would be 0.

mutter.  No ifdefs, please.  We already have 41 #ifdef NUMA's in ./*/*.c

How about we do

/*
 * We do this to avoid lots of ifdefs and their consequential conditional
 * compilation
 */
#ifdef CONFIG_NUMA
#define NUMA_BUILD 1
#else
#define NUMA_BUILD 0
#endif

Then we can do

--- a/mm/page_alloc.c~a
+++ a/mm/page_alloc.c
@@ -903,7 +903,7 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	 */
 	do {
 		zone = *z;
-		if (unlikely((gfp_mask & __GFP_THISNODE) &&
+		if (NUMA_BUILD && unlikely((gfp_mask & __GFP_THISNODE) &&
 			zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
 				break;
 		if ((alloc_flags & ALLOC_CPUSET) &&
_

in lots of places.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
