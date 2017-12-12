Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BDF76B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:44:19 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id h12so12521558wre.12
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:44:19 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 13si13246073wrw.98.2017.12.12.10.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 10:44:17 -0800 (PST)
Date: Tue, 12 Dec 2017 19:43:45 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 13/16] x86/ldt: Introduce LDT write fault handler
In-Reply-To: <20171212181902.a3dj3haouw3corhq@hirez.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.20.1712121942260.2289@nanos>
References: <20171212173221.496222173@linutronix.de> <20171212173334.345422294@linutronix.de> <CALCETrWHQW19G2J2hCS4ZG_U5knG-0RBzruioQzojqWr6ceTBg@mail.gmail.com> <20171212181902.a3dj3haouw3corhq@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 12 Dec 2017, Peter Zijlstra wrote:
> On Tue, Dec 12, 2017 at 09:58:58AM -0800, Andy Lutomirski wrote:
> > On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> > > +bool __ldt_write_fault(unsigned long address)
> > > +{
> > > +       struct ldt_struct *ldt = current->mm->context.ldt;
> > > +       unsigned long start, end, entry;
> > > +       struct desc_struct *desc;
> > > +
> > > +       start = (unsigned long) ldt->entries;
> > > +       end = start + ldt->nr_entries * LDT_ENTRY_SIZE;
> > > +
> > > +       if (address < start || address >= end)
> > > +               return false;
> > > +
> > > +       desc = (struct desc_struct *) ldt->entries;
> > > +       entry = (address - start) / LDT_ENTRY_SIZE;
> > > +       desc[entry].type |= 0x01;
> > 
> > You have another patch that unconditionally sets the accessed bit on
> > installation.  What gives?
> 
> Right, initially we didn't set that unconditionally. But even when we
> did do that, we've observed the CPU generating these write faults.
> 
> > Also, this patch is going to die a horrible death if IRET ever hits
> > this condition.  Or load gs.
> 
> Us touching the CS/SS descriptors with LAR should avoid IRET going off
> the rails, I'm not familiar with the whole gs thing, but we could very
> easily augment refresh_ldt_segments() I suppose.
> 
> Would you care to be a little more specific and or propose a testcase
> for this situation?

Again. load gs does not cause a fault at all like any other segment
load. The fault comes when the segment is accessed the first time or via
LAR. 

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
