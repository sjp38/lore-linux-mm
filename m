Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 72F2A828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 08:31:54 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id bx1so299370034obb.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 05:31:54 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f141si29284658oic.116.2016.01.07.05.31.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 05:31:53 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201512292258.ABF87505.OFOSJLHMFVOQFt@I-love.SAKURA.ne.jp>
	<20160107091512.GB27868@dhcp22.suse.cz>
In-Reply-To: <20160107091512.GB27868@dhcp22.suse.cz>
Message-Id: <201601072231.DGG78695.OOFVLHJFFQOStM@I-love.SAKURA.ne.jp>
Date: Thu, 7 Jan 2016 22:31:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> I do not think the placement in find_lock_task_mm is desirable nor
> correct. This function is used in multiple contexts outside of the oom
> proper. It only returns a locked task_struct for a thread that belongs
> to the process.

OK. Andrew, please drop from -mm tree for now.

> What you are seeing is clearly undesirable of course but I believe we
> should handle it at oom_kill_process layer. Blindly selecting a child
> process even when it doesn't sit on some memory or when it has already
> been killed is wrong. The heuristic is clearly too naive and so we
> should touch it rather than compensating it somewhere else. What about
> the following simple approach? It does two things and I will split it
> up if this looks like a desirable approach. Please note I haven't tested
> it because it is more of an idea than a finished thing. What do you think?

I think we need to filter at select_bad_process() and oom_kill_process().

When P has no children, P is chosen and TIF_MEMDIE is set on P. But P can
be chosen forever due to P->signal->oom_score_adj == OOM_SCORE_ADJ_MAX
even if the OOM reaper reclaimed P's mm. We need to ensure that
oom_kill_process() is not called with P if P already has TIF_MEMDIE.

(By the way, we are already assuming the OOM reaper kernel thread is
available. Changing to BUG_ON(IS_ERR(oom_reaper_th)) should be OK. ;-) )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
