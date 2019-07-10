Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5826C74A36
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:30:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BBC02087F
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:30:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UISwE8VL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BBC02087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA02C8E0088; Wed, 10 Jul 2019 14:30:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D507B8E0032; Wed, 10 Jul 2019 14:30:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C19DE8E0088; Wed, 10 Jul 2019 14:30:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7A18E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:30:02 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b188so1989980ywb.10
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 11:30:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=c+r8Si1/xsvr/kvF0Vd+C34ZR6g5MzaCPwwwwZS7UmU=;
        b=aICr9FaObUu6KHFXRo637jWzPI0zfI1OsofVsVGqjKFSfgtNTYxESJyK6hYYq7lf5M
         KrVWeRmF0ciW08B6XC/wLtUtOuNQLQlktr2IQq8Gk3RBSfWPevMXu6ArqnonzXLpdi0y
         RGan/bbBxojfe40BVn1nCiQddnzPXk6oojEWXOtGHEsUeWdymqZjrQGbY2CI4ddpO9Bj
         4lG/iA/6cID9QKD2YNaHYvvFCGUTDTx0Usic9CMsvCKR0zxHkFdI3lkW8qQ9fxebeWfO
         AviI9SAk2DT385EIMrtNCtENmpHcMaJwX0LX8sp9OlwCEdaVmGGXlSWmtP08o2aBK2cf
         wVHQ==
X-Gm-Message-State: APjAAAXVPVfYnyEbG2YeJ3uM6y3hJit3/itisy6KTAmmibLeMLjihBzE
	kJ1JYORHBgU7o1bru+1kyxX1B+2WRMqi3iL5RHfia9gRdiVBgkSHz0sqqaH++PecSZh3gwIDRUO
	3WO1CHRrp5GjVQceNOlFCwGCfDaCheJQdqvmgxLVyp/vdpvoSj8Jmzct32MsswgkmGw==
X-Received: by 2002:a25:8884:: with SMTP id d4mr18678868ybl.7.1562783402299;
        Wed, 10 Jul 2019 11:30:02 -0700 (PDT)
X-Received: by 2002:a25:8884:: with SMTP id d4mr18678821ybl.7.1562783401411;
        Wed, 10 Jul 2019 11:30:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562783401; cv=none;
        d=google.com; s=arc-20160816;
        b=OMERr819zNsucJeE5BvS0GK0yIqnXY1CtNTG94p5JPoanv/GX2Z5JJKnTb4j1lf8TA
         WjMKcpaTokRZ666n0AOOLRIebwTS9Yg4r5MYw8JRPhmaF4I4rjxLRECWR9DW4wajZYHQ
         gnaPvZzoI1p1ir7yKJzoL3ywSHnKK2a79YMYi4A58CtxPOyU7111s8AvyYePonk7q9C2
         UTvM+WYrTaUcQGoD8SOyKzljPRlSfPi3d78hUBZ/t2TTzTYlG0u0iG0V92VLJ+zNKtZS
         mnn+J6KkRRVEcVjpnq52BsKSbv/Q5nL9x96MokegXwIkgT3NctJBxBmp9YVeBkQj40mn
         V3hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=c+r8Si1/xsvr/kvF0Vd+C34ZR6g5MzaCPwwwwZS7UmU=;
        b=zhU41FQN6ZfZJ9VB2CBRM7Y/UG0xfg5z8tLVRGe7Kj9Bea4VwDcuKzVZ5RTnKGbdXj
         1W3P+Q6hy7HRfIUbh09e55SYxEyWZFcuKkpV0GkrYuv90ASXYr47STUfZbjRHxVEJXk9
         ZBvCdw7Aq2UJnkMg7GhTUPpksUsrP3qddqqVCQE92tTBX09nHtpP0rHY8Vpbf+KJJm3p
         oAlMwy0VwDu8QtMzuef1B2v1bACtdBtFgG2ptzmcby/iZUlixF5NgHsEQMgFs2d+Dlyl
         eV6uc3GKp8ljFcbNj8DSMXvTjx4flKhWtCeTlBebBHPrie96RgTwT1a8i+KSKCFiUfaq
         u+tg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UISwE8VL;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y79sor1598789ywy.122.2019.07.10.11.30.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 11:30:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UISwE8VL;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=c+r8Si1/xsvr/kvF0Vd+C34ZR6g5MzaCPwwwwZS7UmU=;
        b=UISwE8VLrQE18tscTLVjTu4xfQSpU+Ngw5t+WgzRdUNsnTYWOTuDHJaO1Mm174HOa9
         V0Qn2OG/+VKb1yZFCBYg/97ApKmCSfsi/WJ5YbGYHfUmnNpA7FsqsWKWHhgk46kpSZyR
         z5ih3MsJI4tZMGw0ibr6s4wsJinWrM18EKhFy828Djih7f+bt4AT688Z2WSbFlL6zyyY
         Y0AaAjiPi9jCN7pzE0TY7PFp3yErbKtBJZUzXBGUjNNMrhgXOwwm15vMwGdqiJyLrOTI
         D8rQBbTzdD3rJbrXWCVcAhWtQttOyLd3f3mL99dqYokEW5oJqLDAomLG+PYTDXkMMOj0
         TPNw==
X-Google-Smtp-Source: APXvYqzXmDnInD7oBIfKeMDVYoRiXgQhXnLoOXS9ddftPuk/y94pUc7FWGWjBNflVWsCOllIvgXB6WbFdmk0hPRfkW0=
X-Received: by 2002:a81:ae0e:: with SMTP id m14mr20723285ywh.308.1562783400564;
 Wed, 10 Jul 2019 11:30:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190605100630.13293-1-teawaterz@linux.alibaba.com> <20190605100630.13293-2-teawaterz@linux.alibaba.com>
In-Reply-To: <20190605100630.13293-2-teawaterz@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 10 Jul 2019 11:29:49 -0700
Message-ID: <CALvZod41ywjh56T1E1cPJcuYDCydvpnqq3AhyJVny655Tj7jjQ@mail.gmail.com>
Subject: Re: [PATCH V3 2/2] zswap: Use movable memory if zpool support
 allocate movable memory
To: Hui Zhu <teawaterz@linux.alibaba.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, ngupta@vflare.org, 
	sergey.senozhatsky.work@gmail.com, Seth Jennings <sjenning@redhat.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Cc: akpm@linux-foundation.org

The email starts at

http://lkml.kernel.org/r/20190605100630.13293-2-teawaterz@linux.alibaba.com

On Wed, Jun 5, 2019 at 3:06 AM Hui Zhu <teawaterz@linux.alibaba.com> wrote:
>
> This is the third version that was updated according to the comments
> from Sergey Senozhatsky https://lkml.org/lkml/2019/5/29/73 and
> Shakeel Butt https://lkml.org/lkml/2019/6/4/973
>
> zswap compresses swap pages into a dynamically allocated RAM-based
> memory pool.  The memory pool should be zbud, z3fold or zsmalloc.
> All of them will allocate unmovable pages.  It will increase the
> number of unmovable page blocks that will bad for anti-fragment.
>
> zsmalloc support page migration if request movable page:
>         handle = zs_malloc(zram->mem_pool, comp_len,
>                 GFP_NOIO | __GFP_HIGHMEM |
>                 __GFP_MOVABLE);
>
> And commit "zpool: Add malloc_support_movable to zpool_driver" add
> zpool_malloc_support_movable check malloc_support_movable to make
> sure if a zpool support allocate movable memory.
>
> This commit let zswap allocate block with gfp
> __GFP_HIGHMEM | __GFP_MOVABLE if zpool support allocate movable memory.
>
> Following part is test log in a pc that has 8G memory and 2G swap.
>
> Without this commit:
> ~# echo lz4 > /sys/module/zswap/parameters/compressor
> ~# echo zsmalloc > /sys/module/zswap/parameters/zpool
> ~# echo 1 > /sys/module/zswap/parameters/enabled
> ~# swapon /swapfile
> ~# cd /home/teawater/kernel/vm-scalability/
> /home/teawater/kernel/vm-scalability# export unit_size=$((9 * 1024 * 1024 * 1024))
> /home/teawater/kernel/vm-scalability# ./case-anon-w-seq
> 2717908992 bytes / 4826062 usecs = 549973 KB/s
> 2717908992 bytes / 4864201 usecs = 545661 KB/s
> 2717908992 bytes / 4867015 usecs = 545346 KB/s
> 2717908992 bytes / 4915485 usecs = 539968 KB/s
> 397853 usecs to free memory
> 357820 usecs to free memory
> 421333 usecs to free memory
> 420454 usecs to free memory
> /home/teawater/kernel/vm-scalability# cat /proc/pagetypeinfo
> Page block order: 9
> Pages per block:  512
>
> Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
> Node    0, zone      DMA, type    Unmovable      1      1      1      0      2      1      1      0      1      0      0
> Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      1      3
> Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone      DMA, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone      DMA, type          CMA      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone    DMA32, type    Unmovable      6      5      8      6      6      5      4      1      1      1      0
> Node    0, zone    DMA32, type      Movable     25     20     20     19     22     15     14     11     11      5    767
> Node    0, zone    DMA32, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone    DMA32, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone    DMA32, type          CMA      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type    Unmovable   4753   5588   5159   4613   3712   2520   1448    594    188     11      0
> Node    0, zone   Normal, type      Movable     16      3    457   2648   2143   1435    860    459    223    224    296
> Node    0, zone   Normal, type  Reclaimable      0      0     44     38     11      2      0      0      0      0      0
> Node    0, zone   Normal, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
>
> Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic          CMA      Isolate
> Node 0, zone      DMA            1            7            0            0            0            0
> Node 0, zone    DMA32            4         1652            0            0            0            0
> Node 0, zone   Normal          931         1485           15            0            0            0
>
> With this commit:
> ~# echo lz4 > /sys/module/zswap/parameters/compressor
> ~# echo zsmalloc > /sys/module/zswap/parameters/zpool
> ~# echo 1 > /sys/module/zswap/parameters/enabled
> ~# swapon /swapfile
> ~# cd /home/teawater/kernel/vm-scalability/
> /home/teawater/kernel/vm-scalability# export unit_size=$((9 * 1024 * 1024 * 1024))
> /home/teawater/kernel/vm-scalability# ./case-anon-w-seq
> 2717908992 bytes / 4689240 usecs = 566020 KB/s
> 2717908992 bytes / 4760605 usecs = 557535 KB/s
> 2717908992 bytes / 4803621 usecs = 552543 KB/s
> 2717908992 bytes / 5069828 usecs = 523530 KB/s
> 431546 usecs to free memory
> 383397 usecs to free memory
> 456454 usecs to free memory
> 224487 usecs to free memory
> /home/teawater/kernel/vm-scalability# cat /proc/pagetypeinfo
> Page block order: 9
> Pages per block:  512
>
> Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
> Node    0, zone      DMA, type    Unmovable      1      1      1      0      2      1      1      0      1      0      0
> Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      1      3
> Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone      DMA, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone      DMA, type          CMA      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone    DMA32, type    Unmovable     10      8     10      9     10      4      3      2      3      0      0
> Node    0, zone    DMA32, type      Movable     18     12     14     16     16     11      9      5      5      6    775
> Node    0, zone    DMA32, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      1
> Node    0, zone    DMA32, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone    DMA32, type          CMA      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type    Unmovable   2669   1236    452    118     37     14      4      1      2      3      0
> Node    0, zone   Normal, type      Movable   3850   6086   5274   4327   3510   2494   1520    934    438    220    470
> Node    0, zone   Normal, type  Reclaimable     56     93    155    124     47     31     17      7      3      0      0
> Node    0, zone   Normal, type   HighAtomic      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
>
> Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic          CMA      Isolate
> Node 0, zone      DMA            1            7            0            0            0            0
> Node 0, zone    DMA32            4         1650            2            0            0            0
> Node 0, zone   Normal           79         2326           26            0            0            0
>
> You can see that the number of unmovable page blocks is decreased
> when the kernel has this commit.
>
> Signed-off-by: Hui Zhu <teawaterz@linux.alibaba.com>
> ---
>  mm/zswap.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index a4e4d36ec085..c6bf92bf5890 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -1006,6 +1006,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>         char *buf;
>         u8 *src, *dst;
>         struct zswap_header zhdr = { .swpentry = swp_entry(type, offset) };
> +       gfp_t gfp;
>
>         /* THP isn't supported */
>         if (PageTransHuge(page)) {
> @@ -1079,9 +1080,10 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>
>         /* store */
>         hlen = zpool_evictable(entry->pool->zpool) ? sizeof(zhdr) : 0;
> -       ret = zpool_malloc(entry->pool->zpool, hlen + dlen,
> -                          __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM,
> -                          &handle);
> +       gfp = __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM;
> +       if (zpool_malloc_support_movable(entry->pool->zpool))
> +               gfp |= __GFP_HIGHMEM | __GFP_MOVABLE;
> +       ret = zpool_malloc(entry->pool->zpool, hlen + dlen, gfp, &handle);
>         if (ret == -ENOSPC) {
>                 zswap_reject_compress_poor++;
>                 goto put_dstmem;
> --
> 2.21.0 (Apple Git-120)
>

