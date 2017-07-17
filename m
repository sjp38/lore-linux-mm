Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 77ECC6B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 04:56:09 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v60so14596310wrc.7
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 01:56:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i83si9397952wmf.128.2017.07.17.01.56.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 01:56:08 -0700 (PDT)
Date: Mon, 17 Jul 2017 10:56:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20170717085605.GE12888@dhcp22.suse.cz>
References: <1500202791-5427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500202791-5427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

On Sun 16-07-17 19:59:51, Tetsuo Handa wrote:
> Since the whole memory reclaim path has never been designed to handle the
> scheduling priority inversions, those locations which are assuming that
> execution of some code path shall eventually complete without using
> synchronization mechanisms can get stuck (livelock) due to scheduling
> priority inversions, for CPU time is not guaranteed to be yielded to some
> thread doing such code path.
> 
> mutex_trylock() in __alloc_pages_may_oom() (waiting for oom_lock) and
> schedule_timeout_killable(1) in out_of_memory() (already held oom_lock) is
> one of such locations, and it was demonstrated using artificial stressing
> that the system gets stuck effectively forever because SCHED_IDLE priority
> thread is unable to resume execution at schedule_timeout_killable(1) if
> a lot of !SCHED_IDLE priority threads are wasting CPU time [1].

I do not understand this. All the contending tasks will go and sleep for
1s. How can they preempt the lock holder?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
