Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id C59296B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 18:32:42 -0400 (EDT)
Received: by qkdw123 with SMTP id w123so25040771qkd.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 15:32:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 87si15285439qkx.83.2015.09.10.15.32.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 15:32:41 -0700 (PDT)
Date: Thu, 10 Sep 2015 15:32:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/mmap.c: Remove redundent 'get_area' function pointer
 in get_unmapped_area()
Message-Id: <20150910153240.9572375a7a5359a6e2a7ab4a@linux-foundation.org>
In-Reply-To: <1441253691-5798-1-git-send-email-gang.chen.5i5j@gmail.com>
References: <1441253691-5798-1-git-send-email-gang.chen.5i5j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gang.chen.5i5j@gmail.com
Cc: mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gchen_5i5j@21cn.com

On Thu,  3 Sep 2015 12:14:51 +0800 gang.chen.5i5j@gmail.com wrote:

> From: Chen Gang <gang.chen.5i5j@gmail.com>
> 
> Call the function pointer directly, then let code a bit simpler.
> 
> ...
>
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2012,10 +2012,8 @@ unsigned long
>  get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
>  		unsigned long pgoff, unsigned long flags)
>  {
> -	unsigned long (*get_area)(struct file *, unsigned long,
> -				  unsigned long, unsigned long, unsigned long);
> -
>  	unsigned long error = arch_mmap_check(addr, len, flags);
> +
>  	if (error)
>  		return error;
>  
> @@ -2023,10 +2021,12 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
>  	if (len > TASK_SIZE)
>  		return -ENOMEM;
>  
> -	get_area = current->mm->get_unmapped_area;
>  	if (file && file->f_op->get_unmapped_area)
> -		get_area = file->f_op->get_unmapped_area;
> -	addr = get_area(file, addr, len, pgoff, flags);
> +		addr = file->f_op->get_unmapped_area(file, addr, len,
> +							pgoff, flags);
> +	else
> +		addr = current->mm->get_unmapped_area(file, addr, len,
> +							pgoff, flags);
>  	if (IS_ERR_VALUE(addr))
>  		return addr;

size(1) says this generates more object code.  And that probably means
slightly worse code.  I didn't investigate, but probably the compiler
is now preparing those five args at two different sites.

Which is pretty dumb of it - the compiler could have stacked the args
first, then chosen the appropriate function to call.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
