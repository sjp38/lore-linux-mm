Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C5AE16B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 20:34:35 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id q63so83430561pfb.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 17:34:35 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n21si35914102pfi.104.2016.02.21.17.34.34
        for <linux-mm@kvack.org>;
        Sun, 21 Feb 2016 17:34:35 -0800 (PST)
Date: Mon, 22 Feb 2016 10:34:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v2 3/3] mm/zsmalloc: increase ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160222013442.GB27829@bbox>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222002515.GB21710@bbox>
 <20160222004758.GB4958@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160222004758.GB4958@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 22, 2016 at 09:47:58AM +0900, Sergey Senozhatsky wrote:
> On (02/22/16 09:25), Minchan Kim wrote:
> [..]
> > I tempted it several times with same reason you pointed out.
> > But my worry was that if we increase ZS_MAX_ZSPAGE_ORDER, zram can
> > consume more memory because we need several pages chain to populate
> > just a object. Even, at that time, we didn't have compaction scheme
> > so fragmentation of object in zspage is huge pain to waste memory.
> 
> well, the thing is -- we end up requesting less pages after all, so
> zsmalloc has better chances to survive. for example, gcc5 compilation test

Indeed. I saw your test result.

> 
> BASE
> 
>    168  2720           0            1        115833     115831      77222                2
>    190  3072           0            1        109708     109707      82281                3
>    202  3264           0            5          1910       1895       1528                4
>    254  4096           0            0        380174     380174     380174                1
> 
>  Total                44          285       1621495    1618234     891703
> 
> 
> PATCHED
> 
>    192  3104           1            0          3740       3737       2860               13
>    194  3136           0            1          7215       7208       5550               10
>    197  3184           1            0         11151      11150       8673                7
>    199  3216           0            1          9310       9304       7315               11
>    200  3232           0            1          4731       4717       3735               15
>    202  3264           0            1          8400       8396       6720                4
>    206  3328           0            1         22064      22051      17927               13
>    207  3344           0            1          4884       4877       3996                9
>    208  3360           0            1          4420       4415       3640               14
>    211  3408           0            1         11250      11246       9375                5
>    212  3424           1            0          3344       3343       2816               16
>    214  3456           0            2          7345       7329       6215               11
>    217  3504           0            1         10801      10797       9258                6
>    219  3536           0            1          5295       5289       4589               13
>    222  3584           0            0          6008       6008       5257                7
>    223  3600           0            1          1530       1518       1350               15
>    225  3632           0            1          3519       3514       3128                8
>    228  3680           0            1          3990       3985       3591                9
>    230  3712           0            2          2167       2151       1970               10
>    232  3744           1            2          1848       1835       1694               11
>    234  3776           0            2          1404       1384       1296               12
>    235  3792           0            2           672        654        624               13
>    236  3808           1            2           615        592        574               14
>    238  3840           1            2          1120       1098       1050               15
>    254  4096           0            0        241824     241824     241824                1
> 
>  Total               129          489       1627756    1618193     850147
> 
> 
> that's  891703 - 850147 = 41556 less pages. or 162MB less memory used.
> 41556 less pages means that zsmalloc had 41556 less chances to fail.


Let's think swap-case which is more important for zram now. As you know,
most of usecase are swap in embedded world.
Do we really need 16 pages allocator for just less PAGE_SIZE objet
at the moment which is really heavy memory pressure?

> 
> 
> > Now, we have compaction facility so fragment of object might not
> > be a severe problem but still painful to allocate 16 pages to store
> > 3408 byte. So, if we want to increase ZS_MAX_ZSPAGE_ORDER,
> > first of all, we should prepare dynamic creating of sub-page of
> > zspage, I think and more smart compaction to minimize wasted memory.
> 
> well, I agree, but given that we allocate less pages, do we really want to
> introduce this complexity at this point?

I agree with you. Before dynamic subpage chaining feature, we need
lots of testing in heavy memory pressure with zram-swap.
However, I think the feature itself is good to have in the future. :)




> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
