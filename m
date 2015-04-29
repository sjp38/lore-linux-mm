Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 559BF6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 02:23:22 -0400 (EDT)
Received: by oiko83 with SMTP id o83so14255678oik.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 23:23:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c10si17274709oia.129.2015.04.28.23.23.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 23:23:21 -0700 (PDT)
Subject: Re: [PATCH 6/9] mm: oom_kill: simplify OOM killer locking
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
	<1430161555-6058-7-git-send-email-hannes@cmpxchg.org>
	<alpine.DEB.2.10.1504281540280.10203@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1504281540280.10203@chino.kir.corp.google.com>
Message-Id: <201504291448.GDH51070.OOOFMFVHLStQFJ@I-love.SAKURA.ne.jp>
Date: Wed, 29 Apr 2015 14:48:21 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, mhocko@suse.cz, aarcange@redhat.com, david@fromorbit.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes wrote:
> It's not vital and somewhat unrelated to your patch, but if we can't grab 
> the mutex with the trylock in __alloc_pages_may_oom() then I think it 
> would be more correct to do schedule_timeout_killable() rather than 
> uninterruptible.  I just mention it if you happen to go through another 
> revision of the series and want to switch it at the same time.

It is a difficult choice. Killable sleep is a good thing if

  (1) the OOM victim is current thread
  (2) the OOM victim is waiting for current thread to release lock

but is a bad thing otherwise. And currently, (2) is not true because current
thread cannot access the memory reserves when current thread is blocking the
OOM victim. If fatal_signal_pending() threads can access portion of the memory
reserves (like I said

  I don't like allowing only TIF_MEMDIE to get reserve access, for it can be
  one of !TIF_MEMDIE threads which really need memory to safely terminate without
  failing allocations from do_exit(). Rather, why not to discontinue TIF_MEMDIE
  handling and allow getting access to private memory reserves for all
  fatal_signal_pending() threads (i.e. replacing WMARK_OOM with WMARK_KILLED
  in "[patch 09/12] mm: page_alloc: private memory reserves for OOM-killing
  allocations") ?

at https://lkml.org/lkml/2015/3/27/378 ), (2) will become true.

Of course, the threads which the OOM victim is waiting for may not have
SIGKILL pending. WMARK_KILLED helps if the lock contention is happening
among threads sharing the same mm struct, does not help otherwise.

Well, what about introducing WMARK_OOM as a memory reserve which can be
accessed during atomic_read(&oom_victims) > 0? In this way, we can choose
next OOM victim upon reaching WMARK_OOM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
