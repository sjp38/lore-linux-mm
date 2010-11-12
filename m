Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id ECBFA8D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 12:40:25 -0500 (EST)
Date: Fri, 12 Nov 2010 18:34:00 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] ioprio: grab rcu_read_lock in sys_ioprio_{set,get}()
Message-ID: <20101112173400.GA8659@redhat.com>
References: <1289547167-32675-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1289547167-32675-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/11, Greg Thelen wrote:
>
> The fix is to:
> a) grab rcu lock in sys_ioprio_{set,get}() and
> b) avoid grabbing tasklist_lock.
> Discussion in: http://marc.info/?l=linux-kernel&m=128951324702889
>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Reviewed-by: Oleg Nesterov <oleg@redhat.com>

> ---
>  fs/ioprio.c |   13 ++++---------
>  1 files changed, 4 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/ioprio.c b/fs/ioprio.c
> index 748cfb9..7da2a06 100644
> --- a/fs/ioprio.c
> +++ b/fs/ioprio.c
> @@ -103,12 +103,7 @@ SYSCALL_DEFINE3(ioprio_set, int, which, int, who, int, ioprio)
>  	}
>  
>  	ret = -ESRCH;
> -	/*
> -	 * We want IOPRIO_WHO_PGRP/IOPRIO_WHO_USER to be "atomic",
> -	 * so we can't use rcu_read_lock(). See re-copy of ->ioprio
> -	 * in copy_process().
> -	 */
> -	read_lock(&tasklist_lock);
> +	rcu_read_lock();
>  	switch (which) {
>  		case IOPRIO_WHO_PROCESS:
>  			if (!who)
> @@ -153,7 +148,7 @@ free_uid:
>  			ret = -EINVAL;
>  	}
>  
> -	read_unlock(&tasklist_lock);
> +	rcu_read_unlock();
>  	return ret;
>  }
>  
> @@ -197,7 +192,7 @@ SYSCALL_DEFINE2(ioprio_get, int, which, int, who)
>  	int ret = -ESRCH;
>  	int tmpio;
>  
> -	read_lock(&tasklist_lock);
> +	rcu_read_lock();
>  	switch (which) {
>  		case IOPRIO_WHO_PROCESS:
>  			if (!who)
> @@ -250,6 +245,6 @@ SYSCALL_DEFINE2(ioprio_get, int, which, int, who)
>  			ret = -EINVAL;
>  	}
>  
> -	read_unlock(&tasklist_lock);
> +	rcu_read_unlock();
>  	return ret;
>  }
> -- 
> 1.7.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
