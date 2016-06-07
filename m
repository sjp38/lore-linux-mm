Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C035F6B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 02:26:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k184so28064763wme.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 23:26:53 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id w139si23261977wmw.43.2016.06.06.23.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 23:26:52 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n184so21399662wmn.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 23:26:52 -0700 (PDT)
Date: Tue, 7 Jun 2016 08:26:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 10/10] mm, oom: hide mm which is shared with kthread
 or global init
Message-ID: <20160607062650.GA12305@dhcp22.suse.cz>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
 <1464945404-30157-11-git-send-email-mhocko@kernel.org>
 <201606040016.BFG17115.OFMLSJFOtHQOFV@I-love.SAKURA.ne.jp>
 <20160606132650.GI11895@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606132650.GI11895@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Mon 06-06-16 15:26:50, Michal Hocko wrote:
[...]
> @@ -922,8 +941,17 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	}
>  	rcu_read_unlock();
>  
> -	if (can_oom_reap)
> +	if (can_oom_reap) {
>  		wake_oom_reaper(victim);
> +	} else if (victim != current) {
> +		/*
> +		 * If we want to guarantee a forward progress we cannot keep
> +		 * the oom victim TIF_MEMDIE here. Sleep for a while and then
> +		 * drop the flag to make sure another victim can be selected.
> +		 */
> +		schedule_timeout_killable(HZ);
> +		exit_oom_victim(victim);

thiking about it more, with the other change in the
oom_scan_process_thread we do not need to exit_oom_victim. In fact we
even shouldn't because of the oom_disabled synchronization. I will
respin the patch and drop the exit_oom_victim part.
schedule_timeout_killable will stay...

> +	}
>  
>  	mmdrop(mm);
>  	put_task_struct(victim);
> -- 
> 2.8.1
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
