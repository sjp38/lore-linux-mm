Received: by nz-out-0506.google.com with SMTP id i11so869195nzh.26
        for <linux-mm@kvack.org>; Fri, 18 Jan 2008 02:24:28 -0800 (PST)
Message-ID: <cfd9edbf0801180224r3ddf1940h4245e2feff488486@mail.gmail.com>
Date: Fri, 18 Jan 2008 11:24:27 +0100
From: "=?ISO-8859-1?Q?Daniel_Sp=E5ng?=" <daniel.spang@gmail.com>
Subject: Re: [RFC][PATCH 4/5] memory_pressure_notify() caller
In-Reply-To: <20080117120112.11CE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080116104536.11AE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <cfd9edbf0801160303s53237b81yb9d5e374c16cd006@mail.gmail.com>
	 <20080117120112.11CE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 1/17/08, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi Daniel
>
> > > Thank you for good point out!
> > > Could you please post your test program and reproduced method?
> >
> > Sure:
> >
> > 1. Fill almost all available memory with page cache in a system without swap.
> > 2. Run attached alloc-test program.
> > 3. Notification fires when page cache is reclaimed.
>
> Unfortunately, I can't reproduce it.
>
> my machine
>         CPU:    Pentium4 2.8GHz with HT
>         memory: 512M
>
>
> 1. I doubt ZONE_DMA, please shipment ignore zone_dma patch(below).
> 2. Could you please send your .config and /etc/sysctl.conf?
>    I hope more reproduce challenge.
>
> thanks.
>
> - kosaki
>
>
>
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> ---
>  include/linux/mem_notify.h |    3 +++
>  mm/page_alloc.c            |    6 +++++-
>  2 files changed, 8 insertions(+), 1 deletion(-)
>
> Index: linux-2.6.24-rc6-mm1-memnotify/include/linux/mem_notify.h
> ===================================================================
> --- linux-2.6.24-rc6-mm1-memnotify.orig/include/linux/mem_notify.h
>  2008-01-16 21:31:09.000000000 +0900
> +++ linux-2.6.24-rc6-mm1-memnotify/include/linux/mem_notify.h
> 2008-01-16 21:34:24.000000000 +0900
> @@ -22,6 +22,9 @@ static inline void memory_pressure_notif
>         unsigned long target;
>         unsigned long pages_high, pages_free, pages_reserve;
>
> +       if (unlikely(zone->mem_notify_status == -1))
> +               return;
> +
>         if (pressure) {
>                 target = atomic_long_read(&last_mem_notify) + MEM_NOTIFY_FREQ;
>                 if (likely(time_before(jiffies, target)))
> Index: linux-2.6.24-rc6-mm1-memnotify/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.24-rc6-mm1-memnotify.orig/mm/page_alloc.c 2008-01-13
> 19:50:27.000000000 +0900
> +++ linux-2.6.24-rc6-mm1-memnotify/mm/page_alloc.c      2008-01-16
> 21:41:58.000000000 +0900
> @@ -3467,7 +3467,11 @@ static void __meminit free_area_init_cor
>                 zone->zone_pgdat = pgdat;
>
>                 zone->prev_priority = DEF_PRIORITY;
> -               zone->mem_notify_status = 0;
> +
> +               if (zone->present_pages < (pgdat->node_present_pages / 10))
> +                       zone->mem_notify_status = -1;
> +               else
> +                       zone->mem_notify_status = 0;
>
>                 zone_pcp_init(zone);
>                 INIT_LIST_HEAD(&zone->active_list);

Your patch above solves the problem I had with early notification.

Cheers,
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
