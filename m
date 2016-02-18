Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2386B0005
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 00:02:17 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id c10so25084937pfc.2
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 21:02:17 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id uj7si6766305pab.111.2016.02.17.21.02.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 21:02:16 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id q63so24302897pfb.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 21:02:16 -0800 (PST)
Date: Thu, 18 Feb 2016 14:03:33 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC PATCH 3/3] mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160218050333.GC10776@swordfish>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20160218044156.GA10776@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160218044156.GA10776@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/18/16 13:41), Sergey Senozhatsky wrote:
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 0c9f117..d5252d1 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -73,12 +73,6 @@
>   */
>  #define ZS_ALIGN               8
>  
> -/*
> - * A single 'zspage' is composed of up ZS_MAX_PAGES_PER_ZSPAGE discontiguous
> - * 0-order (single) pages.
> - */
> -#define ZS_MAX_PAGES_PER_ZSPAGE        6
> -
>  #define ZS_HANDLE_SIZE (sizeof(unsigned long))
>  
>  /*
> @@ -149,6 +143,21 @@
>  #define ZS_SIZE_CLASS_DELTA    (PAGE_SIZE >> 8)
>  
>  /*
> + * We want to have at least this number of ->huge classes.
> + */
> +#define ZS_MIN_HUGE_CLASSES_NUM        32
> +/*
> + * A single 'zspage' is composed of up ZS_MAX_PAGES_PER_ZSPAGE discontiguous
> + * 0-order (single) pages.
> + *
> + * The smallest huge class will have CLASS_SIZE * SIZE_CLASS_DELTA of
> + * wasted space, calculate how many pages we need to fit a CLASS_SIZE
> + * object there and, thus, to save a additional zspage.
> + */
> +#define ZS_MAX_PAGES_PER_ZSPAGE        \
> +       (PAGE_SIZE / (ZS_MIN_HUGE_CLASSES_NUM * ZS_SIZE_CLASS_DELTA))
> +
> +/*
>   * We do not maintain any list for completely empty or full pages
>   */
>  enum fullness_group {

and the difference between ZS_MIN_HUGE_CLASSES_NUM 57 (BASE number of
->huge classes) and ZS_MIN_HUGE_CLASSES_NUM 32 is:

ZS_MIN_HUGE_CLASSES_NUM 57 (BASE)
1151078400 575501415 621494272        0 621494272       17        0        1
1151074304 575499905 621477888        0 621477888       17        0        1
1151074304 575516318 621363200        0 621363200       17        0        1
1151078400 575558182 621346816        0 621346816       17        0        1
1151078400 575599320 621531136        0 621531136       17        0        1

ZS_MIN_HUGE_CLASSES_NUM 32
1151074304 575483112 594194432        0 594194432       17        0        1
1151074304 575521895 593678336        0 593678336       17        0        1
1151074304 575570453 594173952        0 594173952       17        0        1
1151074304 575461842 594010112        0 594010112       17        0        1
1151074304 575537116 593879040        0 593879040       17        0        1


around 26MB of order-0 pages.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
