Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D36DB6B000A
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 01:06:51 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r2-v6so13394424wrm.15
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 22:06:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s11-v6sor2726294wmb.52.2018.06.18.22.06.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Jun 2018 22:06:50 -0700 (PDT)
MIME-Version: 1.0
References: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
 <CALvZod6Dxx79ztxzHsDVe6pj7Fa7ydJAjMf_EHV9H15+AsVwdA@mail.gmail.com> <CAHmME9qvRDQOJYdSPaAf-hg5raacu4TBgStLy7NzFL+j+dXheQ@mail.gmail.com>
In-Reply-To: <CAHmME9qvRDQOJYdSPaAf-hg5raacu4TBgStLy7NzFL+j+dXheQ@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 18 Jun 2018 22:06:38 -0700
Message-ID: <CALvZod5ZrxjZjJjAV_iH6hgq9pY2QEuFjNi+qvPSzob5Vighjg@mail.gmail.com>
Subject: Re: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason@zx2c4.com
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 18, 2018 at 9:08 PM Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>
> On Tue, Jun 19, 2018 at 5:59 AM Shakeel Butt <shakeelb@google.com> wrote:
> > Hi Jason, yes please do send me the test suite with the kernel config.
>
> $ git clone https://git.zx2c4.com/WireGuard
> $ cd WireGuard/src
> $ [[ $(gcc -v 2>&1) =~ gcc\ version\ 8\.1\.0 ]] || echo crash needs 8.1
> $ export DEBUG_KERNEL=yes
> $ export KERNEL_VERSION=4.18-rc1
> $ make test-qemu -j$(nproc)
>
> This will build a kernel and a minimal userland and load it in qemu,
> which must be installed.
>
> This code is what causes the crash:
> The self test that's executed:
> https://git.zx2c4.com/WireGuard/tree/src/selftest/ratelimiter.h
> Which exercises this code:
> https://git.zx2c4.com/WireGuard/tree/src/ratelimiter.c
>
> The problem occurs after gc_entries(NULL) frees things (line 124 in
> ratelimiter.h above), and then line 133 reallocates those objects.
> Sometime after that happens, elsewhere in the kernel invokes this
> kasan issue in the kasan cache cleanup.
>

I will try to repro with your test suite sometime later this week.
However from high level code inspection, I see that the code is
creating a 'entry_cache' kmem_cache which is destroyed by
ratelimiter_uninit on last reference drop. Currently refcnt in your
code can underflow, through it does not seem like the selftest will
cause the underflow but still you should fix it.

>From high level your code seems fine. Does the issue occur on first
try of selftest? Basically I wanted to ask if kmem_cache_destroy of
your entry_cache was ever executed and have you tried to run this
selftest multiple time while the system was up.

As Dmitry already asked, are you using SLAB or SLUB?

> I realize it's disappointing that the test case here is in WireGuard,
> which isn't (yet!) upstream. That's why in my original message I
> wrote:
>
> > Rather, it looks like this
> > commit introduces a performance optimization, rather than a
> > correctness fix, so it seems that whatever test case is failing is
> > likely an incorrect failure. Does that seem like an accurate
> > possibility to you?
>
> I was hoping to only point you toward my own code after establishing
> the possibility that the bug is not my own. If you still think there's
> a chance this is due to my own correctness issue, and your commit has
> simply unearthed it, let me know and I'll happily keep debugging on my
> own before pinging you further.
>

Sorry, I can not really give a definitive answer.

Shakeel
