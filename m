Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D76536B0253
	for <linux-mm@kvack.org>; Mon, 16 May 2016 10:57:29 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so101381513lfc.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 07:57:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g184si20554451wmf.26.2016.05.16.07.57.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 07:57:28 -0700 (PDT)
Subject: Re: fs/exec.c: fix minor memory leak
References: <20160421141523.d5a96fd694dd8681be5b1d36@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5739DFD7.8030905@suse.cz>
Date: Mon, 16 May 2016 16:57:27 +0200
MIME-Version: 1.0
In-Reply-To: <20160421141523.d5a96fd694dd8681be5b1d36@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 04/21/2016 11:15 PM, Andrew Morton wrote:
>
> Could someone please double-check this?

Looks OK to me.

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: fs/exec.c: fix minor memory leak
>
> When the to-be-removed argument's trailing '\0' is the final byte in the
> page, remove_arg_zero()'s logic will avoid freeing the page, will break
> from the loop and will then advance bprm->p to point at the first byte in
> the next page.  Net result: the final page for the zeroeth argument is
> unfreed.
>
> It isn't a very important leak - that page will be freed later by the
> bprm-wide sweep in free_arg_pages().
>
> Fixes: https://bugzilla.kernel.org/show_bug.cgi?id=116841
> Reported by: hujunjie <jj.net@163.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>
>   fs/exec.c |    9 ++++++++-
>   1 file changed, 8 insertions(+), 1 deletion(-)
>
> diff -puN fs/exec.c~fs-execc-fix-minor-memory-leak fs/exec.c
> --- a/fs/exec.c~fs-execc-fix-minor-memory-leak
> +++ a/fs/exec.c
> @@ -1482,8 +1482,15 @@ int remove_arg_zero(struct linux_binprm
>   		kunmap_atomic(kaddr);
>   		put_arg_page(page);
>
> -		if (offset == PAGE_SIZE)
> +		if (offset == PAGE_SIZE) {
>   			free_arg_page(bprm, (bprm->p >> PAGE_SHIFT) - 1);
> +		} else if (offset == PAGE_SIZE - 1) {
> +			/*
> +			 * The trailing '\0' is the last byte in a page - we're
> +			 * about to advance past that byte so free its page now
> +			 */
> +			free_arg_page(bprm, (bprm->p >> PAGE_SHIFT));
> +		}
>   	} while (offset == PAGE_SIZE);
>
>   	bprm->p++;
> _
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
