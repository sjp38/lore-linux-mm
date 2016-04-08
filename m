Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 801BF6B007E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 07:50:36 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id l6so61480178wml.1
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 04:50:36 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id he1si13045561wjc.187.2016.04.08.04.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 04:50:35 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id l6so3733585wml.3
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 04:50:35 -0700 (PDT)
Date: Fri, 8 Apr 2016 13:50:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] oom, oom_reaper: Try to reap tasks which skip
 regular OOM killer path
Message-ID: <20160408115033.GH29820@dhcp22.suse.cz>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
 <1459951996-12875-3-git-send-email-mhocko@kernel.org>
 <201604072038.CHC51027.MSJOFVLHOFFtQO@I-love.SAKURA.ne.jp>
 <201604082019.EDH52671.OJHQFMStOFLVOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604082019.EDH52671.OJHQFMStOFLVOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com

On Fri 08-04-16 20:19:28, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > @@ -694,6 +746,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> > >  	task_lock(p);
> > >  	if (p->mm && task_will_free_mem(p)) {
> > >  		mark_oom_victim(p);
> > > +		try_oom_reaper(p);
> > >  		task_unlock(p);
> > >  		put_task_struct(p);
> > >  		return;
> > > @@ -873,6 +926,7 @@ bool out_of_memory(struct oom_control *oc)
> > >  	if (current->mm &&
> > >  	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> > >  		mark_oom_victim(current);
> > > +		try_oom_reaper(current);
> > >  		return true;
> > >  	}
> > >  
> 
> oom_reaper() will need to do "tsk->oom_reaper_list = NULL;" due to
> 
> 	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
> 		return;
> 
> test in wake_oom_reaper() if "[PATCH 3/3] mm, oom_reaper: clear
> TIF_MEMDIE for all tasks queued for oom_reaper" will select the same
> thread again.

true, will update my patch.

> Though I think we should not allow the OOM killer to select the same
> thread again.
> 
> > 
> > Why don't you call try_oom_reaper() from the shortcuts in
> > mem_cgroup_out_of_memory() as well?
> 
> I looked at next-20160408 but I again came to think that we should remove
> these shortcuts (something like a patch shown bottom).

feel free to send the patch with the full description. But I would
really encourage you to check the history to learn why those have been
added and describe why those concerns are not valid/important anymore.
Your way of throwing a large patch based on an extreme load which is
basically DoSing the machine is not the ideal one.

I do respect your different opinion. It is well possible that you are
right here and you can convince all the reviewers that your changes
are safe. I would be more than happy to drop my smaller steps approach
then. But I will be honest with you, you haven't convinced me yet and
I have seen so many subtle issues in this code area that the risk is
really non trivial for any larger changes. This is the primary reason I
am doing small steps each focusing on a single improvement which can be
argued about and is known to help a particular case without introducing
a risk of different problems. I am not the maintainer so it is not up to
me to select the right approach.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
