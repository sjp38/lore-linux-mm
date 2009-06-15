Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 008696B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 08:24:51 -0400 (EDT)
Date: Mon, 15 Jun 2009 14:25:28 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090615122528.GA13256@wotan.suse.de>
References: <20090615024520.786814520@intel.com> <4A35BD7A.9070208@linux.vnet.ibm.com> <20090615042753.GA20788@localhost> <20090615064447.GA18390@wotan.suse.de> <20090615070914.GC31969@one.firstfloor.org> <20090615071907.GA8665@wotan.suse.de> <20090615121001.GA10944@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615121001.GA10944@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 08:10:01PM +0800, Wu Fengguang wrote:
> On Mon, Jun 15, 2009 at 03:19:07PM +0800, Nick Piggin wrote:
> > > For KVM you need early kill, for the others it remains to be seen.
> > 
> > Right. It's almost like you need to do a per-process thing, and
> > those that can handle things (such as the new SIGBUS or the new
> > EIO) could get those, and others could be killed.
> 
> To send early SIGBUS kills to processes who has called
> sigaction(SIGBUS, ...)?  KVM will sure do that. For other apps we
> don't mind they can understand that signal at all.

For apps that hook into SIGBUS for some other means and
do not understand the new type of SIGBUS signal? What about
those?

 
> > Early-kill for KVM does seem like reasonable justification on the
> > surface, but when I think more about it, I wonder does the guest
> > actually stand any better chance to correct the error if it is
> > reported at time T rather than T+delta? (who knows what the page
> > will be used for at any given time).
> 
> Early kill makes a lot difference for KVM.  Think about the vast
> amount of clean page cache pages. With early kill the page can be
> trivially isolated. With late kill the whole virtual machine dies
> hard.

Why? In both cases it will enter the exception handler and
attempt to do something about it... in both cases I would
have thought there is some chance that the page error is not
recoverable and some chance it is recoverable. Or am I
missing something?

Anyway, I would like to see a basic analysis of those probabilities
to justify early kill. Not saying there is no justification, but
it would be helpful to see why.

Thanks,
Nick


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
