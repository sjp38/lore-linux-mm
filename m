Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 61A33828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 09:21:28 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id a9so12056097pat.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:21:28 -0800 (PST)
Received: from smtpbg302.qq.com (smtpbg302.qq.com. [184.105.206.27])
        by mx.google.com with ESMTPS id 65si58495954pfc.6.2016.03.02.06.21.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 06:21:27 -0800 (PST)
Subject: Re: kswapd consumes 100% CPU when highest zone is small
References: <CAKQB+ft3q2O2xYG2CTmTM9OCRLCP2FPTfHQ3jvcFSM-FGrjgGA@mail.gmail.com>
From: chen feng <puck.chen@foxmail.com>
Message-ID: <56D6F6D7.50103@foxmail.com>
Date: Wed, 2 Mar 2016 22:21:11 +0800
MIME-Version: 1.0
In-Reply-To: <CAKQB+ft3q2O2xYG2CTmTM9OCRLCP2FPTfHQ3jvcFSM-FGrjgGA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerry Lee <leisurelysw24@gmail.com>, linux-mm@kvack.org, puck.chen@huawei.com



On 2016/3/2 14:20, Jerry Lee wrote:
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
> \
Yes, I have the same issue on arm64 platform.

I think you can increase the normal ZONE size. And I think there will be a memory alloc process
in your system which tigger the kswapd too frequently.

You can set this process to no-kswapd flag will also solve this issue.
> Thanks
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
