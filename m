Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D32A6B0006
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 05:43:46 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n2-v6so8413371edr.5
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 02:43:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m5-v6si5397649edm.189.2018.07.10.02.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 02:43:44 -0700 (PDT)
Date: Tue, 10 Jul 2018 11:43:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: remove sleep from under oom_lock
Message-ID: <20180710094341.GD14284@dhcp22.suse.cz>
References: <20180709074706.30635-1-mhocko@kernel.org>
 <alpine.DEB.2.21.1807091548280.125566@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807091548280.125566@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 09-07-18 15:49:53, David Rientjes wrote:
> On Mon, 9 Jul 2018, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Tetsuo has pointed out that since 27ae357fa82b ("mm, oom: fix concurrent
> > munlock and oom reaper unmap, v3") we have a strong synchronization
> > between the oom_killer and victim's exiting because both have to take
> > the oom_lock. Therefore the original heuristic to sleep for a short time
> > in out_of_memory doesn't serve the original purpose.
> > 
> > Moreover Tetsuo has noticed that the short sleep can be more harmful
> > than actually useful. Hammering the system with many processes can lead
> > to a starvation when the task holding the oom_lock can block for a
> > long time (minutes) and block any further progress because the
> > oom_reaper depends on the oom_lock as well.
> > 
> > Drop the short sleep from out_of_memory when we hold the lock. Keep the
> > sleep when the trylock fails to throttle the concurrent OOM paths a bit.
> > This should be solved in a more reasonable way (e.g. sleep proportional
> > to the time spent in the active reclaiming etc.) but this is much more
> > complex thing to achieve. This is a quick fixup to remove a stale code.
> > 
> > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> This reminds me:
> 
> mm/oom_kill.c
> 
>  54) int sysctl_oom_dump_tasks = 1;
>  55) 
>  56) DEFINE_MUTEX(oom_lock);
>  57) 
>  58) #ifdef CONFIG_NUMA
> 
> Would you mind documenting oom_lock to specify what it's protecting?

What do you think about the following?

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ed9d473c571e..32e6f7becb40 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -53,6 +53,14 @@ int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 
+/*
+ * Serializes oom killer invocations (out_of_memory()) from all contexts to
+ * prevent from over eager oom killing (e.g. when the oom killer is invoked
+ * from different domains).
+ *
+ * oom_killer_disable() relies on this lock to stabilize oom_killer_disabled
+ * and mark_oom_victim
+ */
 DEFINE_MUTEX(oom_lock);
 
 #ifdef CONFIG_NUMA
-- 
Michal Hocko
SUSE Labs
