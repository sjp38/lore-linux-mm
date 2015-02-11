Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id E35BB6B006C
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:59:51 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id u56so5686335wes.10
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 11:59:51 -0800 (PST)
Received: from mail-we0-x22c.google.com (mail-we0-x22c.google.com. [2a00:1450:400c:c03::22c])
        by mx.google.com with ESMTPS id j11si1617703wiv.103.2015.02.11.11.59.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 11:59:50 -0800 (PST)
Received: by mail-we0-f172.google.com with SMTP id k48so5743788wev.3
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 11:59:50 -0800 (PST)
Date: Wed, 11 Feb 2015 11:59:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] mm: move gup() -> posix mlock() error conversion
 out of __mm_populate
In-Reply-To: <1423674728-214192-4-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1502111156480.9656@chino.kir.corp.google.com>
References: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com> <1423674728-214192-4-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>

On Wed, 11 Feb 2015, Kirill A. Shutemov wrote:

> This is praparation to moving mm_populate()-related code out of
> mm/mlock.c.
> 

s/praparation/preparation/

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/mlock.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index c3ea18323034..0837fdb26047 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -712,7 +712,6 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
>  				ret = 0;
>  				continue;	/* continue at next VMA */
>  			}
> -			ret = __mlock_posix_error_return(ret);
>  			break;
>  		}
>  		nend = nstart + ret * PAGE_SIZE;
> @@ -750,9 +749,13 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
>  		error = do_mlock(start, len, 1);
>  
>  	up_write(&current->mm->mmap_sem);
> -	if (!error)
> -		error = __mm_populate(start, len, 0);
> -	return error;
> +	if (error)
> +		return error;
> +
> +	error = __mm_populate(start, len, 0);
> +	if (error)
> +		return  __mlock_posix_error_return(error);

Extra space?

> +	return 0;
>  }
>  
>  SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
