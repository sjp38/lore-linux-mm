Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0E48D6B0009
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 12:36:43 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l68so90689662wml.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 09:36:43 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id g73si3693937wmg.53.2016.03.02.09.36.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 09:36:41 -0800 (PST)
Received: by mail-wm0-f46.google.com with SMTP id p65so88115567wmp.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 09:36:41 -0800 (PST)
Date: Wed, 2 Mar 2016 18:36:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: kswapd consumes 100% CPU when highest zone is small
Message-ID: <20160302173639.GD26701@dhcp22.suse.cz>
References: <CAKQB+ft3q2O2xYG2CTmTM9OCRLCP2FPTfHQ3jvcFSM-FGrjgGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKQB+ft3q2O2xYG2CTmTM9OCRLCP2FPTfHQ3jvcFSM-FGrjgGA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerry Lee <leisurelysw24@gmail.com>
Cc: linux-mm@kvack.org

On Wed 02-03-16 14:20:38, Jerry Lee wrote:
> Hi,
> 
> I have a x86_64 system with 2G RAM using linux-3.12.x.  During copying
> large
> files (e.g. 100GB), kswapd easily consumes 100% CPU until the file is
> deleted
> or the page cache is dropped.  With setting the min_free_kbytes from 16384
> to
> 65536, the symptom is mitigated but I can't totally get rid of the problem.
> 
> After some trial and error, I found that highest zone is always unbalanced
> with
> order-0 page request so that pgdat_blanaced() continuously return false and
> kswapd can't sleep.
> 
> Here's the watermarks (min_free_kbytes = 65536) in my system:
> Node 0, zone      DMA
>   pages free     2167
>         min      138
>         low      172
>         high     207
>         scanned  0
>         spanned  4095
>         present  3996
>         managed  3974
> 
> Node 0, zone    DMA32
>   pages free     215375
>         min      16226
>         low      20282
>         high     24339
>         scanned  0
>         spanned  1044480
>         present  490971
>         managed  464223
> 
> Node 0, zone   Normal
>   pages free     7
>         min      18
>         low      22
>         high     27
>         scanned  0
>         spanned  1536
>         present  1536
>         managed  523

The zone Normal is just too small and that confuses the reclaim path.

> 
> Besides, when the kswapd crazily spins, the value of the following entries
> in vmstat increases quickly even when I stop copying file:
> 
> pgalloc_dma 17719
> pgalloc_dma32 3262823
> slabs_scanned 937728
> kswapd_high_wmark_hit_quickly 54333233
> pageoutrun 54333235
> 
> Is there anything I could do to totally get rid of the problem?

I would try to sacrifice those few megs and get rid of zone normal
completely. AFAIR mem=4G should limit the max_pfn to 4G so DMA32 should
cover the shole memory.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
