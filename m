Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 733D56B0283
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:21:10 -0500 (EST)
Received: by wmdw130 with SMTP id w130so191856330wmd.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 02:21:10 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id e191si3791659wma.104.2015.11.18.02.21.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 02:21:09 -0800 (PST)
Received: by wmww144 with SMTP id w144so190444089wmw.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 02:21:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1447838814-31109-1-git-send-email-aryabinin@virtuozzo.com>
References: <1447838814-31109-1-git-send-email-aryabinin@virtuozzo.com>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Wed, 18 Nov 2015 10:20:49 +0000
Message-ID: <CAHkRjk4OgZQWZkDaQfvEG3EyND2HvvFjzZTvQt2syqgdJ2zZ6A@mail.gmail.com>
Subject: Re: [PATCH v2] kasan: fix kmemleak false-positive in kasan_module_alloc()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 18 November 2015 at 09:26, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> Kmemleak reports the following leak:
>         unreferenced object 0xfffffbfff41ea000 (size 20480):
>         comm "modprobe", pid 65199, jiffies 4298875551 (age 542.568s)
>         hex dump (first 32 bytes):
>           00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>           00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>         backtrace:
>           [<ffffffff82354f5e>] kmemleak_alloc+0x4e/0xc0
>           [<ffffffff8152e718>] __vmalloc_node_range+0x4b8/0x740
>           [<ffffffff81574072>] kasan_module_alloc+0x72/0xc0
>           [<ffffffff810efe68>] module_alloc+0x78/0xb0
>           [<ffffffff812f6a24>] module_alloc_update_bounds+0x14/0x70
>           [<ffffffff812f8184>] layout_and_allocate+0x16f4/0x3c90
>           [<ffffffff812faa1f>] load_module+0x2ff/0x6690
>           [<ffffffff813010b6>] SyS_finit_module+0x136/0x170
>           [<ffffffff8239bbc9>] system_call_fastpath+0x16/0x1b
>           [<ffffffffffffffff>] 0xffffffffffffffff
>
> kasan_module_alloc() allocates shadow memory for module and frees it on
> module unloading. It doesn't store the pointer to allocated shadow memory
> because it could be calculated from the shadowed address, i.e. kasan_mem_to_shadow(addr).
> Since kmemleak cannot find pointer to allocated shadow, it thinks that
> memory leaked.
>
> Use kmemleak_ignore() to tell kmemleak that this is not a leak and shadow
> memory doesn't contain any pointers.
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
