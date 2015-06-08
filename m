Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6680D6B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 19:20:24 -0400 (EDT)
Received: by ieclw1 with SMTP id lw1so3675450iec.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 16:20:24 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com. [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id g76si3172959ioj.58.2015.06.08.16.20.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 16:20:23 -0700 (PDT)
Received: by iebmu5 with SMTP id mu5so3727370ieb.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 16:20:23 -0700 (PDT)
Date: Mon, 8 Jun 2015 16:20:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is
 configured
In-Reply-To: <20150608213218.GB18360@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1506081606500.17040@chino.kir.corp.google.com>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com> <20150605111302.GB26113@dhcp22.suse.cz> <alpine.DEB.2.10.1506081242250.13272@chino.kir.corp.google.com>
 <20150608213218.GB18360@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 8 Jun 2015, Michal Hocko wrote:

> On Mon 08-06-15 12:51:53, David Rientjes wrote:
> > On Fri, 5 Jun 2015, Michal Hocko wrote:
> > 
> > > > Nack, this is not the appropriate response to exit path livelocks.  By 
> > > > doing this, you are going to start unnecessarily panicking machines that 
> > > > have panic_on_oom set when it would not have triggered before.  If there 
> > > > is no reclaimable memory and a process that has already been signaled to 
> > > > die to is in the process of exiting has to allocate memory, it is 
> > > > perfectly acceptable to give them access to memory reserves so they can 
> > > > allocate and exit.  Under normal circumstances, that allows the process to 
> > > > naturally exit.  With your patch, it will cause the machine to panic.
> > > 
> > > Isn't that what the administrator of the system wants? The system
> > > is _clearly_ out of memory at this point. A coincidental exiting task
> > > doesn't change a lot in that regard. Moreover it increases a risk of
> > > unnecessarily unresponsive system which is what panic_on_oom tries to
> > > prevent from. So from my POV this is a clear violation of the user
> > > policy.
> > > 
> > 
> > We rely on the functionality that this patch is short cutting because we 
> > rely on userspace to trigger oom kills.  For system oom conditions, we 
> > must then rely on the kernel oom killer to set TIF_MEMDIE since userspace 
> > cannot grant it itself.  (I think the memcg case is very similar in that 
> > this patch is short cutting it, but I'm more concerned for the system oom 
> > in this case because it's a show stopper for us.)
> 
> Do you actually have panic_on_oops enabled?
> 

CONFIG_PANIC_ON_OOPS_VALUE should be 0, I'm not sure why that's relevant.

The functionality I'm referring to is that your patch now panics the 
machine for configs where /proc/sys/vm/panic_on_oom is set and the same 
scenario occurs as described above.  You're introducing userspace breakage 
because you are using panic_on_oom in a way that it hasn't been used in 
the past and isn't described as working in the documentation.

> > We want to send the SIGKILL, which will interrupt things like 
> 
> But this patch only changes the ordering of panic_on_oops vs.
> fatal_signal_pending(current) shortcut. So it can possible affect the
> case when the current is exiting during OOM. Is this the case that you
> are worried about?
> 

Yes, of course, the case specifically when the killed process is in the 
exit path due to a userspace oom kill and needs access to memory reserves 
to exit.  That's needed because the machine is oom (typically the only 
time a non-buggy userspace oom handler would kill a process).

This:

	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
	...
	if (current->mm &&
	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
		mark_oom_victim(current);
		goto out;
	}

is obviously buggy in that regard.  We need to be able to give a killed 
process or an exiting process memory reserves so it may (1) allocate prior 
to handling the signal and (2) be assured of exiting once it is in the 
exit path.

> The documentation clearly states:
> "
> If this is set to 1, the kernel panics when out-of-memory happens.
> However, if a process limits using nodes by mempolicy/cpusets,
> and those nodes become memory exhaustion status, one process
> may be killed by oom-killer. No panic occurs in this case.
> Because other nodes' memory may be free. This means system total status
> may be not fatal yet.
> 
> If this is set to 2, the kernel panics compulsorily even on the
> above-mentioned. Even oom happens under memory cgroup, the whole
> system panics.
> 
> The default value is 0.
> 1 and 2 are for failover of clustering. Please select either
> according to your policy of failover.
> "
> 
> So I read this as a reliability feature to handle oom situation as soon
> as possible.
> 

A userspace process that is killed by userspace that simply needs memory 
to handle the signal and exit is not oom.  We have always allowed current 
to have access to memory reserves to exit without triggering panic_on_oom.  
This is nothing new, and is not implied by the documentation to be the 
case.

I'm not going to spend all day trying to convince you that you cannot 
change the semantics of sysctls that have existed for years with new 
behavior especially when users require that behavior to handle userspace 
kills while still keeping their machines running.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
