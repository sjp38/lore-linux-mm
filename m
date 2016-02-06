Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 348BF440441
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 06:23:55 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id o185so83175226pfb.1
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 03:23:55 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id cn4si30803951pad.162.2016.02.06.03.23.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 Feb 2016 03:23:54 -0800 (PST)
Subject: Re: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160204144319.GD14425@dhcp22.suse.cz>
	<201602050008.HEG12919.FFOMOHVtQFSLJO@I-love.SAKURA.ne.jp>
	<20160204163113.GF14425@dhcp22.suse.cz>
	<201602052014.HBG52666.HFMOQVLFOSFJtO@I-love.SAKURA.ne.jp>
	<20160206083014.GA25220@dhcp22.suse.cz>
In-Reply-To: <20160206083014.GA25220@dhcp22.suse.cz>
Message-Id: <201602062023.ECG12960.QVStLJOHFOFMOF@I-love.SAKURA.ne.jp>
Date: Sat, 6 Feb 2016 20:23:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> I am not really sure I understand what you are trying to tell here to be honest
> but no I am not going to add any timers at this stage.

> Dropping TIF_MEMDIE will help to unlock OOM killer as soon as we know
> the current victim is no longer interesting for the OOM killer to allow
> further victims selection. If we add MMF_OOM_REAP_DONE after reaping and
> oom_scan_process_thread is taught to ignore those you will get all cases
> of shared memory handles properly AFAICS. Such a patch should be really
> trivial enhancement on top of the current code.

What I'm trying to tell is that we should prepare for corner cases where
dropping TIF_MEMDIE (or reaping the victim's memory) is not taken place.

What happens if TIF_MEMDIE was set at

	if (current->mm &&
	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
		mark_oom_victim(current);
		return true;
	}

in out_of_memory() because current thread received SIGKILL while doing
a GFP_KERNEL allocation of

  Do a GFP_KERNEL allocation.
  Bail out if GFP_KERNEL allocation failed.
  Hold a lock.
  Do a GFP_NOFS allocation.
  Release a lock.

sequence? If current thread is blocked at waiting for that lock held by
somebody else doing memory allocation, nothing will unlock the OOM killer
(because the OOM reaper is not woken up and a timer for unlocking the OOM
killer does not exist).

What happens if TIF_MEMDIE was set at

	task_lock(p);
	if (p->mm && task_will_free_mem(p)) {
		mark_oom_victim(p);
		task_unlock(p);
		put_task_struct(p);
		return;
	}
	task_unlock(p);

in oom_kill_process() when p is waiting for a lock held by somebody else
doing memory allocation? Since the OOM reaper will not be woken up,
nothing will unlock the OOM killer.

If TIF_MEMDIE was set at

	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
	mark_oom_victim(victim);
	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",

in oom_kill_process() but the OOM reaper was not woken up because of
p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN case, nothing will unlock
the OOM killer.

By always waking the OOM reaper up, we can delegate the duty of unlocking
the OOM killer (by clearing TIF_MEMDIE or some other means) to the OOM
reaper because the OOM reaper is tracking all TIF_MEMDIE tasks.

Of course, it is possible that we handle such corner cases by adding
a timer for unlocking the OOM killer (regardless of availability of the
OOM reaper). But if we do "whether a mm is reapable or not" check at the
OOM reaper side by waking the OOM reaper up whenever TIF_MEMDIE is set
on some task, we can increase likeliness of dropping TIF_MEMDIE (after
reaping the victim's memory) being taken place and reduce frequency of
killing more OOM victims by using a timer for unlocking the OOM killer.

> I would like to target the next merge window rather than have this out
> of tree for another release cycle which means that we should really
> focus on the current functionality and make sure we haven't missed
> anything. As there is no fundamental disagreement to the approach all
> the rest are just technicalities.

Of course, we can target the OOM reaper for the next merge window. I'm
suggesting you that my changes would help handling corner cases (bugs)
you are not paying attention to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
