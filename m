Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 751126B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:37:47 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so9534489pad.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:37:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id bw2si33256648pbd.161.2015.08.25.07.37.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 07:37:46 -0700 (PDT)
Subject: Re: [REPOST] [PATCH 2/2] mm,oom: Reverse the order of setting TIF_MEMDIE and sending SIGKILL.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201508231619.CGF82826.MJtVLSHOFFQOOF@I-love.SAKURA.ne.jp>
	<20150824094718.GF17078@dhcp22.suse.cz>
	<201508252106.JIE81718.FHOOFSJFMQLtOV@I-love.SAKURA.ne.jp>
	<20150825141735.GD6285@dhcp22.suse.cz>
In-Reply-To: <20150825141735.GD6285@dhcp22.suse.cz>
Message-Id: <201508252337.IHC12433.OFHFFOtQOSLJVM@I-love.SAKURA.ne.jp>
Date: Tue, 25 Aug 2015 23:37:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Michal Hocko wrote:
> > > The code would be easier then and the race window much smaller. If we
> > > really needed to prevent from preemption then preempt_{enable,disable}
> > > aournd the whole task_lock region + do_send_sig_info would be still
> > > easier to follow than re-taking task_lock.
> > 
> > What's wrong with re-taking task_lock? It seems to me that re-taking
> > task_lock is more straightforward and easier to follow.
> 
> I dunno it looks more awkward to me. You have to re-check the victim->mm
> after retaking the lock because situation might have changed while the
> lock was dropped. If the mark_oom_victim & do_send_sig_info are in the
> same preempt region then nothing like that is needed. But this is
> probably a matter of taste. I find the above more readable but let's see
> what others think.

Disabling preemption does not guarantee that the race window is small enough.

If we set TIF_MEMDIE before sending SIGKILL, long interrupts (an extreme
example is SysRq-t from keyboard which would last many seconds) can step
between. We will spend some percent (the worst case is 100 percent) of memory
reserves for allocations which are not needed for termination.

If we send SIGKILL before settting TIF_MEMDIE, we will spend 0 percent of
memory reserves for allocations which are not needed for termination.

Memory reserves are limited, and thus we don't want to waste some pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
