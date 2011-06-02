Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB9A6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 03:34:23 -0400 (EDT)
Date: Thu, 2 Jun 2011 09:33:35 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
Message-ID: <20110602073335.GA20630@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 02, 2011 at 08:52:47AM +0900, Hiroyuki Kamezawa wrote:
> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> > Hi,
> >
> > this is the second version of the memcg naturalization series.  The
> > notable changes since the first submission are:
> >
> >    o the hierarchy walk is now intermittent and will abort and
> >      remember the last scanned child after sc->nr_to_reclaim pages
> >      have been reclaimed during the walk in one zone (Rik)
> >
> >    o the global lru lists are never scanned when memcg is enabled
> >      after #2 'memcg-aware global reclaim', which makes this patch
> >      self-sufficient and complete without requiring the per-memcg lru
> >      lists to be exclusive (Michal)
> >
> >    o renamed sc->memcg and sc->current_memcg to sc->target_mem_cgroup
> >      and sc->mem_cgroup and fixed their documentation, I hope this is
> >      better understandable now (Rik)
> >
> >    o the reclaim statistic counters have been renamed.  there is no
> >      more distinction between 'pgfree' and 'pgsteal', it is now
> >      'pgreclaim' in both cases; 'kswapd' has been replaced by
> >      'background'
> >
> >    o fixed a nasty crash in the hierarchical soft limit check that
> >      happened during global reclaim in memcgs that are hierarchical
> >      but have no hierarchical parents themselves
> >
> >    o properly implemented the memcg-aware unevictable page rescue
> >      scanner, there were several blatant bugs in there
> >
> >    o documentation on new public interfaces
> >
> > Thanks for your input on the first version.
> >
> > I ran microbenchmarks (sparse file catting, essentially) to stress
> > reclaim and LRU operations.  There is no measurable overhead for
> > !CONFIG_MEMCG, memcg disabled during boot, memcg enabled but no
> > configured groups, and hard limit reclaim.
> >
> > I also ran single-threaded kernbenchs in four unlimited memcgs in
> > parallel, contained in a hard-limited hierarchical parent that put
> > constant pressure on the workload.  There is no measurable difference
> > in runtime, the pgpgin/pgpgout counters, and fairness among memcgs in
> > this test compared to an unpatched kernel.  Needs more evaluation,
> > especially with a higher number of memcgs.
> >
> > The soft limit changes are also proven to work in so far that it is
> > possible to prioritize between children in a hierarchy under pressure
> > and that runtime differences corresponded directly to the soft limit
> > settings in the previously described kernbench setup with staggered
> > soft limits on the groups, but this needs quantification.
> >
> > Based on v2.6.39.
> >
> 
> Hmm, I welcome and will review this patches but.....some points I want to say.
> 
> 1. No more conflict with Ying's work ?
>     Could you explain what she has and what you don't in this v2 ?
>     If Ying's one has something good to be merged to your set, please
> include it.

The problem is that the solution we came up with at LSF, i.e. the
one-dimensional linked list of soft limit-exceeding memcgs, is not
adequate to represent the hierarchy structure of memcgs.

My solution is fundamentally different, so I don't really see possible
synergy between the patch series right now.

This was the conclusion last time:
http://marc.info/?l=linux-mm&m=130564056215365&w=2

> 2. it's required to see performance score in commit log.

The patch series is not a performance optimization.  But I can include
it to prove there are no regressions.

> 4. This work can be splitted into some small works.
>      a) fix for current code and clean ups
>      a') statistics
>      b) soft limit rework
>      c) change global reclaim
> 
>   I like (a)->(b)->(c) order. and while (b) you can merge your work
> with Ying's one.
>   And for a') , I'd like to add a new file memory.reclaim_stat as I've
> already shown.
>   and allow resetting.

Resetting reclaim statistics is a nice idea, let me have a look.
Sorry, I am a bit behind on reviewing other patches...

>   Hmm, how about splitting patch 2/8 into small patches and see what happens in
>   3.2 or 3.3 ? While that, we can make softlimit works better.
>   (and once we do 2/8, our direction will be fixed to the direction to
> remove global LRU.)

Do you have specific parts in mind that could go stand-alone?

One thing I can think of is splitting up those parts:

  1. move /target/ reclaim to generic code

  2. convert /global/ reclaim from global lru to hierarchy reclaim
     including root_mem_cgroup

> 5. please write documentation to explain what new LRU do.

Ok.

> BTW, after this work, lists of ROOT cgroup comes again. I may need to check
> codes which see memcg is ROOT or not. Because we removed many atomic
> ops in memcg, I wonder ROOT cgroup can be accounted again..

Oh, please do if you can find the time.  The memcg lru rules are
scary!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
