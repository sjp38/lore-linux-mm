Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 31FED6B004D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 19:31:07 -0500 (EST)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id o1H0VhJb018397
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 00:31:43 GMT
Received: from pxi41 (pxi41.prod.google.com [10.243.27.41])
	by spaceape13.eur.corp.google.com with ESMTP id o1H0VWBv022330
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 16:31:42 -0800
Received: by pxi41 with SMTP id 41so678435pxi.8
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 16:31:42 -0800 (PST)
Date: Tue, 16 Feb 2010 16:31:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com> <20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
 <20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com> <20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com>
 <20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:

> Hmm, I have a few reason to add special behavior to memcg rather than panic.
> 
>  - freeze_at_oom is enough.
>    If OOM can be notified, the management daemon can do useful jobs. Shutdown
>    all other cgroups or migrate them to other host and do kdump.
> 

The same could be said for cpusets if users use that for memory isolation.

> But, Hmm...I'd like to go this way.
> 
>  1. At first, support panic_on_oom=2 in memcg.
> 

This should panic in mem_cgroup_out_of_memory() and the documentation 
should be added to Documentation/sysctl/vm.txt.

The memory controller also has some protection in the pagefault oom 
handler that seems like it could be made more general: instead of checking 
for mem_cgroup_oom_called(), I'd rather do a tasklist scan to check for 
already oom killed task (checking for the TIF_MEMDIE bit) and check all 
zones for ZONE_OOM_LOCKED.  If no oom killed tasks are found and no zones 
are locked, we can check sysctl_panic_on_oom and invoke the system-wide 
oom.

>  2. Second, I'll add OOM-notifier and freeze_at_oom to memcg.
>     and don't call memcg_out_of_memory in oom_kill.c in this case. Because
>     we don't kill anything. Taking coredumps of all procs in memcg is not
>     very difficult.
> 

The oom notifier would be at a higher level than the oom killer, the oom 
killer's job is simply to kill a task when it is called.  So for these 
particular cases, you would never even call into out_of_memory() to panic 
the machine in the first place.  Hopefully, the oom notifier can be made 
to be more generic as its own cgroup rather than only being used by memcg, 
but if such a userspace notifier would defer to the kernel oom killer, it 
should panic when panic_on_oom == 2 is selected regardless of whether it 
is constrained or not.  Thus, we can keep the sysctl_panic_on_oom logic in 
the oom killer (both in out_of_memory() and mem_cgroup_out_of_memory()) 
without risk of unnecessarily panic whenever an oom notifier or 
freeze_at_oom setting intercepts the condition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
