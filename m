Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1476B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 05:44:00 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so11879211wiw.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 02:43:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ym6si10398402wjc.130.2015.06.09.02.43.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 02:43:58 -0700 (PDT)
Date: Tue, 9 Jun 2015 11:43:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is configured
Message-ID: <20150609094356.GB29057@dhcp22.suse.cz>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com>
 <20150605111302.GB26113@dhcp22.suse.cz>
 <alpine.DEB.2.10.1506081242250.13272@chino.kir.corp.google.com>
 <20150608213218.GB18360@dhcp22.suse.cz>
 <alpine.DEB.2.10.1506081606500.17040@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506081606500.17040@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 08-06-15 16:20:21, David Rientjes wrote:
> On Mon, 8 Jun 2015, Michal Hocko wrote:
[...]
> > On Mon 08-06-15 12:51:53, David Rientjes wrote:
> > Do you actually have panic_on_oops enabled?
> > 
> 
> CONFIG_PANIC_ON_OOPS_VALUE should be 0, I'm not sure why that's relevant.

No I meant panic_on_oops > 0.

> The functionality I'm referring to is that your patch now panics the 
> machine for configs where /proc/sys/vm/panic_on_oom is set and the same 
> scenario occurs as described above.  You're introducing userspace breakage 
> because you are using panic_on_oom in a way that it hasn't been used in 
> the past and isn't described as working in the documentation.

I am sorry, but I do not follow. The knob has been always used to
_panic_ the OOM system. Nothing more and nothing less. Now you
are arguing about the change being buggy because a task might be
killed but that argument doesn't make much sense to me because
basically _any_ other allocation which allows OOM to trigger might hit
check_panic_on_oom() and panic the system well before your killed task
gets a chance to terminate.

I would understand your complain if we waited for oom victim(s) before
check_panic_on_oom but we have not been doing that.

> > > We want to send the SIGKILL, which will interrupt things like 
> > 
> > But this patch only changes the ordering of panic_on_oops vs.
> > fatal_signal_pending(current) shortcut. So it can possible affect the
> > case when the current is exiting during OOM. Is this the case that you
> > are worried about?
> > 
> 
> Yes, of course, the case specifically when the killed process is in the 
> exit path due to a userspace oom kill and needs access to memory reserves 
> to exit.  That's needed because the machine is oom (typically the only 
> time a non-buggy userspace oom handler would kill a process).
>
> This:
> 
> 	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
> 	...
> 	if (current->mm &&
> 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> 		mark_oom_victim(current);
> 		goto out;
> 	}
> 
> is obviously buggy in that regard.  We need to be able to give a killed 
> process or an exiting process memory reserves so it may (1) allocate prior 
> to handling the signal and (2) be assured of exiting once it is in the 
> exit path.

Which OOM path are you talking about here? memcg OOM user space handler
killing a task? This one however doesn't go this path unless the memcg
OOM is racing with the global OOM. Is this the case you are worried
about? If yes then this is racy anyway and nothing to rely on as
described above.
If you have a global OOM detection mechanism then it is racy as well
for the very same reason. User space OOM handling with panic_on_oom
is simply not usable.
 
> > The documentation clearly states:
> > "
> > If this is set to 1, the kernel panics when out-of-memory happens.
> > However, if a process limits using nodes by mempolicy/cpusets,
> > and those nodes become memory exhaustion status, one process
> > may be killed by oom-killer. No panic occurs in this case.
> > Because other nodes' memory may be free. This means system total status
> > may be not fatal yet.
> > 
> > If this is set to 2, the kernel panics compulsorily even on the
> > above-mentioned. Even oom happens under memory cgroup, the whole
> > system panics.
> > 
> > The default value is 0.
> > 1 and 2 are for failover of clustering. Please select either
> > according to your policy of failover.
> > "
> > 
> > So I read this as a reliability feature to handle oom situation as soon
> > as possible.
> > 
> 
> A userspace process that is killed by userspace that simply needs memory 
> to handle the signal and exit is not oom.  We have always allowed current 
> to have access to memory reserves to exit without triggering panic_on_oom.  
> This is nothing new, and is not implied by the documentation to be the 
> case.

The documentation doesn't mention anything about exiting task or any
other last minute attempt to be nice and prevent from OOM killing.
And moreover the assumption that TIF_MEMDIE will help to exit the oom
victim or a task with fatal_signal_pending is not true in general (and
you haven't provided sound arguments yet).

> I'm not going to spend all day trying to convince you that you cannot 
> change the semantics of sysctls that have existed for years with new 
> behavior especially when users require that behavior to handle userspace 
> kills while still keeping their machines running.

Let me remind that you are trying to nack this patch and your
argumentation is unclear at best.

The matter seems quite simple to me. Relying on fatal_signal_pending(current)
to help before check_panic_on_oom might help to prevent OOM but it is
racy and cannot be relied on while not going to check_panic_on_oom might
be potentially harmful, albeil unlikely, and lock up machine which is
against the user defined policy to panic machine on OOM.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
