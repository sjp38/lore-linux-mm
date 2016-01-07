Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9C6828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 10:38:59 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id yy13so168844290pab.3
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 07:38:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id hp4si67566681pad.113.2016.01.07.07.38.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 07:38:58 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201512292258.ABF87505.OFOSJLHMFVOQFt@I-love.SAKURA.ne.jp>
	<20160107091512.GB27868@dhcp22.suse.cz>
	<201601072231.DGG78695.OOFVLHJFFQOStM@I-love.SAKURA.ne.jp>
	<20160107145841.GN27868@dhcp22.suse.cz>
In-Reply-To: <20160107145841.GN27868@dhcp22.suse.cz>
Message-Id: <201601080038.CIF04698.VFJHSOQLOFFMOt@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jan 2016 00:38:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> @@ -333,6 +333,14 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
>  		if (points == chosen_points && thread_group_leader(chosen))
>  			continue;
>  
> +		/*
> +		 * If the current major task is already ooom killed and this
> +		 * is sysrq+f request then we rather choose somebody else
> +		 * because the current oom victim might be stuck.
> +		 */
> +		if (is_sysrq_oom(sc) && test_tsk_thread_flag(p, TIF_MEMDIE))
> +			continue;
> +
>  		chosen = p;
>  		chosen_points = points;
>  	}

Do we want to require SysRq-f for each thread in a process?
If g has 1024 p, dump_tasks() will do

  pr_info("[%5d] %5d %5d %8lu %8lu %7ld %7ld %8lu         %5hd %s\n",

for 1024 times? I think one SysRq-f per one process is sufficient.

How can we guarantee that find_lock_task_mm() from oom_kill_process()
chooses !TIF_MEMDIE thread when try_to_sacrifice_child() somehow chose
!TIF_MEMDIE thread? I think choosing !TIF_MEMDIE thread at
find_lock_task_mm() is the simplest way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
