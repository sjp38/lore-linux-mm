Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 431786B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 07:55:44 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id n1so54639406pfn.2
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 04:55:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id di9si461469pad.129.2016.04.07.04.55.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Apr 2016 04:55:43 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm, oom_reaper: clear TIF_MEMDIE for all tasks queued for oom_reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
	<1459951996-12875-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459951996-12875-4-git-send-email-mhocko@kernel.org>
Message-Id: <201604072055.GAI52128.tHLVOFJOQMFOFS@I-love.SAKURA.ne.jp>
Date: Thu, 7 Apr 2016 20:55:34 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> The first obvious one is when the oom victim clears its mm and gets
> stuck later on. oom_reaper would back of on find_lock_task_mm returning
> NULL. We can safely try to clear TIF_MEMDIE in this case because such a
> task would be ignored by the oom killer anyway. The flag would be
> cleared by that time already most of the time anyway.

I didn't understand what this wants to tell. The OOM victim will clear
TIF_MEMDIE as soon as it sets current->mm = NULL. Even if the oom victim
clears its mm and gets stuck later on (e.g. at exit_task_work()),
TIF_MEMDIE was already cleared by that moment by the OOM victim.

> 
> The less obvious one is when the oom reaper fails due to mmap_sem
> contention. Even if we clear TIF_MEMDIE for this task then it is not
> very likely that we would select another task too easily because
> we haven't reaped the last victim and so it would be still the #1
> candidate. There is a rare race condition possible when the current
> victim terminates before the next select_bad_process but considering
> that oom_reap_task had retried several times before giving up then
> this sounds like a borderline thing.

Is it helpful? Allowing the OOM killer to select the same thread again
simply makes the kernel log buffer flooded with the OOM kill messages.

I think we should not allow the OOM killer to select the same thread again
by e.g. doing tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN regardless of
whether reaping that thread's memory succeeded or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
