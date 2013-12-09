Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id B03CA6B00AA
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 10:33:14 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id e9so2713530qcy.6
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 07:33:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l7si42308qat.177.2013.12.09.07.33.13
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 07:33:13 -0800 (PST)
Date: Mon, 9 Dec 2013 10:33:07 -0500
From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH 3/3] audit: Audit proc cmdline value
Message-ID: <20131209153307.GG20495@madcap2.tricolour.ca>
References: <1386018639-18916-1-git-send-email-wroberts@tresys.com>
 <1386018639-18916-4-git-send-email-wroberts@tresys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386018639-18916-4-git-send-email-wroberts@tresys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <bill.c.roberts@gmail.com>
Cc: linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, William Roberts <wroberts@tresys.com>

On Mon, Dec 02, 2013 at 01:10:39PM -0800, William Roberts wrote:
> During an audit event, cache and print the value of the process's
> cmdline value (proc/<pid>/cmdline). This is useful in situations
> where processes are started via fork'd virtual machines where the
> comm field is incorrect. Often times, setting the comm field still
> is insufficient as the comm width is not very wide and most
> virtual machine "package names" do not fit. Also, during execution,
> many threads have thier comm field set as well. By tying it back to
> the global cmdline value for the process, audit records will be more
> complete in systems with these properties. An example of where this
> is useful and applicable is in the realm of Android.
> 
> The cached cmdline is tied to the lifecycle of the audit_context
> structure and is built on demand.
> 
> Signed-off-by: William Roberts <wroberts@tresys.com>

Acked-by: Richard Guy Briggs <rgb@redhat.com>

I'll Signed-off-by: when I add it to my for-next tree.

> ---
>  kernel/audit.h   |    1 +
>  kernel/auditsc.c |   82 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 83 insertions(+)
> 
> diff --git a/kernel/audit.h b/kernel/audit.h
> index b779642..bd6211f 100644
> --- a/kernel/audit.h
> +++ b/kernel/audit.h
> @@ -202,6 +202,7 @@ struct audit_context {
>  		} execve;
>  	};
>  	int fds[2];
> +	char *cmdline;
>  
>  #if AUDIT_DEBUG
>  	int		    put_count;
> diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> index 90594c9..bfb1698 100644
> --- a/kernel/auditsc.c
> +++ b/kernel/auditsc.c
> @@ -842,6 +842,14 @@ static inline struct audit_context *audit_get_context(struct task_struct *tsk,
>  	return context;
>  }
>  
> +static inline void audit_cmdline_free(struct audit_context *context)
> +{
> +	if (!context->cmdline)
> +		return;
> +	kfree(context->cmdline);
> +	context->cmdline = NULL;
> +}
> +
>  static inline void audit_free_names(struct audit_context *context)
>  {
>  	struct audit_names *n, *next;
> @@ -955,6 +963,7 @@ static inline void audit_free_context(struct audit_context *context)
>  	audit_free_aux(context);
>  	kfree(context->filterkey);
>  	kfree(context->sockaddr);
> +	audit_cmdline_free(context);
>  	kfree(context);
>  }
>  
> @@ -1271,6 +1280,78 @@ static void show_special(struct audit_context *context, int *call_panic)
>  	audit_log_end(ab);
>  }
>  
> +static char *audit_cmdline_get(struct audit_buffer *ab,
> +			       struct task_struct *task)
> +{
> +	int len;
> +	int res;
> +	char *buf;
> +	struct mm_struct *mm;
> +
> +	if (!ab || !task)
> +		return NULL;
> +
> +	mm = get_task_mm(task);
> +	if (!mm)
> +		return NULL;
> +
> +	len = get_cmdline_length(mm);
> +	if (!len)
> +		goto mm_err;
> +
> +	if (len > PATH_MAX)
> +		len = PATH_MAX;
> +
> +	buf = kmalloc(len, GFP_KERNEL);
> +	if (!buf)
> +		goto mm_err;
> +
> +	res = copy_cmdline(task, mm, buf, len);
> +	if (res <= 0)
> +		goto alloc_err;
> +
> +	mmput(mm);
> +	/*
> +	 * res is guarenteed not to be longer than
> +	 * than the buf as it was truncated to len
> +	 * in copy_cmdline()
> +	 */
> +	len = res;
> +
> +	/*
> +	 * Ensure NULL terminated as application
> +	 * could be using setproctitle(3)
> +	 */
> +	buf[len-1] = '\0';
> +	return buf;
> +
> +alloc_err:
> +	kfree(buf);
> +mm_err:
> +	mmput(mm);
> +	return NULL;
> +}
> +
> +static void audit_log_cmdline(struct audit_buffer *ab, struct task_struct *tsk,
> +			 struct audit_context *context)
> +{
> +	char *msg = "(null)";
> +	audit_log_format(ab, " cmdline=");
> +
> +	/* Already cached */
> +	if (context->cmdline) {
> +		msg = context->cmdline;
> +		goto out;
> +	}
> +	/* Not cached */
> +	context->cmdline = audit_cmdline_get(ab, tsk);
> +	if (!context->cmdline)
> +		goto out;
> +	msg = context->cmdline;
> +out:
> +	audit_log_untrustedstring(ab, msg);
> +}
> +
>  static void audit_log_exit(struct audit_context *context, struct task_struct *tsk)
>  {
>  	int i, call_panic = 0;
> @@ -1302,6 +1383,7 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
>  			 context->name_count);
>  
>  	audit_log_task_info(ab, tsk);
> +	audit_log_cmdline(ab, tsk, context);
>  	audit_log_key(ab, context->filterkey);
>  	audit_log_end(ab);
>  
> -- 
> 1.7.9.5
> 
> --
> Linux-audit mailing list
> Linux-audit@redhat.com
> https://www.redhat.com/mailman/listinfo/linux-audit

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
