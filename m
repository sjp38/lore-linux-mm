Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6DD8E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 16:43:45 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s70so14420609qks.4
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:43:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j42sor18659013qta.38.2018.12.11.13.43.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 13:43:44 -0800 (PST)
MIME-Version: 1.0
References: <721E7B42-2D55-4866-9C1A-3E8D64F33F9C@gmx.us> <20181207223449.38808-1-cai@lca.pw>
 <CAK8P3a20kRDrkS1YFLp6cYeKcUoC9s+O_tnYNbKEMWGukia1Tg@mail.gmail.com> <1544548707.18411.3.camel@lca.pw>
In-Reply-To: <1544548707.18411.3.camel@lca.pw>
From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 11 Dec 2018 22:43:26 +0100
Message-ID: <CAK8P3a3ghizoj5xwkQayuwu2Z1HppSqHLwHGPp97dUG4upv+LA@mail.gmail.com>
Subject: Re: [PATCH] arm64: increase stack size for KASAN_EXTRA
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cai@lca.pw
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Dec 11, 2018 at 6:18 PM Qian Cai <cai@lca.pw> wrote:
>
> On Tue, 2018-12-11 at 13:42 +0100, Arnd Bergmann wrote:
> > On Fri, Dec 7, 2018 at 11:35 PM Qian Cai <cai@lca.pw> wrote:
> > >
> > > If the kernel is configured with KASAN_EXTRA, the stack size is
> > > increasted significantly due to enable this option will set
> > > -fstack-reuse to "none" in GCC [1]. As the results, it could trigger
> > > stack overrun quite often with 32k stack size compiled using GCC 8. For
> > > example, this reproducer
> > >
> > > size
> > > 7536 shrink_inactive_list
> > > 7440 shrink_page_list
> > > 6560 fscache_stats_show
> > > 3920 jbd2_journal_commit_transaction
> > > 3216 try_to_unmap_one
> > > 3072 migrate_page_move_mapping
> > > 3584 migrate_misplaced_transhuge_page
> > > 3920 ip_vs_lblcr_schedule
> > > 4304 lpfc_nvme_info_show
> > > 3888 lpfc_debugfs_nvmestat_data.constprop
> > >
> > > There are other 49 functions are over 2k in size while compiling kernel
> > > with "-Wframe-larger-than=" on this machine. Hence, it is too much work
> > > to change Makefiles for each object to compile without
> > > -fsanitize-address-use-after-scope individually.
> > >
> > > [1] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715#c23
> >
> > Could you clarify: are the numbers you see with or without the bugfix
> > from that bugzilla?
> >
>
> The numbers were from GCC8 which does NOT contain this patch [1].
>
> GCC9 is awesome which reduced the numbers in half even for KASAN_EXTRA. Only
> thing is that GCC9 has not been officially released yet, so it is a bit
> inconvenient for users need to compile the compiler by themselves first.
>
> I am fine either way to drop this patch or keep it until GCC9 is GA.
>
> [1] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715#c35

Maybe we can make the constant depend on the compiler version?
It may also be possible to reduce the KASAN_THREAD_SHIFT
constant for the normal case with gcc-9 and go back to the
default frame size then.

       Arnd
