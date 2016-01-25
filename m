Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id ACB366B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:08:48 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id g73so157708120ioe.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:08:48 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d1si34011687ioe.179.2016.01.25.07.08.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 07:08:47 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] proposals for topics
References: <20160125133357.GC23939@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <56A63A6C.9070301@I-love.SAKURA.ne.jp>
Date: Tue, 26 Jan 2016 00:08:28 +0900
MIME-Version: 1.0
In-Reply-To: <20160125133357.GC23939@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Michal Hocko wrote:
>   Another issue is that GFP_NOFS is quite often used without any obvious
>   reason. It is not clear which lock is held and could be taken from
>   the reclaim path. Wouldn't it be much better if the no-recursion
>   behavior was bound to the lock scope rather than particular allocation
>   request? We already have something like this for PM
>   pm_res{trict,tore}_gfp_mask resp. memalloc_noio_{save,restore}. It
>   would be great if we could unify this and use the context based NOFS
>   in the FS.

Yes, I do want it. I think some of LSM hooks are called from GFP_NOFS context
but it is too difficult for me to tell whether we are using GFP_NOFS correctly.

>   First we shouldn't retry endlessly and rather fail the allocation and
>   allow the FS to handle the error. As per my experiments most FS cope
>   with that quite reasonably. Btrfs unfortunately handles many of those
>   failures by BUG_ON which is really unfortunate.

If it turned out that we are using GFP_NOFS from LSM hooks correctly,
I'd expect such GFP_NOFS allocations retry unless SIGKILL is pending.
Filesystems might be able to handle GFP_NOFS allocation failures. But
userspace might not be able to handle system call failures caused by
GFP_NOFS allocation failures; OOM-unkillable processes might unexpectedly
terminate as if they are OOM-killed. Would you please add GFP_KILLABLE
to list of the topics?

> - OOM killer has been discussed a lot throughout this year. We have
>   discussed this topic the last year at LSF and there has been quite some
>   progress since then. We have async memory tear down for the OOM victim
>   [2] which should help in many corner cases. We are still waiting
>   to make mmap_sem for write killable which would help in some other
>   classes of corner cases. Whatever we do, however, will not work in
>   100% cases. So the primary question is how far are we willing to go to
>   support different corner cases. Do we want to have a
>   panic_after_timeout global knob, allow multiple OOM victims after
>   a timeout?

A sequence for handling any corner case (as long as OOM killer is
invoked) was proposal at
http://lkml.kernel.org/r/201601222259.GJB90663.MLOJtFFOQFVHSO@I-love.SAKURA.ne.jp .

> - sysrq+f to trigger the oom killer follows some heuristics used by the
>   OOM killer invoked by the system which means that it is unreliable
>   and it might skip to kill any task without any explanation why. The
>   semantic of the knob doesn't seem to clear and it has been even
>   suggested [3] to remove it altogether as an unuseful debugging aid. Is
>   this really a general consensus?

Even if we remove SysRq-f from future kernels, please give us a fix for
current kernels. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
