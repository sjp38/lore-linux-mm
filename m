Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F06D82963
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 07:21:45 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so50359545lfi.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:21:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m31si3812858lfi.271.2016.07.21.04.21.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 04:21:43 -0700 (PDT)
Date: Thu, 21 Jul 2016 13:21:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 0/8] Change OOM killer to use list of mm_struct.
Message-ID: <20160721112140.GG26379@dhcp22.suse.cz>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Tue 12-07-16 22:29:15, Tetsuo Handa wrote:
> This series is an update of
> http://lkml.kernel.org/r/201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp .
> 
> This series is based on top of linux-next-20160712 +
> http://lkml.kernel.org/r/1467201562-6709-1-git-send-email-mhocko@kernel.org .

I was thinking about this vs. signal_struct::oom_mm [1] and came to the
conclusion that as of now they are mostly equivalent wrt. oom livelock
detection and coping with it. So for now any of them should be good to
go. Good!

Now what about future plans? I would like to get rid of TIF_MEMDIE
altogether and give access to memory reserves to oom victim when they
allocate the memory. Something like:
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 788e4f22e0bb..34446f49c2e1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3358,7 +3358,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 		else if (!in_interrupt() &&
 				((current->flags & PF_MEMALLOC) ||
-				 unlikely(test_thread_flag(TIF_MEMDIE))))
+				 tsk_is_oom_victim(current))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
 #ifdef CONFIG_CMA

where tsk_is_oom_victim wouldn't require the given task to go via
out_of_memory. This would solve some of the problems we have right now
when a thread doesn't get access to memory reserves because it never
reaches out_of_memory (e.g. recently mentioned mempool_alloc doing
__GFP_NORETRY). It would also make the code easier to follow. If we want
to implement that we need an easy to implement tsk_is_oom_victim
obviously. With the signal_struct::oom_mm this is really trivial thing.
I am not sure we can do that with the mm list though because we are
loosing the task->mm at certain point in time. The only way I can see
this would fly would be preserving TIF_MEMDIE and setting it for all
threads but I am not sure this is very much better and puts the mm list
approach to a worse possition from my POV.

What do you think Tetsuo?

[1] http://lkml.kernel.org/r/1467365190-24640-1-git-send-email-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
