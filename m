Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA6DE6B007D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 19:54:39 -0500 (EST)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id o1H0safE010618
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 16:54:36 -0800
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by spaceape11.eur.corp.google.com with ESMTP id o1H0sYAN002847
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 16:54:34 -0800
Received: by pzk33 with SMTP id 33so2291972pzk.2
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 16:54:33 -0800 (PST)
Date: Tue, 16 Feb 2010 16:54:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com> <20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
 <20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com> <20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com>
 <20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com> <20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > This should panic in mem_cgroup_out_of_memory() and the documentation 
> > should be added to Documentation/sysctl/vm.txt.
> > 
> > The memory controller also has some protection in the pagefault oom 
> > handler that seems like it could be made more general: instead of checking 
> > for mem_cgroup_oom_called(), I'd rather do a tasklist scan to check for 
> > already oom killed task (checking for the TIF_MEMDIE bit) and check all 
> > zones for ZONE_OOM_LOCKED.  If no oom killed tasks are found and no zones 
> > are locked, we can check sysctl_panic_on_oom and invoke the system-wide 
> > oom.
> > 
> plz remove memcg's hook after doing that. Current implemantation is desgined 
> not to affect too much to other cgroups by doing unnecessary jobs.
> 

Ok, I'll eliminate pagefault_out_of_memory() and get it to use 
out_of_memory() by only checking for constrained_alloc() when
gfp_mask != 0.

> > >  2. Second, I'll add OOM-notifier and freeze_at_oom to memcg.
> > >     and don't call memcg_out_of_memory in oom_kill.c in this case. Because
> > >     we don't kill anything. Taking coredumps of all procs in memcg is not
> > >     very difficult.
> > > 
> > 
> > The oom notifier would be at a higher level than the oom killer, the oom 
> > killer's job is simply to kill a task when it is called. 
> > So for these particular cases, you would never even call into out_of_memory() to panic 
> > the machine in the first place. 
> 
> That's my point. 
> 

Great, are you planning on implementing a cgroup that is based on roughly 
on the /dev/mem_notify patchset so userspace can poll() a file and be 
notified of oom events?  It would help beyond just memcg, it has an 
application to cpusets (adding more mems on large systems) as well.  It 
can also be used purely to preempt the kernel oom killer and move all the 
policy to userspace even though it would be sacrificing TIF_MEMDIE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
