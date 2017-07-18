Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2456B0292
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 16:51:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e3so31174126pfc.4
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 13:51:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i8si2595978pll.390.2017.07.18.13.51.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Jul 2017 13:51:17 -0700 (PDT)
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1500386810-4881-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170718141602.GB19133@dhcp22.suse.cz>
In-Reply-To: <20170718141602.GB19133@dhcp22.suse.cz>
Message-Id: <201707190551.GJE30718.OFHOQMFJtVSFOL@I-love.SAKURA.ne.jp>
Date: Wed, 19 Jul 2017 05:51:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 18-07-17 23:06:50, Tetsuo Handa wrote:
> > Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
> > guarded whole OOM reaping operations using oom_lock. But there was no
> > need to guard whole operations. We needed to guard only setting of
> > MMF_OOM_REAPED flag because get_page_from_freelist() in
> > __alloc_pages_may_oom() is called with oom_lock held.
> > 
> > If we change to guard only setting of MMF_OOM_SKIP flag, the OOM reaper
> > can start reaping operations as soon as wake_oom_reaper() is called.
> > But since setting of MMF_OOM_SKIP flag at __mmput() is not guarded with
> > oom_lock, guarding only the OOM reaper side is not sufficient.
> > 
> > If we change the OOM killer side to ignore MMF_OOM_SKIP flag once,
> > there is no need to guard setting of MMF_OOM_SKIP flag, and we can
> > guarantee a chance to call get_page_from_freelist() in
> > __alloc_pages_may_oom() without depending on oom_lock serialization.
> > 
> > This patch makes MMF_OOM_SKIP act as if MMF_OOM_REAPED, and adds a new
> > flag which acts as if MMF_OOM_SKIP, in order to close both race window
> > (the OOM reaper side and __mmput() side) without using oom_lock.
> 
> Why do we need this patch when
> http://lkml.kernel.org/r/20170626130346.26314-1-mhocko@kernel.org
> already removes the lock and solves another problem at once?

We haven't got an answer from Hugh and/or Andrea whether that patch is safe.
Even if that patch is safe, this patch still helps with CONFIG_MMU=n case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
