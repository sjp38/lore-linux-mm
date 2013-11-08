Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0851C6B01A6
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 13:43:54 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id q10so2496948pdj.41
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 10:43:54 -0800 (PST)
Received: from psmtp.com ([74.125.245.148])
        by mx.google.com with SMTP id cx4si7443998pbc.119.2013.11.08.10.43.52
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 10:43:53 -0800 (PST)
Date: Fri, 8 Nov 2013 19:45:15 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] mm, oom: Fix race when selecting process to kill
Message-ID: <20131108184515.GA11555@redhat.com>
References: <alpine.DEB.2.02.1311061631280.22318@chino.kir.corp.google.com> <1383934035-933-1-git-send-email-snanda@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383934035-933-1-git-send-email-snanda@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sameer Nanda <snanda@chromium.org>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, rusty@rustcorp.com.au, semenzato@google.com, murzin.v@gmail.com, dserrg@gmail.com, msb@chromium.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Sorry.

I didn't have time to answer other emails, will try to do later.

And yes, yes, while_each_thread() should be fixed, still on my
TODO list... But just in case, whatever we do with while_each_thread()
we should also fix some users.

Until then,

On 11/08, Sameer Nanda wrote:
>
> @@ -412,13 +412,16 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  					      DEFAULT_RATELIMIT_BURST);
>
> +	read_lock(&tasklist_lock);
> +
>  	/*
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>  	 */
> -	if (p->flags & PF_EXITING) {
> +	if (p->flags & PF_EXITING || !pid_alive(p)) {

OK.

> -	read_lock(&tasklist_lock);

But you should also move read_unlock_down(), at least after
find_lock_task_mm().

And of course, this doesn't fix other users in oom_kill.c.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
