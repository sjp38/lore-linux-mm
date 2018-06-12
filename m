Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0776B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 19:40:07 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id k129-v6so907939itg.8
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 16:40:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m144-v6sor804359itg.41.2018.06.12.16.40.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 16:40:06 -0700 (PDT)
MIME-Version: 1.0
References: <20180612071621.26775-1-npiggin@gmail.com> <20180612071621.26775-4-npiggin@gmail.com>
 <CA+55aFzKBieD0Y3sgFQzt+x5esqb9vT6SEQ28xyCz5UWegfFVg@mail.gmail.com>
 <20180613083131.139a3c34@roar.ozlabs.ibm.com> <CA+55aFyk9VBLUk8VYhfEUR55x0TXY9_QX1dE4wE0A_ias9tMNQ@mail.gmail.com>
 <20180613090950.50566245@roar.ozlabs.ibm.com> <CA+55aFxd97-29qi-JMxyPPoZMxw=eObQHB5XXGiLj7SNV8B-oQ@mail.gmail.com>
In-Reply-To: <CA+55aFxd97-29qi-JMxyPPoZMxw=eObQHB5XXGiLj7SNV8B-oQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 12 Jun 2018 16:39:55 -0700
Message-ID: <CA+55aFzbYBXUDcAGaP_HoCxjTvOgkixc0+7nJqMea0yKjLSnhw@mail.gmail.com>
Subject: Re: [RFC PATCH 3/3] powerpc/64s/radix: optimise TLB flush with
 precise TLB ranges in mmu_gather
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-arch <linux-arch@vger.kernel.org>, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Nadav Amit <nadav.amit@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jun 12, 2018 at 4:26 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Right.  Intel depends on the current thing, ie if a page table
> *itself* is freed, we will will need to do a flush, but it's the exact
> same flush as if there had been a regular page there.
>
> That's already handled by (for example) pud_free_tlb() doing the
> __tlb_adjust_range().

Side note: I guess we _could_ make the "page directory" flush be
special on x86 too.

Right now a page directory flush just counts as a range, and then a
range that is more that a few entries just means "flush everything".

End result: in practice, every time you free a page directory, you
flush the whole TLB because it looks identical to flushing a large
range of pages.

And in _theory_, maybe you could have just used "invalpg" with a
targeted address instead. In fact, I think a single invlpg invalidates
_all_ caches for the associated MM, but don't quote me on that.

That said, I don't think this is a common case. But I think that *if*
you extend this to be aware of the page directory caches, and _if_ you
extend it to cover both ppc and x86, at that point all my "this isn't
generic" arguments go away.

Because once x86 does it, it's "common enough" that it counts as
generic. It may be only a single other architecture, but it's the bulk
of all the development machines, so..

                 Linus
