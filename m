Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 822726B03AC
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:42:40 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 23so4672173wry.4
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:42:40 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id 63si3769816wrs.220.2017.06.23.01.42.38
        for <linux-mm@kvack.org>;
        Fri, 23 Jun 2017 01:42:39 -0700 (PDT)
Date: Fri, 23 Jun 2017 10:42:19 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 05/11] x86/mm: Track the TLB's tlb_gen and update the
 flushing algorithm
Message-ID: <20170623084219.k4lrorgtlshej7ri@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <91f24a6145b2077f992902891f8fa59abe5c8696.1498022414.git.luto@kernel.org>
 <20170621184424.eixb2jdyy66xq4hg@pd.tnic>
 <CALCETrWEGrVJj3Jcc3U38CYh01GKgGpLqW=eN_-7nMo4t=V5Mg@mail.gmail.com>
 <20170622072449.4rc4bnvucn7usuak@pd.tnic>
 <CALCETrVdT449KiEJ7wo8g9B6NyTSQhuXpYL76b=ToJhKwKyVXg@mail.gmail.com>
 <20170622145914.tzqdulshlssiywj4@pd.tnic>
 <CALCETrUPqG-YcneqSqUYzWTJbm2Ae0Nj3K0MuS0cKYeD0yWhuw@mail.gmail.com>
 <20170622172220.wf3egiwx2kqbxbi2@pd.tnic>
 <CALCETrUbiXK8gjS=U2j4jW8YgPv4j+wgwsa4nJLnO+902fXfKQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrUbiXK8gjS=U2j4jW8YgPv4j+wgwsa4nJLnO+902fXfKQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, Jun 22, 2017 at 11:08:38AM -0700, Andy Lutomirski wrote:
> Yes, I agree it's confusing.  There really are three numbers.  Those
> numbers are: the latest generation, the generation that this CPU has
> caught up to, and the generation that the requester of the flush we're
> currently handling has asked us to catch up to.  I don't see a way to
> reduce the complexity.

Yeah, can you pls put that clarification what what is, over it. It
explains it nicely what the check is supposed to do.

> >> The flush IPI hits after a switch_mm_irqs_off() call notices the
> >> change from 1 to 2. switch_mm_irqs_off() will do a full flush and
> >> increment the local tlb_gen to 2, and the IPI handler for the partial
> >> flush will see local_tlb_gen == mm_tlb_gen - 1 (because local_tlb_gen
> >> == 2 and mm_tlb_gen == 3) and do a partial flush.
> >
> > Why, the 2->3 flush has f->end == TLB_FLUSH_ALL.
> >
> > That's why you have this thing in addition to the tlb_gen.
> 
> Yes.  The idea is that we only do remote partial flushes when it's
> 100% obvious that it's safe.

So why wouldn't my simplified suggestion work then?

	if (f->end != TLB_FLUSH_ALL &&
	     mm_tlb_gen == local_tlb_gen + 1)

1->2 is a partial flush - gets promoted to a full one
2->3 is a full flush - it will get executed as one due to the f->end setting to
TLB_FLUSH_ALL.

> It could be converted to two full flushes or to just one, I think,
> depending on what order everything happens in.

Right. One flush at the right time would be optimal.

> But this approach of using three separate tlb_gen values seems to
> cover all the bases, and I don't think it's *that* bad.

Sure.

As I said in IRC, let's document that complexity then so that when we
stumble over it in the future, we at least know why it was done this
way.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
