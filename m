Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A08B06B002B
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:54:31 -0400 (EDT)
Received: by bwz17 with SMTP id 17so6404346bwz.14
        for <linux-mm@kvack.org>; Mon, 16 May 2011 14:54:28 -0700 (PDT)
Message-ID: <4DD19D10.3000201@gmail.com>
Date: Mon, 16 May 2011 23:54:24 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org> <1305580757-13175-3-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305580757-13175-3-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 05/16/2011 11:19 PM, John Stultz wrote:
> Accessing task->comm requires proper locking. However in the past
> access to current->comm could be done without locking. This
> is no longer the case, so all comm access needs to be done
> while holding the comm_lock.
> 
> In my attempt to clean up unprotected comm access, I've noticed
> most comm access is done for printk output. To simplify correct
> locking in these cases, I've introduced a new %ptc format,
> which will print the corresponding task's comm.
> 
> Example use:
> printk("%ptc: unaligned epc - sending SIGBUS.\n", current);
> 
> CC: Ted Ts'o <tytso@mit.edu>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: David Rientjes <rientjes@google.com>
> CC: Dave Hansen <dave@linux.vnet.ibm.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: linux-mm@kvack.org
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>  lib/vsprintf.c |   24 ++++++++++++++++++++++++
>  1 files changed, 24 insertions(+), 0 deletions(-)
> 
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index bc0ac6b..b7a9953 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -797,6 +797,23 @@ char *uuid_string(char *buf, char *end, const u8 *addr,
>  	return string(buf, end, uuid, spec);
>  }
>  
> +static noinline_for_stack

Actually, why noinline? Did your previous version have there some
TASK_COMM_LEN buffer or anything on stack which is not there anymore?

> +char *task_comm_string(char *buf, char *end, void *addr,
> +			 struct printf_spec spec, const char *fmt)
> +{
> +	struct task_struct *tsk = addr;
> +	char *ret;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&tsk->comm_lock, flags);
> +	ret = string(buf, end, tsk->comm, spec);
> +	spin_unlock_irqrestore(&tsk->comm_lock, flags);
> +
> +	return ret;
> +}
> +
> +
> +
>  int kptr_restrict = 1;
>  
>  /*

thanks,
-- 
js

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
