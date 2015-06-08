Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 797226B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 17:32:22 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so3229240wib.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 14:32:22 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id db5si3763600wib.63.2015.06.08.14.32.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 14:32:21 -0700 (PDT)
Received: by wgbgq6 with SMTP id gq6so113298304wgb.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 14:32:20 -0700 (PDT)
Date: Mon, 8 Jun 2015 23:32:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is configured
Message-ID: <20150608213218.GB18360@dhcp22.suse.cz>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com>
 <20150605111302.GB26113@dhcp22.suse.cz>
 <alpine.DEB.2.10.1506081242250.13272@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506081242250.13272@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 08-06-15 12:51:53, David Rientjes wrote:
> On Fri, 5 Jun 2015, Michal Hocko wrote:
> 
> > > Nack, this is not the appropriate response to exit path livelocks.  By 
> > > doing this, you are going to start unnecessarily panicking machines that 
> > > have panic_on_oom set when it would not have triggered before.  If there 
> > > is no reclaimable memory and a process that has already been signaled to 
> > > die to is in the process of exiting has to allocate memory, it is 
> > > perfectly acceptable to give them access to memory reserves so they can 
> > > allocate and exit.  Under normal circumstances, that allows the process to 
> > > naturally exit.  With your patch, it will cause the machine to panic.
> > 
> > Isn't that what the administrator of the system wants? The system
> > is _clearly_ out of memory at this point. A coincidental exiting task
> > doesn't change a lot in that regard. Moreover it increases a risk of
> > unnecessarily unresponsive system which is what panic_on_oom tries to
> > prevent from. So from my POV this is a clear violation of the user
> > policy.
> > 
> 
> We rely on the functionality that this patch is short cutting because we 
> rely on userspace to trigger oom kills.  For system oom conditions, we 
> must then rely on the kernel oom killer to set TIF_MEMDIE since userspace 
> cannot grant it itself.  (I think the memcg case is very similar in that 
> this patch is short cutting it, but I'm more concerned for the system oom 
> in this case because it's a show stopper for us.)

Do you actually have panic_on_oops enabled?

> We want to send the SIGKILL, which will interrupt things like 

But this patch only changes the ordering of panic_on_oops vs.
fatal_signal_pending(current) shortcut. So it can possible affect the
case when the current is exiting during OOM. Is this the case that you
are worried about?

> get_user_pages() which we find is our culprit most of the time.  When the 
> process enters the exit path, it must allocate other memory (slab, 
> coredumping and the very problematic proc_exit_connector()) to free 
> memory.  This patch would cause the machine to panic rather than utilizing 
> memory reserves so that it can exit, not as a result of a kernel oom kill 
> but rather a userspace kill.
> 
> Panic_on_oom is to suppress the kernel oom killer.  It's not a sysctl that 
> triggers whenever watermarks are hit and it doesn't suppress memory 
> reserves from being used for things like GFP_ATOMIC.  Setting TIF_MEMDIE 
> for an exiting process is another type of memory reserves and is 
> imperative that we have it to make forward progress. 

is your assumption about exiting process actually true? I mean there is
no _guarantee_ the process will manage to die with the available memory
reserves. Dependency blocking the task is another reason why we should
be careful about relying on TIF_MEMDIE.

> Panic_on_oom should 
> only trigger when the kernel can't make forward progress without killing 
> something (not true in this case).  I believe that's how the documentation 
> has always been interpreted and the tunable used in the wild.

The documentation clearly states:
"
If this is set to 1, the kernel panics when out-of-memory happens.
However, if a process limits using nodes by mempolicy/cpusets,
and those nodes become memory exhaustion status, one process
may be killed by oom-killer. No panic occurs in this case.
Because other nodes' memory may be free. This means system total status
may be not fatal yet.

If this is set to 2, the kernel panics compulsorily even on the
above-mentioned. Even oom happens under memory cgroup, the whole
system panics.

The default value is 0.
1 and 2 are for failover of clustering. Please select either
according to your policy of failover.
"

So I read this as a reliability feature to handle oom situation as soon
as possible.

> 
> It would be interesting to consider your other patch that refactors the 
> sysrq+f tunable.  I think we should make that never trigger panic_on_oom 
> (the sysadmin can use other sysrqs for that) and allow userspace to use 
> sysrq+f as a trigger when it is responsive to handle oom conditions.
> 
> But this patch itself can't possibly be merged.


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
