Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A32B66B052D
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:14:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id z195so2218460wmz.8
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:14:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 18si1144255wmh.215.2017.08.01.05.14.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 05:14:14 -0700 (PDT)
Date: Tue, 1 Aug 2017 14:14:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Possible race condition in oom-killer
Message-ID: <20170801121411.GG15774@dhcp22.suse.cz>
References: <20170728130723.GP2274@dhcp22.suse.cz>
 <201707282215.AGI69210.VFOHQFtOFSOJML@I-love.SAKURA.ne.jp>
 <20170728132952.GQ2274@dhcp22.suse.cz>
 <201707282255.BGI87015.FSFOVQtMOHLJFO@I-love.SAKURA.ne.jp>
 <20170728140706.GT2274@dhcp22.suse.cz>
 <201707291331.JGI18780.OtJVLFMHFOFSOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707291331.JGI18780.OtJVLFMHFOFSOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mjaggi@caviumnetworks.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat 29-07-17 13:31:44, Tetsuo Handa wrote:
[...]
> @@ -806,6 +799,20 @@ static bool task_will_free_mem(struct task_struct *task)
>  	}
>  	rcu_read_unlock();
>  
> +	/*
> +	 * It is possible that current thread fails to try allocation from
> +	 * memory reserves if the OOM reaper set MMF_OOM_SKIP on this mm before
> +	 * current thread calls out_of_memory() in order to get TIF_MEMDIE.
> +	 * In that case, allow current thread to try TIF_MEMDIE allocation
> +	 * before start selecting next OOM victims.
> +	 */
> +	if (ret && test_bit(MMF_OOM_SKIP, &mm->flags)) {
> +		if (task == current && !task->oom_kill_free_check_raced)
> +			task->oom_kill_free_check_raced = true;
> +		else
> +			ret = false;
> +	}
> +
>  	return ret;
>  }

I was going to argue that this will not work because we could mark a
former OOM victim again after it passed exit_oom_victim but this seems
impossible because task_will_free_mem checks task->mm and that will be
NULL by that time. This is still an ugly hack and it doesn't provide any
additional guarantee. Once we merge [1] then the oom victim wouldn't
need to get TIF_MEMDIE to access memory reserves.

[1] http://lkml.kernel.org/r/20170727090357.3205-2-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
