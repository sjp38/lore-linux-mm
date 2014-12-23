Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1E30D6B006E
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 08:52:30 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so7956633pab.12
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 05:52:29 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id bb6si29572282pbd.68.2014.12.23.05.52.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 05:52:28 -0800 (PST)
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141222202511.GA9485@dhcp22.suse.cz>
	<201412231000.AFG78139.SJMtOOLFVFFQOH@I-love.SAKURA.ne.jp>
	<20141223095159.GA28549@dhcp22.suse.cz>
	<201412232046.FHB81206.OVMOOSJHQFFFLt@I-love.SAKURA.ne.jp>
	<20141223122401.GC28549@dhcp22.suse.cz>
In-Reply-To: <20141223122401.GC28549@dhcp22.suse.cz>
Message-Id: <201412232200.BCI48944.LJFSFVOFHMOtQO@I-love.SAKURA.ne.jp>
Date: Tue, 23 Dec 2014 22:00:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Michal Hocko wrote:
> > and finally sets SIGKILL on that victim thread. If such a delay
> > happened, that victim thread is free to abuse TIF_MEMDIE for that period.
> > Thus, I thought sending SIGKILL followed by setting TIF_MEMDIE is better.
> 
> I don't know, I can hardly find a scenario where it would make any
> difference in the real life. If the victim needs to allocate a memory to
> finish then it would trigger OOM again and have to wait/loop until this
> OOM killer releases the oom zonelist lock just to find out it already
> has TIF_MEMDIE set and can dive into memory reserves. Which way is more
> correct is a question but I wouldn't change it without having a really
> good reason. This whole code is subtle already, let's not make it even
> more so.

gfp_to_alloc_flags() in mm/page_alloc.c sets ALLOC_NO_WATERMARKS if
the victim task has TIF_MEMDIE flag, doesn't it?

        if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
                if (gfp_mask & __GFP_MEMALLOC)
                        alloc_flags |= ALLOC_NO_WATERMARKS;
                else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
                        alloc_flags |= ALLOC_NO_WATERMARKS;
                else if (!in_interrupt() &&
                                ((current->flags & PF_MEMALLOC) ||
                                 unlikely(test_thread_flag(TIF_MEMDIE))))
                        alloc_flags |= ALLOC_NO_WATERMARKS;
        }

Then, I think deferring SIGKILL might widen race window for abusing TIF_MEMDIE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
