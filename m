Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 0C4426B0044
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 10:26:50 -0400 (EDT)
Date: Sat, 24 Mar 2012 10:26:21 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] Re: kswapd stuck using 100% CPU
Message-ID: <20120324102621.353114da@annuminas.surriel.com>
In-Reply-To: <20120324130353.48f2e4c8@kryten>
References: <20120324130353.48f2e4c8@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: aarcange@redhat.com, mel@csn.ul.ie, akpm@linux-foundation.org, hughd@google.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Sat, 24 Mar 2012 13:03:53 +1100
Anton Blanchard <anton@samba.org> wrote:

> I booted the latest git today on a ppc64 box. When I pushed it into
> swap I noticed both kswapd's were using 100% CPU and the soft lockup
> detector suggested it was stuck in balance_pgdat:
> 
> BUG: soft lockup - CPU#7 stuck for 23s! [kswapd1:359]
> Call Trace:
> [c00000000015e190] .balance_pgdat+0x150/0x940 
> [c00000000015eb2c] .kswapd+0x1ac/0x490
> [c00000000009edbc] .kthread+0xbc/0xd0
> [c00000000002142c] .kernel_thread+0x54/0x70

Are you running without CONFIG_COMPACTION enabled by any chance?

Because if you do, the stub function compaction_suitable will always
return COMPACT_SKIPPED:
 
> I haven't had time to bisect but I did notice we were looping here:
> 
> +++ b/mm/vmscan.c
> @@ -2945,9 +2959,11 @@ out:
>  			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
>  				continue;
>  
> +#if 0
>  			/* Would compaction fail due to lack of free memory? */
>  			if (compaction_suitable(zone, order) == COMPACT_SKIPPED)
>  				goto loop_again;
> +#endif

The patch below should fix it.

-----

Only test compaction_suitable if the kernel is built with CONFIG_COMPACTION,
otherwise the stub compaction_suitable function will always return
COMPACT_SKIPPED and send kswapd into an infinite loop.

Signed-off-by: Rik van Riel <riel@redhat.com>
Reported-by: Anton Blanchard <anton@samba.org>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7658fd6..33c332b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2946,7 +2946,8 @@ out:
 				continue;
 
 			/* Would compaction fail due to lack of free memory? */
-			if (compaction_suitable(zone, order) == COMPACT_SKIPPED)
+			if (COMPACTION_BUILD &&
+			    compaction_suitable(zone, order) == COMPACT_SKIPPED)
 				goto loop_again;
 
 			/* Confirm the zone is balanced for order-0 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
