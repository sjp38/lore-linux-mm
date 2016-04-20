Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65FDC6B0278
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 10:48:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u190so90743206pfb.0
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 07:48:04 -0700 (PDT)
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com. [209.85.220.54])
        by mx.google.com with ESMTPS id zm6si2464057pab.108.2016.04.20.07.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 07:48:01 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id er2so18527447pad.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 07:48:01 -0700 (PDT)
Date: Wed, 20 Apr 2016 10:47:58 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
Message-ID: <20160420144758.GA7950@dhcp22.suse.cz>
References: <201604200006.FBG45192.SOHFQJFOOLFMtV@I-love.SAKURA.ne.jp>
 <20160419200752.GA10437@dhcp22.suse.cz>
 <201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Wed 20-04-16 06:55:42, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > This patch adds a timeout for handling corner cases where a TIF_MEMDIE
> > > thread got stuck. Since the timeout is checked at oom_unkillable_task(),
> > > oom_scan_process_thread() will not find TIF_MEMDIE thread
> > > (for !oom_kill_allocating_task case) and oom_badness() will return 0
> > > (for oom_kill_allocating_task case).
> > > 
> > > By applying this patch, the kernel will automatically press SysRq-f if
> > > the OOM reaper cannot reap the victim's memory, and we will never OOM
> > > livelock forever as long as the OOM killer is called.
> > 
> > Which will not guarantee anything as already pointed out several times
> > before. So I think this is not really that useful. I have said it
> > earlier and will repeat it again. Any timeout based solution which
> > doesn't guarantee that the system will be in a consistent state (reboot,
> > panic or kill all existing tasks) after the specified timeout is
> > pointless.
> 
> Triggering the reboot/panic is the worst action. Killing all existing tasks
> is the next worst action. Thus, I prefer killing tasks one by one.

killing a task by task doesn't guarantee any convergence to a usable
state. If somebody really cares about these highly unlikely lockups
I am pretty sure he would really appreciate to have a _reliable_ and
_guaranteed_ way out of that situation. Having a fuzzy mechanism to do
something in a good hope of resolving that state is just unhelpful.

If I was an admin and had a machine on the other side of the globe and
that machine just locked up due to OOM I would pretty much wanted to
force reboot as my other means of fixing that situation would be pretty
much close to zero otherwise.

> I'm OK with shortening the timeout like N (when waiting for the 1st victim)
> + N/2 (the 2nd victim) + N/4 (the 3rd victim) + N/8 (the 4th victim) + ...
> but does it worth complicating the least unlikely path?

No it is not IMHO.
 
> > I believe that the chances of the lockup are much less likely with the
> > oom reaper and that we are not really urged to provide a new knob with a
> > random semantic. If we really want to have a timeout based thing better
> > make it behave reliably.
> 
> The threshold which the administrator can wait for ranges. Some may want to
> set few seconds because of 10 seconds /dev/watchdog timeout, others may want
> to set one minute because of not using watchdog. Thus, I think we should not
> hard code the timeout.

I guess you missed my point here. I didn't say this should be hardcoded
in any way. I am just saying that if we really want to do some timeout
based decisions we should better think about the semantic and that
should provide a reliable and deterministic means to resolve the problem.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
