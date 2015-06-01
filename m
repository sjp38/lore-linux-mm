Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 509EE6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 08:34:32 -0400 (EDT)
Received: by padjw17 with SMTP id jw17so36188881pad.2
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 05:34:32 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a13si21042247pbu.153.2015.06.01.05.34.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 05:34:31 -0700 (PDT)
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150601090341.GA7147@dhcp22.suse.cz>
	<201506011951.DCC81216.tMVQHLFOFFOJSO@I-love.SAKURA.ne.jp>
	<20150601114349.GE7147@dhcp22.suse.cz>
	<201506012110.GHJ73931.LVFOOMFtHOSFJQ@I-love.SAKURA.ne.jp>
	<20150601121759.GG7147@dhcp22.suse.cz>
In-Reply-To: <20150601121759.GG7147@dhcp22.suse.cz>
Message-Id: <201506012134.FAH39526.FtHJSLVMOOQFFO@I-love.SAKURA.ne.jp>
Date: Mon, 1 Jun 2015 21:34:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Mon 01-06-15 21:10:18, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Mon 01-06-15 19:51:05, Tetsuo Handa wrote:
> > > [...]
> > > > How can all fatal_signal_pending() "struct task_struct" get access to memory
> > > > reserves when only one of fatal_signal_pending() "struct task_struct" has
> > > > TIF_MEMDIE ?
> > > 
> > > Because of 
> > > 	/*
> > > 	 * If current has a pending SIGKILL or is exiting, then automatically
> > > 	 * select it.  The goal is to allow it to allocate so that it may
> > > 	 * quickly exit and free its memory.
> > > 	 *
> > > 	 * But don't select if current has already released its mm and cleared
> > > 	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
> > > 	 */
> > > 	if (current->mm &&
> > > 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> > > 		mark_oom_victim(current);
> > > 		goto out;
> > > 	}
> > 
> > Then, what guarantees that the thread which is between
> > down_write(&current->mm->mmap_sem) and up_write(&current->mm->mmap_sem)
> > (or whatever locks which are blocking the OOM victim) calls out_of_memory() ?
> > That thread might be doing !__GFP_FS allocation request.
> 
> Could you point to such a place?

I think sequence shown below is possible.

[Thread1-in-Porcess1         Thread2-in-Porcess1]    [Thread3-in-Process2]

mutex_lock(&inode->i_mutex);
                                                     kmalloc(GFP_KERNEL)
                                                     Invokes the OOM killer
                             Receives TIF_MEMDIE
Receives SIGKILL
                             Receives SIGKILL
                             mutex_lock(&inode->i_mutex); <= Waiting forever
kmalloc(GFP_NOFS); <= Can't return because out_of_memory() is not called.
mutex_unlock(&inode->i_mutex);
                             kmalloc(GFP_NOFS);
                             mutex_unlock(&inode->i_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
