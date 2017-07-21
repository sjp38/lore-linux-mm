Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF416B025F
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 11:19:03 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u7so26529996pgo.6
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 08:19:03 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i14si3255887plk.148.2017.07.21.08.19.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Jul 2017 08:19:02 -0700 (PDT)
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170718141602.GB19133@dhcp22.suse.cz>
	<201707190551.GJE30718.OFHOQMFJtVSFOL@I-love.SAKURA.ne.jp>
	<20170720141138.GJ9058@dhcp22.suse.cz>
	<201707210647.BDH57894.MQOtFFOJHLSOFV@I-love.SAKURA.ne.jp>
	<20170721150002.GF5944@dhcp22.suse.cz>
In-Reply-To: <20170721150002.GF5944@dhcp22.suse.cz>
Message-Id: <201707220018.DAE21384.JQFLVMFHSFtOOO@I-love.SAKURA.ne.jp>
Date: Sat, 22 Jul 2017 00:18:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > If we ignore MMF_OOM_SKIP once, we can avoid sequence above.
> 
> But we set MMF_OOM_SKIP _after_ the process lost its address space (well
> after the patch which allows to race oom reaper with the exit_mmap).
> 
> > 
> >     Process-1              Process-2
> > 
> >     Takes oom_lock.
> >     Fails get_page_from_freelist().
> >     Enters out_of_memory().
> >     Get SIGKILL.
> >     Get TIF_MEMDIE.
> >     Leaves out_of_memory().
> >     Releases oom_lock.
> >     Enters do_exit().
> >     Calls __mmput().
> >                            Takes oom_lock.
> >                            Fails get_page_from_freelist().
> >     Releases some memory.
> >     Sets MMF_OOM_SKIP.
> >                            Enters out_of_memory().
> >                            Ignores MMF_OOM_SKIP mm once.
> >                            Leaves out_of_memory().
> >                            Releases oom_lock.
> >                            Succeeds get_page_from_freelist().
> 
> OK, so let's say you have another task just about to jump into
> out_of_memory and ... end up in the same situation.

Right.

> 
>                                                     This race is just
> unavoidable.

There is no perfect way (always timing dependent). But

> 
> > Strictly speaking, this patch is independent with OOM reaper.
> > This patch increases possibility of succeeding get_page_from_freelist()
> > without sending SIGKILL. Your patch is trying to drop it silently.

we can try to reduce possibility of ending up in the same situation by
this proposal, and your proposal is irrelevant with reducing possibility of
ending up in the same situation because

> > 
> > Serializing setting of MMF_OOM_SKIP with oom_lock is one approach,
> > and ignoring MMF_OOM_SKIP once without oom_lock is another approach.
> 
> Or simply making sure that we only set the flag _after_ the address
> space is gone, which is what I am proposing.

the address space being gone does not guarantee that get_page_from_freelist()
shall be called before entering into out_of_memory() (e.g. preempted for seconds
between "Fails get_page_from_freelist()." and "Enters out_of_memory().").

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
