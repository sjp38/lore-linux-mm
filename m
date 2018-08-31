Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7786B566D
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 06:22:57 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r130-v6so3917419pgr.13
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 03:22:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r14-v6si9191417pgl.490.2018.08.31.03.22.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 03:22:55 -0700 (PDT)
Date: Fri, 31 Aug 2018 12:22:48 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: fix BUG_ON() in vmf_insert_pfn_pud() from
 VM_MIXEDMAP removal
Message-ID: <20180831102248.GE11622@quack2.suse.cz>
References: <153565957352.35524.1005746906902065126.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153565957352.35524.1005746906902065126.stgit@djiang5-desk3.ch.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, dan.j.williams@intel.com, vishal.l.verma@intel.com, jack@suse.com

On Thu 30-08-18 13:06:13, Dave Jiang wrote:
> It looks like I missed the PUD path when doing VM_MIXEDMAP removal.
> This can be triggered by:
> 1. Boot with memmap=4G!8G
> 2. build ndctl with destructive flag on
> 3. make TESTS=device-dax check
> 
> [  +0.000675] kernel BUG at mm/huge_memory.c:824!
> 
> Applying the same change that was applied to vmf_insert_pfn_pmd() in the
> original patch.
> 
> Fixes: e1fb4a08649 ("dax: remove VM_MIXEDMAP for fsdax and device dax")
> 
> Reported-by: Vishal Verma <vishal.l.verma@intel.com>
> Signed-off-by: Dave Jiang <dave.jiang@intel.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/huge_memory.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index c3bc7e9c9a2a..533f9b00147d 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -821,11 +821,11 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>  	 * but we need to be consistent with PTEs and architectures that
>  	 * can't support a 'special' bit.
>  	 */
> -	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
> +	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) &&
> +			!pfn_t_devmap(pfn));
>  	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
>  						(VM_PFNMAP|VM_MIXEDMAP));
>  	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
> -	BUG_ON(!pfn_t_devmap(pfn));
>  
>  	if (addr < vma->vm_start || addr >= vma->vm_end)
>  		return VM_FAULT_SIGBUS;
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
