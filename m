Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6244A280842
	for <linux-mm@kvack.org>; Wed, 10 May 2017 04:19:13 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w50so5995936wrc.4
        for <linux-mm@kvack.org>; Wed, 10 May 2017 01:19:13 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x142si3651723wme.58.2017.05.10.01.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 01:19:12 -0700 (PDT)
Date: Wed, 10 May 2017 10:19:02 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC 09/10] x86/mm: Rework lazy TLB to track the actual loaded
 mm
In-Reply-To: <20170510055727.g6wojjiis36a6nvm@gmail.com>
Message-ID: <alpine.DEB.2.20.1705101017590.1979@nanos>
References: <cover.1494160201.git.luto@kernel.org> <1a124281c99741606f1789140f9805beebb119da.1494160201.git.luto@kernel.org> <alpine.DEB.2.20.1705092236290.2295@nanos> <20170510055727.g6wojjiis36a6nvm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Wed, 10 May 2017, Ingo Molnar wrote:
> 
> * Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> > On Sun, 7 May 2017, Andy Lutomirski wrote:
> > >  /* context.lock is held for us, so we don't need any locking. */
> > >  static void flush_ldt(void *current_mm)
> > >  {
> > > +	struct mm_struct *mm = current_mm;
> > >  	mm_context_t *pc;
> > >  
> > > -	if (current->active_mm != current_mm)
> > > +	if (this_cpu_read(cpu_tlbstate.loaded_mm) != current_mm)
> > 
> > While functional correct, this really should compare against 'mm'.
> > 
> > >  		return;
> > >  
> > > -	pc = &current->active_mm->context;
> > > +	pc = &mm->context;
> 
> So this appears to be the function:
> 
>  static void flush_ldt(void *current_mm)
>  {
>         struct mm_struct *mm = current_mm;
>         mm_context_t *pc;
> 
>         if (this_cpu_read(cpu_tlbstate.loaded_mm) != current_mm)
>                 return;
> 
>         pc = &mm->context;
>         set_ldt(pc->ldt->entries, pc->ldt->size);
>  }
> 
> why not rename 'current_mm' to 'mm' and remove the 'mm' local variable?

Because you cannot dereference a void pointer, i.e. &mm->context ....

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
