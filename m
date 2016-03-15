Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 29F6E6B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 07:50:04 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id p65so22664768wmp.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 04:50:04 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id x5si32443723wjr.166.2016.03.15.04.50.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Mar 2016 04:50:03 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n205so3132589wmf.2
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 04:50:02 -0700 (PDT)
Date: Tue, 15 Mar 2016 12:50:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for
 oom_kill_allocating_task
Message-ID: <20160315115001.GE6108@dhcp22.suse.cz>
References: <1454505240-23446-6-git-send-email-mhocko@kernel.org>
 <20160217094855.GC29196@dhcp22.suse.cz>
 <20160219183419.GA30059@dhcp22.suse.cz>
 <201602201132.EFG90182.FOVtSOJHFOLFQM@I-love.SAKURA.ne.jp>
 <20160222094105.GD17938@dhcp22.suse.cz>
 <201603152015.JAE86937.VFOLtQFOFJOSHM@I-love.SAKURA.ne.jp>
 <20160315114300.GC6108@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160315114300.GC6108@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Tue 15-03-16 12:43:00, Michal Hocko wrote:
> On Tue 15-03-16 20:15:24, Tetsuo Handa wrote:
[...]
> > Two thread groups sharing the same mm can disable the OOM reaper
> > when all threads in the former thread group (which will be chosen
> > as an OOM victim by the OOM killer) can immediately call exit_mm()
> > via do_exit() (e.g. simply sleeping in killable state when the OOM
> > killer chooses that thread group) and some thread in the latter thread
> > group is contended on unkillable locks (e.g. inode mutex), due to
> > 
> > 	p = find_lock_task_mm(tsk);
> > 	if (!p)
> > 		return true;
> > 
> > in __oom_reap_task() and
> > 
> > 	can_oom_reap = !test_and_set_bit(MMF_OOM_KILLED, &mm->flags);
> > 
> > in oom_kill_process(). The OOM reaper is woken up in order to reap
> > the former thread group's memory, but it does nothing on the latter
> > thread group's memory because the former thread group can clear its mm
> > before the OOM reaper locks its mm. Even if subsequent out_of_memory()
> > call chose the latter thread group, the OOM reaper will not be woken up.
> > No memory is reaped. We need to queue all thread groups sharing that
> > memory if that memory should be reaped.
> 
> Why it wouldn't be enough to wake the oom reaper only for the oom
> victims? If the oom reaper races with the victims exit path then
> the next round of the out_of_memory will select a different thread
> sharing the same mm.

And just to prevent from a confusion. I mean waking up also when
fatal_signal_pending and we do not really go down to selecting an oom
victim. Which would be worth a separate patch on top of course.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
