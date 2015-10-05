Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5B5440325
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 12:33:39 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so191386554ioi.2
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 09:33:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h10si9345106igq.38.2015.10.05.09.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 09:33:38 -0700 (PDT)
Date: Mon, 5 Oct 2015 18:30:21 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm/mmap.c: Do not initialize retval in mmap_pgoff()
Message-ID: <20151005163021.GB19857@redhat.com>
References: <COL130-W360AE827EAE109246BEB25B9480@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <COL130-W360AE827EAE109246BEB25B9480@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "dave@stgolabs.net" <dave@stgolabs.net>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On 10/06, Chen Gang wrote:
>
> When fget() fails, can return -EBADF directly.

To me this change actually makes the code more readable and clean.

> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

Acked-by: Oleg Nesterov <oleg@redhat.com>

> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1412,13 +1412,13 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
>  		unsigned long, fd, unsigned long, pgoff)
>  {
>  	struct file *file = NULL;
> -	unsigned long retval = -EBADF;
> +	unsigned long retval;
>  
>  	if (!(flags & MAP_ANONYMOUS)) {
>  		audit_mmap_fd(fd, flags);
>  		file = fget(fd);
>  		if (!file)
> -			goto out;
> +			return -EBADF;
>  		if (is_file_hugepages(file))
>  			len = ALIGN(len, huge_page_size(hstate_file(file)));
>  		retval = -EINVAL;
> @@ -1453,7 +1453,6 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
>  out_fput:
>  	if (file)
>  		fput(file);
> -out:
>  	return retval;
>  }
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
