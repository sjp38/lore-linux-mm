Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB01828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 10:44:39 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id f206so102808205wmf.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 07:44:39 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id a4si167662695wjb.207.2016.01.07.07.44.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 07:44:38 -0800 (PST)
Received: by mail-wm0-f50.google.com with SMTP id l65so102071890wmf.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 07:44:38 -0800 (PST)
Date: Thu, 7 Jan 2016 16:44:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
Message-ID: <20160107154436.GO27868@dhcp22.suse.cz>
References: <201512292258.ABF87505.OFOSJLHMFVOQFt@I-love.SAKURA.ne.jp>
 <20160107091512.GB27868@dhcp22.suse.cz>
 <201601072231.DGG78695.OOFVLHJFFQOStM@I-love.SAKURA.ne.jp>
 <20160107145841.GN27868@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160107145841.GN27868@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 07-01-16 15:58:41, Michal Hocko wrote:
> On Thu 07-01-16 22:31:32, Tetsuo Handa wrote:
> [...]
> > I think we need to filter at select_bad_process() and oom_kill_process().
> > 
> > When P has no children, P is chosen and TIF_MEMDIE is set on P. But P can
> > be chosen forever due to P->signal->oom_score_adj == OOM_SCORE_ADJ_MAX
> > even if the OOM reaper reclaimed P's mm. We need to ensure that
> > oom_kill_process() is not called with P if P already has TIF_MEMDIE.
> 
> Hmm. Any task is allowed to set its oom_score_adj that way and I
> guess we should really make sure that at least sysrq+f will make some
> progress. This is what I would do. Again I think this is worth a
> separate patch. Unless there are any objections I will roll out what I
> have and post 3 separate patches.
> ---
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 45e51ad2f7cf..ee34a51bd65a 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
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

I guess we can move this up to oom_scan_process_thread already. It would
be simpler and I it should be also more appropriate because we already
do sysrq specific handling there:
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 45e51ad2f7cf..a27a43212075 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -277,10 +277,16 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	/*
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves.
+	 * If we are doing sysrq+f then it doesn't make any sense to check such
+	 * a task because it might be stuck and unable to terminate while the
+	 * forced OOM might be the only option left to get the system back to
+	 * work.
 	 */
 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
 		if (!is_sysrq_oom(oc))
 			return OOM_SCAN_ABORT;
+		else
+			return OOM_SCAN_CONTINUE;
 	}
 	if (!task->mm)
 		return OOM_SCAN_CONTINUE;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
