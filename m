Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4935B6B0256
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 08:44:35 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so94463189pad.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 05:44:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a6si19933558pas.184.2015.09.07.05.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 05:44:34 -0700 (PDT)
Date: Mon, 7 Sep 2015 14:41:49 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm/mmap.c: Remove redundent 'get_area' function
	pointer in get_unmapped_area()
Message-ID: <20150907124148.GB32668@redhat.com>
References: <COL130-W16C972B0457D5C7C9CB06B9560@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <COL130-W16C972B0457D5C7C9CB06B9560@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On 09/05, Chen Gang wrote:
>
> From a1bf4726f71d6d0394b41309944646fc806a8a0c Mon Sep 17 00:00:00 2001
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> Date: Sat, 5 Sep 2015 21:51:08 +0800
> Subject: [PATCH] mm/mmap.c: Remove redundent 'get_area' function pointer in
> get_unmapped_area()
>
> Call the function pointer directly, then let code a bit simpler.
                                               ^^^^^^^^^^^^^^^^^^

This is subjective you know ;)

I guess the author of this code added this variable to make the code
more readable. And to me it becomes less readable after your change.

I leave this to you and maintainers.

> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  mm/mmap.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 4db7cf0..39fd727 100644
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
>  	if (len> TASK_SIZE)
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
>  
> -- 
> 1.9.3
> 
>  		 	   		  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
