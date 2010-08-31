Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 532BA6B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 22:09:26 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7V29NNt004981
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 31 Aug 2010 11:09:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DB83345DE50
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 11:09:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B9CB245DE51
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 11:09:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A30C41DB8014
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 11:09:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 63B331DB8015
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 11:09:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
In-Reply-To: <AANLkTinhVnMW8f7+jQdDyEzD=O2YPLSyTuGRE2JnRVzm@mail.gmail.com>
References: <20100831102557.87D3.A69D9226@jp.fujitsu.com> <AANLkTinhVnMW8f7+jQdDyEzD=O2YPLSyTuGRE2JnRVzm@mail.gmail.com>
Message-Id: <20100831110815.87D9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 31 Aug 2010 11:09:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> How about this?
> 
> (Not formal patch. If we agree, I will post it later when I have a SMTP).
> 
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3109ff7..c3c44a8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1579,7 +1579,7 @@ static void shrink_active_list(unsigned long
> nr_pages, struct zone *zone,
>         __mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
>         spin_unlock_irq(&zone->lru_lock);
>  }
> -
> +#if CONFIG_SWAP
>  static int inactive_anon_is_low_global(struct zone *zone)
>  {
>         unsigned long active, inactive;
> @@ -1605,12 +1605,21 @@ static int inactive_anon_is_low(struct zone
> *zone, struct scan_control *sc)
>  {
>         int low;
> 
> +       if (nr_swap_pages)
> +               return 0;

!nr_swap_pages ?



> +
>         if (scanning_global_lru(sc))
>                 low = inactive_anon_is_low_global(zone);
>         else
>                 low = mem_cgroup_inactive_anon_is_low(sc->mem_cgroup);
>         return low;
>  }
> +#else
> +static inline int inactive_anon_is_low(struct zone *zone, struct
> scan_control *sc)
> +{
> +       return 0;
> +}
> +#endif

Yup. I prefer this explicit #ifdef :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
