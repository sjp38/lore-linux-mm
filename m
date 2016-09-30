Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6C96B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 04:43:27 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id k17so37117219ywe.3
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 01:43:27 -0700 (PDT)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id b12si3104474ywh.409.2016.09.30.01.43.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Sep 2016 01:43:26 -0700 (PDT)
Received: by mail-yw0-x241.google.com with SMTP id t204so3714052ywt.2
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 01:43:26 -0700 (PDT)
Date: Fri, 30 Sep 2016 10:43:23 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix potential memory leakage for
 pcpu_embed_first_chunk()
Message-ID: <20160930084323.GC29207@mtj.duckdns.org>
References: <d6742bae-1b32-10d8-1857-9993a2d06117@zoho.com>
 <20160929164422.GA3773@mtj.duckdns.org>
 <b88da9b0-0964-8b42-7054-81605fe7eb85@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b88da9b0-0964-8b42-7054-81605fe7eb85@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Fri, Sep 30, 2016 at 01:38:35AM +0800, zijun_hu wrote:
> 1) the simpler way don't work because it maybe free many memory block twice

Right, the punched holes.  Forgot about them.  Yeah, that's why the
later failure just leaks memory.

> 2) as we seen, pcpu_setup_first_chunk() doesn't cause a failure, it  return 0
>    always or panic by BUG_ON(), even if it fails, we can conclude the allocated
>    memory based on information recorded by it, such as pcpu_base_addr and many of
>    static variable, we can complete the free operations; but we can't if we
>    fail in the case pointed by this patch

So, being strictly correct doesn't matter that much here.  These
things failing indicates that something is very wrong with either the
code or configuration and we might as well trigger BUG.  That said,
yeah, it's nicer to recover without leaking anything.

> 3) my test way is simple, i force "if (max_distance > VMALLOC_TOTAL * 3 / 4)"
>    to if (1) and print which memory i allocate before the jumping, then print which memory
>    i free after the jumping and before returning, then check whether i free the memory i 
>    allocate in this function, the result is okay

Can you please include what has been discussed into the patch
description?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
