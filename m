Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 07CF86B03A4
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 03:29:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z81so10462040wrc.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 00:29:45 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g66si3297998wmi.68.2017.06.23.00.29.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 00:29:44 -0700 (PDT)
Date: Fri, 23 Jun 2017 09:29:35 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 11/11] x86/mm: Try to preserve old TLB entries using
 PCID
In-Reply-To: <CALCETrU5VfJMOENEff8HCVn3mihtC_e3xN7wotSimnJujR5YeA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1706230929260.2647@nanos>
References: <cover.1498022414.git.luto@kernel.org> <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org> <alpine.DEB.2.20.1706211159430.2328@nanos> <CALCETrUrwyMt+k4a-Tyh85Xiidr3zgEW7LKLnGDz90Z6jL9XtA@mail.gmail.com>
 <alpine.DEB.2.20.1706221037320.1885@nanos> <CALCETrVm9oQCpovr0aZcDXoG-8hOoYPMDyhYZJPSBNFGemXQNg@mail.gmail.com> <alpine.DEB.2.20.1706222319330.2221@nanos> <CALCETrU5VfJMOENEff8HCVn3mihtC_e3xN7wotSimnJujR5YeA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, 22 Jun 2017, Andy Lutomirski wrote:
> On Thu, Jun 22, 2017 at 2:22 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Thu, 22 Jun 2017, Andy Lutomirski wrote:
> >> On Thu, Jun 22, 2017 at 5:21 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> >> > Now one other optimization which should be trivial to add is to keep the 4
> >> > asid context entries in cpu_tlbstate and cache the last asid in thread
> >> > info. If that's still valid then use it otherwise unconditionally get a new
> >> > one. That avoids the whole loop machinery and thread info is cache hot in
> >> > the context switch anyway. Delta patch on top of your version below.
> >>
> >> I'm not sure I understand.  If an mm has ASID 0 on CPU 0 and ASID 1 on
> >> CPU 1 and a thread in that mm bounces back and forth between those
> >> CPUs, won't your patch cause it to flush every time?
> >
> > Yeah, I was too focussed on the non migratory case, where two tasks from
> > different processes play rapid ping pong. That's what I was looking at for
> > various reasons.
> >
> > There the cached asid really helps by avoiding the loop completely, but
> > yes, the search needs to be done for the bouncing between CPUs case.
> >
> > So maybe a combo of those might be interesting.
> >
> 
> I'm not too worried about optimizing away the loop.  It's a loop over
> four or six things that are all in cachelines that we need anyway.  I
> suspect that we'll never be able to see it in any microbenchmark, let
> alone real application.

Fair enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
