Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC2B6B0253
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 06:40:53 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id z36so403811093qtb.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 03:40:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q25si1656618qtq.57.2016.07.04.03.40.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 03:40:52 -0700 (PDT)
Date: Mon, 4 Jul 2016 12:40:43 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 8/8] mm,oom_reaper: Make OOM reaper use list of mm_struct.
Message-ID: <20160704104042.GB3882@redhat.com>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
 <201607031141.FII82373.FMHQLFOOtVSJOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607031141.FII82373.FMHQLFOOtVSJOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

On 07/03, Tetsuo Handa wrote:
>
> +static void oom_reap_vmas(struct mm_struct *mm)
>  {
>  	int attempts = 0;
> -	struct mm_struct *mm = NULL;
> -	struct task_struct *p = find_lock_task_mm(tsk);
> +	bool ret;
>
>  	/*
> -	 * Make sure we find the associated mm_struct even when the particular
> -	 * thread has already terminated and cleared its mm.
> -	 * We might have race with exit path so consider our work done if there
> -	 * is no mm.
> +	 * Check MMF_OOM_REAPED after holding oom_lock because
> +	 * oom_kill_process() might find this mm pinned.
>  	 */
> -	if (!p)
> -		goto done;
> -	mm = p->mm;
> -	atomic_inc(&mm->mm_count);
> -	task_unlock(p);
> +	mutex_lock(&oom_lock);
> +	ret = test_bit(MMF_OOM_REAPED, &mm->flags);
> +	mutex_unlock(&oom_lock);

OK, but this looks strange...

Can't we instead move mark_oom_victim(victim) to the end of oom_kill_process(),
and change mark_oom_victim() to do nothing if MMF_OOM_REAPED is set? Or just
check this flag in oom_kill_process() before mark_oom_victim().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
