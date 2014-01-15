Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7106B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 09:16:22 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id f10so554901yha.37
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 06:16:21 -0800 (PST)
Received: from nsa.gov (emvm-gh1-uea09.nsa.gov. [63.239.67.10])
        by mx.google.com with ESMTP id t28si1513914yhd.286.2014.01.15.06.16.19
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 06:16:20 -0800 (PST)
Message-ID: <52D6980D.1010206@tycho.nsa.gov>
Date: Wed, 15 Jan 2014 09:15:41 -0500
From: Stephen Smalley <sds@tycho.nsa.gov>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH v2 1/3] mm: Create utility function for accessing
 a tasks commandline value
References: <1389632555-7039-1-git-send-email-wroberts@tresys.com>
In-Reply-To: <1389632555-7039-1-git-send-email-wroberts@tresys.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <bill.c.roberts@gmail.com>, linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org
Cc: William Roberts <wroberts@tresys.com>

On 01/13/2014 12:02 PM, William Roberts wrote:
> introduce get_cmdline() for retreiving the value of a processes
> proc/self/cmdline value.
> 
> Signed-off-by: William Roberts <wroberts@tresys.com>

Acked-by:  Stephen Smalley <sds@tycho.nsa.gov>

> ---
>  include/linux/mm.h |    1 +
>  mm/util.c          |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 49 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 3552717..01e7970 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1134,6 +1134,7 @@ void account_page_writeback(struct page *page);
>  int set_page_dirty(struct page *page);
>  int set_page_dirty_lock(struct page *page);
>  int clear_page_dirty_for_io(struct page *page);
> +int get_cmdline(struct task_struct *task, char *buffer, int buflen);
>  
>  /* Is the vma a continuation of the stack vma above it? */
>  static inline int vma_growsdown(struct vm_area_struct *vma, unsigned long addr)
> diff --git a/mm/util.c b/mm/util.c
> index f7bc209..5285ff0 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -410,6 +410,54 @@ unsigned long vm_commit_limit(void)
>  		* sysctl_overcommit_ratio / 100) + total_swap_pages;
>  }
>  
> +/**
> + * get_cmdline() - copy the cmdline value to a buffer.
> + * @task:     the task whose cmdline value to copy.
> + * @buffer:   the buffer to copy to.
> + * @buflen:   the length of the buffer. Larger cmdline values are truncated
> + *            to this length.
> + * Returns the size of the cmdline field copied. Note that the copy does
> + * not guarantee an ending NULL byte.
> + */
> +int get_cmdline(struct task_struct *task, char *buffer, int buflen)
> +{
> +	int res = 0;
> +	unsigned int len;
> +	struct mm_struct *mm = get_task_mm(task);
> +	if (!mm)
> +		goto out;
> +	if (!mm->arg_end)
> +		goto out_mm;	/* Shh! No looking before we're done */
> +
> +	len = mm->arg_end - mm->arg_start;
> +
> +	if (len > buflen)
> +		len = buflen;
> +
> +	res = access_process_vm(task, mm->arg_start, buffer, len, 0);
> +
> +	/*
> +	 * If the nul at the end of args has been overwritten, then
> +	 * assume application is using setproctitle(3).
> +	 */
> +	if (res > 0 && buffer[res-1] != '\0' && len < buflen) {
> +		len = strnlen(buffer, res);
> +		if (len < res) {
> +			res = len;
> +		} else {
> +			len = mm->env_end - mm->env_start;
> +			if (len > buflen - res)
> +				len = buflen - res;
> +			res += access_process_vm(task, mm->env_start,
> +						 buffer+res, len, 0);
> +			res = strnlen(buffer, res);
> +		}
> +	}
> +out_mm:
> +	mmput(mm);
> +out:
> +	return res;
> +}
>  
>  /* Tracepoints definitions. */
>  EXPORT_TRACEPOINT_SYMBOL(kmalloc);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
