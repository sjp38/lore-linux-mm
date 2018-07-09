Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 213866B0003
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 18:49:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a12-v6so12478379pfn.12
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 15:49:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3-v6sor5062146plb.123.2018.07.09.15.49.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 15:49:55 -0700 (PDT)
Date: Mon, 9 Jul 2018 15:49:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, oom: remove sleep from under oom_lock
In-Reply-To: <20180709074706.30635-1-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.21.1807091548280.125566@chino.kir.corp.google.com>
References: <20180709074706.30635-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 9 Jul 2018, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> Tetsuo has pointed out that since 27ae357fa82b ("mm, oom: fix concurrent
> munlock and oom reaper unmap, v3") we have a strong synchronization
> between the oom_killer and victim's exiting because both have to take
> the oom_lock. Therefore the original heuristic to sleep for a short time
> in out_of_memory doesn't serve the original purpose.
> 
> Moreover Tetsuo has noticed that the short sleep can be more harmful
> than actually useful. Hammering the system with many processes can lead
> to a starvation when the task holding the oom_lock can block for a
> long time (minutes) and block any further progress because the
> oom_reaper depends on the oom_lock as well.
> 
> Drop the short sleep from out_of_memory when we hold the lock. Keep the
> sleep when the trylock fails to throttle the concurrent OOM paths a bit.
> This should be solved in a more reasonable way (e.g. sleep proportional
> to the time spent in the active reclaiming etc.) but this is much more
> complex thing to achieve. This is a quick fixup to remove a stale code.
> 
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

This reminds me:

mm/oom_kill.c

 54) int sysctl_oom_dump_tasks = 1;
 55) 
 56) DEFINE_MUTEX(oom_lock);
 57) 
 58) #ifdef CONFIG_NUMA

Would you mind documenting oom_lock to specify what it's protecting?
