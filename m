Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1833B6B005A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 03:50:00 -0400 (EDT)
Date: Wed, 17 Jun 2009 09:51:31 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when feature is disabled
Message-ID: <20090617075131.GC26664@wotan.suse.de>
References: <20090611142239.192891591@intel.com> <20090611144430.414445947@intel.com> <20090612112258.GA14123@elte.hu> <20090612125741.GA6140@localhost> <20090612131754.GA32105@elte.hu> <alpine.LFD.2.01.0906120827020.3237@localhost.localdomain> <20090612153501.GA5737@elte.hu> <20090615065232.GC18390@wotan.suse.de> <20090616202726.GB31443@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090616202726.GB31443@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Russ Anderson <rja@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 16, 2009 at 03:27:26PM -0500, Russ Anderson wrote:
> On Mon, Jun 15, 2009 at 08:52:32AM +0200, Nick Piggin wrote:
> > On Fri, Jun 12, 2009 at 05:35:01PM +0200, Ingo Molnar wrote:
> > > * Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > > > On Fri, 12 Jun 2009, Ingo Molnar wrote:
> > > > > 
> > > > > This seems like trying to handle a failure mode that cannot be 
> > > > > and shouldnt be 'handled' really. If there's an 'already 
> > > > > corrupted' page then the box should go down hard and fast, and 
> > > > > we should not risk _even more user data corruption_ by trying to 
> > > > > 'continue' in the hope of having hit some 'harmless' user 
> > > > > process that can be killed ...
> > > > 
> > > > No, the box should _not_ go down hard-and-fast. That's the last 
> > > > thing we should *ever* do.
> > > > 
> > > > We need to log it. Often at a user level (ie we want to make sure 
> > > > it actually hits syslog, possibly goes out the network, maybe pops 
> > > > up a window, whatever).
> > > > 
> > > > Shutting down the machine is the last thing we ever want to do.
> > > > 
> > > > The whole "let's panic" mentality is a disease.
> > > 
> > > No doubt about that - and i'm removing BUG_ON()s and panic()s 
> > > wherever i can and havent added a single new one myself in the past 
> > > 5 years or so, its a disease.
> > 
> > In HA failover systems you often do want to panic ASAP (after logging
> > to serial cosole I guess) if anything like this happens so the system
> > can be rebooted with minimal chance of data corruption spreading.
> 
> The whole point of hardware data poisoning is to avoid having to 
> panic the system due to the potential of undetected data corruption,
> because the corrupt data is always marked bad.  This has worked
> well on ia64 where applications that encounter bad data are killed
> and the memory poisoned and not reallocated, avoiding a system panic.
> 
> This has been used at customer sites for a few years.  The type
> customers that really check their data.  It is nice to see
> the hardware poison feature moving to the x86 "mainstream".

So long as you can get an MCE and panic if the corrupt data
actually gets consumed anywhere, then yes a "corrupt data
detected but not consumed" exception would not require a
panic.

I don't know enough about the arch details to know what kinds
of exceptions happen when.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
