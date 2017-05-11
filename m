Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AADA96B0038
	for <linux-mm@kvack.org>; Thu, 11 May 2017 03:13:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n198so4320736wmg.9
        for <linux-mm@kvack.org>; Thu, 11 May 2017 00:13:53 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id h128si6610203wmh.135.2017.05.11.00.13.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 May 2017 00:13:51 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id g12so2164738wrg.2
        for <linux-mm@kvack.org>; Thu, 11 May 2017 00:13:51 -0700 (PDT)
Date: Thu, 11 May 2017 09:13:48 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC 09/10] x86/mm: Rework lazy TLB to track the actual loaded mm
Message-ID: <20170511071348.jhgzdgi7blhgenqj@gmail.com>
References: <cover.1494160201.git.luto@kernel.org>
 <1a124281c99741606f1789140f9805beebb119da.1494160201.git.luto@kernel.org>
 <alpine.DEB.2.20.1705092236290.2295@nanos>
 <20170510055727.g6wojjiis36a6nvm@gmail.com>
 <alpine.DEB.2.20.1705101017590.1979@nanos>
 <20170510082425.5ks5okbjne7xgjtv@gmail.com>
 <CALCETrV-c8n92v040HVw=6OdnNrLvN7ZAcAJ45Xs4wx-7H5r=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrV-c8n92v040HVw=6OdnNrLvN7ZAcAJ45Xs4wx-7H5r=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>


* Andy Lutomirski <luto@kernel.org> wrote:

> On Wed, May 10, 2017 at 1:24 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > * Thomas Gleixner <tglx@linutronix.de> wrote:
> >
> >> On Wed, 10 May 2017, Ingo Molnar wrote:
> >> >
> >> > * Thomas Gleixner <tglx@linutronix.de> wrote:
> >> >
> >> > > On Sun, 7 May 2017, Andy Lutomirski wrote:
> >> > > >  /* context.lock is held for us, so we don't need any locking. */
> >> > > >  static void flush_ldt(void *current_mm)
> >> > > >  {
> >> > > > +       struct mm_struct *mm = current_mm;
> >> > > >         mm_context_t *pc;
> >> > > >
> >> > > > -       if (current->active_mm != current_mm)
> >> > > > +       if (this_cpu_read(cpu_tlbstate.loaded_mm) != current_mm)
> >> > >
> >> > > While functional correct, this really should compare against 'mm'.
> >> > >
> >> > > >                 return;
> >> > > >
> >> > > > -       pc = &current->active_mm->context;
> >> > > > +       pc = &mm->context;
> >> >
> >> > So this appears to be the function:
> >> >
> >> >  static void flush_ldt(void *current_mm)
> >> >  {
> >> >         struct mm_struct *mm = current_mm;
> >> >         mm_context_t *pc;
> >> >
> >> >         if (this_cpu_read(cpu_tlbstate.loaded_mm) != current_mm)
> >> >                 return;
> >> >
> >> >         pc = &mm->context;
> >> >         set_ldt(pc->ldt->entries, pc->ldt->size);
> >> >  }
> >> >
> >> > why not rename 'current_mm' to 'mm' and remove the 'mm' local variable?
> >>
> >> Because you cannot dereference a void pointer, i.e. &mm->context ....
> >
> > Indeed, doh! The naming totally confused me. The way I'd write it is the canonical
> > form for such callbacks:
> >
> >         static void flush_ldt(void *data)
> >         {
> >                 struct mm_struct *mm = data;
> >
> > ... which beyond unconfusing me would probably also have prevented any accidental
> > use of the 'current_mm' callback argument.
> >
> >
> 
> void *data and void *info both seem fairly common in the kernel.

Yes, the most common variants are:

  triton:~/tip> git grep -E 'void.*\(.*void \*.*' | grep -vE ',|\*\*|;' | cut -d\( -f2- | cut -d\) -f1 | sort | uniq -c | sort -n | tail -10
     38 void *args
     38 void *p
     39 void *ptr
     42 void *foo
     46 void *context
     55 void *addr
     69 void *priv
     95 void *info
    235 void *arg
    292 void *data

> How about my personal favorite for non-kernel work, though: void *mm_void? It 
> documents what the parameter means and avoids the confusion.

Dunno, and at the risk of painting that shed bright red it reads a bit weird to 
me: void pointers are fine and are often primary parameters - the _real_ quality 
here is not that it's void, but that's it's an opaque value passed in from a 
common callback. Note that sometimes opaque data is 'unsigned long' (such as in 
the case of timers), so it's really not the 'void' that matters.

In that sense 'data', 'arg' or 'info' seem the most readable names, as they 
clearly express the type opaqueness.

My personal favorite is double underscores prefix, i.e. 'void *__mm', which would 
clearly signal that this is something special. But this does not appear to have 
been picked up overly widely:

  triton:~/tip> git grep -E 'void.*\(.*void \*.*' | grep -vE ',|\*\*|;' | cut -d\( -f2- | cut -d\) -f1 | sort | uniq -c | sort -n | grep __
      1 void *__data
      1 void *__info
      2 void *__dev
      2 void *__tdata
      2 void *__tve
      3 void *__lock
      3 void * __user *
      3 volatile void *__p
      4 void *__map

... but either of these variants is fine to me.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
