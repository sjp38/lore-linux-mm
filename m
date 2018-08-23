Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B95386B291E
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 04:46:58 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g36-v6so2241310plb.5
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 01:46:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h2-v6sor925460pgp.216.2018.08.23.01.46.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 01:46:57 -0700 (PDT)
Date: Thu, 23 Aug 2018 18:46:48 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180823184648.0439a473@roar.ozlabs.ibm.com>
In-Reply-To: <20180822154046.823850812@infradead.org>
References: <20180822153012.173508681@infradead.org>
	<20180822154046.823850812@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, 22 Aug 2018 17:30:15 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> Jann reported that x86 was missing required TLB invalidates when he
> hit the !*batch slow path in tlb_remove_table().
> 
> This is indeed the case; RCU_TABLE_FREE does not provide TLB (cache)
> invalidates, the PowerPC-hash where this code originated and the
> Sparc-hash where this was subsequently used did not need that. ARM
> which later used this put an explicit TLB invalidate in their
> __p*_free_tlb() functions, and PowerPC-radix followed that example.

So this is interesting, I _think_ a145abf12c did fix this bug for
powerpc, but then it seem to have been re-broken by a46cc7a90f
because that one defers the flush back to tlb_flush time. There
was quite a lot of churn getting the radix MMU off the ground at
that point though so I'm not 100% sure.

But AFAIKS powerpc today has this same breakage, and this patch
should fix it.

I have a couple of patches that touch the same code I'll send, you
might have some opinions on them.

Thanks,
Nick
