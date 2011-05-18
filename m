Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E26388D003B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 22:01:48 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5D7DC3EE0D1
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:01:45 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3684245DE78
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:01:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E48C45DE92
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:01:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ED666E18004
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:01:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B50501DB8038
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:01:44 +0900 (JST)
Message-ID: <4DD3287A.2030808@jp.fujitsu.com>
Date: Wed, 18 May 2011 11:01:30 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] comm: Introduce comm_lock spinlock to protect task->comm
 access
References: <1305682865-27111-1-git-send-email-john.stultz@linaro.org> <1305682865-27111-2-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305682865-27111-2-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.stultz@linaro.org
Cc: linux-kernel@vger.kernel.org, joe@perches.com, mingo@elte.hu, mina86@mina86.com, apw@canonical.com, jirislaby@gmail.com, rientjes@google.com, dave@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org

> diff --git a/fs/exec.c b/fs/exec.c
> index 5e62d26..34fa611 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -998,17 +998,28 @@ static void flush_old_files(struct files_struct * files)
> 
>   char *get_task_comm(char *buf, struct task_struct *tsk)
>   {
> -	/* buf must be at least sizeof(tsk->comm) in size */
> -	task_lock(tsk);
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&tsk->comm_lock, flags);
>   	strncpy(buf, tsk->comm, sizeof(tsk->comm));
> -	task_unlock(tsk);
> +	spin_unlock_irqrestore(&tsk->comm_lock, flags);
>   	return buf;
>   }
> 
>   void set_task_comm(struct task_struct *tsk, char *buf)
>   {
> +	unsigned long flags;
> +
> +	/*
> +	 * XXX - Even though comm is protected by comm_lock,
> +	 * we take the task_lock here to serialize against
> +	 * current users that directly access comm.
> +	 * Once those users are removed, we can drop the
> +	 * task locking&  memsetting.
> +	 */

If we provide __get_task_comm(), we can't remove memset() forever.


>   	task_lock(tsk);
> +	spin_lock_irqsave(&tsk->comm_lock, flags);

This is strange order. task_lock() doesn't disable interrupt.
And, can you please document why we need interrupt disabling?


>   	/*
>   	 * Threads may access current->comm without holding
>   	 * the task lock, so write the string carefully.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
