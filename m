Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15E076B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 17:55:48 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id d2so73561161qkg.0
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 14:55:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y19si6459504qka.154.2016.06.24.14.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 14:55:47 -0700 (PDT)
Date: Fri, 24 Jun 2016 23:56:27 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
	TIF_MEMDIE
Message-ID: <20160624215627.GA1148@redhat.com>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, David Rientjes <rientjes@google.com>

Since I mentioned TIF_MEMDIE in another thread, I simply can't resist.
Sorry for grunting.

On 06/24, Tetsuo Handa wrote:
>
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -801,6 +801,7 @@ struct signal_struct {
>  	 * oom
>  	 */
>  	bool oom_flag_origin;
> +	bool oom_ignore_victims;        /* Ignore oom_victims value */
>  	short oom_score_adj;		/* OOM kill score adjustment */
>  	short oom_score_adj_min;	/* OOM kill score adjustment min value.
>  					 * Only settable by CAP_SYS_RESOURCE. */

Yet another kludge to fix yet another problem with TIF_MEMDIE. Not
to mention that that wh

Can't we state the fact TIF_MEMDIE is just broken? The very idea imo.
I am starting to seriously think we should kill this flag, fix the
compilation errors, remove the dead code (including the oom_victims
logic), and then try to add something else. Say, even MMF_MEMDIE looks
better although I understand it is not that simple.

Just one question. Why do we need this bit outside of oom-kill.c? It
affects page_alloc.c and this probably makes sense. But who get this
flag when we decide to kill the memory hog? A random thread foung by
find_lock_task_mm(), iow a random thread with ->mm != NULL, likely the
group leader. This simply can not be right no matter what.



And in any case I don't understand this patch but I have to admit that
I failed to force myself to read the changelog and the actual change ;)
In any case I agree that we should not set MMF_MEMDIE if ->mm == NULL,
and if we ensure this then I do not understand why we can't rely on
MMF_OOM_REAPED. Ignoring the obvious races, if ->oom_victims != 0 then
find_lock_task_mm() should succed.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
