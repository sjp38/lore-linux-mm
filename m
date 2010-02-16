Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4F36B008A
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 03:43:02 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o1G8gw7d020972
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 08:42:58 GMT
Received: from pxi32 (pxi32.prod.google.com [10.243.27.32])
	by wpaz21.hot.corp.google.com with ESMTP id o1G8gsV8014282
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 00:42:55 -0800
Received: by pxi32 with SMTP id 32so1451198pxi.3
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 00:42:54 -0800 (PST)
Date: Tue, 16 Feb 2010 00:42:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100216080817.GK5723@laptop>
Message-ID: <alpine.DEB.2.00.1002160035100.17122@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com> <20100216062035.GA5723@laptop> <alpine.DEB.2.00.1002152252310.2745@chino.kir.corp.google.com> <20100216072047.GH5723@laptop>
 <alpine.DEB.2.00.1002152342120.7470@chino.kir.corp.google.com> <20100216080817.GK5723@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, Nick Piggin wrote:

> > > > Because it is inconsistent at the user's expense, it has never panicked 
> > > > the machine for memory controller ooms, so why is a cpuset or mempolicy 
> > > > constrained oom conditions any different?
> > > 
> > > Well memory controller was added later, wasn't it? So if you think
> > > that's a bug then a fix to panic on memory controller ooms might
> > > be in order.
> > > 
> > 
> > But what about the existing memcg users who set panic_on_oom == 2 and 
> > don't expect the memory controller to be influenced by that?
> 
> But that was a bug in the addition of the memory controller. Either the
> documentation should be fixed, or the implementation should be fixed.
> 

The memory controller behavior seems intentional because it prevents 
panicking in two places: mem_cgroup_out_of_memory() never considers it and 
sysctl_panic_on_oom is preempted in pagefault_out_of_memory() if current's 
memcg is oom.

The documentation is currently right because it only mentions an 
application to cpusets and mempolicies.

That's the reason why I think we should eliminate it: it is completely 
bogus as it stands because it allows tasks to be killed in memory 
controller environments if their hard limit is reached unless they are set 
to OOM_DISABLE.  That doesn't have fail-stop behavior and trying to make 
exceptions to the rule is not true "fail-stop" that we need to preserve 
with this interface.

> > Because the oom killer was never called for VM_FAULT_OOM before, we simply 
> > sent a SIGKILL to current, i.e. the original panic_on_oom semantics were 
> > not even enforced.
> 
> No but now they are. I don't know what your point is here because there
> is no way the users of this interface can be expected to know about
> VM_FAULT_OOM versus pagefault_out_of_memory let alone do anything useful
> with that.
> 

I think VM_FAULT_OOM should panic the machine for panic_on_oom == 1 as it 
presently does, it needs no special handling otherwise.  But this is an 
example of where semantics of panic_on_oom have changed in the past where 
OOM_DISABLE would remove any ambiguity.  Instead of redefining the 
sysctl's semantics everytime we add another usecase for the oom killer, 
why can't we just use a single interface that has been around for years 
when a certain task shouldn't be killed?

> Let's fix the memory controller case.
> 

I doubt you'll find much support from the memory controller folks on that 
since they probably won't agree this is fail-stop behavior and killing a 
task when constrained by a memcg is appropriate because the user asked for 
a hard limit.

Again, OOM_DISABLE would remove all ambiguity and we wouldn't need to 
concern ourselves of what the semantics of a poorly chosen interface such 
as panic_on_oom == 2 is whenever we change the oom killer.

> I assume it is reasonable to want to panic on any OOM if you're after
> fail-stop kind of behaviour. I guess that is why it was added. I see
> more use for that case than panic_on_oom==1 case myself.
> 

panic_on_oom == 1 is reasonable since no system task can make forward 
progress in allocating memory, that isn't necessarily true of cpuset or 
mempolicy (or memcg) constrained applications.  Other cpusets, for 
instance, can continue to do work uninterrupted and without threat of 
having one of their tasks being oom killed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
