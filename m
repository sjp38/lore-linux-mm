Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD5CF280842
	for <linux-mm@kvack.org>; Wed, 10 May 2017 04:24:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q91so6023734wrb.8
        for <linux-mm@kvack.org>; Wed, 10 May 2017 01:24:30 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id 3si2612022wrk.214.2017.05.10.01.24.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 01:24:29 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id v42so6189578wrc.3
        for <linux-mm@kvack.org>; Wed, 10 May 2017 01:24:29 -0700 (PDT)
Date: Wed, 10 May 2017 10:24:25 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC 09/10] x86/mm: Rework lazy TLB to track the actual loaded mm
Message-ID: <20170510082425.5ks5okbjne7xgjtv@gmail.com>
References: <cover.1494160201.git.luto@kernel.org>
 <1a124281c99741606f1789140f9805beebb119da.1494160201.git.luto@kernel.org>
 <alpine.DEB.2.20.1705092236290.2295@nanos>
 <20170510055727.g6wojjiis36a6nvm@gmail.com>
 <alpine.DEB.2.20.1705101017590.1979@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1705101017590.1979@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>


* Thomas Gleixner <tglx@linutronix.de> wrote:

> On Wed, 10 May 2017, Ingo Molnar wrote:
> > 
> > * Thomas Gleixner <tglx@linutronix.de> wrote:
> > 
> > > On Sun, 7 May 2017, Andy Lutomirski wrote:
> > > >  /* context.lock is held for us, so we don't need any locking. */
> > > >  static void flush_ldt(void *current_mm)
> > > >  {
> > > > +	struct mm_struct *mm = current_mm;
> > > >  	mm_context_t *pc;
> > > >  
> > > > -	if (current->active_mm != current_mm)
> > > > +	if (this_cpu_read(cpu_tlbstate.loaded_mm) != current_mm)
> > > 
> > > While functional correct, this really should compare against 'mm'.
> > > 
> > > >  		return;
> > > >  
> > > > -	pc = &current->active_mm->context;
> > > > +	pc = &mm->context;
> > 
> > So this appears to be the function:
> > 
> >  static void flush_ldt(void *current_mm)
> >  {
> >         struct mm_struct *mm = current_mm;
> >         mm_context_t *pc;
> > 
> >         if (this_cpu_read(cpu_tlbstate.loaded_mm) != current_mm)
> >                 return;
> > 
> >         pc = &mm->context;
> >         set_ldt(pc->ldt->entries, pc->ldt->size);
> >  }
> > 
> > why not rename 'current_mm' to 'mm' and remove the 'mm' local variable?
> 
> Because you cannot dereference a void pointer, i.e. &mm->context ....

Indeed, doh! The naming totally confused me. The way I'd write it is the canonical 
form for such callbacks:

	static void flush_ldt(void *data)
	{
		struct mm_struct *mm = data;

... which beyond unconfusing me would probably also have prevented any accidental 
use of the 'current_mm' callback argument.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
