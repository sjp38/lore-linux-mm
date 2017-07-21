Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EEE716B0292
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 11:33:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v102so17233085wrb.2
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 08:33:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p72si1201024wmd.262.2017.07.21.08.33.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Jul 2017 08:33:55 -0700 (PDT)
Date: Fri, 21 Jul 2017 17:33:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
Message-ID: <20170721153353.GG5944@dhcp22.suse.cz>
References: <20170718141602.GB19133@dhcp22.suse.cz>
 <201707190551.GJE30718.OFHOQMFJtVSFOL@I-love.SAKURA.ne.jp>
 <20170720141138.GJ9058@dhcp22.suse.cz>
 <201707210647.BDH57894.MQOtFFOJHLSOFV@I-love.SAKURA.ne.jp>
 <20170721150002.GF5944@dhcp22.suse.cz>
 <201707220018.DAE21384.JQFLVMFHSFtOOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707220018.DAE21384.JQFLVMFHSFtOOO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

On Sat 22-07-17 00:18:48, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > If we ignore MMF_OOM_SKIP once, we can avoid sequence above.
> > 
> > But we set MMF_OOM_SKIP _after_ the process lost its address space (well
> > after the patch which allows to race oom reaper with the exit_mmap).
> > 
> > > 
> > >     Process-1              Process-2
> > > 
> > >     Takes oom_lock.
> > >     Fails get_page_from_freelist().
> > >     Enters out_of_memory().
> > >     Get SIGKILL.
> > >     Get TIF_MEMDIE.
> > >     Leaves out_of_memory().
> > >     Releases oom_lock.
> > >     Enters do_exit().
> > >     Calls __mmput().
> > >                            Takes oom_lock.
> > >                            Fails get_page_from_freelist().
> > >     Releases some memory.
> > >     Sets MMF_OOM_SKIP.
> > >                            Enters out_of_memory().
> > >                            Ignores MMF_OOM_SKIP mm once.
> > >                            Leaves out_of_memory().
> > >                            Releases oom_lock.
> > >                            Succeeds get_page_from_freelist().
> > 
> > OK, so let's say you have another task just about to jump into
> > out_of_memory and ... end up in the same situation.
> 
> Right.
> 
> > 
> >                                                     This race is just
> > unavoidable.
> 
> There is no perfect way (always timing dependent). But

I would rather not add a code which _pretends_ it solves something. If
we see the above race a real problem in out there then we should think
about how to fix it. I definitely do not want to add more hack into an
already complicated code base.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
