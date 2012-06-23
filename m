Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 9D7CE6B028F
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 00:40:13 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id ECA833EE0AE
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:40:11 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 46E8445DE5A
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:40:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D4C645DE56
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:40:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 073D4E38001
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:40:11 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B6CAD1DB804B
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:40:10 +0900 (JST)
Message-ID: <4FE5482C.3010501@jp.fujitsu.com>
Date: Sat, 23 Jun 2012 13:38:04 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
References: <4FE169B1.7020600@kernel.org> <4FE16E80.9000306@gmail.com> <4FE18187.3050103@kernel.org> <4FE23069.5030702@gmail.com> <4FE26470.90401@kernel.org> <CAHGf_=pjoiHQ9vxXXe-GtbkYRzhxdDhu3pf6pwDsCe5pBQE8Nw@mail.gmail.com> <4FE27F15.8050102@kernel.org> <CAHGf_=pDw4axwG2tQ+B5hPks-sz2S5+G1Kk-=HSDmo=DSXOkEw@mail.gmail.com> <4FE2A937.6040701@kernel.org> <4FE2FCFB.4040808@jp.fujitsu.com> <4FE3C4E4.2050107@kernel.org> <4FE414A2.3000700@kernel.org>
In-Reply-To: <4FE414A2.3000700@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

(2012/06/22 15:45), Minchan Kim wrote:
> On 06/22/2012 10:05 AM, Minchan Kim wrote:
>
>> Second approach which is suggested by KOSAKI is what you mentioned.
>> But the concern about second approach is how to make sure matched count increase/decrease of nr_isolated_areas.
>> I mean how to make sure nr_isolated_areas would be zero when isolation is done.
>> Of course, we can investigate all of current caller and make sure they don't make mistake
>> now. But it's very error-prone if we consider future's user.
>> So we might need test_set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>
>
> It's an implementation about above approach.
>

I like this approach.


> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index bf3404e..3e9a9e1 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -474,6 +474,11 @@ struct zone {
>           * rarely used fields:
>           */
>          const char              *name;
> +       /*
> +        * the number of MIGRATE_ISOLATE pageblock
> +        * We need this for accurate free page counting.
> +        */
> +       atomic_t                nr_migrate_isolate;
>   } ____cacheline_internodealigned_in_smp;

Isn't this counter modified only under zone->lock ?


>
>   typedef enum {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2c29b1c..6cb1f9f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -219,6 +219,11 @@ EXPORT_SYMBOL(nr_online_nodes);
>
>   int page_group_by_mobility_disabled __read_mostly;
>
> +/*
> + * NOTE:
> + * Don't use set_pageblock_migratetype(page, MIGRATE_ISOLATE) direclty.
> + * Instead, use {un}set_pageblock_isolate.
> + */
>   void set_pageblock_migratetype(struct page *page, int migratetype)
>   {
>          if (unlikely(page_group_by_mobility_disabled))
> @@ -1622,6 +1627,28 @@ bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>                                          zone_page_state(z, NR_FREE_PAGES));
>   }

I'm glad if this function can be static...Hm. With easy grep, I think it can be...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
