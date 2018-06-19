Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 04CCF6B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 00:08:32 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c1-v6so15647797qtj.6
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 21:08:32 -0700 (PDT)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id g27-v6si1348413qtc.34.2018.06.18.21.08.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Jun 2018 21:08:30 -0700 (PDT)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id e092dfeb
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 04:02:36 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 0876059c (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 04:02:35 +0000 (UTC)
Received: by mail-oi0-f44.google.com with SMTP id l22-v6so16945622oib.4
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 21:08:25 -0700 (PDT)
MIME-Version: 1.0
References: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
 <CALvZod6Dxx79ztxzHsDVe6pj7Fa7ydJAjMf_EHV9H15+AsVwdA@mail.gmail.com>
In-Reply-To: <CALvZod6Dxx79ztxzHsDVe6pj7Fa7ydJAjMf_EHV9H15+AsVwdA@mail.gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 19 Jun 2018 06:08:11 +0200
Message-ID: <CAHmME9qvRDQOJYdSPaAf-hg5raacu4TBgStLy7NzFL+j+dXheQ@mail.gmail.com>
Subject: Re: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: aryabinin@virtuozzo.com, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 19, 2018 at 5:59 AM Shakeel Butt <shakeelb@google.com> wrote:
> Hi Jason, yes please do send me the test suite with the kernel config.

$ git clone https://git.zx2c4.com/WireGuard
$ cd WireGuard/src
$ [[ $(gcc -v 2>&1) =~ gcc\ version\ 8\.1\.0 ]] || echo crash needs 8.1
$ export DEBUG_KERNEL=yes
$ export KERNEL_VERSION=4.18-rc1
$ make test-qemu -j$(nproc)

This will build a kernel and a minimal userland and load it in qemu,
which must be installed.

This code is what causes the crash:
The self test that's executed:
https://git.zx2c4.com/WireGuard/tree/src/selftest/ratelimiter.h
Which exercises this code:
https://git.zx2c4.com/WireGuard/tree/src/ratelimiter.c

The problem occurs after gc_entries(NULL) frees things (line 124 in
ratelimiter.h above), and then line 133 reallocates those objects.
Sometime after that happens, elsewhere in the kernel invokes this
kasan issue in the kasan cache cleanup.

I realize it's disappointing that the test case here is in WireGuard,
which isn't (yet!) upstream. That's why in my original message I
wrote:

> Rather, it looks like this
> commit introduces a performance optimization, rather than a
> correctness fix, so it seems that whatever test case is failing is
> likely an incorrect failure. Does that seem like an accurate
> possibility to you?

I was hoping to only point you toward my own code after establishing
the possibility that the bug is not my own. If you still think there's
a chance this is due to my own correctness issue, and your commit has
simply unearthed it, let me know and I'll happily keep debugging on my
own before pinging you further.

Regards,
Jason
