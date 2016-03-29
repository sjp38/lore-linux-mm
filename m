Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 688A06B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 09:45:45 -0400 (EDT)
Received: by mail-io0-f173.google.com with SMTP id e3so22115734ioa.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 06:45:45 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t37si28783729ioi.205.2016.03.29.06.45.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 06:45:44 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
Message-Id: <201603292245.AAC12437.JFLMQVtSOHFFOO@I-love.SAKURA.ne.jp>
Date: Tue, 29 Mar 2016 22:45:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __alloc_pages_may_oom is the central place to decide when the
> out_of_memory should be invoked. This is a good approach for most checks
> there because they are page allocator specific and the allocation fails
> right after.
> 
> The notable exception is GFP_NOFS context which is faking
> did_some_progress and keep the page allocator looping even though there
> couldn't have been any progress from the OOM killer. This patch doesn't
> change this behavior because we are not ready to allow those allocation
> requests to fail yet. Instead __GFP_FS check is moved down to
> out_of_memory and prevent from OOM victim selection there. There are
> two reasons for that
> 	- OOM notifiers might release some memory even from this context
> 	  as none of the registered notifier seems to be FS related
> 	- this might help a dying thread to get an access to memory
>           reserves and move on which will make the behavior more
>           consistent with the case when the task gets killed from a
>           different context.

Allowing !__GFP_FS allocations to get TIF_MEMDIE by calling the shortcuts in
out_of_memory() would be fine. But I don't like the direction you want to go.

I don't like failing !__GFP_FS allocations without selecting OOM victim
( http://lkml.kernel.org/r/201603252054.ADH30264.OJQFFLMOHFSOVt@I-love.SAKURA.ne.jp ).

Also, I suggested removing all shortcuts by setting TIF_MEMDIE from oom_kill_process()
( http://lkml.kernel.org/r/1458529634-5951-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ).

> 
> Keep a comment in __alloc_pages_may_oom to make sure we do not forget
> how GFP_NOFS is special and that we really want to do something about
> it.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> I am sending this as an RFC now even though I think this makes more
> sense than what we have right now. Maybe there are some side effects
> I do not see, though. A more tricky part is the OOM notifier part
> becasue future notifiers might decide to depend on the FS and we can
> lockup. Is this something to worry about, though? Would such a notifier
> be correct at all? I would call it broken as it would put OOM killer out
> of the way on the contended system which is a plain bug IMHO.
> 
> If this looks like a reasonable approach I would go on think about how
> we can extend this for the oom_reaper and queue the current thread for
> the reaper to free some of the memory.
> 
> Any thoughts

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
