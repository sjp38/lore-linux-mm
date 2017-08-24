Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A98C5440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 11:51:53 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d184so5088049pgc.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 08:51:53 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b1si2948928pgc.807.2017.08.24.08.51.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 08:51:52 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm,oom: Try last second allocation after selecting an OOM victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1503577106-9196-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1503577106-9196-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170824131836.GN5943@dhcp22.suse.cz>
In-Reply-To: <20170824131836.GN5943@dhcp22.suse.cz>
Message-Id: <201708242340.ICG00066.JtFOFVSMOHOLFQ@I-love.SAKURA.ne.jp>
Date: Thu, 24 Aug 2017 23:40:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

Michal Hocko wrote:
> On Thu 24-08-17 21:18:26, Tetsuo Handa wrote:
> > Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
> > count causes random kernel panics when an OOM victim which consumed memory
> > in a way the OOM reaper does not help was selected by the OOM killer [1].
> > 
> > Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> > oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
> > to return false as soon as MMF_OOM_SKIP is set, many threads sharing the
> > victim's mm were not able to try allocation from memory reserves after the
> > OOM reaper gave up reclaiming memory.
> > 
> > I proposed a patch which alllows task_will_free_mem(current) in
> > out_of_memory() to ignore MMF_OOM_SKIP for once so that all OOM victim
> > threads are guaranteed to have tried ALLOC_OOM allocation attempt before
> > start selecting next OOM victims [2], for Michal Hocko did not like
> > calling get_page_from_freelist() from the OOM killer which is a layer
> > violation [3]. But now, Michal thinks that calling get_page_from_freelist()
> > after task_will_free_mem(current) test is better than allowing
> > task_will_free_mem(current) to ignore MMF_OOM_SKIP for once [4], for
> > this would help other cases when we race with an exiting tasks or somebody
> > managed to free memory while we were selecting an OOM victim which can take
> > quite some time.
> 
> This a lot of text which can be more confusing than helpful. Could you
> state the problem clearly without detours? Yes, the oom killer selection
> can race with those freeing memory. And it has been like that since
> basically ever.

The problem which Manish Jaggi reported (and I can still reproduce) is that
the OOM killer ignores MMF_OOM_SKIP mm too early. And the problem became real
in 4.8 due to commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
oom_reaped tasks"). Thus, it has _not_ been like that since basically ever.

>                 Doing a last minute allocation attempt might help. Now
> there are more important questions. How likely is that. Do people have
> to care? __alloc_pages_may_oom already does a almost-the-last moment
> allocation. Do we still need it?

get_page_from_freelist() in __alloc_pages_may_oom() would help only if
MMF_OOM_SKIP is set after some memory is reclaimed. But the problem is
that MMF_OOM_SKIP is set without reclaiming any memory.

>                                  It also does ALLOC_WMARK_HIGH
> allocation which your path doesn't do.

The intent of this patch is to replace "[PATCH v2] mm, oom:
task_will_free_mem(current) should ignore MMF_OOM_SKIP for once."
which you have nacked 3 days ago.

>                                        I wanted to remove this some time
> ago but it has been pointed out that this was really needed
> https://patchwork.kernel.org/patch/8153841/ Maybe things have changed
> and if so please explain.

get_page_from_freelist() in __alloc_pages_may_oom() will remain needed
because it can help allocations which do not call oom_kill_process() (i.e.
allocations which do "goto out;" in __alloc_pages_may_oom() without calling
out_of_memory(), and allocations which do "return;" in out_of_memory()
without calling oom_kill_process() (e.g. !__GFP_FS)) to succeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
