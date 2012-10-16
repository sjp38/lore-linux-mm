Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 640146B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:47:04 -0400 (EDT)
Received: from mail-ee0-f41.google.com ([74.125.83.41])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TO7U7-0004fN-Bd
	for linux-mm@kvack.org; Tue, 16 Oct 2012 13:47:03 +0000
Received: by mail-ee0-f41.google.com with SMTP id c4so3930228eek.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 06:47:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121016130927.GA5603@barrios>
References: <1350278059-14904-1-git-send-email-ming.lei@canonical.com>
	<1350278059-14904-2-git-send-email-ming.lei@canonical.com>
	<20121015154724.GA2840@barrios>
	<CACVXFVM09H=8ZuFSzkcN1NmOCR1pcPUsuUyT9tpR0doVam2BiQ@mail.gmail.com>
	<20121016054946.GA3934@barrios>
	<CACVXFVOdohPprD7N69=Tz2keTbLG7b-s5324OUX-oY84Jszumg@mail.gmail.com>
	<20121016130927.GA5603@barrios>
Date: Tue, 16 Oct 2012 21:47:03 +0800
Message-ID: <CACVXFVMr=JMNHFe1GO=di99eB-6-=_pBkP3QH4x_qtKhdRZMFw@mail.gmail.com>
Subject: Re: [RFC PATCH 1/3] mm: teach mm by current context info to not do
 I/O during memory allocation
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Jiri Kosina <jiri.kosina@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>

On Tue, Oct 16, 2012 at 9:09 PM, Minchan Kim <minchan@kernel.org> wrote:
>
> Good point. You can check it in __zone_reclaim and change gfp_mask of scan_control
> because it's never hot path.
>
>>
>> So could you make sure it is safe to move the branch into
>> __alloc_pages_slowpath()?  If so, I will add the check into
>> gfp_to_alloc_flags().
>
> How about this?

It is quite smart change, :-)

Considered that other part(sched.h) of the patch need update, I
will merge your change into -v1 for further review with your
Signed-off-by if you have no objection.

>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d976957..b3607fa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2614,10 +2614,16 @@ retry_cpuset:
>         page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
>                         zonelist, high_zoneidx, alloc_flags,
>                         preferred_zone, migratetype);
> -       if (unlikely(!page))
> +       if (unlikely(!page)) {
> +               /*
> +                * Resume path can deadlock because block device
> +                * isn't active yet.
> +                */

Not only resume path, I/O transfer or its error handling path may deadlock too.

> +               if (unlikely(tsk_memalloc_no_io(current)))
> +                       gfp_mask &= ~GFP_IOFS;
>                 page = __alloc_pages_slowpath(gfp_mask, order,
>                                 zonelist, high_zoneidx, nodemask,
>                                 preferred_zone, migratetype);
> +       }
>
>         trace_mm_page_alloc(page, order, gfp_mask, migratetype);
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b5e45f4..6c2ccdd 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3290,6 +3290,16 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>         };
>         unsigned long nr_slab_pages0, nr_slab_pages1;
>
> +       if (unlikely(tsk_memalloc_no_io(current))) {
> +               sc.gfp_mask &= ~GFP_IOFS;
> +               shrink.gfp_mask = sc.gfp_mask;
> +               /*
> +                * We allow to reclaim only clean pages.
> +                * It can affect RECLAIM_SWAP and RECLAIM_WRITE mode
> +                * but this is really rare event and allocator can
>                  * fallback to other zones.
> +                */
> +               sc.may_writepage = 0;
> +               sc.may_swap = 0;
> +       }
> +
>         cond_resched();
>         /*
>          * We need to be able to allocate from the reserves for RECLAIM_SWAP
>

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
