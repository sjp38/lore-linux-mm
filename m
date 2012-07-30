Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 1DA726B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 10:00:13 -0400 (EDT)
Date: Mon, 30 Jul 2012 16:00:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + memcg-oom-clarify-some-oom-dump-messages.patch added to -mm
 tree
Message-ID: <20120730140009.GF12680@tiehlicka.suse.cz>
References: <20120724203309.B04155C0050@hpza9.eem.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120724203309.B04155C0050@hpza9.eem.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, handai.szj@taobao.com, gthelen@google.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 24-07-12 13:33:08, Andrew Morton wrote:
> 
> The patch titled
>      Subject: memcg, oom: clarify some oom dump messages
> has been added to the -mm tree.  Its filename is
>      memcg-oom-clarify-some-oom-dump-messages.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Sha Zhengju <handai.szj@taobao.com>
> Subject: memcg, oom: clarify some oom dump messages
> 
> Revise some oom dump messages to avoid misleading admin.

Not that I would care much, but does this make the messages really more
clear?
OOM killer just sends the signal and the task dies asynchronously so
saying that something has been killed is a bit misleading but I am
wondering it it really confuses anybody to make a wrong conclusion from
the message.

[...]
> diff -puN mm/oom_kill.c~memcg-oom-clarify-some-oom-dump-messages mm/oom_kill.c
> --- a/mm/oom_kill.c~memcg-oom-clarify-some-oom-dump-messages
> +++ a/mm/oom_kill.c
[...]
> @@ -509,6 +509,7 @@ void oom_kill_process(struct task_struct
>  	if (!p) {
>  		rcu_read_unlock();
>  		put_task_struct(victim);
> +		pr_err("No process has been killed!\n");

Is this even true? p existed few moments ago so it could have been
killed and exited in the mean time

>  		return;
>  	} else if (victim != p) {
>  		get_task_struct(p);
> @@ -540,7 +541,7 @@ void oom_kill_process(struct task_struct
>  				continue;
>  
>  			task_lock(p);	/* Protect ->comm from prctl() */
> -			pr_err("Kill process %d (%s) sharing same memory\n",
> +			pr_err("Killed process %d (%s) sharing same memory\n",
>  				task_pid_nr(p), p->comm);

technically it hasn't been killed yet because you are sending the signal
bellow.

>  			task_unlock(p);
>  			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
> _
> Subject: Subject: memcg, oom: clarify some oom dump messages
> 
> Patches currently in -mm which might be from handai.szj@taobao.com are
> 
> mm-oom-introduce-helper-function-to-process-threads-during-scan.patch
> mm-memcg-introduce-own-oom-handler-to-iterate-only-over-its-own-threads.patch
> memcg-oom-provide-more-info-while-memcg-oom-happening.patch
> memcg-oom-clarify-some-oom-dump-messages.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
