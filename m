Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8376810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 18:33:15 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x23so1391748wrb.6
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:33:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k129si464331wmf.136.2017.07.11.15.33.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 15:33:14 -0700 (PDT)
Date: Tue, 11 Jul 2017 23:33:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170711223311.iu7hxce5swmet6u3@suse.de>
References: <20170711064149.bg63nvi54ycynxw4@suse.de>
 <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
 <20170711092935.bogdb4oja6v7kilq@suse.de>
 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <CALCETrXvkF3rxLijtou3ndSxG9vu62hrqh1ZXkaWgWbL-wd+cg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALCETrXvkF3rxLijtou3ndSxG9vu62hrqh1ZXkaWgWbL-wd+cg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 03:07:57PM -0700, Andrew Lutomirski wrote:
> On Tue, Jul 11, 2017 at 12:18 PM, Mel Gorman <mgorman@suse.de> wrote:
> 
> I would change this slightly:
> 
> > +void flush_tlb_batched_pending(struct mm_struct *mm)
> > +{
> > +       if (mm->tlb_flush_batched) {
> > +               flush_tlb_mm(mm);
> 
> How about making this a new helper arch_tlbbatch_flush_one_mm(mm);
> The idea is that this could be implemented as flush_tlb_mm(mm), but
> the actual semantics needed are weaker.  All that's really needed
> AFAICS is to make sure that any arch_tlbbatch_add_mm() calls on this
> mm that have already happened become effective by the time that
> arch_tlbbatch_flush_one_mm() returns.
> 
> The initial implementation would be this:
> 
> struct flush_tlb_info info = {
>   .mm = mm,
>   .new_tlb_gen = atomic64_read(&mm->context.tlb_gen);
>   .start = 0,
>   .end = TLB_FLUSH_ALL,
> };
> 
> and the rest is like flush_tlb_mm_range().  flush_tlb_func_common()
> will already do the right thing, but the comments should probably be
> updated, too. 

Yes, from what I remember from your patches and a quick recheck, that should
be fine. I'll be leaving it until the morning to actually do the work. It
requires that your stuff be upstream first but last time I checked, they
were expected in this merge window.

> The benefit would be that, if you just call this on an
> mm when everything is already flushed, it will still do the IPIs but
> it won't do the actual flush.
> 

The benefit is somewhat marginal given that a process that has been
partially reclaimed already has taken a hit on any latency requirements
it has. However, it's a much better fit with your work in general.

> A better future implementation could iterate over each cpu in
> mm_cpumask(), and, using either a new lock or very careful atomics,
> check whether that CPU really needs flushing.  In -tip, all the
> information needed to figure this out is already there in the percpu
> state -- it's just not currently set up for remote access.
> 

Potentially yes although I'm somewhat wary of adding too much complexity
in that path. It'll either be very rare in which case the maintenance
cost isn't worth it or the process is being continually thrashed by
reclaim in which case saving a few TLB flushes isn't going to prevent
performance falling through the floor.

> For backports, it would just be flush_tlb_mm().
> 

Agreed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
