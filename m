Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 99DB46B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 19:52:50 -0400 (EDT)
Received: by bwz17 with SMTP id 17so801687bwz.14
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 16:52:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
Date: Thu, 2 Jun 2011 08:52:47 +0900
Message-ID: <BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> Hi,
>
> this is the second version of the memcg naturalization series. =A0The
> notable changes since the first submission are:
>
> =A0 =A0o the hierarchy walk is now intermittent and will abort and
> =A0 =A0 =A0remember the last scanned child after sc->nr_to_reclaim pages
> =A0 =A0 =A0have been reclaimed during the walk in one zone (Rik)
>
> =A0 =A0o the global lru lists are never scanned when memcg is enabled
> =A0 =A0 =A0after #2 'memcg-aware global reclaim', which makes this patch
> =A0 =A0 =A0self-sufficient and complete without requiring the per-memcg l=
ru
> =A0 =A0 =A0lists to be exclusive (Michal)
>
> =A0 =A0o renamed sc->memcg and sc->current_memcg to sc->target_mem_cgroup
> =A0 =A0 =A0and sc->mem_cgroup and fixed their documentation, I hope this =
is
> =A0 =A0 =A0better understandable now (Rik)
>
> =A0 =A0o the reclaim statistic counters have been renamed. =A0there is no
> =A0 =A0 =A0more distinction between 'pgfree' and 'pgsteal', it is now
> =A0 =A0 =A0'pgreclaim' in both cases; 'kswapd' has been replaced by
> =A0 =A0 =A0'background'
>
> =A0 =A0o fixed a nasty crash in the hierarchical soft limit check that
> =A0 =A0 =A0happened during global reclaim in memcgs that are hierarchical
> =A0 =A0 =A0but have no hierarchical parents themselves
>
> =A0 =A0o properly implemented the memcg-aware unevictable page rescue
> =A0 =A0 =A0scanner, there were several blatant bugs in there
>
> =A0 =A0o documentation on new public interfaces
>
> Thanks for your input on the first version.
>
> I ran microbenchmarks (sparse file catting, essentially) to stress
> reclaim and LRU operations. =A0There is no measurable overhead for
> !CONFIG_MEMCG, memcg disabled during boot, memcg enabled but no
> configured groups, and hard limit reclaim.
>
> I also ran single-threaded kernbenchs in four unlimited memcgs in
> parallel, contained in a hard-limited hierarchical parent that put
> constant pressure on the workload. =A0There is no measurable difference
> in runtime, the pgpgin/pgpgout counters, and fairness among memcgs in
> this test compared to an unpatched kernel. =A0Needs more evaluation,
> especially with a higher number of memcgs.
>
> The soft limit changes are also proven to work in so far that it is
> possible to prioritize between children in a hierarchy under pressure
> and that runtime differences corresponded directly to the soft limit
> settings in the previously described kernbench setup with staggered
> soft limits on the groups, but this needs quantification.
>
> Based on v2.6.39.
>

Hmm, I welcome and will review this patches but.....some points I want to s=
ay.

1. No more conflict with Ying's work ?
    Could you explain what she has and what you don't in this v2 ?
    If Ying's one has something good to be merged to your set, please
include it.

2. it's required to see performance score in commit log.

3. I think dirty_ratio as 1st big patch to be merged. (But...hmm..Greg ?
    My patches for asynchronous reclaim is not very important. I can rework=
 it.

4. This work can be splitted into some small works.
     a) fix for current code and clean ups
     a') statistics
     b) soft limit rework
     c) change global reclaim

  I like (a)->(b)->(c) order. and while (b) you can merge your work
with Ying's one.
  And for a') , I'd like to add a new file memory.reclaim_stat as I've
already shown.
  and allow resetting.

  Hmm, how about splitting patch 2/8 into small patches and see what happen=
s in
  3.2 or 3.3 ? While that, we can make softlimit works better.
  (and once we do 2/8, our direction will be fixed to the direction to
remove global LRU.)

5. please write documentation to explain what new LRU do.

BTW, after this work, lists of ROOT cgroup comes again. I may need to check
codes which see memcg is ROOT or not. Because we removed many atomic
ops in memcg, I wonder ROOT cgroup can be accounted again..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
