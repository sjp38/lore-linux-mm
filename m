Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 6BA286B0034
	for <linux-mm@kvack.org>; Sat,  1 Jun 2013 11:15:49 -0400 (EDT)
Date: Sat, 1 Jun 2013 11:15:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130601151537.GD15576@cmpxchg.org>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
 <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
 <20130601061151.GC15576@cmpxchg.org>
 <20130601102905.GB19474@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130601102905.GB19474@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Sat, Jun 01, 2013 at 12:29:05PM +0200, Michal Hocko wrote:
> On Sat 01-06-13 02:11:51, Johannes Weiner wrote:
> [...]
> > I'm currently messing around with the below patch.  When a task faults
> > and charges under OOM, the memcg is remembered in the task struct and
> > then made to sleep on the memcg's OOM waitqueue only after unwinding
> > the page fault stack.  With the kernel OOM killer disabled, all tasks
> > in the OOMing group sit nicely in
> > 
> >   mem_cgroup_oom_synchronize
> >   pagefault_out_of_memory
> >   mm_fault_error
> >   __do_page_fault
> >   page_fault
> >   0xffffffffffffffff
> > 
> > regardless of whether they were faulting anon or file.  They do not
> > even hold the mmap_sem anymore at this point.
> > 
> > [ I kept syscalls really simple for now and just have them return
> >   -ENOMEM, never trap them at all (just like the global OOM case).
> >   It would be more work to have them wait from a flatter stack too,
> >   but it should be doable if necessary. ]
> > 
> > I suggested this at the MM summit and people were essentially asking
> > if I was feeling well, so maybe I'm still missing a gaping hole in
> > this idea.
> 
> I didn't get to look at the patch (will do on Monday) but it doesn't
> sounds entirely crazy. Well, we would have to drop mmap_sem so things
> have to be rechecked but we are doing that already with VM_FAULT_RETRY
> in some archs so it should work.

The global OOM case has been doing this for a long time (1c0fe6e mm:
invoke oom-killer from page fault), way before VM_FAULT_RETRY.  The
fault is aborted with VM_FAULT_OOM and the oom killer is invoked.
Either the task gets killed or it'll just retrigger the fault.  The
only difference is that a memcg OOM kill may take longer because of
userspace handling, so memcg needs a waitqueue where the global case
simply does a trylock (try_set_zonelist_oom) and restarts the fault
immediately if somebody else is handling the situation.

In fact, when Nick added the page fault OOM invocation, KAME merged
something similar to my patch, which tried to catch memcg OOM kills
from pagefault_out_of_memory() (a636b32 memcg: avoid unnecessary
system-wide-oom-killer).

Only when he reworked the whole memcg OOM synchronization, added the
ability to disable OOM and the waitqueues etc, the OOMs were trapped
right there in the charge context (867578c memcg: fix oom kill
behavior).  But I see no reason why we shouldn't be able to keep the
waitqueues and still go back to synchronizing from the bottom of the
page fault stack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
