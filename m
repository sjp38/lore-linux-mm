Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 281286B0095
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 11:34:07 -0400 (EDT)
Date: Fri, 12 Jun 2009 17:35:01 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when
	feature is disabled
Message-ID: <20090612153501.GA5737@elte.hu>
References: <20090611142239.192891591@intel.com> <20090611144430.414445947@intel.com> <20090612112258.GA14123@elte.hu> <20090612125741.GA6140@localhost> <20090612131754.GA32105@elte.hu> <alpine.LFD.2.01.0906120827020.3237@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0906120827020.3237@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Fri, 12 Jun 2009, Ingo Molnar wrote:
> > 
> > This seems like trying to handle a failure mode that cannot be 
> > and shouldnt be 'handled' really. If there's an 'already 
> > corrupted' page then the box should go down hard and fast, and 
> > we should not risk _even more user data corruption_ by trying to 
> > 'continue' in the hope of having hit some 'harmless' user 
> > process that can be killed ...
> 
> No, the box should _not_ go down hard-and-fast. That's the last 
> thing we should *ever* do.
> 
> We need to log it. Often at a user level (ie we want to make sure 
> it actually hits syslog, possibly goes out the network, maybe pops 
> up a window, whatever).
> 
> Shutting down the machine is the last thing we ever want to do.
> 
> The whole "let's panic" mentality is a disease.

No doubt about that - and i'm removing BUG_ON()s and panic()s 
wherever i can and havent added a single new one myself in the past 
5 years or so, its a disease.

If a fault hits a harmless piece of the system, then the log message 
will make it out and people know what happened. hwpoison does not 
affect that at all. If the fault hits the critical path towards 
gettig the log message out - then we wont get a log message, 
hwpoison or not.

My point is that hwpoison allows the _ignoring_ of hardware problems 
and thus pushes more buggy hardware up the pipeline.

Clusters will be running with this under the (false IMO) assumption 
that the kernel will tell the admin when something bad happened and 
the machine can limp along otherwise.

So i think hwpoison simply does not affect our ability to get log 
messages out - but it sure allows crappier hardware to be used.
Am i wrong about that for some reason?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
