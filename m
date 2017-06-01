Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 301B06B02B4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 09:28:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b84so10030390wmh.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 06:28:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d33si17977660edd.209.2017.06.01.06.28.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 06:28:13 -0700 (PDT)
Date: Thu, 1 Jun 2017 15:28:08 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170601132808.GD9091@dhcp22.suse.cz>
References: <1496317427-5640-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170601115936.GA9091@dhcp22.suse.cz>
 <201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

On Thu 01-06-17 22:11:13, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
> > > Cong Wang has reported a lockup when running LTP memcg_stress test [1].
> >
> > This seems to be on an old and not pristine kernel. Does it happen also
> > on the vanilla up-to-date kernel?
> 
> 4.9 is not an old kernel! It might be close to the kernel version which
> enterprise distributions would choose for their next long term supported
> version.
> 
> And please stop saying "can you reproduce your problem with latest
> linux-next (or at least latest linux)?" Not everybody can use the vanilla
> up-to-date kernel!

The changelog mentioned that the source of stalls is not clear so this
might be out-of-tree patches doing something wrong and dump_stack
showing up just because it is called often. This wouldn't be the first
time I have seen something like that. I am not really keen on adding
heavy lifting for something that is not clearly debugged and based on
hand waving and speculations.

> What I'm pushing via kmallocwd patch is to prepare for overlooked problems
> so that enterprise distributors can collect information and identify what
> changes are needed to be backported.
> 
> As long as you ignore problems not happened with latest linux-next (or
> at least latest linux), enterprise distribution users can do nothing.
> 
> >
> > [...]
> > > Therefore, this patch uses a mutex dedicated for warn_alloc() like
> > > suggested in [3].
> >
> > As I've said previously. We have rate limiting and if that doesn't work
> > out well, let's tune it. The lock should be the last resort to go with.
> > We already throttle show_mem, maybe we can throttle dump_stack as well,
> > although it sounds a bit strange that this adds so much to the picture.
> 
> Ratelimiting never works well. It randomly drops information which is
> useful for debugging. Uncontrolled concurrent dump_stack() causes lockups.
> And restricting dump_stack() drops more information.

As long as the dump_stack can be a source of the stalls, which I am not
so sure about, then we should rate limit it.

> What we should do is to yield CPU time to operations which might do useful
> things (let threads not doing memory allocation; e.g. let printk kernel
> threads to flush pending buffer, let console drivers write the output to
> consoles, let watchdog kernel threads report what is happening).

yes we call that preemptive kernel...

> When memory allocation request is stalling, serialization via waiting
> for a lock does help.

Which will mean that those unlucky ones which stall will stall even more
because they will wait on a lock with potentially many others. While
this certainly is a throttling mechanism it is also a big hammer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
