Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D51D6B0279
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 09:59:39 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l34so12954748wrc.12
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 06:59:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g24si4078762wrb.24.2017.06.23.06.59.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 06:59:37 -0700 (PDT)
Date: Fri, 23 Jun 2017 15:59:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] exec: Account for argv/envp pointers
Message-ID: <20170623135924.GC5314@dhcp22.suse.cz>
References: <20170622001720.GA32173@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170622001720.GA32173@beast>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Qualys Security Advisory <qsa@qualys.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed 21-06-17 17:17:20, Kees Cook wrote:
> When limiting the argv/envp strings during exec to 1/4 of the stack limit,
> the storage of the pointers to the strings was not included. This means
> that an exec with huge numbers of tiny strings could eat 1/4 of the
> stack limit in strings and then additional space would be later used
> by the pointers to the strings. For example, on 32-bit with a 8MB stack
> rlimit, an exec with 1677721 single-byte strings would consume less than
> 2MB of stack, the max (8MB / 4) amount allowed, but the pointers to the
> strings would consume the remaining additional stack space (1677721 *
> 4 == 6710884). The result (1677721 + 6710884 == 8388605) would exhaust
> stack space entirely. Controlling this stack exhaustion could result in
> pathological behavior in setuid binaries (CVE-2017-1000365).
> 
> Fixes: b6a2fea39318 ("mm: variable length argument support")
> Cc: stable@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  fs/exec.c | 20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index 72934df68471..8079ca70cfda 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -220,8 +220,18 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
>  
>  	if (write) {
>  		unsigned long size = bprm->vma->vm_end - bprm->vma->vm_start;
> +		unsigned long ptr_size;
>  		struct rlimit *rlim;
>  
> +		/*
> +		 * Since the stack will hold pointers to the strings, we
> +		 * must account for them as well.
> +		 */
> +		ptr_size = (bprm->argc + bprm->envc) * sizeof(void *);
> +		if (ptr_size > ULONG_MAX - size)
> +			goto fail;
> +		size += ptr_size;
> +
>  		acct_arg_size(bprm, size / PAGE_SIZE);

Doesn't this over account? I mean this gets called for partial arguments
as they fit into a page so a single argument can get into this function
multiple times AFAIU. I also do not understand why would you want to
account bprm->argc + bprm->envc pointers for each argument.

>  
>  		/*
> @@ -239,13 +249,15 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
>  		 *    to work from.
>  		 */
>  		rlim = current->signal->rlim;
> -		if (size > ACCESS_ONCE(rlim[RLIMIT_STACK].rlim_cur) / 4) {
> -			put_page(page);
> -			return NULL;
> -		}
> +		if (size > READ_ONCE(rlim[RLIMIT_STACK].rlim_cur) / 4)
> +			goto fail;
>  	}
>  
>  	return page;
> +
> +fail:
> +	put_page(page);
> +	return NULL;
>  }
>  
>  static void put_arg_page(struct page *page)
> -- 
> 2.7.4
> 
> 
> -- 
> Kees Cook
> Pixel Security
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
