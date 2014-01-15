Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2006B0035
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 09:17:13 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id c41so543332yho.6
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 06:17:13 -0800 (PST)
Received: from nsa.gov (emvm-gh1-uea08.nsa.gov. [63.239.67.9])
        by mx.google.com with ESMTP id s22si5438729yha.26.2014.01.15.06.17.12
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 06:17:12 -0800 (PST)
Message-ID: <52D69844.9000200@tycho.nsa.gov>
Date: Wed, 15 Jan 2014 09:16:36 -0500
From: Stephen Smalley <sds@tycho.nsa.gov>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH v2 2/3] proc: Update get proc_pid_cmdline() to use
 mm.h helpers
References: <1389632555-7039-1-git-send-email-wroberts@tresys.com> <1389632555-7039-2-git-send-email-wroberts@tresys.com>
In-Reply-To: <1389632555-7039-2-git-send-email-wroberts@tresys.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <bill.c.roberts@gmail.com>, linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org
Cc: William Roberts <wroberts@tresys.com>

On 01/13/2014 12:02 PM, William Roberts wrote:
> Re-factor proc_pid_cmdline() to use get_cmdline() helper
> from mm.h.
> 
> Signed-off-by: William Roberts <wroberts@tresys.com>

Acked-by:  Stephen Smalley <sds@tycho.nsa.gov>

> ---
>  fs/proc/base.c |   36 ++----------------------------------
>  1 file changed, 2 insertions(+), 34 deletions(-)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 03c8d74..cfd178d 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -200,41 +200,9 @@ static int proc_root_link(struct dentry *dentry, struct path *path)
>  	return result;
>  }
>  
> -static int proc_pid_cmdline(struct task_struct *task, char * buffer)
> +static int proc_pid_cmdline(struct task_struct *task, char *buffer)
>  {
> -	int res = 0;
> -	unsigned int len;
> -	struct mm_struct *mm = get_task_mm(task);
> -	if (!mm)
> -		goto out;
> -	if (!mm->arg_end)
> -		goto out_mm;	/* Shh! No looking before we're done */
> -
> - 	len = mm->arg_end - mm->arg_start;
> - 
> -	if (len > PAGE_SIZE)
> -		len = PAGE_SIZE;
> - 
> -	res = access_process_vm(task, mm->arg_start, buffer, len, 0);
> -
> -	// If the nul at the end of args has been overwritten, then
> -	// assume application is using setproctitle(3).
> -	if (res > 0 && buffer[res-1] != '\0' && len < PAGE_SIZE) {
> -		len = strnlen(buffer, res);
> -		if (len < res) {
> -		    res = len;
> -		} else {
> -			len = mm->env_end - mm->env_start;
> -			if (len > PAGE_SIZE - res)
> -				len = PAGE_SIZE - res;
> -			res += access_process_vm(task, mm->env_start, buffer+res, len, 0);
> -			res = strnlen(buffer, res);
> -		}
> -	}
> -out_mm:
> -	mmput(mm);
> -out:
> -	return res;
> +	return get_cmdline(task, buffer, PAGE_SIZE);
>  }
>  
>  static int proc_pid_auxv(struct task_struct *task, char *buffer)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
