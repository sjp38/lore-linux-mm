Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AE70C6B007D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 02:53:42 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o1G7rbI2026983
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 07:53:38 GMT
Received: from pzk17 (pzk17.prod.google.com [10.243.19.145])
	by wpaz29.hot.corp.google.com with ESMTP id o1G7raqa010405
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 23:53:36 -0800
Received: by pzk17 with SMTP id 17so4796761pzk.4
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 23:53:35 -0800 (PST)
Date: Mon, 15 Feb 2010 23:53:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100216072047.GH5723@laptop>
Message-ID: <alpine.DEB.2.00.1002152342120.7470@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com> <20100216062035.GA5723@laptop> <alpine.DEB.2.00.1002152252310.2745@chino.kir.corp.google.com>
 <20100216072047.GH5723@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, Nick Piggin wrote:

> > Because it is inconsistent at the user's expense, it has never panicked 
> > the machine for memory controller ooms, so why is a cpuset or mempolicy 
> > constrained oom conditions any different?
> 
> Well memory controller was added later, wasn't it? So if you think
> that's a bug then a fix to panic on memory controller ooms might
> be in order.
> 

But what about the existing memcg users who set panic_on_oom == 2 and 
don't expect the memory controller to be influenced by that?

> >  It also panics the machine even 
> > on VM_FAULT_OOM which is ridiculous,
> 
> Why?
> 

Because the oom killer was never called for VM_FAULT_OOM before, we simply 
sent a SIGKILL to current, i.e. the original panic_on_oom semantics were 
not even enforced.

> > the tunable is certainly not being 
> > used how it was documented
> 
> Why not? The documentation seems to match the implementation.
> 

It was meant to panic the machine anytime it was out of memory, regardless 
of the constraint, but that obviously doesn't match the memory controller 
case.  Just because cpusets and mempolicies decide to use the oom killer 
as a mechanism for enforcing a user-defined policy does not mean that we 
want to panic for them: mempolicies, for example, are user created and do 
not require any special capability.  Does it seem reasonable that an oom 
condition on those mempolicy nodes should panic the machine when killing 
the offender is possible (and perhaps even encouraged if the user sets a 
high /proc/pid/oom_score_adj?)  In other words, is an admin setting 
panic_on_oom == 2 really expecting that no application will use 
set_mempolicy() or do an mbind()?  This is a very error-prone interface 
that needs to be dealt with on a case-by-case basis and the perfect way to 
do that is by setting the affected tasks to be OOM_DISABLE; that 
interface, unlike panic_on_oom == 2, is very well understood by those with 
CAP_SYS_RESOURCE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
