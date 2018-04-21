Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD4A76B0008
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 17:06:56 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id y4-v6so10716766iod.5
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 14:06:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n4-v6sor4109783iof.338.2018.04.21.14.06.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Apr 2018 14:06:55 -0700 (PDT)
Date: Sat, 21 Apr 2018 16:06:29 -0500
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: Re: [PATCH v2] KASAN: prohibit KASAN+STRUCTLEAK combination
Message-ID: <20180421210629.GA44181@big-sky.restechservices.net>
References: <20180419172451.104700-1-dvyukov@google.com>
 <CAGXu5jK0fWnyQUYP3H5e8hP-6QbtmeC102a-2Mab4CSqj4bpgg@mail.gmail.com>
 <20180420053329.GA37680@big-sky.local>
 <CACT4Y+ZZZvHDbiCXXWNVzACU25QZT0j-TbpMpSetuUQFb8Km=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZZZvHDbiCXXWNVzACU25QZT0j-TbpMpSetuUQFb8Km=Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Kees Cook <keescook@google.com>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Fengguang Wu <fengguang.wu@intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

Hi,

On Fri, Apr 20, 2018 at 07:56:56AM +0200, Dmitry Vyukov wrote:
> As a sanity check, I would count number of zeroing inserted by the
> plugin it both cases and ensure that now it does not insert order of
> magnitude more/less. It's easy with function calls (count them in
> objdump output), not sure what's the easiest way to do it for inline
> instrumentation. We could insert printf into the pass itself, but it
> if runs before inlining and other optimization, it's not the final
> number.

I modified the structleak_plugin to count the number of initializations
and output if the function was an inline function or not. The aggregated
values are below.

declared inline       no       yes
----------------------------------
early_optimizations:  12168   7114
*all_optimizations:   12554     13

These numbers seem appropriate. The structleak initializes in declared
inline functions are redundant.

> Also note that asan pass is at different locations in the pipeline
> depending on optimization level:
> https://gcc.gnu.org/viewcvs/gcc/trunk/gcc/passes.def?view=markup

The *all_optimizations pass happens before any of the asan pass
locations so I think this shouldn't change those semantics.

Thanks,
Dennis
