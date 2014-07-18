Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 389796B0036
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 03:50:38 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so4566534pdb.19
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 00:50:37 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id hr7si4968705pac.109.2014.07.18.00.50.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 18 Jul 2014 00:50:36 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8W00IWKDS1CN70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 18 Jul 2014 08:50:25 +0100 (BST)
Message-id: <53C8D1CA.9070102@samsung.com>
Date: Fri, 18 Jul 2014 09:50:34 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] CMA/HOTPLUG: clear buffer-head lru before page migration
References: <53C8C290.90503@lge.com>
In-reply-to: <53C8C290.90503@lge.com>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?J+q5gOykgOyImCc=?= <iamjoonsoo.kim@lge.com>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>

Hello,

On 2014-07-18 08:45, Gioh Kim wrote:
> For page migration of CMA, buffer-heads of lru should be dropped.
> Please refer to https://lkml.org/lkml/2014/7/4/101 for the history.
>
> I have two solution to drop bhs.
> One is invalidating entire lru.
> Another is searching the lru and dropping only one bh that Laura proposed
> at https://lkml.org/lkml/2012/8/31/313.
>
> I'm not sure which has better performance.
> So I did performance test on my cortex-a7 platform with Lmbench
> that has "File & VM system latencies" test.
> I am attaching the results.
> The first line is of invalidating entire lru and the second is dropping selected bh.
>
> File & VM system latencies in microseconds - smaller is better
> -------------------------------------------------------------------------------
> Host                 OS   0K File      10K File     Mmap    Prot   Page   100fd
>                          Create Delete Create Delete Latency Fault  Fault  selct
> --------- ------------- ------ ------ ------ ------ ------- ----- ------- -----
> 10.178.33 Linux 3.10.19   25.1   19.6   32.6   19.7  5098.0 0.666 3.45880 6.506
> 10.178.33 Linux 3.10.19   24.9   19.5   32.3   19.4  5059.0 0.563 3.46380 6.521
>
>
> I tried several times but the result tells that they are the same under 1% gap
> except Protection Fault.
> But the latency of Protection Fault is very small and I think it has little effect.
>
> Therefore we can choose anything but I choose invalidating entire lru.
> The try_to_free_buffers() which is calling drop_buffers() is called by many filesystem code.
> So I think inserting codes in drop_buffers() can affect the system.
> And also we cannot distinguish migration type in drop_buffers().
>
> In alloc_contig_range() we can distinguish migration type and invalidate lru if it needs.
> I think alloc_contig_range() is proper to deal with bh like following patch.
>
> Laura, can I have you name on Acked-by line?
> Please let me represent my thanks.
>
> Thanks for any feedback.
>
> ------------------------------- 8< ----------------------------------
>
> >From 33c894b1bab9bc26486716f0c62c452d3a04d35d Mon Sep 17 00:00:00 2001
> From: Gioh Kim <gioh.kim@lge.com>
> Date: Fri, 18 Jul 2014 13:40:01 +0900
> Subject: [PATCH] CMA/HOTPLUG: clear buffer-head lru before page migration
>
> The bh must be free to migrate a page at which bh is mapped.
> The reference count of bh is increased when it is installed
> into lru so that the bh of lru must be freed before migrating the page.
>
> This frees every bh of lru. We could free only bh of migrating page.
> But searching lru costs more than invalidating entire lru.
>
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> Acked-by: Laura Abbott <lauraa@codeaurora.org>
> ---
>   mm/page_alloc.c |    3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b99643d4..3b474e0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6369,6 +6369,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>          if (ret)
>                  return ret;
>
> +       if (migratetype == MIGRATE_CMA || migratetype == MIGRATE_MOVABLE)

I'm not sure if it really makes sense to check the migratetype here. 
This check
doesn't add any new information to the code and make false impression 
that this
function can be called for other migratetypes than CMA or MOVABLE. Even 
if so,
then invalidating bh_lrus unconditionally will make more sense, IMHO.

> +               invalidate_bh_lrus();
> +
>          ret = __alloc_contig_migrate_range(&cc, start, end);
>          if (ret)
>                  goto done;
> --
> 1.7.9.5
>

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
