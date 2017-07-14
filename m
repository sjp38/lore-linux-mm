Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C90D4408E5
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 03:00:50 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 188so96718190itx.9
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 00:00:50 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id u126si1462190itg.48.2017.07.14.00.00.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 00:00:49 -0700 (PDT)
Message-ID: <1500015641.2865.81.camel@kernel.crashing.org>
Subject: Re: Potential race in TLB flush batching?
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 14 Jul 2017 17:00:41 +1000
In-Reply-To: <CALCETrXvkF3rxLijtou3ndSxG9vu62hrqh1ZXkaWgWbL-wd+cg@mail.gmail.com>
References: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
	 <20170711064149.bg63nvi54ycynxw4@suse.de>
	 <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
	 <20170711092935.bogdb4oja6v7kilq@suse.de>
	 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
	 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
	 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
	 <20170711155312.637eyzpqeghcgqzp@suse.de>
	 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
	 <20170711191823.qthrmdgqcd3rygjk@suse.de>
	 <CALCETrXvkF3rxLijtou3ndSxG9vu62hrqh1ZXkaWgWbL-wd+cg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Mel Gorman <mgorman@suse.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, linux-mm@kvack.org

On Tue, 2017-07-11 at 15:07 -0700, Andy Lutomirski wrote:
> On Tue, Jul 11, 2017 at 12:18 PM, Mel Gorman <mgorman@suse.de> wrote:
> 
> I would change this slightly:
> 
> > +void flush_tlb_batched_pending(struct mm_struct *mm)
> > +{
> > +A A A A A A  if (mm->tlb_flush_batched) {
> > +A A A A A A A A A A A A A A  flush_tlb_mm(mm);
> 
> How about making this a new helper arch_tlbbatch_flush_one_mm(mm);
> The idea is that this could be implemented as flush_tlb_mm(mm), but
> the actual semantics needed are weaker.A  All that's really needed
> AFAICS is to make sure that any arch_tlbbatch_add_mm() calls on this
> mm that have already happened become effective by the time that
> arch_tlbbatch_flush_one_mm() returns.

Jumping in ... I just discovered that 'new' batching stuff... is it
documented anywhere ?

We already had some form of batching via the mmu_gather, now there's a
different somewhat orthogonal and it's completely unclear what it's
about and why we couldn't use what we already had. Also what
assumptions it makes if I want to port it to my arch....

The page table management code was messy enough without yet another
undocumented batching mechanism that isn't quite the one we already
had...
 
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
