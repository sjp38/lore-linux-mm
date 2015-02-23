Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2ED6B006C
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 16:59:22 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id i50so26910790qgf.0
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 13:59:22 -0800 (PST)
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com. [209.85.192.53])
        by mx.google.com with ESMTPS id x2si13129205qas.42.2015.02.23.13.59.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 13:59:21 -0800 (PST)
Received: by mail-qg0-f53.google.com with SMTP id f51so26982699qge.12
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 13:59:21 -0800 (PST)
From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH v2 2/3] kernel/audit: reduce mmap_sem hold for mm->exe_file
Date: Mon, 23 Feb 2015 16:59:19 -0500
Message-ID: <5919995.Ma7fOL8jhY@sifl>
In-Reply-To: <1424658009.6539.15.camel@stgolabs.net>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de> <1424304641-28965-3-git-send-email-dbueso@suse.de> <1424658009.6539.15.camel@stgolabs.net>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, eparis@redhat.com, linux-audit@redhat.com

On Sunday, February 22, 2015 06:20:09 PM Davidlohr Bueso wrote:
> The mm->exe_file is currently serialized with mmap_sem (shared)
> in order to both safely (1) read the file and (2) audit it via
> audit_log_d_path(). Good users will, on the other hand, make use
> of the more standard get_mm_exe_file(), requiring only holding
> the mmap_sem to read the value, and relying on reference counting
> to make sure that the exe file won't dissapear underneath us.
> 
> Additionally, upon NULL return of get_mm_exe_file, we also call
> audit_log_format(ab, " exe=(null)").
> 
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> ---
> 
> changes from v1: rebased on top of 1/1.
> 
>  kernel/audit.c | 22 ++++++++++++++--------
>  1 file changed, 14 insertions(+), 8 deletions(-)

Merged into audit#next.

> diff --git a/kernel/audit.c b/kernel/audit.c
> index a71cbfe..b446d54 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -43,6 +43,7 @@
> 
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> 
> +#include <linux/file.h>
>  #include <linux/init.h>
>  #include <linux/types.h>
>  #include <linux/atomic.h>
> @@ -1841,15 +1842,20 @@ EXPORT_SYMBOL(audit_log_task_context);
>  void audit_log_d_path_exe(struct audit_buffer *ab,
>  			  struct mm_struct *mm)
>  {
> -	if (!mm) {
> -		audit_log_format(ab, " exe=(null)");
> -		return;
> -	}
> +	struct file *exe_file;
> +
> +	if (!mm)
> +		goto out_null;
> 
> -	down_read(&mm->mmap_sem);
> -	if (mm->exe_file)
> -		audit_log_d_path(ab, " exe=", &mm->exe_file->f_path);
> -	up_read(&mm->mmap_sem);
> +	exe_file = get_mm_exe_file(mm);
> +	if (!exe_file)
> +		goto out_null;
> +
> +	audit_log_d_path(ab, " exe=", &exe_file->f_path);
> +	fput(exe_file);
> +	return;
> +out_null:
> +	audit_log_format(ab, " exe=(null)");
>  }
> 
>  void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk)

-- 
paul moore
www.paul-moore.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
