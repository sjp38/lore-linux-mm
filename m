Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id CA6DD6B0256
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 08:32:52 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id n186so131732914wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:32:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r123si20990345wmb.8.2016.03.08.05.32.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 05:32:51 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] mm,oom: Reduce needless dereference.
References: <1457434951-12691-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <56DED480.3040202@suse.cz>
Date: Tue, 8 Mar 2016 14:32:48 +0100
MIME-Version: 1.0
In-Reply-To: <1457434951-12691-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org

On 03/08/2016 12:02 PM, Tetsuo Handa wrote:
> Since we assigned mm = victim->mm before pr_err(),
> we don't need to dereference victim->mm again at pr_err().
> This saves a few instructions.

That sounds obvious, right. Yet once in a while I try to test these for
fun, and there can be indeed surprises :)

./scripts/bloat-o-meter says:
add/remove: 0/0 grow/shrink: 1/0 up/down: 1/0 (1)
function                                     old     new   delta
oom_kill_process                            1085    1086      +1

a naive asmdiff is too complicated to follow  but it seems from the
number of lines that indeed there are less instructions in your case,
but still the code is a bit larger.

Just a reminder that compilers can be quite counter-intuitive. Anyway, a
liquid-helium-path like this probably doesn't need such
microoptimisations as an extra patch, given the ongoing churn in the oom
area?

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index c84e784..1808db32 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -756,10 +756,10 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
>  	mark_oom_victim(victim);
>  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> -		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
> -		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> -		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
> -		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
> +	       task_pid_nr(victim), victim->comm, K(mm->total_vm),
> +	       K(get_mm_counter(mm, MM_ANONPAGES)),
> +	       K(get_mm_counter(mm, MM_FILEPAGES)),
> +	       K(get_mm_counter(mm, MM_SHMEMPAGES)));
>  	task_unlock(victim);
>  
>  	/*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
