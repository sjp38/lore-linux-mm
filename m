Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id C14E76B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 12:27:23 -0400 (EDT)
Received: by qgez77 with SMTP id z77so43051253qge.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 09:27:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b15si8537946qkh.105.2015.09.18.09.27.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 09:27:23 -0700 (PDT)
Date: Fri, 18 Sep 2015 18:24:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
Message-ID: <20150918162423.GA18136@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150917192204.GA2728@redhat.com> <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kyle Walker <kwalker@redhat.com>, akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Stanislav Kozina <skozina@redhat.com>

On 09/18, Christoph Lameter wrote:
>
> > But yes, such a deadlock is possible. I would really like to see the comments
> > from maintainers. In particular, I seem to recall that someone suggested to
> > try to kill another !TIF_MEMDIE process after timeout, perhaps this is what
> > we should actually do...
>
> Well yes here is a patch that kills another memdie process but there is
> some risk with such an approach of overusing the reserves.

Yes, I understand it is not that simple. And probably this is all I can
understand ;)

> --- linux.orig/mm/oom_kill.c	2015-09-18 10:38:29.601963726 -0500
> +++ linux/mm/oom_kill.c	2015-09-18 10:39:55.911699017 -0500
> @@ -265,8 +265,8 @@ enum oom_scan_t oom_scan_process_thread(
>  	 * Don't allow any other task to have access to the reserves.
>  	 */
>  	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> -		if (oc->order != -1)
> -			return OOM_SCAN_ABORT;
> +		if (unlikely(frozen(task)))
> +			__thaw_task(task);

To simplify the discussion lets ignore PF_FROZEN, this is another issue.

I am not sure this change is enough, we need to ensure that
select_bad_process() won't pick the same task (or its sub-thread) again.

And perhaps something like

	wait_event_timeout(oom_victims_wait, !oom_victims,
				configurable_timeout);

before select_bad_process() makes sense?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
