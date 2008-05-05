Received: by rv-out-0708.google.com with SMTP id f25so751249rvb.26
        for <linux-mm@kvack.org>; Sun, 04 May 2008 22:21:15 -0700 (PDT)
Message-ID: <44c63dc40805042221s4eb347acu6e7d86310696825f@mail.gmail.com>
Date: Mon, 5 May 2008 14:21:15 +0900
From: "minchan Kim" <barrioskmc@gmail.com>
Subject: Re: [-mm][PATCH 4/5] core of reclaim throttle
In-Reply-To: <20080504221043.8F64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080504215819.8F5E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080504221043.8F64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>  @@ -120,6 +125,7 @@ struct scan_control {
>   int vm_swappiness = 60;
>   long vm_total_pages;   /* The total number of pages which the VM controls */
>
>  +#define MAX_RECLAIM_TASKS CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE
>   static LIST_HEAD(shrinker_list);
>   static DECLARE_RWSEM(shrinker_rwsem);
>
>  @@ -1187,7 +1193,46 @@ static int shrink_zone(int priority, str
>
>         unsigned long nr_inactive;
>         unsigned long nr_to_scan;
>         unsigned long nr_reclaimed = 0;
>  +       int ret = 0;
>  +       int throttle_on = 0;
>  +       unsigned long freed;
>  +       unsigned long threshold;
>
> +
>  +       /* avoid recursing wait_evnet */
>  +       if (current->flags & PF_RECLAIMING)
>  +               goto shrinking;
>  +
>  +       throttle_on = 1;
>  +       current->flags |= PF_RECLAIMING;
>  +       wait_event(zone->reclaim_throttle_waitq,
>  +                atomic_add_unless(&zone->nr_reclaimers, 1, MAX_RECLAIM_TASKS));
>  +
>  +       /* in some situation (e.g. hibernation), shrink processing shouldn't be
>  +          cut off even though large memory freeded.  */
>  +       if (!sc->may_cut_off)
>  +               goto shrinking;
>  +

where do you initialize may_cut_off ?
Current Implementation, may_cut_off is always "0" so always goto shrinking
-- 
Thanks,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
