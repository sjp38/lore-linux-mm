Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 10A1D6B0010
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 01:57:52 -0400 (EDT)
Subject: Re: [PATCH] slub Discard slab page only when node partials >
 minimum setting
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <CAOJsxLFeZS-6wt+_+Lronc5ds-D05=PYDHna4-8pNu8aBP+pCw@mail.gmail.com>
References: <1315188460.31737.5.camel@debian>
	 <alpine.DEB.2.00.1109061914440.18646@router.home>
	 <1315357399.31737.49.camel@debian>
	 <alpine.DEB.2.00.1109062022100.20474@router.home>
	 <4E671E5C.7010405@cs.helsinki.fi>
	 <6E3BC7F7C9A4BF4286DD4C043110F30B5D00DA333C@shsmsx502.ccr.corp.intel.com>
	 <alpine.DEB.2.00.1109071003240.9406@router.home>
	 <1315442639.31737.224.camel@debian>
	 <1315445674.29510.74.camel@sli10-conroe>
	 <1315448656.31737.252.camel@debian>
	 <CAOJsxLFeZS-6wt+_+Lronc5ds-D05=PYDHna4-8pNu8aBP+pCw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 15 Sep 2011 14:03:53 +0800
Message-ID: <1316066633.14905.11.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Li, Shaohua" <shaohua.li@intel.com>, Christoph Lameter <cl@linux.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Huang, Ying" <ying.huang@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 2011-09-15 at 13:40 +0800, Pekka Enberg wrote:
> On Thu, Sep 8, 2011 at 5:24 AM, Alex,Shi <alex.shi@intel.com> wrote:
> >> > BTW, some testing results for your PCP SLUB:
> >> >
> >> > for hackbench process testing:
> >> > on WSM-EP, inc ~60%, NHM-EP inc ~25%
> >> > on NHM-EX, inc ~200%, core2-EP, inc ~250%.
> >> > on Tigerton-EX, inc 1900%, :)
> >> >
> >> > for hackbench thread testing:
> >> > on WSM-EP, no clear inc, NHM-EP no clear inc
> >> > on NHM-EX, inc 10%, core2-EP, inc ~20%.
> >> > on Tigertion-EX, inc 100%,
> >> >
> >> > for  netperf loopback testing, no clear performance change.
> >> did you add my patch to add page to partial list tail in the test?
> >> Without it the per-cpu partial list can have more significant impact to
> >> reduce lock contention, so the result isn't precise.
> >>
> >
> > No, the penberg tree did include your patch on slub/partial head.
> > Actually PCP won't take that path, so, there is no need for your patch.
> > I daft a patch to remove some unused code in __slab_free, that related
> > this, and will send it out later.
> 
> Which patch is that? Please send me it to penberg@cs.helsinki.fi as
> @kernel.org email forward isn't working.


Ops, this thread mentioned 2 patches,
1, shaohua's bug fixing patch, that already in your tree as 'slub/urgent
head', if my memory service me right.

2, [PATCH] slub Discard slab page only when node partials > minimum
setting, that is the following. 

----------
From: Alex Shi <alex.shi@intel.com>
Date: Tue, 6 Sep 2011 14:46:01 +0800
Subject: [PATCH ] Discard slab page when node partial > mininum partial number

Discarding slab should be done when node partial > min_partial.
Otherwise, node partial slab may eat up all memory.

Signed-off-by: Alex Shi <alex.shi@intel.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1348c09..492beab 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1953,7 +1953,7 @@ static void unfreeze_partials(struct kmem_cache *s)
 
 			new.frozen = 0;
 
-			if (!new.inuse && (!n || n->nr_partial < s->min_partial))
+			if (!new.inuse && (!n || n->nr_partial > s->min_partial))
 				m = M_FREE;
 			else {
 				struct kmem_cache_node *n2 = get_node(s,
-- 
1.7.0




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
