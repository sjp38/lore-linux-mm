Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 818E06B02FA
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 10:17:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z48so2824354wrc.4
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 07:17:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g6si2285997eda.41.2017.07.18.07.17.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jul 2017 07:17:58 -0700 (PDT)
Date: Tue, 18 Jul 2017 10:17:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
Message-ID: <20170718141754.GA6573@cmpxchg.org>
References: <1500386810-4881-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500386810-4881-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, mhocko@kernel.org, rientjes@google.com, linux-kernel@vger.kernel.org

On Tue, Jul 18, 2017 at 11:06:50PM +0900, Tetsuo Handa wrote:
> Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
> guarded whole OOM reaping operations using oom_lock. But there was no
> need to guard whole operations. We needed to guard only setting of
> MMF_OOM_REAPED flag because get_page_from_freelist() in
> __alloc_pages_may_oom() is called with oom_lock held.
>
> If we change to guard only setting of MMF_OOM_SKIP flag, the OOM reaper
> can start reaping operations as soon as wake_oom_reaper() is called.
> But since setting of MMF_OOM_SKIP flag at __mmput() is not guarded with
> oom_lock, guarding only the OOM reaper side is not sufficient.
> 
> If we change the OOM killer side to ignore MMF_OOM_SKIP flag once,
> there is no need to guard setting of MMF_OOM_SKIP flag, and we can
> guarantee a chance to call get_page_from_freelist() in
> __alloc_pages_may_oom() without depending on oom_lock serialization.
> 
> This patch makes MMF_OOM_SKIP act as if MMF_OOM_REAPED, and adds a new
> flag which acts as if MMF_OOM_SKIP, in order to close both race window
> (the OOM reaper side and __mmput() side) without using oom_lock.

I have no idea what this is about - a race window fix? A performance
optimization? A code simplification?

Users and vendors are later going to read through these changelogs and
have to decide whether they want this patch or upgrade to a kernel
containing it. Please keep these people in mind when writing the
subject and first paragraph of the changelogs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
