Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id E6E036B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 07:42:33 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fg1so90027623pad.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 04:42:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w2si5366905pay.144.2016.06.03.04.42.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Jun 2016 04:42:33 -0700 (PDT)
Subject: Re: [PATCH 07/10] mm, oom: fortify task_will_free_mem
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
	<1464945404-30157-8-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464945404-30157-8-git-send-email-mhocko@kernel.org>
Message-Id: <201606032042.ADC04699.SFFOJLHFOOQMVt@I-love.SAKURA.ne.jp>
Date: Fri, 3 Jun 2016 20:42:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, mhocko@suse.com

Michal Hocko wrote:
> +static inline bool __task_will_free_mem(struct task_struct *task)
> +{
> +	struct signal_struct *sig = task->signal;
> +
> +	/*
> +	 * A coredumping process may sleep for an extended period in exit_mm(),
> +	 * so the oom killer cannot assume that the process will promptly exit
> +	 * and release memory.
> +	 */
> +	if (sig->flags & SIGNAL_GROUP_COREDUMP)
> +		return false;
> +
> +	if (sig->flags & SIGNAL_GROUP_EXIT)
> +		return true;
> +
> +	if (thread_group_empty(task) && PF_EXITING)
> +		return true;

"thread_group_empty(task) && PF_EXITING" is wrong.

> +
> +	return false;
> +}
> +
> +/*
> + * Checks whether the given task is dying or exiting and likely to
> + * release its address space. This means that all threads and processes
> + * sharing the same mm have to be killed or exiting.
> + */
> +bool task_will_free_mem(struct task_struct *task)
> +{
> +	struct mm_struct *mm;
> +	struct task_struct *p;
> +	bool ret;
> +
> +	if (!__task_will_free_mem(p))
> +		return false;

mm/oom_kill.c: In function 'task_will_free_mem':
mm/oom_kill.c:758:27: warning: 'p' is used uninitialized in this function [-Wuninitialized]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
