Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BBB5E6B0029
	for <linux-mm@kvack.org>; Tue, 17 May 2011 04:25:47 -0400 (EDT)
Date: Tue, 17 May 2011 10:25:12 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch 2/6] vmscan: make distinction between memcg reclaim
 and LRU list selection
Message-ID: <20110517082512.GA16531@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <1305212038-15445-3-git-send-email-hannes@cmpxchg.org>
 <4DCBFDB9.10209@redhat.com>
 <20110512160349.GJ16531@cmpxchg.org>
 <BANLkTi=+hVKx6bkowgiiatPGwSy0m3=2uQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTi=+hVKx6bkowgiiatPGwSy0m3=2uQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 16, 2011 at 11:38:07PM -0700, Ying Han wrote:
> On Thu, May 12, 2011 at 9:03 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Thu, May 12, 2011 at 11:33:13AM -0400, Rik van Riel wrote:
> >> On 05/12/2011 10:53 AM, Johannes Weiner wrote:
> >> >The reclaim code has a single predicate for whether it currently
> >> >reclaims on behalf of a memory cgroup, as well as whether it is
> >> >reclaiming from the global LRU list or a memory cgroup LRU list.
> >> >
> >> >Up to now, both cases always coincide, but subsequent patches will
> >> >change things such that global reclaim will scan memory cgroup lists.
> >> >
> >> >This patch adds a new predicate that tells global reclaim from memory
> >> >cgroup reclaim, and then changes all callsites that are actually about
> >> >global reclaim heuristics rather than strict LRU list selection.
> >> >
> >> >Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>
> >> >---
> >> >  mm/vmscan.c |   96 ++++++++++++++++++++++++++++++++++------------------------
> >> >  1 files changed, 56 insertions(+), 40 deletions(-)
> >> >
> >> >diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> >index f6b435c..ceeb2a5 100644
> >> >--- a/mm/vmscan.c
> >> >+++ b/mm/vmscan.c
> >> >@@ -104,8 +104,12 @@ struct scan_control {
> >> >      */
> >> >     reclaim_mode_t reclaim_mode;
> >> >
> >> >-    /* Which cgroup do we reclaim from */
> >> >-    struct mem_cgroup *mem_cgroup;
> >> >+    /*
> >> >+     * The memory cgroup we reclaim on behalf of, and the one we
> >> >+     * are currently reclaiming from.
> >> >+     */
> >> >+    struct mem_cgroup *memcg;
> >> >+    struct mem_cgroup *current_memcg;
> >>
> >> I can't say I'm fond of these names.  I had to read the
> >> rest of the patch to figure out that the old mem_cgroup
> >> got renamed to current_memcg.
> >
> > To clarify: sc->memcg will be the memcg that hit the hard limit and is
> > the main target of this reclaim invocation.  current_memcg is the
> > iterator over the hierarchy below the target.
> 
> I would assume the new variable memcg is a renaming of the
> "mem_cgroup" which indicating which cgroup we reclaim on behalf of.

The thing is, mem_cgroup would mean both the group we are reclaiming
on behalf of AND the group we are currently reclaiming from.  Because
the hierarchy walk was implemented in memcontrol.c, vmscan.c only ever
saw one cgroup at a time.

> About the "current_memcg", i couldn't find where it is indicating to
> be the current cgroup under the hierarchy below the "memcg".

It's codified in shrink_zone().

	for each child of sc->memcg:
	  sc->current_memcg = child
	  reclaim(sc)

In the new version I named (and documented) them:

	sc->target_mem_cgroup: the entry point into the hierarchy, set
	by the functions that have the scan control structure on their
	stack.  That's the one hitting its hard limit.

	sc->mem_cgroup: the current position in the hierarchy below
	sc->target_mem_cgroup.  That's the one that actively gets its
	pages reclaimed.

> Both mem_cgroup_shrink_node_zone() and try_to_free_mem_cgroup_pages()
> are called within mem_cgroup_hierarchical_reclaim(), and the sc->memcg
> is initialized w/ the victim passed down which is already the memcg
> under hierarchy.

I changed mem_cgroup_shrink_node_zone() to use do_shrink_zone(), and
mem_cgroup_hierarchical_reclaim() no longer calls
try_to_free_mem_cgroup_pages().

So there is no hierarchy walk triggered from within a hierarchy walk.

I just noticed that there is, however, a bug in that
mem_cgroup_shrink_node_zone() does not initialize sc->current_memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
