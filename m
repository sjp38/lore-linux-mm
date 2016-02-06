Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 97729440441
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 00:54:40 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id g73so150365290ioe.3
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 21:54:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s205si9164845ios.148.2016.02.05.21.54.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 21:54:39 -0800 (PST)
Subject: Re: [PATCH 5/5] mm, oom_reaper: implement OOM victims queuing
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
	<1454505240-23446-6-git-send-email-mhocko@kernel.org>
	<201602041949.BIG30715.QVFLFOOOHMtSFJ@I-love.SAKURA.ne.jp>
	<20160204145357.GE14425@dhcp22.suse.cz>
In-Reply-To: <20160204145357.GE14425@dhcp22.suse.cz>
Message-Id: <201602061454.GDG43774.LSHtOOMFOFVJQF@I-love.SAKURA.ne.jp>
Date: Sat, 6 Feb 2016 14:54:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > But if we consider non system-wide OOM events, it is not very unlikely to hit
> > this race. This queue is useful for situations where memcg1 and memcg2 hit
> > memcg OOM at the same time and victim1 in memcg1 cannot terminate immediately.
> 
> This can happen of course but the likelihood is _much_ smaller without
> the global OOM because the memcg OOM killer is invoked from a lockless
> context so the oom context cannot block the victim to proceed.

Suppose mem_cgroup_out_of_memory() is called from a lockless context via
mem_cgroup_oom_synchronize() called from pagefault_out_of_memory(), that
"lockless" is talking about only current thread, doesn't it?

Since oom_kill_process() sets TIF_MEMDIE on first mm!=NULL thread of a
victim process, it is possible that non-first mm!=NULL thread triggers
pagefault_out_of_memory() and first mm!=NULL thread gets TIF_MEMDIE,
isn't it?

Then, where is the guarantee that victim1 (first mm!=NULL thread in memcg1
which got TIF_MEMDIE) is not waiting at down_read(&victim2->mm->mmap_sem)
when victim2 (first mm!=NULL thread in memcg2 which got TIF_MEMDIE) is
waiting at down_write(&victim2->mm->mmap_sem) or both victim1 and victim2
are waiting on a lock somewhere in memory reclaim path (e.g.
mutex_lock(&inode->i_mutex))?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
