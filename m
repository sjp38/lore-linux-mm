Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC41C6B0006
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 07:30:54 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id f206so95851163wmf.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 04:30:54 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id n8si166550625wjy.101.2016.01.07.04.30.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 04:30:53 -0800 (PST)
Received: by mail-wm0-f53.google.com with SMTP id l65so95039980wmf.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 04:30:53 -0800 (PST)
Date: Thu, 7 Jan 2016 13:30:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20160107123051.GK27868@dhcp22.suse.cz>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
 <1452094975-551-2-git-send-email-mhocko@kernel.org>
 <201601072023.AGC51005.QSFFHOVMJOFLtO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601072023.AGC51005.QSFFHOVMJOFLtO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 07-01-16 20:23:04, Tetsuo Handa wrote:
[...]
> According to commit a2b829d95958da20 ("mm/oom_kill.c: avoid attempting
> to kill init sharing same memory"), below patch is needed for avoid
> killing init process with SIGSEGV.
> 
> ----------
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 9548dce..9832f3f 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -784,9 +784,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>   			continue;
>   		if (same_thread_group(p, victim))
>   			continue;
> -		if (is_global_init(p))
> -			continue;
> -		if (unlikely(p->flags & PF_KTHREAD) ||
> +		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
>   		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
>   			/*
>   			 * We cannot use oom_reaper for the mm shared by this
[...]
> [    3.132836] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
> [    3.137232] [   98]     0    98   279607   244400     489       5        0             0 init
> [    3.141664] Out of memory: Kill process 98 (init) score 940 or sacrifice child
> [    3.145346] Killed process 98 (init) total-vm:1118428kB, anon-rss:977464kB, file-rss:136kB, shmem-rss:0kB
> [    3.416105] init[1]: segfault at 0 ip           (null) sp 00007ffd484cf5f0 error 14 in init[400000+1000]
> [    3.439074] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
> [    3.439074]
> [    3.450193] Kernel Offset: disabled
> [    3.456259] ---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
> [    3.456259]

Ouch. You are right. The reaper will tear down the shared mm and the
global init will blow up. Very well spotted! The system will blow up
later, I would guess, because killing the victim wouldn't release a lot
of memory which will be pinned by the global init. So a panic sounds
unevitable. The scenario is really insane but what you are proposing is
correct.

Updated patch below.
--- 
