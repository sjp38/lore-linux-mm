Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6D14B6B0257
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:21:34 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id n186so1537001wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:21:34 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id t10si33333767wjf.128.2016.02.29.10.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 10:21:33 -0800 (PST)
Received: by mail-wm0-f52.google.com with SMTP id l68so3140920wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:21:33 -0800 (PST)
Date: Mon, 29 Feb 2016 19:21:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] exit: clear TIF_MEMDIE after exit_task_work
Message-ID: <20160229182131.GP16930@dhcp22.suse.cz>
References: <1456765329-14890-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456765329-14890-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 29-02-16 20:02:09, Vladimir Davydov wrote:
> An mm_struct may be pinned by a file. An example is vhost-net device
> created by a qemu/kvm (see vhost_net_ioctl -> vhost_net_set_owner ->
> vhost_dev_set_owner). If such process gets OOM-killed, the reference to
> its mm_struct will only be released from exit_task_work -> ____fput ->
> __fput -> vhost_net_release -> vhost_dev_cleanup, which is called after
> exit_mmap, where TIF_MEMDIE is cleared. As a result, we can start
> selecting the next victim before giving the last one a chance to free
> its memory. In practice, this leads to killing several VMs along with
> the fattest one.

I am wondering why our PF_EXITING protection hasn't fired up. This is
not done in the mmotm tree but I guess you have seen the issue with the
linus tree, right? Do you have a log with oom reports available?

To be honest I do not feel very comfortable about moving the
exit_oom_victim even further down in do_exit path behind even less clear
locking or other dependencies.

Let's see if we can do any better for this particular case. 

> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> ---
>  kernel/exit.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/exit.c b/kernel/exit.c
> index fd90195667e1..cc50e12165f7 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -434,8 +434,6 @@ static void exit_mm(struct task_struct *tsk)
>  	task_unlock(tsk);
>  	mm_update_next_owner(mm);
>  	mmput(mm);
> -	if (test_thread_flag(TIF_MEMDIE))
> -		exit_oom_victim(tsk);
>  }
>  
>  static struct task_struct *find_alive_thread(struct task_struct *p)
> @@ -746,6 +744,8 @@ void do_exit(long code)
>  		disassociate_ctty(1);
>  	exit_task_namespaces(tsk);
>  	exit_task_work(tsk);
> +	if (test_thread_flag(TIF_MEMDIE))
> +		exit_oom_victim(tsk);
>  	exit_thread();
>  
>  	/*
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
