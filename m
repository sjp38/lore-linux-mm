Received: by an-out-0708.google.com with SMTP id d33so429773and.105
        for <linux-mm@kvack.org>; Sun, 27 Jan 2008 22:43:57 -0800 (PST)
Message-ID: <28c262360801272243h71bf4464s431d1377051c756b@mail.gmail.com>
Date: Mon, 28 Jan 2008 15:43:56 +0900
From: "minchan kim" <minchan.kim@gmail.com>
Subject: Re: [PATCH] remove duplicating priority setting in try_to_free_p
In-Reply-To: <20080127213312.517b8014.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <28c262360801252329q7232edc2l2d0e4ed17c054832@mail.gmail.com>
	 <20080127213312.517b8014.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Bligh <mbligh@mbligh.org>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Jan 28, 2008 2:33 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Sat, 26 Jan 2008 02:29:23 -0500 "minchan kim" <minchan.kim@gmail.com> wrote:
>
> > shrink_zones in try_to_free_pages already set zone through
> > note_zone_scanning_priority.
> > So, setting prev_priority in try_to_free_pages is needless.
> >
> > This patch is made by 2.6.24-rc8.
> >
> > Signed-off-by: barrios <minchan.kim@gmail.com>
> > ---
> >  mm/vmscan.c |   17 -----------------
> >  1 files changed, 0 insertions(+), 17 deletions(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index e5a9597..fc55c23 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1273,23 +1273,6 @@ unsigned long try_to_free_pages(struct z
> >     if (!sc.all_unreclaimable)
> >         ret = 1;
> >  out:
> > -   /*
> > -    * Now that we've scanned all the zones at this priority level, note
> > -    * that level within the zone so that the next thread which performs
> > -    * scanning of this zone will immediately start out at this priority
> > -    * level.  This affects only the decision whether or not to bring
> > -    * mapped pages onto the inactive list.
> > -    */
> > -   if (priority < 0)
> > -       priority = 0;
> > -   for (i = 0; zones[i] != NULL; i++) {
> > -       struct zone *zone = zones[i];
> > -
> > -       if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> > -           continue;
> > -
> > -       zone->prev_priority = priority;
> > -   }
> >     return ret;
> >  }
>
> (your mail client is replacing tabs with spaces)

Thank for your kindness.

> I think this is actually a bugfix.  The code you're removing doesn't do the
>
>         if (priority < zone->prev_priority)
>
> thing.
>

shrink_zones() in try_to_free_pages() already called
note_zone_scanning_priority().
So, it have done it.

> otoh with this change, the only thing which will cause prev_priority to
> increase (ie: lower priority) is kswapd, which seems odd.
>

So, There is not only kswapd but also direct page reclaim.

> So:
>
> a) this is a functional change and needs more thought and lots of runtime
>    testing.  I'll duck it for now.
>
> b) the prev_priority stuff is still screwed up.
>



-- 
Kinds regards,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
