Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 30BAF6B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 03:08:25 -0500 (EST)
Date: Tue, 16 Feb 2010 19:08:17 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
Message-ID: <20100216080817.GK5723@laptop>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com>
 <20100216062035.GA5723@laptop>
 <alpine.DEB.2.00.1002152252310.2745@chino.kir.corp.google.com>
 <20100216072047.GH5723@laptop>
 <alpine.DEB.2.00.1002152342120.7470@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002152342120.7470@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 15, 2010 at 11:53:33PM -0800, David Rientjes wrote:
> On Tue, 16 Feb 2010, Nick Piggin wrote:
> 
> > > Because it is inconsistent at the user's expense, it has never panicked 
> > > the machine for memory controller ooms, so why is a cpuset or mempolicy 
> > > constrained oom conditions any different?
> > 
> > Well memory controller was added later, wasn't it? So if you think
> > that's a bug then a fix to panic on memory controller ooms might
> > be in order.
> > 
> 
> But what about the existing memcg users who set panic_on_oom == 2 and 
> don't expect the memory controller to be influenced by that?

But that was a bug in the addition of the memory controller. Either the
documentation should be fixed, or the implementation should be fixed.

 
> > >  It also panics the machine even 
> > > on VM_FAULT_OOM which is ridiculous,
> > 
> > Why?
> > 
> 
> Because the oom killer was never called for VM_FAULT_OOM before, we simply 
> sent a SIGKILL to current, i.e. the original panic_on_oom semantics were 
> not even enforced.

No but now they are. I don't know what your point is here because there
is no way the users of this interface can be expected to know about
VM_FAULT_OOM versus pagefault_out_of_memory let alone do anything useful
with that.

> 
> > > the tunable is certainly not being 
> > > used how it was documented
> > 
> > Why not? The documentation seems to match the implementation.
> > 
> 
> It was meant to panic the machine anytime it was out of memory, regardless 
> of the constraint, but that obviously doesn't match the memory controller 
> case.

Right, and it's been like that for 3 years and people who don't use
the memory controller will be using that tunable.

Let's fix the memory controller case.

>  Just because cpusets and mempolicies decide to use the oom killer 
> as a mechanism for enforcing a user-defined policy does not mean that we 
> want to panic for them: mempolicies, for example, are user created and do 
> not require any special capability.  Does it seem reasonable that an oom 
> condition on those mempolicy nodes should panic the machine when killing 
> the offender is possible (and perhaps even encouraged if the user sets a 
> high /proc/pid/oom_score_adj?)  In other words, is an admin setting 
> panic_on_oom == 2 really expecting that no application will use 
> set_mempolicy() or do an mbind()?  This is a very error-prone interface 
> that needs to be dealt with on a case-by-case basis and the perfect way to 
> do that is by setting the affected tasks to be OOM_DISABLE; that 
> interface, unlike panic_on_oom == 2, is very well understood by those with 
> CAP_SYS_RESOURCE.

I assume it is reasonable to want to panic on any OOM if you're after
fail-stop kind of behaviour. I guess that is why it was added. I see
more use for that case than panic_on_oom==1 case myself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
