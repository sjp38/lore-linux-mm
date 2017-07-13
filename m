Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A64D0440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 14:23:53 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 23so9771664wry.4
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 11:23:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o188si45277wmd.102.2017.07.13.11.23.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Jul 2017 11:23:52 -0700 (PDT)
Date: Thu, 13 Jul 2017 19:23:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170713182350.n64dmnkgbiivikmh@suse.de>
References: <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de>
 <CALCETrWF7hxR7rFCUwi5FZWPt_NUy2U5dV+zy6HUm_x+0jdomA@mail.gmail.com>
 <20170713170712.4iriw5lncoulcgda@suse.de>
 <CALCETrXm8GXXgbXOw8DKL2O9fWfyv2CzExwCLR+6kHLELPsP3Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALCETrXm8GXXgbXOw8DKL2O9fWfyv2CzExwCLR+6kHLELPsP3Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Thu, Jul 13, 2017 at 10:15:15AM -0700, Andrew Lutomirski wrote:
> On Thu, Jul 13, 2017 at 10:07 AM, Mel Gorman <mgorman@suse.de> wrote:
> > On Thu, Jul 13, 2017 at 09:08:21AM -0700, Andrew Lutomirski wrote:
> >> On Wed, Jul 12, 2017 at 11:07 PM, Mel Gorman <mgorman@suse.de> wrote:
> >> > --- a/arch/x86/mm/tlb.c
> >> > +++ b/arch/x86/mm/tlb.c
> >> > @@ -455,6 +455,39 @@ void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
> >> >         put_cpu();
> >> >  }
> >> >
> >> > +/*
> >> > + * Ensure that any arch_tlbbatch_add_mm calls on this mm are up to date when
> >>
> >> s/are up to date/have flushed the TLBs/ perhaps?
> >>
> >>
> >> Can you update this comment in arch/x86/include/asm/tlbflush.h:
> >>
> >>          * - Fully flush a single mm.  .mm will be set, .end will be
> >>          *   TLB_FLUSH_ALL, and .new_tlb_gen will be the tlb_gen to
> >>          *   which the IPI sender is trying to catch us up.
> >>
> >> by adding something like: This can also happen due to
> >> arch_tlbflush_flush_one_mm(), in which case it's quite likely that
> >> most or all CPUs are already up to date.
> >>
> >
> > No problem, thanks. Care to ack the patch below? If so, I'll send it
> > to Ingo with x86 and linux-mm cc'd after some tests complete (hopefully
> > successfully). It's fairly x86 specific and makes sense to go in with the
> > rest of the pcid and mm tlb_gen stuff rather than via Andrew's tree even
> > through it touches core mm.
> 
> Acked-by: Andy Lutomirski <luto@kernel.org> # for the x86 parts
> 
> When you send to Ingo, you might want to change
> arch_tlbbatch_flush_one_mm to arch_tlbbatch_flush_one_mm(), because
> otherwise he'll probably do it for you :)

*cringe*. I fixed it up.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
