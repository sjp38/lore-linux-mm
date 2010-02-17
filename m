Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 988606B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 21:28:10 -0500 (EST)
Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id o1H2SB9Z012793
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 18:28:12 -0800
Received: from pxi35 (pxi35.prod.google.com [10.243.27.35])
	by spaceape24.eur.corp.google.com with ESMTP id o1H2S9pV026777
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 18:28:10 -0800
Received: by pxi35 with SMTP id 35so1515868pxi.16
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 18:28:09 -0800 (PST)
Date: Tue, 16 Feb 2010 18:28:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100217111319.d342f10e.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002161825280.2768@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com> <20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
 <20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com> <20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com>
 <20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com> <20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com> <20100217111319.d342f10e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > What do you think about making pagefaults use out_of_memory() directly and 
> > respecting the sysctl_panic_on_oom settings?
> > 
> 
> I don't think this patch is good. Because several memcg can
> cause oom at the same time independently, system-wide oom locking is
> unsuitable. BTW, what I doubt is much more fundamental thing.
> 

We want to lock all populated zones with ZONE_OOM_LOCKED to avoid 
needlessly killing more than one task regardless of how many memcgs are 
oom.

> What I doubt at most is "why VM_FAULT_OOM is necessary ? or why we have
> to call oom_killer when page fault returns it".
> Is there someone who returns VM_FAULT_OOM without calling page allocator
> and oom-killer helps something in such situation ?
> 

Before we invoked the oom killer for VM_FAULT_OOM, we simply sent a 
SIGKILL to current because we simply don't have memory to fault the page 
in, it's better to select a memory-hogging task to kill based on badness() 
than to constantly kill current which may not help in the long term.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
