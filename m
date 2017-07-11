Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7186B04FB
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 08:36:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l34so31426554wrc.12
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 05:36:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z68si9354364wmz.6.2017.07.11.05.36.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 05:36:45 -0700 (PDT)
Date: Tue, 11 Jul 2017 14:36:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
Message-ID: <20170711123642.GC11936@dhcp22.suse.cz>
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu 06-07-17 09:17:26, Mike Kravetz wrote:
> The mremap system call has the ability to 'mirror' parts of an existing
> mapping.  To do so, it creates a new mapping that maps the same pages as
> the original mapping, just at a different virtual address.  This
> functionality has existed since at least the 2.6 kernel.
> 
> This patch simply adds a new flag to mremap which will make this
> functionality part of the API.  It maintains backward compatibility with
> the existing way of requesting mirroring (old_size == 0).
> 
> If this new MREMAP_MIRROR flag is specified, then new_size must equal
> old_size.  In addition, the MREMAP_MAYMOVE flag must be specified.

I have to admit that this came as a suprise to me. There is no mention
about this special case in the man page and the mremap code is so
convoluted that I simply didn't see it there. I guess the only
reasonable usecase is when you do not have a fd for the shared memory.

Anyway the patch should fail with -EINVAL on private mappings as Kirill
already pointed out and this should go along with an update to the
man page which describes also the historical behavior. Make sure you
document that this is not really a mirroring (e.g. faulting page in one
address will automatically map it to the other mapping(s)) but merely a
copy of the range. Maybe MREMAP_COPY would be more appropriate name.

> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  include/uapi/linux/mman.h       |  5 +++--
>  mm/mremap.c                     | 23 ++++++++++++++++-------
>  tools/include/uapi/linux/mman.h |  5 +++--
>  3 files changed, 22 insertions(+), 11 deletions(-)
> 
> diff --git a/include/uapi/linux/mman.h b/include/uapi/linux/mman.h
> index ade4acd..6b3e0df 100644
> --- a/include/uapi/linux/mman.h
> +++ b/include/uapi/linux/mman.h
> @@ -3,8 +3,9 @@
>  
>  #include <asm/mman.h>
>  
> -#define MREMAP_MAYMOVE	1
> -#define MREMAP_FIXED	2
> +#define MREMAP_MAYMOVE	0x01
> +#define MREMAP_FIXED	0x02
> +#define MREMAP_MIRROR	0x04
>  
>  #define OVERCOMMIT_GUESS		0
>  #define OVERCOMMIT_ALWAYS		1
> diff --git a/mm/mremap.c b/mm/mremap.c
> index cd8a1b1..f18ab36 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -516,10 +516,11 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>  	struct vm_userfaultfd_ctx uf = NULL_VM_UFFD_CTX;
>  	LIST_HEAD(uf_unmap);
>  
> -	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
> +	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE | MREMAP_MIRROR))
>  		return ret;
>  
> -	if (flags & MREMAP_FIXED && !(flags & MREMAP_MAYMOVE))
> +	if ((flags & MREMAP_FIXED || flags & MREMAP_MIRROR) &&
> +	    !(flags & MREMAP_MAYMOVE))
>  		return ret;
>  
>  	if (offset_in_page(addr))
> @@ -528,14 +529,22 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>  	old_len = PAGE_ALIGN(old_len);
>  	new_len = PAGE_ALIGN(new_len);
>  
> -	/*
> -	 * We allow a zero old-len as a special case
> -	 * for DOS-emu "duplicate shm area" thing. But
> -	 * a zero new-len is nonsensical.
> -	 */
> +	/* A zero new-len is nonsensical. */
>  	if (!new_len)
>  		return ret;
>  
> +	/*
> +	 * For backward compatibility, we allow a zero old-len to imply
> +	 * mirroring.  This was originally a special case for DOS-emu.
> +	 */
> +	if (!old_len)
> +		flags |= MREMAP_MIRROR;
> +	else if (flags & MREMAP_MIRROR) {
> +		if (old_len != new_len)
> +			return ret;
> +		old_len = 0;
> +	}
> +
>  	if (down_write_killable(&current->mm->mmap_sem))
>  		return -EINTR;
>  
> diff --git a/tools/include/uapi/linux/mman.h b/tools/include/uapi/linux/mman.h
> index 81d8edf..069f7a5 100644
> --- a/tools/include/uapi/linux/mman.h
> +++ b/tools/include/uapi/linux/mman.h
> @@ -3,8 +3,9 @@
>  
>  #include <uapi/asm/mman.h>
>  
> -#define MREMAP_MAYMOVE	1
> -#define MREMAP_FIXED	2
> +#define MREMAP_MAYMOVE	0x01
> +#define MREMAP_FIXED	0x02
> +#define MREMAP_MIRROR	0x04
>  
>  #define OVERCOMMIT_GUESS		0
>  #define OVERCOMMIT_ALWAYS		1
> -- 
> 2.7.5
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
