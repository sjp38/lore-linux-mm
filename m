Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id AAE9C6B0070
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 08:52:31 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so8013745pad.3
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 05:52:31 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id bb6si29572282pbd.68.2014.12.23.05.52.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 05:52:30 -0800 (PST)
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141223095159.GA28549@dhcp22.suse.cz>
	<201412232046.FHB81206.OVMOOSJHQFFFLt@I-love.SAKURA.ne.jp>
	<20141223122401.GC28549@dhcp22.suse.cz>
	<201412232200.BCI48944.LJFSFVOFHMOtQO@I-love.SAKURA.ne.jp>
	<20141223130909.GE28549@dhcp22.suse.cz>
In-Reply-To: <20141223130909.GE28549@dhcp22.suse.cz>
Message-Id: <201412232220.IIJ57305.OMOOSVFtFFHQLJ@I-love.SAKURA.ne.jp>
Date: Tue, 23 Dec 2014 22:20:57 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Michal Hocko wrote:
> On Tue 23-12-14 22:00:52, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > and finally sets SIGKILL on that victim thread. If such a delay
> > > > happened, that victim thread is free to abuse TIF_MEMDIE for that period.
> > > > Thus, I thought sending SIGKILL followed by setting TIF_MEMDIE is better.
> > > 
> > > I don't know, I can hardly find a scenario where it would make any
> > > difference in the real life. If the victim needs to allocate a memory to
> > > finish then it would trigger OOM again and have to wait/loop until this
> > > OOM killer releases the oom zonelist lock just to find out it already
> > > has TIF_MEMDIE set and can dive into memory reserves. Which way is more
> > > correct is a question but I wouldn't change it without having a really
> > > good reason. This whole code is subtle already, let's not make it even
> > > more so.
> > 
> > gfp_to_alloc_flags() in mm/page_alloc.c sets ALLOC_NO_WATERMARKS if
> > the victim task has TIF_MEMDIE flag, doesn't it?
> 
> This is the whole point of TIF_MEMDIE.
> 
> [...]
> 
> > Then, I think deferring SIGKILL might widen race window for abusing TIF_MEMDIE.
> 
> How would it abuse the flag? The OOM victim has to die and if it needs
> to allocate then we have to allow it to do so otherwise the whole
> exercise was pointless. fatal_signal_pending check is not so widespread
> in the kernel that the task would notice it immediately.

I'm talking about possible delay between TIF_MEMDIE was set on the victim
and SIGKILL is delivered to the victim. Why the victim has to die before
receiving SIGKILL? The victim can access memory reserves until SIGKILL is
delivered, can't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
