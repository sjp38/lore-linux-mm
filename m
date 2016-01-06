Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id E95886B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 08:17:58 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l65so58925343wmf.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 05:17:58 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id 75si12449665wmn.68.2016.01.06.05.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 05:17:57 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id f206so59137356wmf.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 05:17:57 -0800 (PST)
Date: Wed, 6 Jan 2016 14:17:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC][PATCH] sysrq: ensure manual invocation of the OOM
 killerunder OOM livelock
Message-ID: <20160106131755.GB13900@dhcp22.suse.cz>
References: <201512301533.JDJ18237.QOFOMVSFtHOJLF@I-love.SAKURA.ne.jp>
 <20160105162246.GH15324@dhcp22.suse.cz>
 <20160105180507.GB23326@dhcp22.suse.cz>
 <201601062049.CIB17682.VtMHSQFOJOOLFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601062049.CIB17682.VtMHSQFOJOOLFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 06-01-16 20:49:23, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 05-01-16 17:22:46, Michal Hocko wrote:
> > > On Wed 30-12-15 15:33:47, Tetsuo Handa wrote:
> > [...]
> > > > I wish for a kernel thread that does OOM-kill operation.
> > > > Maybe we can change the OOM reaper kernel thread to do it.
> > > > What do you think?
> > > 
> > > I do no think a separate kernel thread would help much if the
> > > allocations have to keep looping in the allocator. oom_reaper is a
> > > separate kernel thread only due to locking required for the exit_mmap
> > > path.
> > 
> > Let me clarify what I've meant here. What you actually want is to do
> > select_bad_process and oom_kill_process (including oom_reap_vmas) in
> > the kernel thread context, right?
> 
> Right.

It still seems we were not on the same page. I thought you wanted to
make _all_ oom killer handling to be done from the kernel thread while
you only cared about the sysrq+f case. Your patch below sounds like a
reasonable compromise to me. It conflates two different things together
but they are not that different in principle so I guess this could be
acceptable. Maybe s@oom_reaper@async_oom_killer@ would be more
appropriate to reflect that fact.

[...]

> While testing above patch, I once hit depletion of memory reserves.
[...]
> Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160106.txt.xz .
> 
> I don't think this depletion was caused by above patch because the last
> invocation was not SysRq-f.

Yes I agree this is not related to the patch.

> I believe we should add a workaround for
> the worst case now. It is impossible to add it after we made the code
> more and more difficult to test.
> 
> >                               We would have to handle queuing of the
> > oom requests because multiple oom killers might be active in different
> > allocation domains (cpusets, memcgs) so I am not so sure this would be a
> > great win in the end. But I haven't tried to do it so I might be wrong
> > and it will turn up being much more easier than I expect.
> 
> I could not catch what you want to say.

I was contemplating about all the OOM killer handling from within the
kernel thread as that was my understanding of what you were proposing.

> If you are worrying about failing
> to call oom_reap_vmas() for second victim due to invoking the OOM killer
> again before mm_to_reap is updated from first victim to NULL, we can walk
> on the process list.
[...]

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
