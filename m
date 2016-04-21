Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65C1E6B02AD
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 09:07:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so22596371wme.0
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 06:07:57 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id x4si2953691wjl.170.2016.04.21.06.07.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 06:07:54 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id e201so86367204wme.0
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 06:07:54 -0700 (PDT)
Date: Thu, 21 Apr 2016 09:07:51 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
Message-ID: <20160421130750.GA18427@dhcp22.suse.cz>
References: <201604200006.FBG45192.SOHFQJFOOLFMtV@I-love.SAKURA.ne.jp>
 <20160419200752.GA10437@dhcp22.suse.cz>
 <201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
 <20160420144758.GA7950@dhcp22.suse.cz>
 <201604212049.GFE34338.OQFOJSMOHFFLVt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604212049.GFE34338.OQFOJSMOHFFLVt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Thu 21-04-16 20:49:16, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 20-04-16 06:55:42, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > > This patch adds a timeout for handling corner cases where a TIF_MEMDIE
> > > > > thread got stuck. Since the timeout is checked at oom_unkillable_task(),
> > > > > oom_scan_process_thread() will not find TIF_MEMDIE thread
> > > > > (for !oom_kill_allocating_task case) and oom_badness() will return 0
> > > > > (for oom_kill_allocating_task case).
> > > > > 
> > > > > By applying this patch, the kernel will automatically press SysRq-f if
> > > > > the OOM reaper cannot reap the victim's memory, and we will never OOM
> > > > > livelock forever as long as the OOM killer is called.
> > > > 
> > > > Which will not guarantee anything as already pointed out several times
> > > > before. So I think this is not really that useful. I have said it
> > > > earlier and will repeat it again. Any timeout based solution which
> > > > doesn't guarantee that the system will be in a consistent state (reboot,
> > > > panic or kill all existing tasks) after the specified timeout is
> > > > pointless.
> > > 
> > > Triggering the reboot/panic is the worst action. Killing all existing tasks
> > > is the next worst action. Thus, I prefer killing tasks one by one.
> > 
> > killing a task by task doesn't guarantee any convergence to a usable
> > state. If somebody really cares about these highly unlikely lockups
> > I am pretty sure he would really appreciate to have a _reliable_ and
> > _guaranteed_ way out of that situation. Having a fuzzy mechanism to do
> > something in a good hope of resolving that state is just unhelpful.
> 
> Killing a task by task shall eventually converge to the kernel panic.

I (as an admin) do not want to wait unbounded amount of time though.
This is just not practical.

> But since we now have the OOM reaper, the possibility of needing to kill
> next task is very low. Killing a task by task via timeout is an insurance
> for rare situations where the OOM reaper cannot reap the OOM-killed thread's
> memory due to mmap_sem being held for write.

You are changing one unlikely situation for another and that's why I
think this is basically unusable in the real life and why I am so
strongly opposing it.

> (If TIF_MEMDIE were set to all
> OOM-kiled thread groups, the OOM killer can converge to the kernel panic
> more quickly by ignoring the rest of OOM-killed threads sharing the same
> memory, but that is a different patch.)
> 
> > 
> > If I was an admin and had a machine on the other side of the globe and
> > that machine just locked up due to OOM I would pretty much wanted to
> > force reboot as my other means of fixing that situation would be pretty
> > much close to zero otherwise.
> 
> I posted V2 of patch which also allows triggering the kernel panic via timeout.

I have seen that patch. I didn't get to review it properly yet as I am
still travelling. From a quick view I think it is conflating two things
together. I could see arguments for the panic part but I do not consider
the move-to-kill-another timeout as justified. I would have to see a
clear indication this is actually useful for real life usecases.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
