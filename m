Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 47E656B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 08:10:17 -0400 (EDT)
Date: Mon, 15 Jun 2009 20:10:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090615121001.GA10944@localhost>
References: <20090615024520.786814520@intel.com> <4A35BD7A.9070208@linux.vnet.ibm.com> <20090615042753.GA20788@localhost> <20090615064447.GA18390@wotan.suse.de> <20090615070914.GC31969@one.firstfloor.org> <20090615071907.GA8665@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615071907.GA8665@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 03:19:07PM +0800, Nick Piggin wrote:
> On Mon, Jun 15, 2009 at 09:09:14AM +0200, Andi Kleen wrote:
> > On Mon, Jun 15, 2009 at 08:44:47AM +0200, Nick Piggin wrote:
> > > > 
> > > > So IMHO it's OK for .31 as long as we agree on the user interfaces,
> > > > ie. /proc/sys/vm/memory_failure_early_kill and the hwpoison uevent.
> > > > 
> > > > It comes a long way through numerous reviews, and I believe all the
> > > > important issues and concerns have been addressed. Nick, Rik, Hugh,
> > > > Ingo, ... what are your opinions? Is the uevent good enough to meet
> > > > your request to "die hard" or "die gracefully" or whatever on memory
> > > > failure events?
> > > 
> > > Uevent? As in, send a message to userspace? I don't think this
> > > would be ideal for a fail-stop/failover situation.
> > 
> > Agreed.
> > 
> > For failover you typically want a application level heartbeat anyways
> > to guard against user space software problems and if there's a kill then it
> > would catch it. Also again in you want to check against all corruptions you
> > have to do it in the low level handler or better watch corrected
> > events too to predict failures (but the later is quite hard to do generally). 
> > To some extent the first is already implemented on x86, e.g. set
> > the tolerance level to 0 will give more aggressive panics.
> > 
> > > I can't see a good reason to rush to merge it.
> > 
> > The low level x86 code for MCA recovery is in, just this high level
> > part is missing to kill the correct process. I think it would be good to merge 
> > a core now.  The basic code seems to be also as well tested as we can do it 
> > right now and exposing it to more users would be good. It's undoubtedly not 
> > perfect yet, but that's not a requirement for merge.
> > 
> > There's a lot of fancy stuff that could be done in addition,
> > but that's not really needed right now and for a lot of the fancy
> > ideas (I have enough on my own :) it's dubious they are actually
> > worth it.
> 
> Just my opinion. Normally it takes a lot longer for VM patches
> like this to go through, but it's not really up to me anyway.
> If Andrew or Linus has it in their head to merge it in 2.6.31,
> it's going to get merged ;) 
> 
>  
> > > IMO the userspace-visible changes have maybe not been considered
> > > too thoroughly, which is what I'd be most worried about. I probably
> > > missed seeing documentation of exact semantics and situations
> > > where admins should tune things one way or the other.
> > 
> > There's only a single tunable anyways, early kill vs late kill.
> > 
> > For KVM you need early kill, for the others it remains to be seen.
> 
> Right. It's almost like you need to do a per-process thing, and
> those that can handle things (such as the new SIGBUS or the new
> EIO) could get those, and others could be killed.

To send early SIGBUS kills to processes who has called
sigaction(SIGBUS, ...)?  KVM will sure do that. For other apps we
don't mind they can understand that signal at all.

> Early-kill for KVM does seem like reasonable justification on the
> surface, but when I think more about it, I wonder does the guest
> actually stand any better chance to correct the error if it is
> reported at time T rather than T+delta? (who knows what the page
> will be used for at any given time).

Early kill makes a lot difference for KVM.  Think about the vast
amount of clean page cache pages. With early kill the page can be
trivially isolated. With late kill the whole virtual machine dies
hard.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
