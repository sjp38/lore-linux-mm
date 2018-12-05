Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 014D86B74CF
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 09:39:06 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id m128so16581391itd.3
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 06:39:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j65sor23319712itj.0.2018.12.05.06.39.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 06:39:04 -0800 (PST)
MIME-Version: 1.0
References: <1541712198.12945.12.camel@gmx.us> <D7C9EA14-C812-406F-9570-CFF36F4C3983@gmx.us>
 <20181110165938.lbt6dfamk2ljafcv@localhost> <a2a9180f-32cf-a0fa-3829-f36133e3b924@gmx.us>
In-Reply-To: <a2a9180f-32cf-a0fa-3829-f36133e3b924@gmx.us>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 5 Dec 2018 15:38:51 +0100
Message-ID: <CACT4Y+ZXHgvHdZc=VDsiTSBCkG3FomEC3TAhZgw9-_L4RBukjQ@mail.gmail.com>
Subject: Re: kmemleak: Early log buffer exceeded (525980) during boot
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cai@gmx.us
Cc: Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Will Deacon <will.deacon@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Wed, Nov 28, 2018 at 5:21 AM Qian Cai <cai@gmx.us> wrote:
> On 11/10/18 11:59 AM, Catalin Marinas wrote:
> > On Sat, Nov 10, 2018 at 10:08:10AM -0500, Qian Cai wrote:
> >> On Nov 8, 2018, at 4:23 PM, Qian Cai <cai@gmx.us> wrote:
> >>> The maximum value for DEBUG_KMEMLEAK_EARLY_LOG_SIZE is only 40000, so it
> >>> disables kmemleak every time on this aarch64 server running the latest mainline
> >>> (b00d209).
> >>>
> >>> # echo scan > /sys/kernel/debug/kmemleak
> >>> -bash: echo: write error: Device or resource busy
> >>>
> >>> Any idea on how to enable kmemleak there?
> >>
> >> I have managed to hard-code DEBUG_KMEMLEAK_EARLY_LOG_SIZE to 600000,
> >
> > That's quite a high number, I wouldn't have thought it is needed.
> > Basically the early log buffer is only used until the slub allocator
> > gets initialised and kmemleak_init() is called from start_kernel(). I
> > don't know what allocates that much memory so early.
> >
>
> It turned out that kmemleak does not play well with KASAN on those aarch64 (HPE
> Apollo 70 and Huawei TaiShan 2280) servers.
>
> After calling start_kernel()->setup_arch()->kasan_init(), kmemleak early log
> buffer went from something like from 280 to 260000. The multitude of
> kmemleak_alloc() calls is,
>
> for_each_memblock(memory, reg) x \
> while (pgdp++, addr = next, addr != end) x \
> while (ptep++, addr = next, addr != end && \ pte_none(READ_ONCE(*ptep)))
>
> Is this expected?


FTR, this should be resolved by (if put pieces together correctly):
https://lkml.org/lkml/2018/11/29/191
