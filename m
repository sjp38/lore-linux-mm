Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C96706B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 09:17:32 -0400 (EDT)
Date: Fri, 12 Jun 2009 15:17:54 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when
	feature is disabled
Message-ID: <20090612131754.GA32105@elte.hu>
References: <20090611142239.192891591@intel.com> <20090611144430.414445947@intel.com> <20090612112258.GA14123@elte.hu> <20090612125741.GA6140@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090612125741.GA6140@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> Hi Ingo,
> 
> On Fri, Jun 12, 2009 at 07:22:58PM +0800, Ingo Molnar wrote:
> > 
> > * Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > So as to eliminate one #ifdef in the c source.
> > > 
> > > Proposed by Nick Piggin.
> > > 
> > > CC: Nick Piggin <npiggin@suse.de>
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > ---
> > >  arch/x86/mm/fault.c |    3 +--
> > >  include/linux/mm.h  |    7 ++++++-
> > >  2 files changed, 7 insertions(+), 3 deletions(-)
> > > 
> > > --- sound-2.6.orig/arch/x86/mm/fault.c
> > > +++ sound-2.6/arch/x86/mm/fault.c
> > > @@ -819,14 +819,13 @@ do_sigbus(struct pt_regs *regs, unsigned
> > >  	tsk->thread.error_code	= error_code;
> > >  	tsk->thread.trap_no	= 14;
> > >  
> > > -#ifdef CONFIG_MEMORY_FAILURE
> > >  	if (fault & VM_FAULT_HWPOISON) {
> > >  		printk(KERN_ERR
> > >  	"MCE: Killing %s:%d due to hardware memory corruption fault at %lx\n",
> > >  			tsk->comm, tsk->pid, address);
> > >  		code = BUS_MCEERR_AR;
> > >  	}
> > > -#endif
> > 
> > Btw., anything like this should happen in close cooperation with 
> > the x86 tree, not as some pure MM feature. I dont see Cc:s and 
> > nothing that indicates that realization. What's going on here?
> 
> Ah sorry for the ignorance!  Andi has a nice overview of the big 
> picture here: http://lkml.org/lkml/2009/6/3/371
> 
> In the above chunk, the process is trying to access the already 
> corrupted page and thus shall be killed, otherwise it will either 
> silently consume corrupted data, or will trigger another (deadly) 
> MCE event and bring down the whole machine.

This seems like trying to handle a failure mode that cannot be and 
shouldnt be 'handled' really. If there's an 'already corrupted' page 
then the box should go down hard and fast, and we should not risk 
_even more user data corruption_ by trying to 'continue' in the hope 
of having hit some 'harmless' user process that can be killed ...

So i find the whole feature rather dubious - what's the point? We 
should panic at this point - we just corrupted user data so that 
piece of hardware cannot be trusted. Nor can any subsequent kernel 
bug messages be trusted.

Do we really want this in the core Linux VM and in the architecture 
pagefault handling code and elsewhere? Am i the only one who finds 
this concept of 'handling' user data corruption rather dubious?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
