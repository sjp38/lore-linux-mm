Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D1059440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:31:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c81so8148796wmd.10
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:31:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l202si1713012wmb.153.2017.07.14.01.31.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 01:31:16 -0700 (PDT)
Date: Fri, 14 Jul 2017 09:31:14 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170714083114.zhaz3pszrklnrn52@suse.de>
References: <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
 <20170711092935.bogdb4oja6v7kilq@suse.de>
 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <CALCETrXvkF3rxLijtou3ndSxG9vu62hrqh1ZXkaWgWbL-wd+cg@mail.gmail.com>
 <1500015641.2865.81.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1500015641.2865.81.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, linux-mm@kvack.org

On Fri, Jul 14, 2017 at 05:00:41PM +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2017-07-11 at 15:07 -0700, Andy Lutomirski wrote:
> > On Tue, Jul 11, 2017 at 12:18 PM, Mel Gorman <mgorman@suse.de> wrote:
> > 
> > I would change this slightly:
> > 
> > > +void flush_tlb_batched_pending(struct mm_struct *mm)
> > > +{
> > > +       if (mm->tlb_flush_batched) {
> > > +               flush_tlb_mm(mm);
> > 
> > How about making this a new helper arch_tlbbatch_flush_one_mm(mm);
> > The idea is that this could be implemented as flush_tlb_mm(mm), but
> > the actual semantics needed are weaker.  All that's really needed
> > AFAICS is to make sure that any arch_tlbbatch_add_mm() calls on this
> > mm that have already happened become effective by the time that
> > arch_tlbbatch_flush_one_mm() returns.
> 
> Jumping in ... I just discovered that 'new' batching stuff... is it
> documented anywhere ?
> 

This should be a new thread.

The original commit log has many of the details and the comments have
others. It's clearer what the boundaries are and what is needed from an
architecture with Andy's work on top which right now is easier to see
from tip/x86/mm

> We already had some form of batching via the mmu_gather, now there's a
> different somewhat orthogonal and it's completely unclear what it's
> about and why we couldn't use what we already had. Also what
> assumptions it makes if I want to port it to my arch....
> 

The batching in this context is more about mm's than individual pages
and was done this was as the number of mm's to track was potentially
unbound. At the time of implementation, tracking individual pages and the
extra bits for mmu_gather was overkill and fairly complex due to the need
to potentiall restart when the gather structure filled.

It may also be only a gain on a limited number of architectures depending
on exactly how an architecture handles flushing. At the time, batching
this for x86 in the worse-case scenario where all pages being reclaimed
were mapped from multiple threads knocked 24.4% off elapsed run time and
29% off system CPU but only on multi-socket NUMA machines. On UMA, it was
barely noticable. For some workloads where only a few pages are mapped or
the mapped pages on the LRU are relatively sparese, it'll make no difference.

The worst-case situation is extremely IPI intensive on x86 where many
IPIs were being sent for each unmap. It's only worth even considering if
you see that the time spent sending IPIs for flushes is a large portion
of reclaim.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
