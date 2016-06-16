Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B1B3A6B007E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 12:25:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g62so112217531pfb.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:25:16 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m87si6674668pfi.190.2016.06.16.09.25.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 09:25:15 -0700 (PDT)
Subject: Re: [PATCH 07/10] mm, oom: fortify task_will_free_mem
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160609142026.GF24777@dhcp22.suse.cz>
	<201606111710.IGF51027.OJLSOQtHVOFFFM@I-love.SAKURA.ne.jp>
	<20160613112746.GD6518@dhcp22.suse.cz>
	<201606162154.CGE05294.HJQOSMFFVFtOOL@I-love.SAKURA.ne.jp>
	<20160616142940.GK6836@dhcp22.suse.cz>
In-Reply-To: <20160616142940.GK6836@dhcp22.suse.cz>
Message-Id: <201606170040.FGC21882.FMLHOtVSFFJOQO@I-love.SAKURA.ne.jp>
Date: Fri, 17 Jun 2016 00:40:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 16-06-16 21:54:27, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Sat 11-06-16 17:10:03, Tetsuo Handa wrote:
> [...]
> > I still don't like it. current->mm == NULL in
> > 
> > -	if (current->mm &&
> > -	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> > +	if (task_will_free_mem(current)) {
> > 
> > is not highly unlikely. You obviously break commit d7a94e7e11badf84
> > ("oom: don't count on mm-less current process") on CONFIG_MMU=n kernels.
> 
> I still fail to see why you care about that case so much. The heuristic
> was broken for other reasons before this patch. The patch fixes a class
> of issues for both mmu and nommu. I can restore the current->mm check
> for now but the more I am thinking about it the less I am sure the
> commit you are referring to is evem correct/necessary.
> 
> It claims that the OOM killer would be stuck because the child would be
> sitting in the final schedule() until the parent reaps it. That is not
> true, though, because victim would be unhashed down in release_task()
> path so it is not visible by the oom killer when it is waiting for the
> parent.  I have completely missed that part when reviewing the patch. Or
> am I missing something...

That explanation started from 201411292304.CGF68419.MOLHVQtSFFOOJF@I-love.SAKURA.ne.jp
(Sat, 29 Nov 2014 23:04:33 +0900) in your mailbox. I confirmed that a TIF_MEMDIE
zombie inside the final schedule() in do_exit() is waiting for parent to reap.
release_task() will be called when parent noticed that there is a zombie, but
this OOM livelock situation prevented parent looping inside page allocator waiting
for that TIF_MEMDIE zombie from noticing that there is a zombie.

> 
> Anyway, would you be OK with the patch if I added the current->mm check
> and resolve its necessity in a separate patch?

Please correct task_will_free_mem() in oom_kill_process() as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
