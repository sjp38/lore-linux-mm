Date: Fri, 18 Jan 2008 16:28:42 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] a bit improvement of ZONE_DMA page reclaim
In-Reply-To: <20080117232147.85ae8cab.akpm@linux-foundation.org>
References: <20080118151822.8FAE.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080117232147.85ae8cab.akpm@linux-foundation.org>
Message-Id: <20080118162434.8FB1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Rik van Riel <riel@redhat.com>, Daniel Spang <daniel.spang@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi Andrew

> > on X86, ZONE_DMA is very very small.
> > It is often no used at all. 
> 
> In that case page-reclaim is supposed to set all_unreclaimable and
> basically ignores the zone altogether until it looks like something might
> have changed.
> 
> Is that code not working?  (quite possible).

please insert blow debug printk and dd if=bigfile of=/dev/null.
you see "near_oom(DMA) 0 0 0" messages :)

at least, I can reproduce it on my machine.

my machine
	CPU: x86_64 1.86GHz x2
	memory: 6G

- kosaki


Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c       2008-01-18 14:49:06.000000000 +0900
+++ b/mm/vmscan.c       2008-01-18 14:50:21.000000000 +0900
@@ -966,8 +966,14 @@ static int calc_reclaim_mapped(struct sc
        int reclaim_mapped = 0;
        int prev_priority;

-       if (scan_global_lru(sc) && zone_is_near_oom(zone))
+       if (scan_global_lru(sc) && zone_is_near_oom(zone)) {
+               printk("near_oom(%s) %ld %ld %ld\n",
+                      zone->name,
+                      zone->pages_scanned,
+                      zone_page_state(zone, NR_ACTIVE),
+                      zone_page_state(zone, NR_INACTIVE));
                return 1;
+       }
        /*
         * `distress' is a measure of how much trouble we're having
         * reclaiming pages.  0 -> no problems.  100 -> great trouble.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
