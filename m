Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D231A6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 10:02:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p64so401678922pfb.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 07:02:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id xp2si33838216pac.150.2016.07.25.07.02.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 07:02:49 -0700 (PDT)
Subject: Re: [PATCH v3 0/8] Change OOM killer to use list of mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160725084803.GE9401@dhcp22.suse.cz>
	<201607252007.BGI56224.SHVFLFOOFMJtOQ@I-love.SAKURA.ne.jp>
	<20160725112140.GF9401@dhcp22.suse.cz>
	<201607252047.CHG57343.JFSOHMFVOQFtLO@I-love.SAKURA.ne.jp>
	<20160725115900.GG9401@dhcp22.suse.cz>
In-Reply-To: <20160725115900.GG9401@dhcp22.suse.cz>
Message-Id: <201607252302.JFE86466.FOMFVFJOtSHQLO@I-love.SAKURA.ne.jp>
Date: Mon, 25 Jul 2016 23:02:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

Michal Hocko wrote:
> On Mon 25-07-16 20:47:03, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Mon 25-07-16 20:07:11, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > > Are you planning to change the scope where the OOM victims can access memory
> > > > > > reserves?
> > > > > 
> > > > > Yes. Because we know that there are some post exit_mm allocations and I
> > > > > do not want to get back to PF_EXITING and other tricks...
> > > > > 
> > > > > > (1) If you plan to allow the OOM victims to access memory reserves until
> > > > > >     TASK_DEAD, tsk_is_oom_victim() will be as trivial as
> > > > > > 
> > > > > > bool tsk_is_oom_victim(struct task_struct *task)
> > > > > > {
> > > > > > 	return task->signal->oom_mm;
> > > > > > }
> > > > > 
> > > > > yes, exactly. That's what I've tried to say above. with the oom_mm this
> > > > > is trivial to implement while mm lists will not help us much due to
> > > > > their life time. This also means that we know about the oom victim until
> > > > > it is unhashed and become invisible to the oom killer.
> > > > 
> > > > Then, what are advantages with allowing only OOM victims access to memory
> > > > reserves after they left exit_mm()?
> > > 
> > > Because they might need it in order to move on... Say you want to close
> > > all the files which might release considerable amount of memory or any
> > > other post exit_mm() resources.
> > 
> > OOM victims might need memory reserves in order to move on, but non OOM victims
> > might also need memory reserves in order to move on. And non OOM victims might
> > be blocking OOM victims via locks.
> 
> Yes that might be true but OOM situations are rare events and quite
> reduced in the scope. Considering all exiting tasks is more dangerous
> because they might deplete those memory reserves easily.

Why do you assume that we grant all of memory reserves?
I'm suggesting that we grant portion of memory reserves.
Killed/exiting tasks cannot deplete memory reserves.

> 
> > > > Since we assume that mm_struct is the primary source of memory consumption,
> > > > we don't select threads which already left exit_mm(). Since we assume that
> > > > mm_struct is the primary source of memory consumption, why should we
> > > > distinguish OOM victims and non OOM victims after they left exit_mm()?
> > > 
> > > Because we might prevent from pointless OOM killer selection that way.
> > 
> > That "might" sounds obscure to me.
> > 
> > If currently allocating task is not an OOM victim then not giving it
> > access to memory reserves will cause OOM victim selection.
> 
> Sure, that is true. I am talking about the case where the current victim
> tries to get out and exit and it needs a memory for that.
> 
> > We might prevent from pointless OOM victim selection by giving
> > killed/exiting tasks access to memory reserves.
> 
> This will open risks for other problems, I am afraid. Please note that
> we are only trying to reduce the damage as much as possible. There is no
> 100% correct thing to do.

My suggestion (allowing only portion of memory reserves) includes that
memory allocations done by killed/exiting tasks do not give up. That is,
try to guarantee that memory allocations for commit/cleanup operations
do not fail due to use of ALLOC_NO_WATERMARKS, for there is no means for
killed/exiting tasks to handle problems caused by memory allocation
failures.

> 
> > > If we know that the currently allocating task is an OOM victim then
> > > giving it access to memory reserves is preferable to selecting another
> > > oom victim.
> > 
> > If we know that the currently allocating task is killed/exiting then
> > giving it access to memory reserves is preferable to selecting another
> > OOM victim.
> 
> I believe this is getting getting off topic. Can we get back to mm list
> vs signal::oom_mm decision? I have expressed one aspect that would speak
> for oom_mm as it provides a persistent and easy to detect oom victim
> which would be tricky with the mm list approach. Could you name some
> arguments which would speak for the mm list and would be a problem with
> the other approach?

I thought we are talking about future plan. I didn't know you are asking for
some arguments which would speak for the mm list.

Since the mm list approach turned out that we after all need victim's
task_struct in order to test eligibility of victim's mm, the signal::oom_mm
approach will be easier to access both victim's task_struct and victim's mm
than the mm list approach. I'm fine with signal::oom_mm approach regarding
oom_scan_process_thread() part.

But I don't like use of ALLOC_NO_WATERMARKS by signal::oom_mm != NULL tasks
after they passed exit_mm(). Such behavior may cause post-exit_mm() allocation
requests which might be doing commit/cleanup operations to start failing. I'm
trying to reduce the damage as much as possible by not giving up memory
allocations by OOM victims or by killed/exiting tasks (unless __GFP_KILLABLE
is used and killed by SIGKILL). My approach will select next OOM victim when
killed/exiting tasks cannot satisfy their allocation requests even if some
portion of memory reserves are granted because my approach does not use
ALLOC_NO_WATERMARKS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
