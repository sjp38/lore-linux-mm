Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id B57E96B0032
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 08:43:12 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so10866679wiv.8
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 05:43:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ee8si24988398wib.54.2014.12.23.05.43.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 05:43:11 -0800 (PST)
Date: Tue, 23 Dec 2014 14:43:09 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
Message-ID: <20141223134309.GF28549@dhcp22.suse.cz>
References: <20141223095159.GA28549@dhcp22.suse.cz>
 <201412232046.FHB81206.OVMOOSJHQFFFLt@I-love.SAKURA.ne.jp>
 <20141223122401.GC28549@dhcp22.suse.cz>
 <201412232200.BCI48944.LJFSFVOFHMOtQO@I-love.SAKURA.ne.jp>
 <20141223130909.GE28549@dhcp22.suse.cz>
 <201412232220.IIJ57305.OMOOSVFtFFHQLJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412232220.IIJ57305.OMOOSVFtFFHQLJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Tue 23-12-14 22:20:57, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 23-12-14 22:00:52, Tetsuo Handa wrote:
[...]
> > > Then, I think deferring SIGKILL might widen race window for abusing TIF_MEMDIE.
> > 
> > How would it abuse the flag? The OOM victim has to die and if it needs
> > to allocate then we have to allow it to do so otherwise the whole
> > exercise was pointless. fatal_signal_pending check is not so widespread
> > in the kernel that the task would notice it immediately.
> 
> I'm talking about possible delay between TIF_MEMDIE was set on the victim
> and SIGKILL is delivered to the victim.

I can read what you wrote. You are just ignoring my questions it seems
because I haven't got any reason _why it matters_. My point was that the
victim might be looping in the kernel and doing other allocations until
it notices it has fatal_signal_pending and bail out. So the delay
between setting the flag and sending the signal is not that important
AFAICS.

> Why the victim has to die before receiving SIGKILL?

It has to die to resolve the current OOM condition. I haven't written
anything about dying before receiving SIGKILL.

> The victim can access memory reserves until SIGKILL is delivered,
> can't it?

And why does that matter? It would have to do such an allocation anyway
because it wouldn't proceed without it... And the only difference
between having the flag and not having it is that the allocation has
higher chance to succeed with the flag so it will not trigger the OOM
killer again right away. See the point or am I missing something here?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
