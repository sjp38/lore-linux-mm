Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35810C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 19:53:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3ADA206C3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 19:53:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aDihaTMg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3ADA206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FEBA6B0266; Wed,  5 Jun 2019 15:53:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B00B6B0269; Wed,  5 Jun 2019 15:53:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C5716B026A; Wed,  5 Jun 2019 15:53:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4BAF86B0266
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 15:53:18 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id t128so2299374ywd.15
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 12:53:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=pq+ABjtf9saoF6dUdDDxsada/8divT9WxU6TICP/hS0=;
        b=QE+QZwfkY7J/y7QCqr78wuBHq3Cpy8j0KwR5bt07yb1cUWpjNYP8apjLBJ/jIKPbdg
         SN1Q56MSX/OmFRFUkmTVwHV4x5jzIZAMHxx28aGyIS6gKtz5owJsrIygN6Pz9VS8ALvn
         JonpOcpPYC99NM2iL2SYUhgQ8gPWxioaewT/G1DHhOLY+F4i0F+e4xSCHiaYJhlBIlRz
         WGL9CjdDpu62Wr1MVOWzc970h0Pl7FYGq/Po0JQQ6rrpHJa7A9xGGevtbzLTmyLkmSU6
         oMqM8+vQugCIe0/LPlqJ4kDNeSRmN78W3DuZdx8DbPF/3VM6cU/RA3+4fDfjR9Ji3fHG
         TWyg==
X-Gm-Message-State: APjAAAURmfs2FvX6jMuWRFerZtwr5HUdnIu9vHh1z5hLU+asgGqW3ICa
	9ngrivEauoK2y6NEJHerhxj85MTO9+xZY4lQ0qMYGZUyWhyAhbRCm88VGPTst0SRMuPdFcZRwK/
	2HMbNgabDaQOnjFrsPozV/NeUk13iHJIYOiZIn1UyGLVfxEX+S5VYMx1D+uDivdf7Vw==
X-Received: by 2002:a81:1f56:: with SMTP id f83mr21391897ywf.444.1559764398039;
        Wed, 05 Jun 2019 12:53:18 -0700 (PDT)
X-Received: by 2002:a81:1f56:: with SMTP id f83mr21391853ywf.444.1559764396504;
        Wed, 05 Jun 2019 12:53:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559764396; cv=none;
        d=google.com; s=arc-20160816;
        b=a62l4zurWCmXRUuQqdYEt91Sj0sqOFJCRc9TcXEQkekfF0YZGwOnIVUJyAPI0yuhT6
         xJBFIHYpDrsfqnIF+Zuca84zowE4RF2oOaIDbYNNGOTByL/u60t0xMg8bWAk1cQWeCNb
         WiJ9g5Mdq2XQabJi7vilfkcZkLDllP9Kcqdwb8bl3znYetzHMaVm6dXfdQ2AEZrXNoH1
         hwpQcS9Kt1vByK6Rz26s+saqMJKt0unobvS9ibUx7om+VhCBCSfXQjrIxjyOmdOfj1s9
         dLr4HdGEZe/Cmwoz0s8twN1cXUFiA6wYjBFld8dird7ItJklGzLMG/9/JNMkkEShAKjH
         umyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=pq+ABjtf9saoF6dUdDDxsada/8divT9WxU6TICP/hS0=;
        b=VZQsRJdJx/7zkijaNuF6vINKpUH5x4qyjy/ZKTdoMVgAKEScGt0VYk6Q8Z43k54CYP
         FIvCEfG7lI410jbn4QsqBLzB48sYaHbxd5I66RRO6XkYrBFkdvE0pNP7fQ+rXKmo3Lzg
         zG6dF3fSjCmX3i6sjjn0YkqlfhP0o+fx5++JbffCubudtslSI8EEBbLACrrITJ9+4mrw
         XIj1bBfg22n1iyWt5wNBPhV0QC5CWJqllV9oomNRBPZFa3q6PAjCCgYpr5S3FyTy3hl1
         knnc3mDSnS7JPaIZxXsUBx+lq5Ir75Q6K16K1LCw1496xlhgBVrHFYPByyqNmHHKzN/t
         IoIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aDihaTMg;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m18sor5242540ywh.182.2019.06.05.12.53.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 12:53:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aDihaTMg;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pq+ABjtf9saoF6dUdDDxsada/8divT9WxU6TICP/hS0=;
        b=aDihaTMgou/t97G57d7rSXoCcTQDt7cJhZO/VzPbMeLi4sGgyQE/L+c/Xb2mFlIHNc
         KaML8q353hRhpyMrBy6fUDg55Gbs7i6N+EZcB6tOI30QgIX+8REuTUsVHEh/37+Lr+Ng
         jNb4ZdmEeXJqM9mhi2gQO2UwqZCUeQx7LvIWYvy9CteXIaZEtI+6ecTcJB/NmyXLcQe0
         SvWHAspDlFvaNOq04iKRcDFUKaib9HUW1PYlGomdLdDVMiBpKMV/VZMhOW9XL0fTWOt0
         lK290QFMMxxqOu5DnJfLakjc8YpLtXySQhJ9HWoKAbxNvNX5Hqh7LQbTqWFkyzTPFX2D
         VT0Q==
X-Google-Smtp-Source: APXvYqxIXoHj7TFv4XDBsjG+UUtDEa51VaOVh8r8ws5N3z+MR2V3qHzEtoVcLjgTR69Tnx8hRJ2yOcD2jp2DSjv95tU=
X-Received: by 2002:a81:5741:: with SMTP id l62mr21598650ywb.4.1559764395811;
 Wed, 05 Jun 2019 12:53:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190605100630.13293-1-teawaterz@linux.alibaba.com> <20190605100630.13293-2-teawaterz@linux.alibaba.com>
In-Reply-To: <20190605100630.13293-2-teawaterz@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 5 Jun 2019 12:53:04 -0700
Message-ID: <CALvZod62+jQjebNVmQHt=T8s7TFiRW-Zcw5kdUU23MZZqgaKYw@mail.gmail.com>
Subject: Re: [PATCH V3 2/2] zswap: Use movable memory if zpool support
 allocate movable memory
To: Hui Zhu <teawaterz@linux.alibaba.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, ngupta@vflare.org, 
	sergey.senozhatsky.work@gmail.com, Seth Jennings <sjenning@redhat.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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

Reviewed-by: Shakeel Butt <shakeelb@google.com>

