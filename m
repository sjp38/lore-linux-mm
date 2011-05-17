Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 019056B0026
	for <linux-mm@kvack.org>; Tue, 17 May 2011 17:42:09 -0400 (EDT)
Received: by bwz17 with SMTP id 17so1342356bwz.14
        for <linux-mm@kvack.org>; Tue, 17 May 2011 14:42:05 -0700 (PDT)
Message-ID: <4DD2EBAB.5080004@gmail.com>
Date: Tue, 17 May 2011 23:42:03 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org> <1305665263-20933-3-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305665263-20933-3-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 05/17/2011 10:47 PM, John Stultz wrote:
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
> CC: Joe Perches <joe@perches.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> CC: Andy Whitcroft <apw@canonical.com>
> CC: Jiri Slaby <jirislaby@gmail.com>
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

I still fail to see why this should be slowed down by noinlining it.
Care to explain?

With my setup, the code below inlined will use 32 bytes of stack. The
same as %pK case. Uninlined it obviously eats "only" 8 bytes for IP.

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

thanks,
-- 
js

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
