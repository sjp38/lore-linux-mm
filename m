Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B1B63828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 11:26:13 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id u188so305023847wmu.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 08:26:13 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id eg8si3016808wjd.210.2016.01.13.08.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 08:26:12 -0800 (PST)
Received: by mail-wm0-f44.google.com with SMTP id u188so305023235wmu.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 08:26:12 -0800 (PST)
Date: Wed, 13 Jan 2016 17:26:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
Message-ID: <20160113162610.GD17512@dhcp22.suse.cz>
References: <201601072026.JCJ95845.LHQOFOOSMFtVFJ@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1601121717220.17063@chino.kir.corp.google.com>
 <201601132111.GIG81705.LFOOHFOtQJSMVF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601132111.GIG81705.LFOOHFOtQJSMVF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 13-01-16 21:11:30, Tetsuo Handa wrote:
[...]
> Those who use panic_on_oom = 1 expect that the system triggers kernel panic
> rather than stall forever. This is a translation of administrator's wish that
> "Please press SysRq-c on behalf of me if the memory exhausted. In that way,
> I don't need to stand by in front of the console twenty-four seven."
> 
> Those who use panic_on_oom = 0 expect that the OOM killer solves OOM condition
> rather than stall forever. This is a translation of administrator's wish that
> "Please press SysRq-f on behalf of me if the memory exhausted. In that way,
> I don't need to stand by in front of the console twenty-four seven."

I think you are missing an important point. There is _no reliable_ way
to resolve the OOM condition in general except to panic the system. Even
killing all user space tasks might not be sufficient in general because
they might be blocked by an unkillable context (e.g. kernel thread).
So if you need a reliable behavior then either use panic_on_oom=1 or
provide a measure to panic after fixed timeout if the OOM cannot get
resolved. We have seen patches in that regards but there was no general
interest in them to merge them.

All we can do is a best effort approach which tries to be optimized to
reduce the impact of an unexpected SIGKILL sent to a "random" task. And
this is a reasonable objective IMHO. This works well in 99% of cases.
You can argue you do care about that 1% and I sympathy with you but
steps to mitigate those shouldn't involve steps which bring another
level of non-determinism into an already complicated system. This was
the biggest issue of the early OOM killer.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
