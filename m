Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 362006B00A9
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 09:23:56 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id w5so797678qac.14
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 06:23:56 -0800 (PST)
Received: from nsa.gov (emvm-gh1-uea08.nsa.gov. [63.239.67.9])
        by mx.google.com with ESMTP id t7si2296032qar.171.2013.12.13.06.23.53
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 06:23:54 -0800 (PST)
Message-ID: <52AB1875.2090207@tycho.nsa.gov>
Date: Fri, 13 Dec 2013 09:23:49 -0500
From: Stephen Smalley <sds@tycho.nsa.gov>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] proc: Update get proc_pid_cmdline() to use mm.h helpers
References: <1386018639-18916-1-git-send-email-wroberts@tresys.com> <1386018639-18916-3-git-send-email-wroberts@tresys.com>
In-Reply-To: <1386018639-18916-3-git-send-email-wroberts@tresys.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <bill.c.roberts@gmail.com>, linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk
Cc: William Roberts <wroberts@tresys.com>

On 12/02/2013 04:10 PM, William Roberts wrote:
> Re-factor proc_pid_cmdline() to use get_cmdline_length() and
> copy_cmdline() helpers from mm.h
> 
> Signed-off-by: William Roberts <wroberts@tresys.com>
> ---
>  fs/proc/base.c |   35 ++++++++++-------------------------
>  1 file changed, 10 insertions(+), 25 deletions(-)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 03c8d74..fb4eda5 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -203,37 +203,22 @@ static int proc_root_link(struct dentry *dentry, struct path *path)
>  static int proc_pid_cmdline(struct task_struct *task, char * buffer)
>  {
>  	int res = 0;
> -	unsigned int len;
> +	unsigned int len = 0;

Why?  You set len below before first use, so this is redundant.

>  	struct mm_struct *mm = get_task_mm(task);
>  	if (!mm)
> -		goto out;
> -	if (!mm->arg_end)
> -		goto out_mm;	/* Shh! No looking before we're done */
> +		return 0;

Equivalent to goto out in the original code, so why change it?  Don't
make unnecessary changes.

Also, I think the get_task_mm() ought to move into the helper (or all of
proc_pid_cmdline() should just become the helper).  In what situation
will you not be calling get_task_mm() and mmput() around every call to
the helper?

>  
> - 	len = mm->arg_end - mm->arg_start;
> - 
> +	len = get_cmdline_length(mm);
> +	if (!len)
> +		goto mm_out;

Could be moved into the helper.  Not sure how the inline function helps
readability or maintainability.

> +
> +	/*The caller of this allocates a page */
>  	if (len > PAGE_SIZE)
>  		len = PAGE_SIZE;

If the capping of len is handled by the caller, then pass an int to your
helper rather than an unsigned int to avoid problems later with
access_process_vm().

> -out_mm:
> +
> +	res = copy_cmdline(task, mm, buffer, len);
> +mm_out:
>  	mmput(mm);

Odd style.  If there is only one exit path, just call it out; if there
are two, keep them as out_mm and out.

> -out:
>  	return res;
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
