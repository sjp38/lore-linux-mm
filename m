Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9016B0009
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 02:15:41 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j4so13110896wrg.11
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 23:15:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p65sor2487544wmp.81.2018.02.26.23.15.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 23:15:39 -0800 (PST)
Date: Tue, 27 Feb 2018 10:15:36 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 3/4 v2] fs: proc: use down_read_killable() in
 environ_read()
Message-ID: <20180227071536.GA5234@avx2>
References: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
 <1519691151-101999-4-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1519691151-101999-4-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 27, 2018 at 08:25:50AM +0800, Yang Shi wrote:
> Like reading /proc/*/cmdline, it is possible to be blocked for long time
> when reading /proc/*/environ when manipulating large mapping at the mean
> time. The environ reading process will be waiting for mmap_sem become
> available for a long time then it may cause the reading task hung.
> 
> Convert down_read() and access_remote_vm() to killable version.
> 
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Suggested-by: Alexey Dobriyan <adobriyan@gmail.com>

Ehh, bloody tags.
I didn't suggest _killable() variants, they're quite ugly because API
multiplies. access_remote_vm() could be converted to down_read_killable().

> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -933,7 +933,9 @@ static ssize_t environ_read(struct file *file, char __user *buf,
>  	if (!mmget_not_zero(mm))
>  		goto free;
>  
> -	down_read(&mm->mmap_sem);
> +	ret = down_read_killable(&mm->mmap_sem);
> +	if (ret)
> +		goto out_mmput;
>  	env_start = mm->env_start;
>  	env_end = mm->env_end;
>  	up_read(&mm->mmap_sem);
> @@ -950,7 +952,8 @@ static ssize_t environ_read(struct file *file, char __user *buf,
>  		max_len = min_t(size_t, PAGE_SIZE, count);
>  		this_len = min(max_len, this_len);
>  
> -		retval = access_remote_vm(mm, (env_start + src), page, this_len, 0);
> +		retval = access_remote_vm_killable(mm, (env_start + src),
> +						page, this_len, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
