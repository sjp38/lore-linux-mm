Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4CF831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 09:57:30 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 123so34771783pge.14
        for <linux-mm@kvack.org>; Thu, 18 May 2017 06:57:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s191si5071468pgc.237.2017.05.18.06.57.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 06:57:29 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: fix oom invocation issues
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170517161446.GB20660@dhcp22.suse.cz>
	<20170517194316.GA30517@castle>
	<201705180703.JGH95344.SOHJtFFMOQFLOV@I-love.SAKURA.ne.jp>
	<20170518084729.GB25462@dhcp22.suse.cz>
	<20170518090039.GC25462@dhcp22.suse.cz>
In-Reply-To: <20170518090039.GC25462@dhcp22.suse.cz>
Message-Id: <201705182257.HJJ52185.OQStFLFMHVOJOF@I-love.SAKURA.ne.jp>
Date: Thu, 18 May 2017 22:57:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> It is racy and it basically doesn't have any allocation context so we
> might kill a task from a different domain. So can we do this instead?
> There is a slight risk that somebody might have returned VM_FAULT_OOM
> without doing an allocation but from my quick look nobody does that
> currently.

I can't tell whether it is safe to remove out_of_memory() from pagefault_out_of_memory().
There are VM_FAULT_OOM users in fs/ directory. What happens if pagefault_out_of_memory()
was called as a result of e.g. GFP_NOFS allocation failure? Is it guaranteed that all
memory allocations that might occur from page fault event (or any action that might return
VM_FAULT_OOM) are allowed to call oom_kill_process() from out_of_memory() before
reaching pagefault_out_of_memory() ?

Anyway, I want

	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE))
+	if (alloc_flags == ALLOC_NO_WATERMARKS && test_thread_flag(TIF_MEMDIE))
		goto nopage;

so that we won't see similar backtraces and memory information from both
out_of_memory() and warn_alloc().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
