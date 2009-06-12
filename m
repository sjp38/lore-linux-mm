Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 584DF6B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 09:48:40 -0400 (EDT)
Date: Fri, 12 Jun 2009 15:58:03 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when feature is disabled
Message-ID: <20090612135803.GL25568@one.firstfloor.org>
References: <20090611142239.192891591@intel.com> <20090611144430.414445947@intel.com> <20090612112258.GA14123@elte.hu> <20090612125741.GA6140@localhost> <20090612131754.GA32105@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090612131754.GA32105@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > In the above chunk, the process is trying to access the already 
> > corrupted page and thus shall be killed, otherwise it will either 
> > silently consume corrupted data, or will trigger another (deadly) 
> > MCE event and bring down the whole machine.
> 
> This seems like trying to handle a failure mode that cannot be and 
> shouldnt be 'handled' really. If there's an 'already corrupted' page 

I must slightly correct Fengguang, there is no silently consumed
corrupted data (at least not unless you disable machine checks, don't do
that). Or rather if the hardware cannot contain the error
it will definitely cause a panic and never call this.

Memory does have soft errors and the more memory you have the more
errors. Normally hardware hides that from you by correcting it, but
in some cases you can get multi-bit errors which lead to
uncorrected errors the hardware cannot hide.

This does not necessarily mean that the hardware is
broken; for example it can be caused by cosmic particles hitting
a unlucky transistor. So it can really happen in normal
operation.

The hardware contains these errors (it is marked "poisoned" in caches); 
if it was ever consumed there would be another machine check. 
The only problem is just that the other machine check couldn't be survived;
you would need to reboot.

But the hardware also supports telling the OS when it first detects
the error, which can be often before the error is consumed.

So hwpoison tries to get rid of the pages first when it can be safely
done with some help of the VM. This works because a lot of pages are 
"expendable", e.g. clean pages that can be just reloaded from disk or 
belonging to a process (so only that process is affected)

Another important use case is with virtualization: for a KVM guest you
only want to kill the guest that owns the affected memory, but not
the others. This is one of the features needed for KVM to catch up
with other hypervisors.

I should add it's generic infrastructure not only intended for x86, but
for generically for other architectures. e.g. we will get IA64 support
at some point and probably others too.

> then the box should go down hard and fast, and we should not risk 
> _even more user data corruption_ by trying to 'continue' in the hope 
> of having hit some 'harmless' user process that can be killed ...

Typically when there is a severe hardware failure (e.g. DIMM
completely dying) the box comes down pretty quickly due to multiple machine 
checks. I agree with you in this case panic is best. This code
does not really change that.

This infrastructure is more for handling standard error rates
where you can get an occasional error without panicing the box.
Panicing doesn't really help in this case.

> 
> So i find the whole feature rather dubious - what's the point? We 
> should panic at this point - we just corrupted user data so that 
> piece of hardware cannot be trusted. Nor can any subsequent kernel 

That's not an accurate description of what happens in real memory.
Even good memory has a error rate, how large it is depends on the 
environment. And obviously the error frequency rises with more DIMMs:
more transistors = more potential errors which also means more potential
uncorrected errors.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
