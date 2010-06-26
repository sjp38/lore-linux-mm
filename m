Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 399726B01AD
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 19:56:50 -0400 (EDT)
Received: by iwn36 with SMTP id 36so329457iwn.14
        for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:56:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100625173002.8052.A69D9226@jp.fujitsu.com>
References: <20100625173002.8052.A69D9226@jp.fujitsu.com>
Date: Sun, 27 Jun 2010 08:56:48 +0900
Message-ID: <AANLkTikm9fXmGoE1phY7vgQcMsS9_FVAvPHgtt1hnvTV@mail.gmail.com>
Subject: Re: [PATCH] vmscan: zone_reclaim don't call disable_swap_token()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 25, 2010 at 5:31 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Swap token don't works when zone reclaim is enabled since it was born.
> Because __zone_reclaim() always call disable_swap_token()
> unconditionally.
>
> This kill swap token feature completely. As far as I know, nobody want
> to that. Remove it.
>

In f7b7fd8f3ebbb, Rik added disable_swap_token.
At that time, sc.priority in zone_reclaim is zero so it does make sense.
But in a92f71263a, Christoph changed the priority to begin from
ZONE_RECLAIM_PRIORITY with remained disable_swap_token. It doesn't
make sense.

So doesn't we add disable_swap_token following as than removing?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9c7e57c..d8050c7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2590,7 +2590,6 @@ static int __zone_reclaim(struct zone *zone,
gfp_t gfp_mask, unsigned int order)
        };
        unsigned long slab_reclaimable;

-       disable_swap_token();
        cond_resched();
        /*
         * We need to be able to allocate from the reserves for RECLAIM_SWAP
@@ -2612,6 +2611,8 @@ static int __zone_reclaim(struct zone *zone,
gfp_t gfp_mask, unsigned int order)
                        note_zone_scanning_priority(zone, priority);
                        shrink_zone(priority, zone, &sc);
                        priority--;
+                       if (!priority)
+                               disable_swap_token();
                } while (priority >= 0 && sc.nr_reclaimed < nr_pages);
        }


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
