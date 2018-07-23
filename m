Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB0446B0010
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 12:24:49 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id p4-v6so524602ybk.6
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 09:24:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i18-v6sor1811210ywc.128.2018.07.23.09.24.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 09:24:46 -0700 (PDT)
Date: Mon, 23 Jul 2018 12:27:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 02/10] mm: workingset: tell cache transitions from
 workingset thrashing
Message-ID: <20180723162735.GA5980@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-3-hannes@cmpxchg.org>
 <CAK8P3a3Nsmt54-ed_gWNev3CBS6_Sv5QGOw4G0sY4ZXOi1R4_Q@mail.gmail.com>
 <20180723152323.GA3699@cmpxchg.org>
 <CAK8P3a15K-TXYuFX-ZsJiroqA1GWX2XS4ioZSjcjJYgh1b_xSA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a15K-TXYuFX-ZsJiroqA1GWX2XS4ioZSjcjJYgh1b_xSA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Suren Baghdasaryan <surenb@google.com>, Mike Galbraith <efault@gmx.de>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Linux-MM <linux-mm@kvack.org>, Vinayak Menon <vinmenon@codeaurora.org>, Ingo Molnar <mingo@redhat.com>, Shakeel Butt <shakeelb@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christopher Lameter <cl@linux.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Mon, Jul 23, 2018 at 05:35:35PM +0200, Arnd Bergmann wrote:
> On Mon, Jul 23, 2018 at 5:23 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > From 1d24635a6c7cd395bad5c29a3b9e5d2e98d9ab84 Mon Sep 17 00:00:00 2001
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Date: Mon, 23 Jul 2018 10:18:23 -0400
> > Subject: [PATCH] arm64: fix vmemmap BUILD_BUG_ON() triggering on !vmemmap
> >  setups
> >
> > Arnd reports the following arm64 randconfig build error with the PSI
> > patches that add another page flag:
> >
> 
> You could add further text here that I had just added to my
> patch description (not sent):
> 
>     Further experiments show that the build error already existed before,
>     but was only triggered with larger values of CONFIG_NR_CPU and/or
>     CONFIG_NODES_SHIFT that might be used in actual configurations but
>     not in randconfig builds.
> 
>     With longer CPU and node masks, I could recreate the problem with
>     kernels as old as linux-4.7 when arm64 NUMA support got added.
> 
>     Cc: stable@vger.kernel.org
>     Fixes: 1a2db300348b ("arm64, numa: Add NUMA support for arm64 platforms.")
>     Fixes: 3e1907d5bf5a ("arm64: mm: move vmemmap region right below
> the linear region")

Sure thing.

> >  arch/arm64/mm/init.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> > index 1b18b4722420..72c9b6778b0a 100644
> > --- a/arch/arm64/mm/init.c
> > +++ b/arch/arm64/mm/init.c
> > @@ -611,11 +611,13 @@ void __init mem_init(void)
> >         BUILD_BUG_ON(TASK_SIZE_32                       > TASK_SIZE_64);
> >  #endif
> >
> > +#ifndef CONFIG_SPARSEMEM_VMEMMAP
> >         /*
> 
> I tested it on two broken configurations, and found that you have
> a typo here, it should be 'ifdef', not 'ifndef'. With that change, it
> seems to build fine.
> 
> Tested-by: Arnd Bergmann <arnd@arndb.de>

Thanks for testing it, I don't have a cross-compile toolchain set up.

---
