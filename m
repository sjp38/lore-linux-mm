Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3A20D6B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 11:24:43 -0400 (EDT)
Received: by mail-yh0-f49.google.com with SMTP id b6so771000yha.22
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 08:24:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r4si5653745yhh.123.2014.07.30.08.24.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jul 2014 08:24:42 -0700 (PDT)
Date: Wed, 30 Jul 2014 17:06:15 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] mm, oom: remove unnecessary exit_state check
Message-ID: <20140730150615.GA20659@redhat.com>
References: <alpine.DEB.2.02.1407291638310.858@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407291638310.858@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/29, David Rientjes wrote:
>
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -455,6 +455,7 @@ static void exit_mm(struct task_struct * tsk)
>  	task_unlock(tsk);
>  	mm_update_next_owner(mm);
>  	mmput(mm);
> +	clear_thread_flag(TIF_MEMDIE);
>  }
>  
>  /*
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -258,8 +258,6 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
>  		unsigned long totalpages, const nodemask_t *nodemask,
>  		bool force_kill)
>  {
> -	if (task->exit_state)
> -		return OOM_SCAN_CONTINUE;

IIRC, this check was a workaround, to ensure that a oom-killed zombie
can't block oom-killer.

I think this patch can equally work.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
