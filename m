Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f180.google.com (mail-ve0-f180.google.com [209.85.128.180])
	by kanga.kvack.org (Postfix) with ESMTP id B2E406B00A7
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 09:12:19 -0500 (EST)
Received: by mail-ve0-f180.google.com with SMTP id jz11so1379568veb.39
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 06:12:19 -0800 (PST)
Received: from nsa.gov (emvm-gh1-uea08.nsa.gov. [63.239.67.9])
        by mx.google.com with ESMTP id e7si2288829qez.112.2013.12.13.06.12.18
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 06:12:18 -0800 (PST)
Message-ID: <52AB15C0.7090701@tycho.nsa.gov>
Date: Fri, 13 Dec 2013 09:12:16 -0500
From: Stephen Smalley <sds@tycho.nsa.gov>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: Create utility functions for accessing a tasks
 commandline value
References: <1386018639-18916-1-git-send-email-wroberts@tresys.com> <1386018639-18916-2-git-send-email-wroberts@tresys.com>
In-Reply-To: <1386018639-18916-2-git-send-email-wroberts@tresys.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <bill.c.roberts@gmail.com>, linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk
Cc: William Roberts <wroberts@tresys.com>

On 12/02/2013 04:10 PM, William Roberts wrote:
> Add two new functions to mm.h:
> * copy_cmdline()
> * get_cmdline_length()
> 
> Signed-off-by: William Roberts <wroberts@tresys.com>
> ---
>  include/linux/mm.h |    7 +++++++
>  mm/util.c          |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 55 insertions(+)
> 
> index f7bc209..c8cad32 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -410,6 +411,53 @@ unsigned long vm_commit_limit(void)
>  		* sysctl_overcommit_ratio / 100) + total_swap_pages;
>  }
>  
> +/**
> + * copy_cmdline - Copy's the tasks commandline value to a buffer

spelling: Copies, task's, command-line or command line

> + * @task: The task whose command line to copy

is to be copied?

> + * @mm: The mm struct refering to task with proper semaphores held

referring

> + * @buf: The buffer to copy the value into

> + * @buflen: The length og the buffer. It trucates the value to

of, truncates

> + *           buflen.
> + * @return: The number of chars copied.
> + */
> +int copy_cmdline(struct task_struct *task, struct mm_struct *mm,
> +		 char *buf, unsigned int buflen)
> +{
> +	int res = 0;
> +	unsigned int len;
> +
> +	if (!task || !mm || !buf)
> +		return -1;

Typically these kinds of tests are frowned upon in the kernel unless
there is a legal usage where NULL is valid.  Otherwise you may just be
covering up a bug.

Also, why not just get_task_mm(task) within the function rather than
pass it in by the caller?

> +
> +	res = access_process_vm(task, mm->arg_start, buf, buflen, 0);

Unsigned int buflen passed as int len argument without a range check?
Note that in the proc_pid_cmdline() code, they first cap it at PAGE_SIZE
before passing it.

The closer you can keep your code to the original proc_pid_cmdline()
code, the better (less chance for new bugs to be introduced).

> +	if (res <= 0)
> +		return 0;
> +
> +	if (res > buflen)
> +		res = buflen;

Is this a possible condition?  Under what circumstances?

> +	/*
> +	 * If the nul at the end of args had been overwritten, then
> +	 * assume application is using setproctitle(3).
> +	 */
> +	if (buf[res-1] != '\0') {

Lost the len < PAGE_SIZE check from proc_pid_cmdline() here, and that
isn't the same as the check above.

> +		/* Nul between start and end of vm space?
> +		   If so then truncate */

Not sure where these comments are coming from.  Isn't the issue that
lack of NUL at the end of args indicates that the cmdline extends
further into the environ and thus they need to copy in the rest?

> +		len = strnlen(buf, res);
> +		if (len < res) {
> +			res = len;
> +		} else {
> +			/* No nul, truncate buflen if to big */

It isn't truncating buflen but rather copying the remainder of the
cmdline from the environ, right?

> +			len = mm->env_end - mm->env_start;
> +			if (len > buflen - res)
> +				len = buflen - res;
> +			/* Copy any remaining data */
> +			res += access_process_vm(task, mm->env_start, buf+res,
> +						 len, 0);
> +			res = strnlen(buf, res);
> +		}
> +	}
> +	return res;
> +}

I think you are better off just copying proc_pid_cmdline() exactly as is
into a common helper function and then reusing it for audit.  Far less
work, and far less potential for mistakes.

>  
>  /* Tracepoints definitions. */
>  EXPORT_TRACEPOINT_SYMBOL(kmalloc);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
