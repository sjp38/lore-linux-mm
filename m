Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 896776B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 08:46:16 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so1070092pad.31
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 05:46:16 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id vu10si2217426pbc.189.2014.03.13.05.46.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 05:46:10 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id lj1so1068539pab.20
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 05:46:10 -0700 (PDT)
Date: Thu, 13 Mar 2014 05:44:57 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: performance regression due to commit e82e0561("mm: vmscan: obey
 proportional scanning requirements for kswapd")
In-Reply-To: <20140312165447.GO10663@suse.de>
Message-ID: <alpine.LSU.2.11.1403130516050.10128@eggly.anvils>
References: <20140218080122.GO26593@yliu-dev.sh.intel.com> <20140312165447.GO10663@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Yuanhan Liu <yuanhan.liu@linux.intel.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 12 Mar 2014, Mel Gorman wrote:
> On Tue, Feb 18, 2014 at 04:01:22PM +0800, Yuanhan Liu wrote:
> > Hi,
> > 
> > Commit e82e0561("mm: vmscan: obey proportional scanning requirements for
> > kswapd") caused a big performance regression(73%) for vm-scalability/
> > lru-file-readonce testcase on a system with 256G memory without swap.
> > 
> > That testcase simply looks like this:
> >      truncate -s 1T /tmp/vm-scalability.img
> >      mkfs.xfs -q /tmp/vm-scalability.img
> >      mount -o loop /tmp/vm-scalability.img /tmp/vm-scalability
> > 
> >      SPARESE_FILE="/tmp/vm-scalability/sparse-lru-file-readonce"
> >      for i in `seq 1 120`; do
> >          truncate $SPARESE_FILE-$i -s 36G
> >          timeout --foreground -s INT 300 dd bs=4k if=$SPARESE_FILE-$i of=/dev/null
> >      done
> > 
> >      wait
> > 
> 
> The filename implies that it's a sparse file with no IO but does not say
> what the truncate function/program/whatever actually does. If it's really a
> sparse file then the dd process should be reading zeros and writing them to
> NULL without IO. Where are pages being dirtied? Does the truncate command
> really create a sparse file or is it something else?
> 
> > Actually, it's not the newlly added code(obey proportional scanning)
> > in that commit caused the regression. But instead, it's the following
> > change:
> > +
> > +               if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
> > +                       continue;
> > +
> > 
> > 
> > -               if (nr_reclaimed >= nr_to_reclaim &&
> > -                   sc->priority < DEF_PRIORITY)
> > +               if (global_reclaim(sc) && !current_is_kswapd())
> >                         break;
> > 
> > The difference is that we might reclaim more than requested before
> > in the first round reclaimming(sc->priority == DEF_PRIORITY).
> > 
> > So, for a testcase like lru-file-readonce, the dirty rate is fast, and
> > reclaimming SWAP_CLUSTER_MAX(32 pages) each time is not enough for catching
> > up the dirty rate. And thus page allocation stalls, and performance drops:
...
> > I made a patch which simply keeps reclaimming more if sc->priority == DEF_PRIORITY.
> > I'm not sure it's the right way to go or not. Anyway, I pasted it here for comments.
> > 
> 
> The impact of the patch is that a direct reclaimer will now scan and
> reclaim more pages than requested so the unlucky reclaiming process will
> stall for longer than it should while others make forward progress.
> 
> That would explain the difference in allocstall figure as each stall is
> now doing more work than it did previously. The throughput figure is
> harder to explain. What is it measuring?
> 
> Any idea why kswapd is failing to keep up?
> 
> I'm not saying the patch is wrong but there appears to be more going on
> that is explained in the changelog. Is the full source of the benchmark
> suite available? If so, can you point me to it and the exact commands
> you use to run the testcase please?

I missed Yuanhan's mail, but seeing your reply reminds me of another
issue with that proportionality patch - or perhaps more thought would
show them to be two sides of the same issue, with just one fix required.
Let me throw our patch into the cauldron.

[PATCH] mm: revisit shrink_lruvec's attempt at proportionality

We have a memcg reclaim test which exerts a certain amount of pressure,
and expects to see a certain range of page reclaim in response.  It's a
very wide range allowed, but the test repeatably failed on v3.11 onwards,
because reclaim goes wild and frees up almost everything.

This wild behaviour bisects to Mel's "scan_adjusted" commit e82e0561dae9
"mm: vmscan: obey proportional scanning requirements for kswapd".  That
attempts to achieve proportionality between anon and file lrus: to the
extent that once one of those is empty, it then tries to empty the other.
Stop that.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

We've been running happily with this for months; but all that time it's
been on my TODO list with a "needs more thought" tag before we could
upstream it, and I never got around to that.  We also have a somewhat
similar, but older and quite independent, fix to get_scan_count() from
Suleiman, which I'd meant to send along at the same time: I'll dig that
one out tomorrow or the day after.

 mm/vmscan.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

--- 3.14-rc6/mm/vmscan.c	2014-02-02 18:49:07.949302116 -0800
+++ linux/mm/vmscan.c	2014-03-13 04:38:04.664030175 -0700
@@ -2019,7 +2019,6 @@ static void shrink_lruvec(struct lruvec
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct blk_plug plug;
-	bool scan_adjusted = false;
 
 	get_scan_count(lruvec, sc, nr);
 
@@ -2042,7 +2041,7 @@ static void shrink_lruvec(struct lruvec
 			}
 		}
 
-		if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
+		if (nr_reclaimed < nr_to_reclaim)
 			continue;
 
 		/*
@@ -2064,6 +2063,15 @@ static void shrink_lruvec(struct lruvec
 		nr_file = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
 		nr_anon = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];
 
+		/*
+		 * It's just vindictive to attack the larger once the smaller
+		 * has gone to zero.  And given the way we stop scanning the
+		 * smaller below, this makes sure that we only make one nudge
+		 * towards proportionality once we've got nr_to_reclaim.
+		 */
+		if (!nr_file || !nr_anon)
+			break;
+
 		if (nr_file > nr_anon) {
 			unsigned long scan_target = targets[LRU_INACTIVE_ANON] +
 						targets[LRU_ACTIVE_ANON] + 1;
@@ -2093,8 +2101,6 @@ static void shrink_lruvec(struct lruvec
 		nr_scanned = targets[lru] - nr[lru];
 		nr[lru] = targets[lru] * (100 - percentage) / 100;
 		nr[lru] -= min(nr[lru], nr_scanned);
-
-		scan_adjusted = true;
 	}
 	blk_finish_plug(&plug);
 	sc->nr_reclaimed += nr_reclaimed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
