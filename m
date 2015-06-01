Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 21D4A6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 08:18:02 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so68987331wic.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 05:18:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rw6si17803648wjb.95.2015.06.01.05.18.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 05:18:00 -0700 (PDT)
Date: Mon, 1 Jun 2015 14:17:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"
 message.
Message-ID: <20150601121759.GG7147@dhcp22.suse.cz>
References: <20150529144922.GE22728@dhcp22.suse.cz>
 <201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
 <20150601090341.GA7147@dhcp22.suse.cz>
 <201506011951.DCC81216.tMVQHLFOFFOJSO@I-love.SAKURA.ne.jp>
 <20150601114349.GE7147@dhcp22.suse.cz>
 <201506012110.GHJ73931.LVFOOMFtHOSFJQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506012110.GHJ73931.LVFOOMFtHOSFJQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Mon 01-06-15 21:10:18, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 01-06-15 19:51:05, Tetsuo Handa wrote:
> > [...]
> > > How can all fatal_signal_pending() "struct task_struct" get access to memory
> > > reserves when only one of fatal_signal_pending() "struct task_struct" has
> > > TIF_MEMDIE ?
> > 
> > Because of 
> > 	/*
> > 	 * If current has a pending SIGKILL or is exiting, then automatically
> > 	 * select it.  The goal is to allow it to allocate so that it may
> > 	 * quickly exit and free its memory.
> > 	 *
> > 	 * But don't select if current has already released its mm and cleared
> > 	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
> > 	 */
> > 	if (current->mm &&
> > 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> > 		mark_oom_victim(current);
> > 		goto out;
> > 	}
> 
> Then, what guarantees that the thread which is between
> down_write(&current->mm->mmap_sem) and up_write(&current->mm->mmap_sem)
> (or whatever locks which are blocking the OOM victim) calls out_of_memory() ?
> That thread might be doing !__GFP_FS allocation request.

Could you point to such a place?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
