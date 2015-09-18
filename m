Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB186B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 15:10:27 -0400 (EDT)
Received: by qkap81 with SMTP id p81so23477714qka.2
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 12:10:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f73si9338050qkh.55.2015.09.18.12.10.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 12:10:26 -0700 (PDT)
Date: Fri, 18 Sep 2015 21:07:25 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
Message-ID: <20150918190725.GA24989@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150917192204.GA2728@redhat.com> <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org> <20150918162423.GA18136@redhat.com> <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kyle Walker <kwalker@redhat.com>, akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Stanislav Kozina <skozina@redhat.com>

On 09/18, Christoph Lameter wrote:
>
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

Well, I can't really comment. Hopefully we will see more comments from
those who understand oom-killer.

But I still think this is not enough, and we need some (configurable?)
timeout before we pick another victim...


And btw. Yes, this is a bit off-topic, but I think another change make
sense too. We should report the fact we are going to kill another task
because the previous victim refuse to die, and print its stack trace.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
