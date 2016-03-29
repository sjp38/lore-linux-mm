Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 262A76B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 11:29:38 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id x3so14785818obt.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 08:29:38 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id rw1si430842obb.106.2016.03.29.08.29.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 08:29:32 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
	<201603292245.AAC12437.JFLMQVtSOHFFOO@I-love.SAKURA.ne.jp>
	<20160329142216.GE4466@dhcp22.suse.cz>
In-Reply-To: <20160329142216.GE4466@dhcp22.suse.cz>
Message-Id: <201603300029.JHE39088.OLFFStQOHFMVJO@I-love.SAKURA.ne.jp>
Date: Wed, 30 Mar 2016 00:29:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 29-03-16 22:45:40, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > __alloc_pages_may_oom is the central place to decide when the
> > > out_of_memory should be invoked. This is a good approach for most checks
> > > there because they are page allocator specific and the allocation fails
> > > right after.
> > > 
> > > The notable exception is GFP_NOFS context which is faking
> > > did_some_progress and keep the page allocator looping even though there
> > > couldn't have been any progress from the OOM killer. This patch doesn't
> > > change this behavior because we are not ready to allow those allocation
> > > requests to fail yet. Instead __GFP_FS check is moved down to
> > > out_of_memory and prevent from OOM victim selection there. There are
> > > two reasons for that
> > > 	- OOM notifiers might release some memory even from this context
> > > 	  as none of the registered notifier seems to be FS related
> > > 	- this might help a dying thread to get an access to memory
> > >           reserves and move on which will make the behavior more
> > >           consistent with the case when the task gets killed from a
> > >           different context.
> > 
> > Allowing !__GFP_FS allocations to get TIF_MEMDIE by calling the shortcuts in
> > out_of_memory() would be fine. But I don't like the direction you want to go.
> > 
> > I don't like failing !__GFP_FS allocations without selecting OOM victim
> > ( http://lkml.kernel.org/r/201603252054.ADH30264.OJQFFLMOHFSOVt@I-love.SAKURA.ne.jp ).
> 
> I didn't get to read and digest that email yet but from a quick glance
> it doesn't seem to be directly related to this patch. Even if we decide
> that __GFP_FS vs. OOM killer logic is flawed for some reason then would
> build on top as granting the access to memory reserves is not against
> it.
> 

I think that removing these shortcuts is better.

> > Also, I suggested removing all shortcuts by setting TIF_MEMDIE from oom_kill_process()
> > ( http://lkml.kernel.org/r/1458529634-5951-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ).
> 
> I personally do not like this much. I believe we have already tried to
> explain why we have (some of) those shortcuts. They might be too
> optimistic and there is a room for improvements for sure but I am not
> convinced we can get rid of them that easily.

These shortcuts are too optimistic. They assume that the target thread can call
exit_oom_victim() but the reality is that the target task can get stuck at
down_read(&mm->mmap_sem) in exit_mm(). If SIGKILL were sent to all thread
groups sharing that mm, the possibility of the target thread getting stuck at
down_read(&mm->mmap_sem) in exit_mm() is significantly reduced.

http://lkml.kernel.org/r/20160329141442.GD4466@dhcp22.suse.cz tried to let
the OOM reaper to call exit_oom_victim() on behalf of the target thread
by waking up the OOM reaper. But the OOM reaper won't call exit_oom_victim()
because the OOM reaper will fail to reap memory because some thread sharing
that mm and holding mm->mmap_sem for write will not receive SIGKILL if we use
these shortcuts. As far as I know, all existing explanations for why we have
these shortcuts are ignoring the possibility of such some thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
