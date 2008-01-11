Date: Fri, 11 Jan 2008 10:55:00 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 1/2][RFC][BUG] msync: massive code cleanup of
 sys_msync()
Message-ID: <20080111105500.4a35e63f@bree.surriel.com>
In-Reply-To: <1200011922.19293.92.camel@codedot>
References: <1200006638.19293.42.camel@codedot>
	<1200011922.19293.92.camel@codedot>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, Valdis.Kletnieks@vt.edu, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jan 2008 03:38:42 +0300
Anton Salikhmetov <salikhmetov@gmail.com> wrote:

> @@ -33,71 +34,60 @@ asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
>  	unsigned long end;
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma;
> -	int unmapped_error = 0;
> -	int error = -EINVAL;
> +	int error = 0, unmapped_error = 0;
> +
> +	if ((flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC)) ||
> +			(start & ~PAGE_MASK) ||
> +			((flags & MS_ASYNC) && (flags & MS_SYNC)))
> +		return -EINVAL;
>  
> -	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
> -		goto out;
> -	if (start & ~PAGE_MASK)
> -		goto out;
> -	if ((flags & MS_ASYNC) && (flags & MS_SYNC))
> -		goto out;
> -	error = -ENOMEM;

Personally I prefer having these error checks separated out,
but that's just my opinion :)

I like the rest of your cleanup patch.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
