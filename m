Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 372ED6B0547
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 09:15:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e9so144933272pga.5
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:15:09 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h4si13053692pln.760.2017.07.28.06.15.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 06:15:08 -0700 (PDT)
Subject: Re: Possible race condition in oom-killer
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com>
	<20170728123235.GN2274@dhcp22.suse.cz>
	<46e1e3ee-af9a-4e67-8b4b-5cf21478ad21@I-love.SAKURA.ne.jp>
	<20170728130723.GP2274@dhcp22.suse.cz>
In-Reply-To: <20170728130723.GP2274@dhcp22.suse.cz>
Message-Id: <201707282215.AGI69210.VFOHQFtOFSOJML@I-love.SAKURA.ne.jp>
Date: Fri, 28 Jul 2017 22:15:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: mjaggi@caviumnetworks.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> > 4578 is consuming memory as mlocked pages. But the OOM reaper cannot reclaim
> > mlocked pages (i.e. can_madv_dontneed_vma() returns false due to VM_LOCKED), can it?
> 
> You are absolutely right. I am pretty sure I've checked mlocked counter
> as the first thing but that must be from one of the earlier oom reports.
> My fault I haven't checked it in the critical one
> 
> [  365.267347] oom_reaper: reaped process 4578 (oom02), now anon-rss:131559616kB, file-rss:0kB, shmem-rss:0kB
> [  365.282658] oom_reaper: reaped process 4583 (oom02), now anon-rss:131561664kB, file-rss:0kB, shmem-rss:0kB
> 
> and the above screemed about the fact I was just completely blind.
> 
> mlock pages handling is on my todo list for quite some time already but
> I didn't get around it to implement that. mlock code is very tricky.

task_will_free_mem(current) in out_of_memory() returning false due to
MMF_OOM_SKIP already set allowed each thread sharing that mm to select a new
OOM victim. If task_will_free_mem(current) in out_of_memory() did not return
false, threads sharing MMF_OOM_SKIP mm would not have selected new victims
to the level where all OOM killable processes are killed and calls panic().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
