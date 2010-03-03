Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 26E646B004D
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 19:44:39 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o230ibFE029874
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 16:44:37 -0800
Received: from pxi34 (pxi34.prod.google.com [10.243.27.34])
	by kpbe17.cbf.corp.google.com with ESMTP id o230iX1b020423
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 16:44:36 -0800
Received: by pxi34 with SMTP id 34so294950pxi.10
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 16:44:33 -0800 (PST)
Date: Tue, 2 Mar 2010 16:44:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
In-Reply-To: <20100303092417.1a2f0418.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003021639110.18535@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com> <alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com> <20100301101259.af730fa0.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003010204180.26824@chino.kir.corp.google.com>
 <20100302085932.7b22f830.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021547210.11946@chino.kir.corp.google.com> <20100303092417.1a2f0418.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010, KAMEZAWA Hiroyuki wrote:

> > Trying to set ZONE_OOM_LOCKED for all populated zones is fundamentally the 
> > correct thing to do on VM_FAULT_OOM when you don't know the context in 
> > which we're trying to allocate pages.  The _only_ thing that does is close 
> > a race between when another thread calls out_of_memory(), which is likely 
> > in such conditions, and the oom killer hasn't killed a task yet so we 
> > can't detect the TIF_MEMDIE bit during the tasklist scan.  Memcg is 
> > completely irrelevant with respect to this zone locking and that's why I 
> > didn't touch mem_cgroup_out_of_memory().  Did you seriously even read this 
> > patch?
> > 
> 
> Then, memcg will see second oom-kill.
> 

Sigh.  Memcg will only kill a second task if the parallel oom hasn't 
killed anything yet or the parallel oom kills a task that is not in the 
memcg, and that's because memcg needs to enforce its limit by killing 
something, freeing memory for the system won't help that.  We may kill 
another task for the system-wide oom after the memcg has already killed a 
task if the system-wide oom is iterating through the tasklist and the 
memcg kill sets TIF_MEMDIE too late.  That's independent of this patch, we 
can't go and recind an oom kill.  Labeling that as a regression is just 
not truthful, it's outside the scope of closing the VM_FAULT_OOM race.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
