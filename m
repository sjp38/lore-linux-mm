Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4C96B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 11:20:03 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so18534734wic.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:20:02 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id kb8si39381175wjb.134.2015.08.25.08.20.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 08:20:02 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so18260799wid.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:20:01 -0700 (PDT)
Date: Tue, 25 Aug 2015 17:20:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [REPOST] [PATCH 2/2] mm,oom: Reverse the order of setting
 TIF_MEMDIE and sending SIGKILL.
Message-ID: <20150825152000.GH6285@dhcp22.suse.cz>
References: <201508231619.CGF82826.MJtVLSHOFFQOOF@I-love.SAKURA.ne.jp>
 <20150824094718.GF17078@dhcp22.suse.cz>
 <201508252106.JIE81718.FHOOFSJFMQLtOV@I-love.SAKURA.ne.jp>
 <20150825141735.GD6285@dhcp22.suse.cz>
 <201508252337.IHC12433.OFHFFOtQOSLJVM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508252337.IHC12433.OFHFFOtQOSLJVM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Tue 25-08-15 23:37:27, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > The code would be easier then and the race window much smaller. If we
> > > > really needed to prevent from preemption then preempt_{enable,disable}
> > > > aournd the whole task_lock region + do_send_sig_info would be still
> > > > easier to follow than re-taking task_lock.
> > > 
> > > What's wrong with re-taking task_lock? It seems to me that re-taking
> > > task_lock is more straightforward and easier to follow.
> > 
> > I dunno it looks more awkward to me. You have to re-check the victim->mm
> > after retaking the lock because situation might have changed while the
> > lock was dropped. If the mark_oom_victim & do_send_sig_info are in the
> > same preempt region then nothing like that is needed. But this is
> > probably a matter of taste. I find the above more readable but let's see
> > what others think.
> 
> Disabling preemption does not guarantee that the race window is small enough.
> 
> If we set TIF_MEMDIE before sending SIGKILL, long interrupts (an extreme
> example is SysRq-t from keyboard which would last many seconds) can step
> between. We will spend some percent (the worst case is 100 percent) of memory
> reserves for allocations which are not needed for termination.

I wouldn't be worried about sysrq+t because that requires the
administrator. And IRQs shouldn't take too long normally. But I guess
you are right that this will be inherently less fragile long term. All
other callers of mark_oom_victim except for lowmem_scan are safe. Could
you update the lmk as well please?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
