Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f177.google.com (mail-yw0-f177.google.com [209.85.161.177])
	by kanga.kvack.org (Postfix) with ESMTP id 99B8A6B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 01:10:11 -0500 (EST)
Received: by mail-yw0-f177.google.com with SMTP id b72so7596476ywe.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 22:10:11 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id k4si12966652ybb.97.2016.03.02.22.10.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 22:10:10 -0800 (PST)
Subject: Re: kswapd consumes 100% CPU when highest zone is small
References: <CAKQB+ft3q2O2xYG2CTmTM9OCRLCP2FPTfHQ3jvcFSM-FGrjgGA@mail.gmail.com>
 <56D6F6D7.50103@foxmail.com>
 <CAKQB+fso7XvRXrPdpD9L18pq0sVy7BbM1d5cZQMJ77wT-v-1PQ@mail.gmail.com>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <56D7D2D2.6030709@hisilicon.com>
Date: Thu, 3 Mar 2016 13:59:46 +0800
MIME-Version: 1.0
In-Reply-To: <CAKQB+fso7XvRXrPdpD9L18pq0sVy7BbM1d5cZQMJ77wT-v-1PQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerry Lee <leisurelysw24@gmail.com>, chen feng <puck.chen@foxmail.com>
Cc: linux-mm@kvack.org, puck.chen@huawei.com



On 2016/3/3 9:56, Jerry Lee wrote:
> Hi,
> 
> Thanks for sharing the same experience and workaround with me.
> But it's kind of hard for me to set all the possible processes to no-kswapd flag
> in advance so that they would not trigger kswapd in the future.
> 
> Cheers,
> - Jerry
> 
> On 2 March 2016 at 22:21, chen feng <puck.chen@foxmail.com <mailto:puck.chen@foxmail.com>> wrote:
> 
> 
> 
>     On 2016/3/2 14:20, Jerry Lee wrote:
>     > Hi,
>     >
>     > I have a x86_64 system with 2G RAM using linux-3.12.x.  During copying
>     > large
>     > files (e.g. 100GB), kswapd easily consumes 100% CPU until the file is
>     > deleted
>     > or the page cache is dropped.  With setting the min_free_kbytes from 16384
>     > to
>     > 65536, the symptom is mitigated but I can't totally get rid of the problem.
>     >
>     > After some trial and error, I found that highest zone is always unbalanced
>     > with
>     > order-0 page request so that pgdat_blanaced() continuously return false and
>     > kswapd can't sleep.
>     >
>     > Here's the watermarks (min_free_kbytes = 65536) in my system:
>     > Node 0, zone      DMA
>     >   pages free     2167
>     >         min      138
>     >         low      172
>     >         high     207
>     >         scanned  0
>     >         spanned  4095
>     >         present  3996
>     >         managed  3974
>     >
>     > Node 0, zone    DMA32
>     >   pages free     215375
>     >         min      16226
>     >         low      20282
>     >         high     24339
>     >         scanned  0
>     >         spanned  1044480
>     >         present  490971
>     >         managed  464223
>     >
>     > Node 0, zone   Normal
>     >   pages free     7
>     >         min      18
>     >         low      22
>     >         high     27
>     >         scanned  0
>     >         spanned  1536
>     >         present  1536
>     >         managed  523
>     >
>     > Besides, when the kswapd crazily spins, the value of the following entries
>     > in vmstat increases quickly even when I stop copying file:
>     >
>     > pgalloc_dma 17719
>     > pgalloc_dma32 3262823
>     > slabs_scanned 937728
>     > kswapd_high_wmark_hit_quickly 54333233
>     > pageoutrun 54333235
>     >
>     > Is there anything I could do to totally get rid of the problem?
>     > \
>     Yes, I have the same issue on arm64 platform.
> 
>     I think you can increase the normal ZONE size. And I think there will be a memory alloc process
>     in your system which tigger the kswapd too frequently.
> 
>     You can set this process to no-kswapd flag will also solve this issue.
>     > Thanks
>     >

Just hack the process who tigger it too frequenctly.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
