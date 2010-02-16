Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7AEBF6B007E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 01:59:38 -0500 (EST)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o1G6xZkZ004098
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 22:59:35 -0800
Received: from pwj7 (pwj7.prod.google.com [10.241.219.71])
	by kpbe12.cbf.corp.google.com with ESMTP id o1G6xAuo019728
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 22:59:34 -0800
Received: by pwj7 with SMTP id 7so767611pwj.13
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 22:59:32 -0800 (PST)
Date: Mon, 15 Feb 2010 22:59:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100216062035.GA5723@laptop>
Message-ID: <alpine.DEB.2.00.1002152252310.2745@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com> <20100216062035.GA5723@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, Nick Piggin wrote:

> What is the point of removing it, though? If it doesn't significantly
> help some future patch, just leave it in. It's not worth breaking the
> user/kernel interface just to remove 3 trivial lines of code.
> 

Because it is inconsistent at the user's expense, it has never panicked 
the machine for memory controller ooms, so why is a cpuset or mempolicy 
constrained oom conditions any different?  It also panics the machine even 
on VM_FAULT_OOM which is ridiculous, the tunable is certainly not being 
used how it was documented and so given the fact that mempolicy 
constrained ooms are now much smarter with my rewrite and we never simply 
kill current unless oom_kill_quick is enabled anymore, the compulsory 
panic_on_oom == 2 mode is no longer required.  Simply set all tasks 
attached to a cpuset or bound to a specific mempolicy to be OOM_DISABLE, 
the kernel need not provide confusing alternative modes to sysctls for 
this behavior.  Before panic_on_oom == 2 was introduced, it would have 
only panicked the machine if panic_on_oom was set to a non-zero integer, 
defining it be something different for '2' after it has held the same 
semantics for years is inappropriate.  There is just no concrete example 
that anyone can give where they want a cpuset-constrained oom to panic the 
machine when other tasks on a disjoint set of mems can continue to do 
work and the cpuset of interest cannot have its tasks set to OOM_DISABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
