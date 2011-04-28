Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4E96B0022
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 08:37:05 -0400 (EDT)
Date: Thu, 28 Apr 2011 14:36:52 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Fw: [PATCH] memcg: add reclaim statistics accounting
Message-ID: <20110428123652.GM12437@cmpxchg.org>
References: <20110428121643.b3cbf420.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTimywCF06gfKWFcbAsWtFUbs73rZrQ@mail.gmail.com>
 <20110428180139.6ec67196.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110428180139.6ec67196.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Apr 28, 2011 at 06:01:39PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 27 Apr 2011 20:43:58 -0700
> Ying Han <yinghan@google.com> wrote:
> 
> > On Wed, Apr 27, 2011 at 8:16 PM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > sorry, I had wrong TO:...
> > >
> > > Begin forwarded message:
> > >
> > > Date: Thu, 28 Apr 2011 12:02:34 +0900
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > To: linux-mm@vger.kernel.org
> > > Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
> > > Subject: [PATCH] memcg: add reclaim statistics accounting
> > >
> > >
> > >
> > > Now, memory cgroup provides poor reclaim statistics per memcg. This
> > > patch adds statistics for direct/soft reclaim as the number of
> > > pages scans, the number of page freed by reclaim, the nanoseconds of
> > > latency at reclaim.
> > >
> > > It's good to add statistics before we modify memcg/global reclaim, largely.
> > > This patch refactors current soft limit status and add an unified update logic.
> > >
> > > For example, After #cat 195Mfile > /dev/null under 100M limit.
> > >        # cat /cgroup/memory/A/memory.stat
> > >        ....
> > >        limit_freed 24592
> > 
> > why not "limit_steal" ?
> > 
> > >        soft_steal 0
> > >        limit_scan 43974
> > >        soft_scan 0
> > >        limit_latency 133837417
> > >
> > > nearly 96M caches are freed. scanned twice. used 133ms.
> > 
> > Does it make sense to split up the soft_steal/scan for bg reclaim and
> > direct reclaim? The same for the limit_steal/scan. I am now testing
> > the patch to add the soft_limit reclaim on global ttfp, and i already
> > have the patch to add the following:
> > 
> > kswapd_soft_steal 0
> > kswapd_soft_scan 0
> > direct_soft_steal 0
> > direct_soft_scan 0
> > kswapd_steal 0
> > pg_pgsteal 0
> > kswapd_pgscan 0
> > pg_scan 0
> > 
> 
> I'll not post updated version until the end of holidays but my latest plan is
> adding
> 
> 
> limit_direct_free   - # of pages freed by limit in foreground (not stealed, you freed by yourself's limit)
> soft_kswapd_steal   - # of pages stealed by kswapd based on soft limit
> limit_direct_scan   - # of pages scanned by limit in foreground
> soft_kswapd_scan    - # of pages scanned by kswapd based on soft limit
> 
> And then, you can add
> 
> soft_direct_steal     - # of pages stealed by foreground reclaim based on soft limit
> soft_direct_scan        - # of pages scanned by foreground reclaim based on soft limit
> 
> And
> 
> kern_direct_steal  - # of pages stealed by foreground reclaim at memory shortage.
> kern_direct_scan   - # of pages scanned by foreground reclaim at memory shortage.
> kern_direct_steal  - # of pages stealed by kswapd at memory shortage
> kern_direct_scan   - # of pages scanned by kswapd at memory shortage
> 
> (Above kern_xxx number includes soft_xxx in it. ) These will show influence by
> other cgroups.
> 
> And
> 
> wmark_bg_free      - # of pages freed by watermark in background(not kswapd)
> wmark_bg_scan      - # of pages scanned by watermark in background(not kswapd)
> 
> Hmm ? too many stats ;)

Indeed, and you have not even taken hierarchical reclaim into account.
What I propose is the separation of reclaim that happens within a
memcg due to an internal memcg condition, and reclaim that happens
within a memcg due to outside conditions - either the hierarchy or
global memory pressure.  Something like the following, maybe?

1. Limit-triggered direct reclaim

The memory cgroup hits its limit and the task does direct reclaim from
its own memcg.  We probably want statistics for this separately from
background reclaim to see how successful background reclaim is, the
same reason we have this separation in the global vmstat as well.

	pgscan_direct_limit
	pgfree_direct_limit

2. Limit-triggered background reclaim

This is the watermark-based asynchroneous reclaim that is currently in
discussion.  It's triggered by the memcg breaching its watermark,
which is relative to its hard-limit.  I named it kswapd because I
still think kswapd should do this job, but it is all open for
discussion, obviously.  Treat it as meaning 'background' or
'asynchroneous'.

	pgscan_kswapd_limit
	pgfree_kswapd_limit

3. Hierarchy-triggered direct reclaim

A condition outside the memcg leads to a task directly reclaiming from
this memcg.  This could be global memory pressure for example, but
also a parent cgroup hitting its limit.  It's probably helpful to
assume global memory pressure meaning that the root cgroup hit its
limit, conceptually.  We don't have that yet, but this could be the
direct softlimit reclaim Ying mentioned above.

	pgscan_direct_hierarchy
	pgsteal_direct_hierarchy

4. Hierarchy-triggered background reclaim

An outside condition leads to kswapd reclaiming from this memcg, like
kswapd doing softlimit pushback due to global memory pressure.

	pgscan_kswapd_hierarchy
	pgsteal_kswapd_hierarchy

---

With these stats in place, you can see how much pressure there is on
your memcg hierarchy.  This includes machine utilization and if you
overcommitted too much on a global level if there is a lot of reclaim
activity indicated in the hierarchical stats.

With the limit-based stats, you can see the amount of internal
pressure of memcgs, which shows you if you overcommitted on a local
level.

And for both cases, you can also see the effectiveness of background
reclaim by comparing the direct and the kswapd stats.

> And making current soft_steal/soft_scan planned to be obsolete...

It's in -mm, but not merged upstream.

Regardless of my proposol for any stats above, I want to ask everybody
involved that we do not add any more ABI and exports of random
internals of the memcg reclaim process at this point.

We have a lot of plans and ideas still in flux for memcg reclaim, I
think it's about the worst point in time to commit ourselves to
certain behaviour, knobs, and statistics regarding this code.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
