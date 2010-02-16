Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CCE946B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 02:20:57 -0500 (EST)
Date: Tue, 16 Feb 2010 18:20:47 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
Message-ID: <20100216072047.GH5723@laptop>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com>
 <20100216062035.GA5723@laptop>
 <alpine.DEB.2.00.1002152252310.2745@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002152252310.2745@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 15, 2010 at 10:59:26PM -0800, David Rientjes wrote:
> On Tue, 16 Feb 2010, Nick Piggin wrote:
> 
> > What is the point of removing it, though? If it doesn't significantly
> > help some future patch, just leave it in. It's not worth breaking the
> > user/kernel interface just to remove 3 trivial lines of code.
> > 
> 
> Because it is inconsistent at the user's expense, it has never panicked 
> the machine for memory controller ooms, so why is a cpuset or mempolicy 
> constrained oom conditions any different?

Well memory controller was added later, wasn't it? So if you think
that's a bug then a fix to panic on memory controller ooms might
be in order.

>  It also panics the machine even 
> on VM_FAULT_OOM which is ridiculous,

Why?

> the tunable is certainly not being 
> used how it was documented

Why not? The documentation seems to match the implementation.

> and so given the fact that mempolicy 
> constrained ooms are now much smarter with my rewrite and we never simply 
> kill current unless oom_kill_quick is enabled anymore, the compulsory 
> panic_on_oom == 2 mode is no longer required.  Simply set all tasks 
> attached to a cpuset or bound to a specific mempolicy to be OOM_DISABLE, 
> the kernel need not provide confusing alternative modes to sysctls for 
> this behavior.  Before panic_on_oom == 2 was introduced, it would have 
> only panicked the machine if panic_on_oom was set to a non-zero integer, 
> defining it be something different for '2' after it has held the same 
> semantics for years is inappropriate.

Well it was always defined in the documentation that it should be 0
or 1. Just that the limit wasn't enforced. I agree that's not ideal,
but anyway the existing and documented 0/1/2 has been there for 3 years
and so now removing the 2 is even worse.

>  There is just no concrete example 
> that anyone can give where they want a cpuset-constrained oom to panic the 
> machine when other tasks on a disjoint set of mems can continue to do 
> work and the cpuset of interest cannot have its tasks set to OOM_DISABLE.

But this is changing the way the environment is required to set up. So
a kernel upgrade can break previously working setups. We don't do this
without really good reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
