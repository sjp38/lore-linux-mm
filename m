Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E777F6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 10:22:12 -0400 (EDT)
Date: Mon, 15 Jun 2009 22:22:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090615142225.GA11167@localhost>
References: <20090615024520.786814520@intel.com> <4A35BD7A.9070208@linux.vnet.ibm.com> <20090615042753.GA20788@localhost> <20090615064447.GA18390@wotan.suse.de> <20090615070914.GC31969@one.firstfloor.org> <20090615071907.GA8665@wotan.suse.de> <20090615121001.GA10944@localhost> <20090615122528.GA13256@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615122528.GA13256@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 08:25:28PM +0800, Nick Piggin wrote:
> On Mon, Jun 15, 2009 at 08:10:01PM +0800, Wu Fengguang wrote:
> > On Mon, Jun 15, 2009 at 03:19:07PM +0800, Nick Piggin wrote:
> > > > For KVM you need early kill, for the others it remains to be seen.
> > > 
> > > Right. It's almost like you need to do a per-process thing, and
> > > those that can handle things (such as the new SIGBUS or the new
> > > EIO) could get those, and others could be killed.
> > 
> > To send early SIGBUS kills to processes who has called
> > sigaction(SIGBUS, ...)?  KVM will sure do that. For other apps we
> > don't mind they can understand that signal at all.
> 
> For apps that hook into SIGBUS for some other means and

Yes I was referring to the sigaction(SIGBUS) apps, others will
be late killed anyway.

> do not understand the new type of SIGBUS signal? What about
> those?

We introduced two new SIGBUS codes:
        BUS_MCEERR_AO=5         for early kill
        BUS_MCEERR_AR=4         for late  kill
I'd assume a legacy application will handle them in the same way (both
are unexpected code to the application).

We don't care whether the application can be killed by BUS_MCEERR_AO
or BUS_MCEERR_AR depending on its SIGBUS handler implementation.
But (in the rare case) if the handler
- refused to die on BUS_MCEERR_AR, it may create a busy loop and
  flooding of SIGBUS signals, which is a bug of the application.
  BUS_MCEERR_AO is one time and won't lead to busy loops.
- does something that hurts itself (ie. data safety) on BUS_MCEERR_AO,
  it may well hurt the same way on BUS_MCEERR_AR. The latter one is
  unavoidable, so the application must be fixed anyway.

>  
> > > Early-kill for KVM does seem like reasonable justification on the
> > > surface, but when I think more about it, I wonder does the guest
> > > actually stand any better chance to correct the error if it is
> > > reported at time T rather than T+delta? (who knows what the page
> > > will be used for at any given time).
> > 
> > Early kill makes a lot difference for KVM.  Think about the vast
> > amount of clean page cache pages. With early kill the page can be
> > trivially isolated. With late kill the whole virtual machine dies
> > hard.
> 
> Why? In both cases it will enter the exception handler and
> attempt to do something about it... in both cases I would
> have thought there is some chance that the page error is not
> recoverable and some chance it is recoverable. Or am I
> missing something?

The early kill / late kill to KVM from the POV of host kernel matches
the MCE AO/AR events inside the KVM guest kernel. The key difference
between AO/AR is, whether the page is _being_ consumed.

It's a lot harder (if possible) to try to stop an active consumer.
For example, the clean cache pages can be consumed in many ways:
- be accessed by read()/write() or mapped read/write
- be reclaimed and then allocated for whatever new usage, for example,
  be zeroed by __GFP_ZERO, or be insert into another file and start
  read/write IO and be accessed by disk driver via DMA, or even be
  allocated for kernel slabs..
Frankly speaking I don't know how to stop all the above consumers.
We now simply die on AR events.

> Anyway, I would like to see a basic analysis of those probabilities
> to justify early kill. Not saying there is no justification, but
> it would be helpful to see why.

That's fine. I'd be glad if the above explanation paves way to
solutions for AR events :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
