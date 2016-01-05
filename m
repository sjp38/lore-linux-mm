Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id A390E6B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:05:11 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id f206so32663378wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:05:11 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id x203si6819171wmg.14.2016.01.05.10.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 10:05:10 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id f206so41448645wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:05:10 -0800 (PST)
Date: Tue, 5 Jan 2016 19:05:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC][PATCH] sysrq: ensure manual invocation of the OOM killer
 under OOM livelock
Message-ID: <20160105180507.GB23326@dhcp22.suse.cz>
References: <201512301533.JDJ18237.QOFOMVSFtHOJLF@I-love.SAKURA.ne.jp>
 <20160105162246.GH15324@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160105162246.GH15324@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 05-01-16 17:22:46, Michal Hocko wrote:
> On Wed 30-12-15 15:33:47, Tetsuo Handa wrote:
[...]
> > I wish for a kernel thread that does OOM-kill operation.
> > Maybe we can change the OOM reaper kernel thread to do it.
> > What do you think?
> 
> I do no think a separate kernel thread would help much if the
> allocations have to keep looping in the allocator. oom_reaper is a
> separate kernel thread only due to locking required for the exit_mmap
> path.

Let me clarify what I've meant here. What you actually want is to do
select_bad_process and oom_kill_process (including oom_reap_vmas) in
the kernel thread context, right? That should be doable because we do
not depend on the allocation context there. That would certainly save
1 kernel thread for the sysrq+f part but it would make the regular
case more complicated AFAICS. We would have to handle queuing of the
oom requests because multiple oom killers might be active in different
allocation domains (cpusets, memcgs) so I am not so sure this would be a
great win in the end. But I haven't tried to do it so I might be wrong
and it will turn up being much more easier than I expect.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
