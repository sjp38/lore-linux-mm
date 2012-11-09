Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 6EB906B005D
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 04:13:03 -0500 (EST)
Date: Fri, 9 Nov 2012 09:12:58 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] Revert "mm: vmscan: scale number of pages reclaimed by
 reclaim/compaction based on failures"
Message-ID: <20121109091258.GH8218@suse.de>
References: <119175.1349979570@turing-police.cc.vt.edu>
 <5077434D.7080008@suse.cz>
 <50780F26.7070007@suse.cz>
 <20121012135726.GY29125@suse.de>
 <507BDD45.1070705@suse.cz>
 <20121015110937.GE29125@suse.de>
 <5093A3F4.8090108@redhat.com>
 <5093A631.5020209@suse.cz>
 <509422C3.1000803@suse.cz>
 <20121105142449.GI8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121105142449.GI8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zdenek Kabelac <zkabelac@redhat.com>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Jiri Slaby <jslaby@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 05, 2012 at 02:24:49PM +0000, Mel Gorman wrote:
> Jiri Slaby reported the following:
> 
> 	(It's an effective revert of "mm: vmscan: scale number of pages
> 	reclaimed by reclaim/compaction based on failures".) Given kswapd
> 	had hours of runtime in ps/top output yesterday in the morning
> 	and after the revert it's now 2 minutes in sum for the last 24h,
> 	I would say, it's gone.
> 
> The intention of the patch in question was to compensate for the loss
> of lumpy reclaim. Part of the reason lumpy reclaim worked is because
> it aggressively reclaimed pages and this patch was meant to be a sane
> compromise.
> 
> When compaction fails, it gets deferred and both compaction and
> reclaim/compaction is deferred avoid excessive reclaim. However, since
> commit c6543459 (mm: remove __GFP_NO_KSWAPD), kswapd is woken up each time
> and continues reclaiming which was not taken into account when the patch
> was developed.
> 
> Attempts to address the problem ended up just changing the shape of the
> problem instead of fixing it. The release window gets closer and while a
> THP allocation failing is not a major problem, kswapd chewing up a lot of
> CPU is. This patch reverts "mm: vmscan: scale number of pages reclaimed
> by reclaim/compaction based on failures" and will be revisited in the future.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Andrew, can you pick up this patch please and drop
mm-vmscan-scale-number-of-pages-reclaimed-by-reclaim-compaction-only-in-direct-reclaim.patch
?

There are mixed reports on how much it helps but it comes down to "this
fixes a problem" versus "kswapd is still showing higher usage". I think
the higher kswapd usage is explained by the removal of __GFP_NO_KSWAPD
and so while higher usage is bad, it is not necessarily unjustified.
Ideally it would have been proven that having kswapd doing the work
reduced application stalls in direct reclaim but unfortunately I do not
have concrete evidence of that at this time.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
