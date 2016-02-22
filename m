Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7BDB46B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 21:23:07 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ho8so84797614pac.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 18:23:07 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id f77si36194134pfd.94.2016.02.21.18.23.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 18:23:06 -0800 (PST)
Received: by mail-pf0-x236.google.com with SMTP id c10so86826060pfc.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 18:23:06 -0800 (PST)
Date: Mon, 22 Feb 2016 11:24:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v2 3/3] mm/zsmalloc: increase ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160222022424.GA11961@swordfish>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222002515.GB21710@bbox>
 <20160222004758.GB4958@swordfish>
 <20160222013442.GB27829@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160222013442.GB27829@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (02/22/16 10:34), Minchan Kim wrote:
[..]
> > 
> > that's  891703 - 850147 = 41556 less pages. or 162MB less memory used.
> > 41556 less pages means that zsmalloc had 41556 less chances to fail.
> 
> 
> Let's think swap-case which is more important for zram now. As you know,
> most of usecase are swap in embedded world.

> Do we really need 16 pages allocator for just less PAGE_SIZE objet
> at the moment which is really heavy memory pressure?

well, it's not about having less PAGE_SIZE sized objects, it's about
allocating less pages in the first place; and to achieve this we need
less PAGE_SIZE sized objects.

in the existing scheme of things (current implementation) allocating
up to 16 pages to end up using less pages looks quite ok.

and not all of the huge classes request 16 pages to become a 'normal' class:

   191  3088           1            0          3588       3586       2760               10
   192  3104           1            0          3740       3737       2860               13
   194  3136           0            1          7215       7208       5550               10
   197  3184           1            0         11151      11150       8673                7
   199  3216           0            1          9310       9304       7315               11
   200  3232           0            1          4731       4717       3735               15
   202  3264           0            1          8400       8396       6720                4
   206  3328           0            1         22064      22051      17927               13
   207  3344           0            1          4884       4877       3996                9
   208  3360           0            1          4420       4415       3640               14
   211  3408           0            1         11250      11246       9375                5
   212  3424           1            0          3344       3343       2816               16
   214  3456           0            2          7345       7329       6215               11
   217  3504           0            1         10801      10797       9258                6
   219  3536           0            1          5295       5289       4589               13
   222  3584           0            0          6008       6008       5257                7
   223  3600           0            1          1530       1518       1350               15
   225  3632           0            1          3519       3514       3128                8
   228  3680           0            1          3990       3985       3591                9
   230  3712           0            2          2167       2151       1970               10
   232  3744           1            2          1848       1835       1694               11
   234  3776           0            2          1404       1384       1296               12
   235  3792           0            2           672        654        624               13
   236  3808           1            2           615        592        574               14
   238  3840           1            2          1120       1098       1050               15
   254  4096           0            0        241824     241824     241824                1



hm.... I just thought about it. do we have a big enough computation
error in static int get_pages_per_zspage(int class_size)

 777                 zspage_size = i * PAGE_SIZE;
 778                 waste = zspage_size % class_size;
 779                 usedpc = (zspage_size - waste) * 100 / zspage_size;
 780
 781                 if (usedpc > max_usedpc) {
 782                         max_usedpc = usedpc;
 783                         max_usedpc_order = i;
 784                 }


to begin `misconfiguring' the classes? we cast `usedpc' to int, so we can miss
the difference between 90% and 90.95% for example... hm, need to check it later.



so, yes, dynamic page allocation sounds interesting. but should it be part of
this patch set or we can introduce it later (I think we can do it later)?


a good testing for now would be really valuable, hopefully you guys can help
me here. depending on those tests we will have a better road map, I think.
the test I've done (and will do more) demonstrate that we save pages.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
