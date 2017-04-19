Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0186B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 20:15:11 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d3so4624873pfj.5
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:15:11 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id w185si609930pgd.418.2017.04.18.17.15.09
        for <linux-mm@kvack.org>;
        Tue, 18 Apr 2017 17:15:10 -0700 (PDT)
Date: Wed, 19 Apr 2017 09:14:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch] mm, vmscan: avoid thrashing anon lru when free + file is
 low
Message-ID: <20170419001405.GA13364@bbox>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com>
 <20170418013659.GD21354@bbox>
 <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com>
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi David,

On Tue, Apr 18, 2017 at 02:32:56PM -0700, David Rientjes wrote:
> On Tue, 18 Apr 2017, Minchan Kim wrote:
> 
> > > The purpose of the code that commit 623762517e23 ("revert 'mm: vmscan: do
> > > not swap anon pages just because free+file is low'") reintroduces is to
> > > prefer swapping anonymous memory rather than trashing the file lru.
> > > 
> > > If all anonymous memory is unevictable, however, this insistance on
> > 
> > "unevictable" means hot workingset, not (mlocked and increased refcount
> > by some driver)?
> > I got confused.
> > 
> 
> For my purposes, it's mlocked, but I think this thrashing is possible 
> anytime we fail the file lru heuristic and the evictable anon lrus are 
> very small themselves.  I'll update the changelog to make this explicit.

I understood now. Thanks for clarifying.

> 
> > > Check that enough evictable anon memory is actually on this lruvec before
> > > insisting on SCAN_ANON.  SWAP_CLUSTER_MAX is used as the threshold to
> > > determine if only scanning anon is beneficial.
> > 
> > Why do you use SWAP_CLUSTER_MAX instead of (high wmark + free) like
> > file-backed pages?
> > As considering anonymous pages have more probability to become workingset
> > because they are are mapped, IMO, more {strong or equal} condition than
> > file-LRU would be better to prevent anon LRU thrashing.
> > 
> 
> If the suggestion is checking
> NR_ACTIVE_ANON + NR_INACTIVE_ANON > total_high_wmark pages, it would be a 
> separate heurstic to address a problem that I'm not having :)  My issue is 
> specifically when NR_ACTIVE_FILE + NR_INACTIVE_FILE < total_high_wmark, 
> NR_ACTIVE_ANON + NR_INACTIVE_ANON is very large, but all not on this 
> lruvec's evictable lrus.

I understand it as "all not eligible LRU lists". Right?
I will write the comment below with that my assumption is right.

> 
> This is the reason why I chose lruvec_lru_size() rather than per-node 
> statistics.  The argument could also be made for the file lrus in the 
> get_scan_count() heuristic that forces SCAN_ANON, but I have not met such 
> an issue (yet).  I could follow-up with that change or incorporate it into 
> a v2 of this patch if you'd prefer.

I don't think we need to fix that part because the logic is to keep
some amount of file-backed page workingset regardless of eligible
zones. 

> 
> In other words, I want get_scan_count() to not force SCAN_ANON and 
> fallback to SCAN_FRACT, absent other heuristics, if the amount of 
> evictable anon is below a certain threshold for this lruvec.  I 
> arbitrarily chose SWAP_CLUSTER_MAX to be conservative, but I could easily 
> compare to total_high_wmark as well, although I would consider that more 
> aggressive.

I realize your problem now. It's rather different heuristic so no need
to align file-lru. But SWAP_CLUSTER_MAX is too conservatie, too. IMHO.

How about this?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 24efcc20af91..5d2f3fa41e92 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2174,8 +2174,17 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 		}
 
 		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
-			scan_balance = SCAN_ANON;
-			goto out;
+			/*
+			 * force SCAN_ANON if inactive anonymous LRU lists of
+			 * eligible zones are enough pages. Otherwise, thrashing
+			 * can be happen on the small anonymous LRU list.
+			 */
+			if (!inactive_list_is_low(lruvec, false, NULL, sc, false) &&
+			     lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
+					>> sc->priority) {
+				scan_balance = SCAN_ANON;
+				goto out;
+			}
 		}
 	}
 

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
