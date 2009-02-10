Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9809E6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 09:21:44 -0500 (EST)
Date: Tue, 10 Feb 2009 14:21:39 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] introduce for_each_populated_zone() macro
Message-ID: <20090210142138.GD4023@csn.ul.ie>
References: <20090210162220.6FBC.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210135050.GB4023@csn.ul.ie> <2f11576a0902100613g311f8387sb23f866c94bd48bf@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2f11576a0902100613g311f8387sb23f866c94bd48bf@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 11:13:12PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> >> +#define for_each_populated_zone(zone)                        \
> >> +     for (zone = (first_online_pgdat())->node_zones; \
> >> +          zone;                                      \
> >> +          zone = next_zone(zone))                    \
> >> +             if (!populated_zone(zone))              \
> >> +                     ; /* do nothing */              \
> >> +             else
> >> +
> >> +
> >> +
> >> +
> >
> > There is tabs vs whitespace damage in there.
> 
> ??
> I'm look at it again. but I don't found whitespace damage.
> 

Maybe there is some oddity in my mailer, but the second part of the for
loop with "zone;" looks like a tab followed by spaces to me. Not a big
deal, probably looks better with the spaces in this case.

> > Multiple empty lines are introduced for no apparent reason.
> 
> Will fix. thanks.
> 
> > It's not clear why you did not use if (populated_zone(zone))
> > instead of an if/else.
> 
> Good question.
> if we make following macro,
> 
> #define for_each_populated_zone(zone)                        \
>      for (zone = (first_online_pgdat())->node_zones; \
>           zone;                                      \
>           zone = next_zone(zone))                    \
>              if (populated_zone(zone))
> 
> and, writing following caller code.
> 
> if (always_true_assumption)
>   for_each_populated_zone(){
>      /* some code */
>   }
> else
>   panic();
> 
> expand to
> 
> if (always_true_assumption)
>   for()
>      if (populated_zone() {
>      /* some code */
>   }
> else
>   panic();
> 
> then, memoryless node cause panic().
> 

Oof, that's tricky but you're correct. The macro has to work as you suggest
or weird things can happen.

> >
> > Otherwise, I did not spot anything out of the ordinary. Nice cleanup.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
