Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 736206B0047
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 11:56:54 -0400 (EDT)
Received: by pwj6 with SMTP id 6so3303672pwj.14
        for <linux-mm@kvack.org>; Wed, 01 Sep 2010 08:56:52 -0700 (PDT)
Date: Thu, 2 Sep 2010 00:56:44 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [BUGFIX][PATCH] vmscan: don't use return value trick when
 oom_killer_disabled
Message-ID: <20100901155644.GA10246@barrios-desktop>
References: <20100901092430.9741.A69D9226@jp.fujitsu.com>
 <AANLkTikXfvEVXEyw_5_eJs2v-3J6Xhd=CT9X-0D+GMCA@mail.gmail.com>
 <20100901105232.974F.A69D9226@jp.fujitsu.com>
 <AANLkTinxHbeCUh80i515FPMpF-GY4S0kh9PHqUNtYP-m@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinxHbeCUh80i515FPMpF-GY4S0kh9PHqUNtYP-m@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "M. Vefa Bicakci" <bicave@superonline.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 01, 2010 at 11:01:43AM +0900, Minchan Kim wrote:
> On Wed, Sep 1, 2010 at 10:55 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Hi
> >
> > Thank you for good commenting!
> >
> >
> >> I don't like use oom_killer_disabled directly.
> >> That's because we have wrapper inline functions to handle the
> >> variable(ex, oom_killer_[disable/enable]).
> >> It means we are reluctant to use the global variable directly.
> >> So should we make new function as is_oom_killer_disable?
> >>
> >> I think NO.
> >>
> >> As I read your description, this problem is related to only hibernation.
> >> Since hibernation freezes all processes(include kswapd), this problem
> >> happens. Of course, now oom_killer_disabled is used by only
> >> hibernation. But it can be used others in future(Off-topic : I don't
> >> want it). Others can use it without freezing processes. Then kswapd
> >> can set zone->all_unreclaimable and the problem can't happen.
> >>
> >> So I want to use sc->hibernation_mode which is already used
> >> do_try_to_free_pages instead of oom_killer_disabled.
> >
> > Unfortunatelly, It's impossible. shrink_all_memory() turn on
> > sc->hibernation_mode. but other hibernation caller merely call
> > alloc_pages(). so we don't have any hint.
> >
> Ahh.. True. Sorry for that.
> I will think some better method.
> if I can't find it, I don't mind this patch. :)

It seems that the poblem happens following as. 
(I might miss something since I just read theyour description)

hibernation
oom_disable
alloc_pages
do_try_to_free_pages
        if (scanning_global_lru(sc) && !all_unreclaimable)
                return 1;
If kswapd is not freezed, it would set zone->all_unreclaimable to 1 and then
shrink_zones maybe return true. so alloc_pages could go to _nopage_.
If it is, it's no problem. 
Right?

I think the problem would come from shrink_zones. 
It set false to all_unreclaimable blindly even though shrink_zone can't reclaim
any page. It doesn't make sense. 
How about this?
I think we need this regardless of the problem.
What do you think about?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d8fd87d..22017b3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1901,7 +1901,8 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
                }
 
                shrink_zone(priority, zone, sc);
-               all_unreclaimable = false;
+               if (sc->nr_reclaimed)
+                       all_unreclaimable = false;
        }
        return all_unreclaimable;
 }

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
