Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA6186B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 00:26:17 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 201so262591102pfw.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 21:26:17 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 74si22201510pga.139.2017.01.24.21.26.16
        for <linux-mm@kvack.org>;
        Tue, 24 Jan 2017 21:26:17 -0800 (PST)
Date: Wed, 25 Jan 2017 14:26:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
Message-ID: <20170125052614.GB18289@bbox>
References: <CGME20170119001317epcas1p188357c77e1f4ff08b6d3dcb76dedca06@epcas1p1.samsung.com>
 <afd38699-f1c4-f63f-7362-29c514e9ffb4@samsung.com>
 <20170119024421.GA9367@bbox>
 <0a184bbf-0612-5f71-df68-c37500fa1eda@samsung.com>
 <20170119062158.GB9367@bbox>
 <e0e1fcae-d2c4-9068-afa0-b838d57d8dff@samsung.com>
 <20170123052244.GC11763@bbox>
 <20170123053056.GB2327@jagdpanzerIV.localdomain>
 <20170123054034.GA12327@bbox>
 <7488422b-98d1-1198-70d5-47c1e2bac721@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7488422b-98d1-1198-70d5-47c1e2bac721@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chulmin Kim <cmlaika.kim@samsung.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, Jan 24, 2017 at 11:06:51PM -0500, Chulmin Kim wrote:
> On 01/23/2017 12:40 AM, Minchan Kim wrote:
> >On Mon, Jan 23, 2017 at 02:30:56PM +0900, Sergey Senozhatsky wrote:
> >>On (01/23/17 14:22), Minchan Kim wrote:
> >>[..]
> >>>>Anyway, I will let you know the situation when it gets more clear.
> >>>
> >>>Yeb, Thanks.
> >>>
> >>>Perhaps, did you tried flush page before the writing?
> >>>I think arm64 have no d-cache alising problem but worth to try it.
> >>>Who knows :)
> >>
> >>I thought that flush_dcache_page() is only for cases when we write
> >>to page (store that makes pages dirty), isn't it?
> >
> >I think we need both because to see recent stores done by the user.
> >I'm not sure it should be done by block device driver rather than
> >page cache. Anyway, brd added it so worth to try it, I thought. :)
> >
> 
> Thanks for the suggestion!
> It might be helpful
> though proving it is not easy as the problem appears rarely.
> 
> Have you thought about
> zram swap or zswap dealing with self modifying code pages (ex. JIT)?
> (arm64 may have i-cache aliasing problem)

It can happen, I think, although I don't know how arm64 handles it.

> 
> If it is problematic,
> especiallly zswap (without flush_dcache_page in zswap_frontswap_load()) may
> provide the corrupted data
> and even swap out (compressing) may see the corrupted data sooner or later,
> i guess.

try_to_unmap_one calls flush_cache_page which I hope to handle swap-out side
but for swap-in, I think zswap need flushing logic because it's first
touch of the user buffer so it's his resposibility.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
