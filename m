Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id 25AD56B0082
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 06:44:51 -0500 (EST)
Received: by mail-bk0-f44.google.com with SMTP id d7so1331248bkh.31
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 03:44:50 -0800 (PST)
Received: from r00tworld.com (r00tworld.com. [212.85.137.150])
        by mx.google.com with ESMTPS id ou7si370236bkb.128.2013.12.13.03.44.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 03:44:49 -0800 (PST)
From: "PaX Team" <pageexec@freemail.hu>
Date: Fri, 13 Dec 2013 12:10:17 +0100
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix use-after-free in sys_remap_file_pages
Reply-to: pageexec@freemail.hu
Message-ID: <52AAEB19.27706.CCB8B7D@pageexec.freemail.hu>
In-reply-to: <20131212224118.17a951c2@annuminas.surriel.com>
References: <20131212220757.GA14928@www.outflux.net>, <20131212224118.17a951c2@annuminas.surriel.com>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>

On 12 Dec 2013 at 22:41, Rik van Riel wrote:

> If the vma has been freed by the time the code jumps to the
> out label (because it was freed by a function called from
> mmap_region), surely it will also already have been freed
> by the time this patch dereferences it?

oops, yes, i meant to save the flags away before mmap_region,
no idea how i ended up with this ;).

> Also, setting vma = NULL to avoid the if (vma) branch at
> the out: label is unnecessarily obfuscated. Lets make things
> clear by documenting what is going on, and having a label
> after that dereference.

on that note, how about this as well:

> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -203,6 +203,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
>  		if (mapping_cap_account_dirty(mapping)) {
>  			unsigned long addr;
>  			struct file *file = get_file(vma->vm_file);
> +			vm_flags = vma->vm_flags;
>  
>  			addr = mmap_region(file, start, size,
>  					vma->vm_flags, pgoff);
                                    ^^^^^^^^^^^^^
pass in vm_flags instead of vma->vm_flags just to prevent someone
from 'optimizing' away the read in the future?

> @@ -213,7 +214,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
>  				BUG_ON(addr != start);
>  				err = 0;
>  			}
> -			goto out;
> +			/* mmap_region may have freed vma */
> +			goto out_freed;

perhaps {copy,move} this comment above the previous hunk since that's
where the relevant action is?

cheers,
  PaX Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
