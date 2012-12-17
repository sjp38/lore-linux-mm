Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id D3DFB6B0044
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 11:37:38 -0500 (EST)
Date: Mon, 17 Dec 2012 17:37:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/8] mm: vmscan: disregard swappiness shortly before
 going OOM
Message-ID: <20121217163735.GE25432@dhcp22.suse.cz>
References: <1355348620-9382-3-git-send-email-hannes@cmpxchg.org>
 <20121213103420.GW1009@suse.de>
 <20121213152959.GE21644@dhcp22.suse.cz>
 <20121213160521.GG21644@dhcp22.suse.cz>
 <8631DC5930FA9E468F04F3FD3A5D007214AD2FA2@USINDEM103.corp.hds.com>
 <20121214045030.GE6317@cmpxchg.org>
 <20121214083738.GA6898@dhcp22.suse.cz>
 <50CB493B.8000900@redhat.com>
 <20121214161345.GA18780@dhcp22.suse.cz>
 <20121215001850.GA21353@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121215001850.GA21353@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Satoru Moriya <satoru.moriya@hds.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri 14-12-12 19:18:51, Johannes Weiner wrote:
> On Fri, Dec 14, 2012 at 05:13:45PM +0100, Michal Hocko wrote:
> > On Fri 14-12-12 10:43:55, Rik van Riel wrote:
> > > On 12/14/2012 03:37 AM, Michal Hocko wrote:
> > > 
> > > >I can answer the later. Because memsw comes with its price and
> > > >swappiness is much cheaper. On the other hand it makes sense that
> > > >swappiness==0 doesn't swap at all. Or do you think we should get back to
> > > >_almost_ doesn't swap at all?
> > > 
> > > swappiness==0 will swap in emergencies, specifically when we have
> > > almost no page cache left, we will still swap things out:
> > > 
> > >         if (global_reclaim(sc)) {
> > >                 free  = zone_page_state(zone, NR_FREE_PAGES);
> > >                 if (unlikely(file + free <= high_wmark_pages(zone))) {
> > >                         /*
> > >                          * If we have very few page cache pages, force-scan
> > >                          * anon pages.
> > >                          */
> > >                         fraction[0] = 1;
> > >                         fraction[1] = 0;
> > >                         denominator = 1;
> > >                         goto out;
> > > 
> > > This makes sense, because people who set swappiness==0 but
> > > do have swap space available would probably prefer some
> > > emergency swapping over an OOM kill.
> > 
> > Yes, but this is the global reclaim path. I was arguing about
> > swappiness==0 & memcg. As this patch doesn't make a big difference for
> > the global case (as both the changelog and you mentioned) then we should
> > focus on whether this is desirable change for the memcg path. I think it
> > makes sense to keep "no swapping at all for memcg semantic" as we have
> > it currently.
> 
> I would prefer we could agree on one thing, though.  Having global
> reclaim behave different from memcg reclaim violates the principle of
> least surprise. 

Hmm, I think that no swapping at all with swappiness==0 makes some sense
with the global reclaim as well. Why should we swap if admin told us not
to do that?
I am not so strong in that though because the global swappiness has been
more relaxed in the past and people got used to that. We have seen bug
reports already where users were surprised by a high io wait times when
it turned out that they had swappiness set to 0 because that prevented
swapping most of the time in the past but fe35004f changed that.

Usecases for memcg are more natural because memcg allows much better
control over OOM and also requirements for (not) swapping are per group
rather than on swap availability. We shouldn't push users into using
memcg swap accounting to accomplish the same IMHO because the accounting
has some costs and its primary usage is not to disable swapping but
rather to keep it on the leash. The two approaches are also different
from semantic point of view. Swappiness is proportional while the limit
is an absolute number.

> Having the code behave like that implicitely without any mention of
> global_reclaim() and vm_swappiness() is unacceptable.

So what about:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7f30961..e6d4f23 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1750,7 +1750,15 @@ out:
 		unsigned long scan;
 
 		scan = get_lru_size(lruvec, lru);
-		if (sc->priority || noswap || !vmscan_swappiness(sc)) {
+		/*
+		 * Memcg targeted reclaim, unlike the global reclaim, honours
+		 * swappiness==0 and no swapping is allowed even if that would
+		 * lead to an OOM killer which is a) local to the group resp.
+		 * hierarchy and moreover can be handled from userspace which
+		 * makes it different from the global reclaim.
+		 */
+		if (sc->priority || noswap ||
+				(!global_reclaim(sc) && !vmscan_swappiness(sc))) {
 			scan >>= sc->priority;
 			if (!scan && force_scan)
 				scan = SWAP_CLUSTER_MAX;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
