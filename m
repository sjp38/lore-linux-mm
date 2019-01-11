Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8E1F8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 08:34:04 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id v4so5803070edm.18
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 05:34:04 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a12si2355312edk.106.2019.01.11.05.34.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 05:34:03 -0800 (PST)
Date: Fri, 11 Jan 2019 14:34:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
Message-ID: <20190111133401.GA6997@dhcp22.suse.cz>
References: <e55fb27c-f23b-0ac5-acfd-7265c0a3b8dc@i-love.sakura.ne.jp>
 <20190109120212.GT31793@dhcp22.suse.cz>
 <201901102359.x0ANxIbn020225@www262.sakura.ne.jp>
 <fbdfdfeb-5664-ddf3-4d65-c64f9851ac26@i-love.sakura.ne.jp>
 <20190111113354.GD14956@dhcp22.suse.cz>
 <0d67b389-91e2-18ab-b596-39361b895c89@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0d67b389-91e2-18ab-b596-39361b895c89@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 11-01-19 21:40:52, Tetsuo Handa wrote:
[...]
> Did you notice that there is no
> 
>   "Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n"
> 
> line between
> 
>   [   71.304703][ T9694] Memory cgroup out of memory: Kill process 9692 (a.out) score 904 or sacrifice child
> 
> and
> 
>   [   71.309149][   T54] oom_reaper: reaped process 9750 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:185532kB
> 
> ? Then, you will find that [ T9694] failed to reach for_each_process(p) loop inside
> __oom_kill_process() in the first round of out_of_memory() call because
> find_lock_task_mm() == NULL at __oom_kill_process() because Ctrl-C made that victim
> complete exit_mm() before find_lock_task_mm() is called.

OK, so we haven't killed anything because the victim has exited by the
time we wanted to do so. We still have other tasks sharing that mm
pending and not killed because nothing has killed them yet, right?

How come the oom reaper could act on this oom event at all then?

What am I missing?
-- 
Michal Hocko
SUSE Labs
