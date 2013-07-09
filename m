Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 4A2D56B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 09:08:11 -0400 (EDT)
Date: Tue, 9 Jul 2013 15:08:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2] memcg: do not trap chargers with full callstack
 on OOM
Message-ID: <20130709130808.GF20281@dhcp22.suse.cz>
References: <20130211112240.GC19922@dhcp22.suse.cz>
 <20130222092332.4001E4B6@pobox.sk>
 <20130606160446.GE24115@dhcp22.suse.cz>
 <20130606181633.BCC3E02E@pobox.sk>
 <20130607131157.GF8117@dhcp22.suse.cz>
 <20130617122134.2E072BA8@pobox.sk>
 <20130619132614.GC16457@dhcp22.suse.cz>
 <20130622220958.D10567A4@pobox.sk>
 <20130624201345.GA21822@cmpxchg.org>
 <20130709130017.GE20281@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130709130017.GE20281@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue 09-07-13 15:00:17, Michal Hocko wrote:
> On Mon 24-06-13 16:13:45, Johannes Weiner wrote:
> > Hi guys,
> > 
> > On Sat, Jun 22, 2013 at 10:09:58PM +0200, azurIt wrote:
> > > >> But i'm sure of one thing - when problem occurs, nothing is able to
> > > >> access hard drives (every process which tries it is freezed until
> > > >> problem is resolved or server is rebooted).
> > > >
> > > >I would be really interesting to see what those tasks are blocked on.
> > > 
> > > I'm trying to get it, stay tuned :)
> > > 
> > > Today i noticed one bug, not 100% sure it is related to 'your' patch
> > > but i didn't seen this before. I noticed that i have lots of cgroups
> > > which cannot be removed - if i do 'rmdir <cgroup_directory>', it
> > > just hangs and never complete. Even more, it's not possible to
> > > access the whole cgroup filesystem until i kill that rmdir
> > > (anything, which tries it, just hangs). All unremoveable cgroups has
> > > this in 'memory.oom_control': oom_kill_disable 0 under_oom 1
> > 
> > Somebody acquires the OOM wait reference to the memcg and marks it
> > under oom but then does not call into mem_cgroup_oom_synchronize() to
> > clean up.  That's why under_oom is set and the rmdir waits for
> > outstanding references.
> > 
> > > And, yes, 'tasks' file is empty.
> > 
> > It's not a kernel thread that does it because all kernel-context
> > handle_mm_fault() are annotated properly, which means the task must be
> > userspace and, since tasks is empty, have exited before synchronizing.
> 
> Yes, well spotted. I have missed that while reviewing your patch.
> The follow up fix looks correct.

Hmm, I guess you wanted to remove !(fault & VM_FAULT_ERROR) test as well
otherwise the else BUG() path would be unreachable and we wouldn't know
that something fishy is going on.

> > Can you try with the following patch on top?
> > 
> > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > index 5db0490..9a0b152 100644
> > --- a/arch/x86/mm/fault.c
> > +++ b/arch/x86/mm/fault.c
> > @@ -846,17 +846,6 @@ static noinline int
> >  mm_fault_error(struct pt_regs *regs, unsigned long error_code,
> >  	       unsigned long address, unsigned int fault)
> >  {
> > -	/*
> > -	 * Pagefault was interrupted by SIGKILL. We have no reason to
> > -	 * continue pagefault.
> > -	 */
> > -	if (fatal_signal_pending(current)) {
> > -		if (!(fault & VM_FAULT_RETRY))
> > -			up_read(&current->mm->mmap_sem);
> > -		if (!(error_code & PF_USER))
> > -			no_context(regs, error_code, address);
> > -		return 1;
> > -	}
> >  	if (!(fault & VM_FAULT_ERROR))
> >  		return 0;
> >  
> 
> -- 
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
