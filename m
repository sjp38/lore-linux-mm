Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E18AF2806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:32:59 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 68so3026328pgj.23
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:32:59 -0700 (PDT)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id p3si316177pli.132.2017.04.18.14.32.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 14:32:58 -0700 (PDT)
Received: by mail-pg0-x230.google.com with SMTP id g2so2570573pge.3
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:32:57 -0700 (PDT)
Date: Tue, 18 Apr 2017 14:32:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, vmscan: avoid thrashing anon lru when free + file
 is low
In-Reply-To: <20170418013659.GD21354@bbox>
Message-ID: <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com> <20170418013659.GD21354@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Apr 2017, Minchan Kim wrote:

> > The purpose of the code that commit 623762517e23 ("revert 'mm: vmscan: do
> > not swap anon pages just because free+file is low'") reintroduces is to
> > prefer swapping anonymous memory rather than trashing the file lru.
> > 
> > If all anonymous memory is unevictable, however, this insistance on
> 
> "unevictable" means hot workingset, not (mlocked and increased refcount
> by some driver)?
> I got confused.
> 

For my purposes, it's mlocked, but I think this thrashing is possible 
anytime we fail the file lru heuristic and the evictable anon lrus are 
very small themselves.  I'll update the changelog to make this explicit.

> > Check that enough evictable anon memory is actually on this lruvec before
> > insisting on SCAN_ANON.  SWAP_CLUSTER_MAX is used as the threshold to
> > determine if only scanning anon is beneficial.
> 
> Why do you use SWAP_CLUSTER_MAX instead of (high wmark + free) like
> file-backed pages?
> As considering anonymous pages have more probability to become workingset
> because they are are mapped, IMO, more {strong or equal} condition than
> file-LRU would be better to prevent anon LRU thrashing.
> 

If the suggestion is checking
NR_ACTIVE_ANON + NR_INACTIVE_ANON > total_high_wmark pages, it would be a 
separate heurstic to address a problem that I'm not having :)  My issue is 
specifically when NR_ACTIVE_FILE + NR_INACTIVE_FILE < total_high_wmark, 
NR_ACTIVE_ANON + NR_INACTIVE_ANON is very large, but all not on this 
lruvec's evictable lrus.

This is the reason why I chose lruvec_lru_size() rather than per-node 
statistics.  The argument could also be made for the file lrus in the 
get_scan_count() heuristic that forces SCAN_ANON, but I have not met such 
an issue (yet).  I could follow-up with that change or incorporate it into 
a v2 of this patch if you'd prefer.

In other words, I want get_scan_count() to not force SCAN_ANON and 
fallback to SCAN_FRACT, absent other heuristics, if the amount of 
evictable anon is below a certain threshold for this lruvec.  I 
arbitrarily chose SWAP_CLUSTER_MAX to be conservative, but I could easily 
compare to total_high_wmark as well, although I would consider that more 
aggressive.

So we're in global reclaim, our file lrus are below thresholds, but we 
don't want to force SCAN_ANON for all lruvecs if there's not enough to 
reclaim from evictable anon.  Do you have a suggestion for how to 
implement this logic other than this patch?

> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2186,26 +2186,31 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
> >  	 * anon pages.  Try to detect this based on file LRU size.
> 
> Please update this comment, too.
> 

Ok, I've added: "Try to detect this based on file LRU size, but do not 
limit scanning to anon if it is too small itself."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
