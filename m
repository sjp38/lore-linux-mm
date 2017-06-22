Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E01B6B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:59:30 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l34so5243287wrc.12
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:59:30 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id n68si1364995wmn.63.2017.06.22.07.59.28
        for <linux-mm@kvack.org>;
        Thu, 22 Jun 2017 07:59:28 -0700 (PDT)
Date: Thu, 22 Jun 2017 16:59:15 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 05/11] x86/mm: Track the TLB's tlb_gen and update the
 flushing algorithm
Message-ID: <20170622145914.tzqdulshlssiywj4@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <91f24a6145b2077f992902891f8fa59abe5c8696.1498022414.git.luto@kernel.org>
 <20170621184424.eixb2jdyy66xq4hg@pd.tnic>
 <CALCETrWEGrVJj3Jcc3U38CYh01GKgGpLqW=eN_-7nMo4t=V5Mg@mail.gmail.com>
 <20170622072449.4rc4bnvucn7usuak@pd.tnic>
 <CALCETrVdT449KiEJ7wo8g9B6NyTSQhuXpYL76b=ToJhKwKyVXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrVdT449KiEJ7wo8g9B6NyTSQhuXpYL76b=ToJhKwKyVXg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, Jun 22, 2017 at 07:48:21AM -0700, Andy Lutomirski wrote:
> On Thu, Jun 22, 2017 at 12:24 AM, Borislav Petkov <bp@alien8.de> wrote:
> > On Wed, Jun 21, 2017 at 07:46:05PM -0700, Andy Lutomirski wrote:
> >> > I'm certainly still missing something here:
> >> >
> >> > We have f->new_tlb_gen and mm_tlb_gen to control the flushing, i.e., we
> >> > do once
> >> >
> >> >         bump_mm_tlb_gen(mm);
> >> >
> >> > and once
> >> >
> >> >         info.new_tlb_gen = bump_mm_tlb_gen(mm);
> >> >
> >> > and in both cases, the bumping is done on mm->context.tlb_gen.
> >> >
> >> > So why isn't that enough to do the flushing and we have to consult
> >> > info.new_tlb_gen too?
> >>
> >> The issue is a possible race.  Suppose we start at tlb_gen == 1 and
> >> then two concurrent flushes happen.  The first flush is a full flush
> >> and sets tlb_gen to 2.  The second is a partial flush and sets tlb_gen
> >> to 3.  If the second flush gets propagated to a given CPU first and it
> >
> > Maybe I'm still missing something, which is likely...
> >
> > but if the second flush gets propagated to the CPU first, the CPU will
> > have local tlb_gen 1 and thus enforce a full flush anyway because we
> > will go 1 -> 3 on that particular CPU. Or?
> >
> 
> Yes, exactly.  Which means I'm probably just misunderstanding your
> original question.  Can you re-ask it?

Ah, simple: we control the flushing with info.new_tlb_gen and
mm->context.tlb_gen. I.e., this check:


        if (f->end != TLB_FLUSH_ALL &&
            f->new_tlb_gen == local_tlb_gen + 1 &&
            f->new_tlb_gen == mm_tlb_gen) {

why can't we write:

        if (f->end != TLB_FLUSH_ALL &&
	    mm_tlb_gen == local_tlb_gen + 1)

?

If mm_tlb_gen is + 2, then we'll do a full flush, if it is + 1, then
partial.

If the second flush, as you say is a partial one and still gets
propagated first, the check will force a full flush anyway.

When the first flush propagates after the second, we'll ignore it
because local_tlb_gen has advanced adready due to the second flush.

As a matter of fact, we could simplify the logic: if local_tlb_gen is
only mm_tlb_gen - 1, then do the requested flush type.

If mm_tlb_gen has advanced more than 1 generation, just do a full flush
unconditionally. ... and I think we do something like that already but I
think the logic could be simplified, unless I'm missing something, that is.

Thanks.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
