Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 78C6F440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:18:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u132so707228wmf.9
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:18:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v80si3474935wrc.301.2017.08.24.06.18.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 06:18:39 -0700 (PDT)
Date: Thu, 24 Aug 2017 15:18:36 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH 2/2] mm,oom: Try last second allocation after
 selecting an OOM victim.
Message-ID: <20170824131836.GN5943@dhcp22.suse.cz>
References: <1503577106-9196-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1503577106-9196-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503577106-9196-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Manish Jaggi <mjaggi@caviumnetworks.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu 24-08-17 21:18:26, Tetsuo Handa wrote:
> Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
> count causes random kernel panics when an OOM victim which consumed memory
> in a way the OOM reaper does not help was selected by the OOM killer [1].
> 
> Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
> to return false as soon as MMF_OOM_SKIP is set, many threads sharing the
> victim's mm were not able to try allocation from memory reserves after the
> OOM reaper gave up reclaiming memory.
> 
> I proposed a patch which alllows task_will_free_mem(current) in
> out_of_memory() to ignore MMF_OOM_SKIP for once so that all OOM victim
> threads are guaranteed to have tried ALLOC_OOM allocation attempt before
> start selecting next OOM victims [2], for Michal Hocko did not like
> calling get_page_from_freelist() from the OOM killer which is a layer
> violation [3]. But now, Michal thinks that calling get_page_from_freelist()
> after task_will_free_mem(current) test is better than allowing
> task_will_free_mem(current) to ignore MMF_OOM_SKIP for once [4], for
> this would help other cases when we race with an exiting tasks or somebody
> managed to free memory while we were selecting an OOM victim which can take
> quite some time.

This a lot of text which can be more confusing than helpful. Could you
state the problem clearly without detours? Yes, the oom killer selection
can race with those freeing memory. And it has been like that since
basically ever. Doing a last minute allocation attempt might help. Now
there are more important questions. How likely is that. Do people have
to care? __alloc_pages_may_oom already does a almost-the-last moment
allocation. Do we still need it? It also does ALLOC_WMARK_HIGH
allocation which your path doesn't do. I wanted to remove this some time
ago but it has been pointed out that this was really needed
https://patchwork.kernel.org/patch/8153841/ Maybe things have changed
and if so please explain.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
