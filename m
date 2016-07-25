Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 60BE16B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:41:08 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id q11so402398249qtb.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 14:41:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u50si12225023ota.64.2016.07.25.14.41.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 14:41:07 -0700 (PDT)
Subject: Re: [PATCH v3 0/8] Change OOM killer to use list of mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160725112140.GF9401@dhcp22.suse.cz>
	<201607252047.CHG57343.JFSOHMFVOQFtLO@I-love.SAKURA.ne.jp>
	<20160725115900.GG9401@dhcp22.suse.cz>
	<201607252302.JFE86466.FOMFVFJOtSHQLO@I-love.SAKURA.ne.jp>
	<20160725141749.GI9401@dhcp22.suse.cz>
In-Reply-To: <20160725141749.GI9401@dhcp22.suse.cz>
Message-Id: <201607260640.CFJ12946.SMOFFQVHFJtLOO@I-love.SAKURA.ne.jp>
Date: Tue, 26 Jul 2016 06:40:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

Michal Hocko wrote:
> On Mon 25-07-16 23:02:35, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Mon 25-07-16 20:47:03, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > On Mon 25-07-16 20:07:11, Tetsuo Handa wrote:
> > > > > > Michal Hocko wrote:
> > > > > > > > Are you planning to change the scope where the OOM victims can access memory
> > > > > > > > reserves?
> > > > > > > 
> > > > > > > Yes. Because we know that there are some post exit_mm allocations and I
> > > > > > > do not want to get back to PF_EXITING and other tricks...
> > > > > > > 
> > > > > > > > (1) If you plan to allow the OOM victims to access memory reserves until
> > > > > > > >     TASK_DEAD, tsk_is_oom_victim() will be as trivial as
> > > > > > > > 
> > > > > > > > bool tsk_is_oom_victim(struct task_struct *task)
> > > > > > > > {
> > > > > > > > 	return task->signal->oom_mm;
> > > > > > > > }
> > > > > > > 
> > > > > > > yes, exactly. That's what I've tried to say above. with the oom_mm this
> > > > > > > is trivial to implement while mm lists will not help us much due to
> > > > > > > their life time. This also means that we know about the oom victim until
> > > > > > > it is unhashed and become invisible to the oom killer.
> > > > > > 
> > > > > > Then, what are advantages with allowing only OOM victims access to memory
> > > > > > reserves after they left exit_mm()?
> > > > > 
> > > > > Because they might need it in order to move on... Say you want to close
> > > > > all the files which might release considerable amount of memory or any
> > > > > other post exit_mm() resources.
> > > > 
> > > > OOM victims might need memory reserves in order to move on, but non OOM victims
> > > > might also need memory reserves in order to move on. And non OOM victims might
> > > > be blocking OOM victims via locks.
> > > 
> > > Yes that might be true but OOM situations are rare events and quite
> > > reduced in the scope. Considering all exiting tasks is more dangerous
> > > because they might deplete those memory reserves easily.
> > 
> > Why do you assume that we grant all of memory reserves?
> 
> I've said deplete "those memory reserves". It would be just too easy to
> exit many tasks at once and use up that memory.

But that will not be a problem unless an OOM event occurs. Even if some
portion of memory reserves are granted, killed/exiting tasks unlikely
access memory reserves. If killed/exiting tasks need to deplete that
portion of memory reserves, it is reasonable to select an OOM victim.

> 
> > I'm suggesting that we grant portion of memory reserves.
> 
> Which doesn't solve anything because it will always be a finite resource
> which can get depleted. This is basically the same as the oom victim
> (ab)using reserves accept that OOM is much less likely and it is under
> control of the kernel which task gets killed.

Given that OOM is much less likely event, maybe we even do not need to use
task_struct->oom_reaper_list and instead we can use a global variable

  static struct mm_struct *current_oom_mm;

and wait for current_oom_mm to become NULL regardless of in which domain an
OOM event occurred (as with we changed to use global oom_lock for preventing
concurrent OOM killer invocations)? Then, we can determine OOM_SCAN_ABORT by
inspecting that variable. This change may defer invocation of OOM killer in
different domains, but concurrent OOM events in different domains will be
also much less likely?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
