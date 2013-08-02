Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id ECA126B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 23:53:03 -0400 (EDT)
Date: Fri, 2 Aug 2013 12:53:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Possible deadloop in direct reclaim?
Message-ID: <20130802035333.GD32486@bbox>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
 <20130801054338.GD19540@bbox>
 <89813612683626448B837EE5A0B6A7CB3B630BE04E@SC-VEXCH4.marvell.com>
 <20130801073330.GG19540@bbox>
 <89813612683626448B837EE5A0B6A7CB3B630BE0E3@SC-VEXCH4.marvell.com>
 <20130801084259.GA32486@bbox>
 <20130802015241.GB32486@bbox>
 <89813612683626448B837EE5A0B6A7CB3B630BE43E@SC-VEXCH4.marvell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B630BE43E@SC-VEXCH4.marvell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>

On Thu, Aug 01, 2013 at 08:17:56PM -0700, Lisa Du wrote:
> >-----Original Message-----
> >From: Minchan Kim [mailto:minchan@kernel.org]
> >Sent: 2013a1'8ae??2ae?JPY 10:26
> >To: Lisa Du
> >Cc: linux-mm@kvack.org; KOSAKI Motohiro
> >Subject: Re: Possible deadloop in direct reclaim?
> >
> >Hello Lisa and KOSAKI,
> >
> >Lisa's quote style is very hard to follow so I'd like to write at bottom
> >as ignoring line by line rule.
> >
> >Lisa, please correct your MUA.
> I'm really sorry for my quote style, will improve it in my following mails.
> >
> >
> >I reviewed current mmotm because recently Mel changed kswapd a lot and
> >all_unreclaimable patch history today.
> >What I see is recent mmotm has a same problem, too if system have no swap
> >and no compaction. Of course, compaction is default yes option so we could
> >recommend to enable if system works well but it's up to user and we should
> >avoid direct reclaim hang although user disable compaction.
> >
> >When I see the patch history, real culprit is 929bea7c.
> >
> >"  zone->all_unreclaimable and zone->pages_scanned are neigher atomic
> >    variables nor protected by lock.  Therefore zones can become a state of
> >    zone->page_scanned=0 and zone->all_unreclaimable=1.  In this case, current
> >    all_unreclaimable() return false even though zone->all_unreclaimabe=1."
> >
> >I understand the problem but apparently, it makes Lisa's problem because
> >kswapd can give up balancing when high order allocation happens to prevent
> >excessive reclaim with assuming the process requested high order allocation
> >can do direct reclaim/compaction. But what if the process can't reclaim
> >by no swap but lots of anon pages and can't compact by !CONFIG_COMPACTION?
> >
> >In such system, OOM kill is natural but not hang.
> >So, a solution we can fix simply introduces zone_reclaimable check again in
> >all_unreclaimabe() like this.
> >
> >What do you think about it?
> >
> >It's a same patch Lisa posted so we should give a credit
> >to her/him(Sorry I'm not sure) if we agree thie approach.
> >
> >Lisa, If KOSAKI agree with this, could you resend this patch with your SOB?
> >
> >Thanks.
> >
> >diff --git a/mm/vmscan.c b/mm/vmscan.c
> >index a3bf7fd..78f46d8 100644
> >--- a/mm/vmscan.c
> >+++ b/mm/vmscan.c
> >@@ -2367,7 +2367,15 @@ static bool all_unreclaimable(struct zonelist *zonelist,
> > 			continue;
> > 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> > 			continue;
> >-		if (!zone->all_unreclaimable)
> >+		/*
> >+		 * zone->page_scanned and could be raced so we need
> >+		 * dobule check by zone->all_unreclaimable. Morever, kswapd
> >+		 * could skip (zone->all_unreclaimable = 1) if the zone
> >+		 * is heavily fragmented but enough free pages to meet
> >+		 * high watermark. In such case, kswapd never set
> >+		 * all_unreclaimable to 1 so we need zone_reclaimable, too.
> >+		 */
> >+		if (!zone->all_unreclaimable || zone_reclaimable(zone))
> > 			return false;
> > 	}
>    I'm afraid this patch may can't help.
>    zone->all_unreclaimable = 0 will always result the false return,
>    zone_reclaimable(zone) check wouldn't take effect no matter
>    it's true of false right?

You're right. It was not what I want but check both conditions.

> 
> Also Bob found below thread, seems Kosaki also found same issue:
> mm, vmscan: fix do_try_to_free_pages() livelock
> https://lkml.org/lkml/2012/6/14/74

I remember it and AFAIRC, I had a concern because description was
too vague without detailed example and I fixed Aaditya's problem with
another approach. That's why it wasn't merged at that time.

Now, we have a real problem and analysis so I think KOSAKI's patch makes
perfect to me.

Lisa, Could you resend KOSAKI's patch with more detailed description?

> 
> >
> >
> >
> >--
> >Kind regards,
> >Minchan Kim

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
