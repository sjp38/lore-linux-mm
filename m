Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A01C16B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:53:52 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a4so24535547lfa.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:53:52 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id jf6si6147121wjb.6.2016.06.16.08.53.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 08:53:50 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id k184so12472438wme.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:53:49 -0700 (PDT)
Date: Thu, 16 Jun 2016 17:53:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 07/10] mm, oom: fortify task_will_free_mem
Message-ID: <20160616155347.GO6836@dhcp22.suse.cz>
References: <20160609142026.GF24777@dhcp22.suse.cz>
 <201606111710.IGF51027.OJLSOQtHVOFFFM@I-love.SAKURA.ne.jp>
 <20160613112746.GD6518@dhcp22.suse.cz>
 <201606162154.CGE05294.HJQOSMFFVFtOOL@I-love.SAKURA.ne.jp>
 <20160616142940.GK6836@dhcp22.suse.cz>
 <201606170040.FGC21882.FMLHOtVSFFJOQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606170040.FGC21882.FMLHOtVSFFJOQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 17-06-16 00:40:41, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 16-06-16 21:54:27, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Sat 11-06-16 17:10:03, Tetsuo Handa wrote:
> > [...]
> > > I still don't like it. current->mm == NULL in
> > > 
> > > -	if (current->mm &&
> > > -	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> > > +	if (task_will_free_mem(current)) {
> > > 
> > > is not highly unlikely. You obviously break commit d7a94e7e11badf84
> > > ("oom: don't count on mm-less current process") on CONFIG_MMU=n kernels.
> > 
> > I still fail to see why you care about that case so much. The heuristic
> > was broken for other reasons before this patch. The patch fixes a class
> > of issues for both mmu and nommu. I can restore the current->mm check
> > for now but the more I am thinking about it the less I am sure the
> > commit you are referring to is evem correct/necessary.
> > 
> > It claims that the OOM killer would be stuck because the child would be
> > sitting in the final schedule() until the parent reaps it. That is not
> > true, though, because victim would be unhashed down in release_task()
> > path so it is not visible by the oom killer when it is waiting for the
> > parent.  I have completely missed that part when reviewing the patch. Or
> > am I missing something...
> 
> That explanation started from 201411292304.CGF68419.MOLHVQtSFFOOJF@I-love.SAKURA.ne.jp
> (Sat, 29 Nov 2014 23:04:33 +0900) in your mailbox. I confirmed that a TIF_MEMDIE
> zombie inside the final schedule() in do_exit() is waiting for parent to reap.
> release_task() will be called when parent noticed that there is a zombie, but
> this OOM livelock situation prevented parent looping inside page allocator waiting
> for that TIF_MEMDIE zombie from noticing that there is a zombie.

I cannot seem to find this msg-id. Anyway, let's forget it for now
to not get side tracked. I have to study that code more deeply to better
understand it.

> > Anyway, would you be OK with the patch if I added the current->mm check
> > and resolve its necessity in a separate patch?
> 
> Please correct task_will_free_mem() in oom_kill_process() as well.

We cannot hold task_lock over all task_will_free_mem I am even not sure
we have to develop an elaborate way to make it raceless just for the nommu
case. The current case is simple as we cannot race here. Is that
sufficient for you?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
