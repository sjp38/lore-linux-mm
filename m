Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB7A6B0254
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 04:32:22 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so55509464wic.1
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 01:32:21 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id bt11si16918536wjb.210.2015.09.19.01.32.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 01:32:21 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so55386512wic.0
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 01:32:20 -0700 (PDT)
Date: Sat, 19 Sep 2015 10:32:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
Message-ID: <20150919083218.GD28815@dhcp22.suse.cz>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
 <20150917192204.GA2728@redhat.com>
 <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org>
 <20150918162423.GA18136@redhat.com>
 <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Stanislav Kozina <skozina@redhat.com>

On Fri 18-09-15 12:00:59, Christoph Lameter wrote:
[...]
> Subject: Allow multiple kills from the OOM killer
> 
> The OOM killer currently aborts if it finds a process that already is having
> access to the reserve memory pool for exit processing. This is done so that
> the reserves are not overcommitted but on the other hand this also allows
> only one process being oom killed at the time. That process may be stuck
> in D state.

This has been posted in various forms many times over past years. I
still do not think this is a right approach of dealing with the problem.
You can quickly deplete memory reserves this way without making further
progress (I am afraid you can even trigger this from userspace without
having big privileges) so even administrator will have no way to
intervene.

> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/oom_kill.c
> ===================================================================
> --- linux.orig/mm/oom_kill.c	2015-09-18 11:58:52.963946782 -0500
> +++ linux/mm/oom_kill.c	2015-09-18 11:59:42.010684778 -0500
> @@ -264,10 +264,9 @@ enum oom_scan_t oom_scan_process_thread(
>  	 * This task already has access to memory reserves and is being killed.
>  	 * Don't allow any other task to have access to the reserves.
>  	 */
> -	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> -		if (oc->order != -1)
> -			return OOM_SCAN_ABORT;
> -	}
> +	if (test_tsk_thread_flag(task, TIF_MEMDIE))
> +		return OOM_SCAN_CONTINUE;
> +
>  	if (!task->mm)
>  		return OOM_SCAN_CONTINUE;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
