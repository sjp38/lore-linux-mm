Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id E97E06B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 19:26:46 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n15-v6so817441ioc.17
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 16:26:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b191-v6sor636083iof.297.2018.06.12.16.26.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 16:26:45 -0700 (PDT)
MIME-Version: 1.0
References: <20180612071621.26775-1-npiggin@gmail.com> <20180612071621.26775-4-npiggin@gmail.com>
 <CA+55aFzKBieD0Y3sgFQzt+x5esqb9vT6SEQ28xyCz5UWegfFVg@mail.gmail.com>
 <20180613083131.139a3c34@roar.ozlabs.ibm.com> <CA+55aFyk9VBLUk8VYhfEUR55x0TXY9_QX1dE4wE0A_ias9tMNQ@mail.gmail.com>
 <20180613090950.50566245@roar.ozlabs.ibm.com>
In-Reply-To: <20180613090950.50566245@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 12 Jun 2018 16:26:33 -0700
Message-ID: <CA+55aFxd97-29qi-JMxyPPoZMxw=eObQHB5XXGiLj7SNV8B-oQ@mail.gmail.com>
Subject: Re: [RFC PATCH 3/3] powerpc/64s/radix: optimise TLB flush with
 precise TLB ranges in mmu_gather
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-arch <linux-arch@vger.kernel.org>, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Nadav Amit <nadav.amit@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jun 12, 2018 at 4:09 PM Nicholas Piggin <npiggin@gmail.com> wrote:
>
> Sorry I mean Intel needs the existing behaviour of range flush expanded
> to cover page table pages.... right?

Right.  Intel depends on the current thing, ie if a page table
*itself* is freed, we will will need to do a flush, but it's the exact
same flush as if there had been a regular page there.

That's already handled by (for example) pud_free_tlb() doing the
__tlb_adjust_range().

Again, I may be missing entirely what you're talking about, because it
feels like we're talking across each other.

My argument is that your new patches in (2-3 in the series - patch #1
looks ok) seem to be fundamentally specific to things that have a
*different* tlb invalidation for the directory entries than for the
leaf entries.

But that's not what at least x86 has, and not what the generic code has done.

I think it might be fine to introduce a few new helpers that end up
being no-ops for the traditional cases.

I just don't think it makes sense to maintain a set of range values
that then aren't actually used in the general case.

              Linus
