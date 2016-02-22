Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 63BA46B0253
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 06:39:36 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id a4so158353265wme.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 03:39:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u184si32139753wmd.92.2016.02.22.03.39.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 Feb 2016 03:39:35 -0800 (PST)
Date: Mon, 22 Feb 2016 12:39:33 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,oom: don't kill children of oom_task_origin() process.
Message-ID: <20160222113933.GE17938@dhcp22.suse.cz>
References: <1455944042-7614-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455944042-7614-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, linux-mm@kvack.org

On Sat 20-02-16 13:54:02, Tetsuo Handa wrote:
> Selecting a child of the candidate which was chosen by oom_task_origin()
> is pointless. We want to kill the candidate first.

NACK, until we see a clear evidence that there is a real application
which triggers ksm/swapoff from a context where this would make a
difference. There is no good reason to add new checks to an already
subtle code just for something that even doesn't matter in the real
life.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 28d6a32..703537a2 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -697,6 +697,14 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	if (__ratelimit(&oom_rs))
>  		dump_header(oc, p, memcg);
>  
> +	/*
> +	 * We must send SEGKILL on p rather than p's children in order to make
> +	 * sure that oom_task_origin(p) becomes false. Printing the score value
> +	 * which is (ULONG_MAX * 1000 / totalpages) is useless for this case.
> +	 */
> +	if (oom_task_origin(p))
> +		goto kill;
> +
>  	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
>  		message, task_pid_nr(p), p->comm, points);
>  
> @@ -728,6 +736,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	}
>  	read_unlock(&tasklist_lock);
>  
> + kill:
>  	p = find_lock_task_mm(victim);
>  	if (!p) {
>  		put_task_struct(victim);
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
