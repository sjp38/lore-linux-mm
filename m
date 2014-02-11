Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id 19FDC6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 12:59:02 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id k10so1657320eaj.40
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 09:59:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w5si33621141eef.46.2014.02.11.09.59.00
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 09:59:01 -0800 (PST)
Date: Tue, 11 Feb 2014 11:30:27 -0500
From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH v5 2/3] proc: Update get proc_pid_cmdline() to use mm.h
 helpers
Message-ID: <20140211163027.GL18807@madcap2.tricolour.ca>
References: <1391710528-23481-1-git-send-email-wroberts@tresys.com>
 <1391710528-23481-2-git-send-email-wroberts@tresys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391710528-23481-2-git-send-email-wroberts@tresys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <bill.c.roberts@gmail.com>
Cc: linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, sds@tycho.nsa.gov, William Roberts <wroberts@tresys.com>

On 14/02/06, William Roberts wrote:
> Re-factor proc_pid_cmdline() to use get_cmdline() helper
> from mm.h.
> 
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Stephen Smalley <sds@tycho.nsa.gov>

Acked-by: Richard Guy Briggs <rgb@redhat.com>

> Signed-off-by: William Roberts <wroberts@tresys.com>
> ---
>  fs/proc/base.c |   36 ++----------------------------------
>  1 file changed, 2 insertions(+), 34 deletions(-)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 5150706..f0c5927 100644
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
> -- 
> 1.7.9.5
> 

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
