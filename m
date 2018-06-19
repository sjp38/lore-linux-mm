Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 975F36B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 00:55:52 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t19-v6so11407890plo.9
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 21:55:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j1-v6sor5662614pld.42.2018.06.18.21.55.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Jun 2018 21:55:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHmME9qvRDQOJYdSPaAf-hg5raacu4TBgStLy7NzFL+j+dXheQ@mail.gmail.com>
References: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
 <CALvZod6Dxx79ztxzHsDVe6pj7Fa7ydJAjMf_EHV9H15+AsVwdA@mail.gmail.com> <CAHmME9qvRDQOJYdSPaAf-hg5raacu4TBgStLy7NzFL+j+dXheQ@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 19 Jun 2018 06:55:30 +0200
Message-ID: <CACT4Y+YLySJMfG4kCJ2FiPpPtN6sgU6k2FoZUYMFrJGLj+vDjw@mail.gmail.com>
Subject: Re: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Shakeel Butt <shakeelb@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 19, 2018 at 6:08 AM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> On Tue, Jun 19, 2018 at 5:59 AM Shakeel Butt <shakeelb@google.com> wrote:
>> Hi Jason, yes please do send me the test suite with the kernel config.
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
> I realize it's disappointing that the test case here is in WireGuard,
> which isn't (yet!) upstream. That's why in my original message I
> wrote:
>
>> Rather, it looks like this
>> commit introduces a performance optimization, rather than a
>> correctness fix, so it seems that whatever test case is failing is
>> likely an incorrect failure. Does that seem like an accurate
>> possibility to you?
>
> I was hoping to only point you toward my own code after establishing
> the possibility that the bug is not my own. If you still think there's
> a chance this is due to my own correctness issue, and your commit has
> simply unearthed it, let me know and I'll happily keep debugging on my
> own before pinging you further.


Hi Jason,

Your code frees all entries before freeing the cache, right? If you
add total_entries check before freeing the cache, it does not fire,
right?
Are you using SLAB or SLUB? We stress kernel pretty heavily, but with
SLAB, and I suspect Shakeel may also be using SLAB. So if you are
using SLUB, there is significant chance that it's a bug in the SLUB
part of the change.
