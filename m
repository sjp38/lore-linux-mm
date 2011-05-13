Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D194D90010D
	for <linux-mm@kvack.org>; Fri, 13 May 2011 07:11:52 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CBAB53EE0BB
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:11:48 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B281645DE59
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:11:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 83DF245DE55
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:11:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7517AEF8004
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:11:48 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C5F8E08002
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:11:48 +0900 (JST)
Message-ID: <4DCD1256.4070808@jp.fujitsu.com>
Date: Fri, 13 May 2011 20:13:26 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock seqlock to protect task->comm
 access
References: <1305241371-25276-1-git-send-email-john.stultz@linaro.org> <1305241371-25276-2-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305241371-25276-2-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Hi

Sorry for the long delay.

>   char *get_task_comm(char *buf, struct task_struct *tsk)
>   {
> -	/* buf must be at least sizeof(tsk->comm) in size */
> -	task_lock(tsk);
> -	strncpy(buf, tsk->comm, sizeof(tsk->comm));
> -	task_unlock(tsk);
> +	unsigned long seq;
> +
> +	do {
> +		seq = read_seqbegin(&tsk->comm_lock);
> +
> +		strncpy(buf, tsk->comm, sizeof(tsk->comm));
> +
> +	} while (read_seqretry(&tsk->comm_lock, seq));
> +
>   	return buf;
>   }

Can you please explain why we should use seqlock? That said,
we didn't use seqlock for /proc items. because, plenty seqlock
write may makes readers busy wait. Then, if we don't have another
protection, we give the local DoS attack way to attackers.

task->comm is used for very fundamentally. then, I doubt we can
assume write is enough rare. Why can't we use normal spinlock?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
