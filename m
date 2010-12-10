Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D37AB6B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 05:54:59 -0500 (EST)
Date: Fri, 10 Dec 2010 11:54:36 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-ID: <20101210105436.GO2356@cmpxchg.org>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
 <AANLkTikOgkGBn9AbEDAM4KegsnwuXqF2jg7icu0yc8Kh@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTikOgkGBn9AbEDAM4KegsnwuXqF2jg7icu0yc8Kh@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 09, 2010 at 10:51:40AM -0800, Ying Han wrote:
> On Wed, Dec 8, 2010 at 7:16 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > @@ -2587,7 +2607,7 @@ void wakeup_kswapd(struct zone *zone, int order)
> >                pgdat->kswapd_max_order = order;
> >        if (!waitqueue_active(&pgdat->kswapd_wait))
> >                return;
> > -       if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0))
> > +       if (!zone_needs_scan(zone, order, low_wmark_pages(zone), 0))
> >                return;
> >
> >        trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
> 
> So we look at zone_reclaimable_pages() only to determine proceed
> reclaiming or not. What if I have tons of unused dentry and inode
> caches and we are skipping the shrinker here?

We have no straight-forward way to asking that (yet - per-zone
shrinkers may change that?), so the zone is left for direct reclaim to
figure this out.

Forcing allocators into direct reclaim more often is still better than
having kswapd run wild.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
