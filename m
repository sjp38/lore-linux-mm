Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id E26DB6B007E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 00:36:55 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id xm6so142445290pab.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 21:36:55 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 3si15312158pfj.2.2016.05.05.21.36.54
        for <linux-mm@kvack.org>;
        Thu, 05 May 2016 21:36:55 -0700 (PDT)
Date: Fri, 6 May 2016 13:37:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: avoid unnecessary iteration in
 get_pages_per_zspage()
Message-ID: <20160506043702.GB18573@bbox>
References: <1462425447-13385-1-git-send-email-opensource.ganesh@gmail.com>
 <20160505100329.GA497@swordfish>
 <20160506030935.GA18573@bbox>
 <CADAEsF9S4GQE6V+zsvRRVYjdbfN3VRQFcTiN5E_MWw60bfk0Zw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADAEsF9S4GQE6V+zsvRRVYjdbfN3VRQFcTiN5E_MWw60bfk0Zw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hi Ganesh,

On Fri, May 06, 2016 at 12:25:18PM +0800, Ganesh Mahendran wrote:
> Hi, Minchan:
> 
> 2016-05-06 11:09 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> > On Thu, May 05, 2016 at 07:03:29PM +0900, Sergey Senozhatsky wrote:
> >> On (05/05/16 13:17), Ganesh Mahendran wrote:
> >> > if we find a zspage with usage == 100%, there is no need to
> >> > try other zspages.
> >>
> >> Hello,
> >>
> >> well... we iterate there from 0 to 1<<2, which is not awfully
> >> a lot to break it in the middle, and we do this only when we
> >> initialize a new pool (for every size class).
> >>
> >> the check is
> >>  - true   15 times
> >>  - false  492 times
> >
> > Thanks for the data, Sergey!
> >
> >>
> >> so it _sort of_ feels like this new if-condition doesn't
> >> buy us a lot, and most of the time it just sits there with
> >> no particular gain. let's hear from Minchan.
> >>
> >
> > I agree with Sergey.
> > First of al, I appreciates your patch, Ganesh! But as Sergey pointed
> > out, I don't see why it improves current zsmalloc.
> 
> This patch does not obviously improve zsmalloc.
> It just reduces unnecessary code path.
> 
> From data provided by Sergey, 15 * (4 -  1) = 45 times loop will be avoided.
> So 45 times of below caculation will be reduced:
> ---
> zspage_size = i * PAGE_SIZE;
> waste = zspage_size % class_size;
> usedpc = (zspage_size - waste) * 100 / zspage_size;
> 
> if (usedpc > max_usedpc) {

As well, it bloats code side without much gain. I don't think
it's worth to do until someone really has trouble with slow
zs_create_pool performance.

add/remove: 0/0 grow/shrink: 1/0 up/down: 15/0 (15)
function                                     old     new   delta
zs_create_pool                               960     975     +15


> ---
> 
> Thanks.
> 
> > If you want to merge strongly, please convince me with more detail
> > reason.
> >
> > Thanks.
> >
> >
> >>       -ss
> >>
> >> > Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> >> > Cc: Minchan Kim <minchan@kernel.org>
> >> > Cc: Nitin Gupta <ngupta@vflare.org>
> >> > Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> >> > ---
> >> >  mm/zsmalloc.c |    3 +++
> >> >  1 file changed, 3 insertions(+)
> >> >
> >> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> >> > index fda7177..310c7b0 100644
> >> > --- a/mm/zsmalloc.c
> >> > +++ b/mm/zsmalloc.c
> >> > @@ -765,6 +765,9 @@ static int get_pages_per_zspage(int class_size)
> >> >             if (usedpc > max_usedpc) {
> >> >                     max_usedpc = usedpc;
> >> >                     max_usedpc_order = i;
> >> > +
> >> > +                   if (max_usedpc == 100)
> >> > +                           break;
> >> >             }
> >> >     }
> >> >
> >> > --
> >> > 1.7.9.5
> >> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
