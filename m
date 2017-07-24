Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB8D6B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 04:50:54 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x43so23949899wrb.9
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 01:50:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y19si4727400wra.194.2017.07.24.01.50.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 01:50:53 -0700 (PDT)
Date: Mon, 24 Jul 2017 10:50:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/mremap: Fail map duplication attempts for private
 mappings
Message-ID: <20170724085045.GD25221@dhcp22.suse.cz>
References: <20170720082058.GF9058@dhcp22.suse.cz>
 <1500583079-26504-1-git-send-email-mike.kravetz@oracle.com>
 <20170721143644.GC5944@dhcp22.suse.cz>
 <cb9d9f6a-7095-582f-15a5-62643d65c736@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cb9d9f6a-7095-582f-15a5-62643d65c736@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, Linux API <linux-api@vger.kernel.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On Fri 21-07-17 14:18:31, Mike Kravetz wrote:
[...]
> >From 5c4a1602bd6a942544ed011dc0a72fd258e874b2 Mon Sep 17 00:00:00 2001
> From: Mike Kravetz <mike.kravetz@oracle.com>
> Date: Wed, 12 Jul 2017 13:52:47 -0700
> Subject: [PATCH] mm/mremap: Fail map duplication attempts for private mappings
> 
> mremap will attempt to create a 'duplicate' mapping if old_size
> == 0 is specified.  In the case of private mappings, mremap
> will actually create a fresh separate private mapping unrelated
> to the original.  This does not fit with the design semantics of
> mremap as the intention is to create a new mapping based on the
> original.
> 
> Therefore, return EINVAL in the case where an attempt is made
> to duplicate a private mapping.  Also, print a warning message
> (once) if such an attempt is made.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/mremap.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index cd8a1b1..75b167d 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -383,6 +383,19 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
>  	if (!vma || vma->vm_start > addr)
>  		return ERR_PTR(-EFAULT);
>  
> +	/*
> +	 * !old_len is a special case where an attempt is made to 'duplicate'
> +	 * a mapping.  This makes no sense for private mappings as it will
> +	 * instead create a fresh/new mapping unrelated to the original.  This
> +	 * is contrary to the basic idea of mremap which creates new mappings
> +	 * based on the original.  There are no known use cases for this
> +	 * behavior.  As a result, fail such attempts.
> +	 */
> +	if (!old_len && !(vma->vm_flags & (VM_SHARED | VM_MAYSHARE))) {
> +		pr_warn_once("%s (%d): attempted to duplicate a private mapping with mremap.  This is not supported.\n", current->comm, current->pid);
> +		return ERR_PTR(-EINVAL);
> +	}
> +
>  	if (is_vm_hugetlb_page(vma))
>  		return ERR_PTR(-EINVAL);
>  
> -- 
> 2.7.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
