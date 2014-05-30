Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id DC7956B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 10:23:19 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id lc6so2155920vcb.30
        for <linux-mm@kvack.org>; Fri, 30 May 2014 07:23:19 -0700 (PDT)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id zw17si3164716veb.78.2014.05.30.07.23.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 May 2014 07:23:19 -0700 (PDT)
Received: by mail-vc0-f170.google.com with SMTP id la4so2149107vcb.15
        for <linux-mm@kvack.org>; Fri, 30 May 2014 07:23:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53883902.8020701@lge.com>
References: <1401260672-28339-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1401260672-28339-3-git-send-email-iamjoonsoo.kim@lge.com>
	<53883902.8020701@lge.com>
Date: Fri, 30 May 2014 23:23:18 +0900
Message-ID: <CAAmzW4Nyic0VC9W16ZbjsZtNGGBet4HBDomQfMi-OvMGMKv9iw@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] CMA: aggressively allocate the pages on cma
 reserved memory when not used
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2014-05-30 16:53 GMT+09:00 Gioh Kim <gioh.kim@lge.com>:
> Joonsoo,
>
> I'm attaching a patch for combination of __rmqueue and __rmqueue_cma.
> I didn't test fully but my board is turned on and working well if no frequent memory allocations.
>
> I'm sorry to send not-tested code.
> I just want to report this during your working hour ;-)
>
> I'm testing this this evening and reporting next week.
> Have a nice weekend!

Thanks Gioh. :)

> -------------------------------------- 8< -----------------------------------------
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7f97767..9ced736 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -964,7 +964,7 @@ static int fallbacks[MIGRATE_TYPES][4] = {
>         [MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_R
>  #ifdef CONFIG_CMA
>         [MIGRATE_MOVABLE]     = { MIGRATE_CMA,         MIGRATE_RECLAIMABLE, MIGRATE_U
> -       [MIGRATE_CMA]         = { MIGRATE_RESERVE }, /* Never used */
> +       [MIGRATE_CMA]         = { MIGRATE_MOVABLE,     MIGRATE_RECLAIMABLE, MIGRATE_U

I don't want to use __rmqueue_fallback() for CMA.
__rmqueue_fallback() takes big order page rather than small order page
in order to steal large amount of pages and continue to use them in
next allocation attempts.
We can use CMA pages on limited cases, so stealing some pages from
other migrate type
to CMA type isn't good idea to me.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
