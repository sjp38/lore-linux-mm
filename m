Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 148876B0032
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 12:37:19 -0400 (EDT)
Date: Mon, 9 Sep 2013 18:31:09 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] OOM killer: wait for tasks with pending SIGKILL to exit
Message-ID: <20130909163109.GA9334@redhat.com>
References: <1378740624-2456-1-git-send-email-dserrg@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378740624-2456-1-git-send-email-dserrg@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Dyasly <dserrg@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Rusty Russell <rusty@rustcorp.com.au>, Sha Zhengju <handai.szj@taobao.com>

Can't really comment this patch, just one off-topic note...

On 09/09, Sergey Dyasly wrote:
>
> @@ -275,13 +275,16 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
>  	if (oom_task_origin(task))
>  		return OOM_SCAN_SELECT;
>  
> -	if (task->flags & PF_EXITING && !force_kill) {
> +	if ((task->flags & PF_EXITING || fatal_signal_pending(task)) &&
> +	    !force_kill) {
>  		/*
>  		 * If this task is not being ptraced on exit, then wait for it
>  		 * to finish before killing some other task unnecessarily.
>  		 */
> -		if (!(task->group_leader->ptrace & PT_TRACE_EXIT))
> +		if (!(task->group_leader->ptrace & PT_TRACE_EXIT)) {

can't we finally kill (or fix?) this PT_TRACE_EXIT check?

It was added to fix the exploit I sent. But the patch was wrong,
that exploit could be easily modified to trigger the same problem.

However, now that the coredumping is killable that exploit won't
work, so the original reason has gone away.

So why do we need this check today?

And note that we check ->group_leader, this looks completely wrong.
(again, ->group_leader was used just because the original exploit
 traced the group leader).

David?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
