Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 729E66B006C
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 08:09:13 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id hv19so5535260lab.28
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 05:09:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jt19si20826874lab.35.2014.12.23.05.09.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 05:09:11 -0800 (PST)
Date: Tue, 23 Dec 2014 14:09:09 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
Message-ID: <20141223130909.GE28549@dhcp22.suse.cz>
References: <20141222202511.GA9485@dhcp22.suse.cz>
 <201412231000.AFG78139.SJMtOOLFVFFQOH@I-love.SAKURA.ne.jp>
 <20141223095159.GA28549@dhcp22.suse.cz>
 <201412232046.FHB81206.OVMOOSJHQFFFLt@I-love.SAKURA.ne.jp>
 <20141223122401.GC28549@dhcp22.suse.cz>
 <201412232200.BCI48944.LJFSFVOFHMOtQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412232200.BCI48944.LJFSFVOFHMOtQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Tue 23-12-14 22:00:52, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > and finally sets SIGKILL on that victim thread. If such a delay
> > > happened, that victim thread is free to abuse TIF_MEMDIE for that period.
> > > Thus, I thought sending SIGKILL followed by setting TIF_MEMDIE is better.
> > 
> > I don't know, I can hardly find a scenario where it would make any
> > difference in the real life. If the victim needs to allocate a memory to
> > finish then it would trigger OOM again and have to wait/loop until this
> > OOM killer releases the oom zonelist lock just to find out it already
> > has TIF_MEMDIE set and can dive into memory reserves. Which way is more
> > correct is a question but I wouldn't change it without having a really
> > good reason. This whole code is subtle already, let's not make it even
> > more so.
> 
> gfp_to_alloc_flags() in mm/page_alloc.c sets ALLOC_NO_WATERMARKS if
> the victim task has TIF_MEMDIE flag, doesn't it?

This is the whole point of TIF_MEMDIE.

[...]

> Then, I think deferring SIGKILL might widen race window for abusing TIF_MEMDIE.

How would it abuse the flag? The OOM victim has to die and if it needs
to allocate then we have to allow it to do so otherwise the whole
exercise was pointless. fatal_signal_pending check is not so widespread
in the kernel that the task would notice it immediately.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
