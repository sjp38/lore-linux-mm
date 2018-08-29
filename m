Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58B616B4C74
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 11:42:22 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id r206-v6so4833666iod.2
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 08:42:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r194-v6sor1399959itb.21.2018.08.29.08.42.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 08:42:21 -0700 (PDT)
MIME-Version: 1.0
References: <20180828112034.30875-1-npiggin@gmail.com> <20180828112034.30875-3-npiggin@gmail.com>
In-Reply-To: <20180828112034.30875-3-npiggin@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 29 Aug 2018 08:42:09 -0700
Message-ID: <CA+55aFwbZrsdZEh0ds1W3AWUeTamDRheQPKSi9O=--cEOSjr5g@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm/cow: optimise pte dirty/accessed bits handling in fork
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Aug 28, 2018 at 4:20 AM Nicholas Piggin <npiggin@gmail.com> wrote:
>
> fork clears dirty/accessed bits from new ptes in the child. This logic
> has existed since mapped page reclaim was done by scanning ptes when
> it may have been quite important. Today with physical based pte
> scanning, there is less reason to clear these bits.

Can you humor me, and make the dirty/accessed bit patches separate?

There is actually a difference wrt the dirty bit: if we unmap an area
with dirty pages, we have to do the special synchronous flush.

So a clean page in the virtual mapping is _literally_ cheaper to have.

> This eliminates a major source of faults powerpc/radix requires to set
> dirty/accessed bits in ptes, speeding up a fork/exit microbenchmark by
> about 5% on POWER9 (16600 -> 17500 fork/execs per second).

I don't think the dirty bit matters.

The accessed bit I think may be worth keeping, so by all means remove the mkold.

                  Linus
