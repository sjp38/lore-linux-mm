Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19BC76B5329
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 16:16:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 33-v6so4529558plf.19
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 13:16:11 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s68-v6si7720734pgc.16.2018.08.30.13.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 13:16:10 -0700 (PDT)
Subject: Re: [PATCH] mm: fix BUG_ON() in vmf_insert_pfn_pud() from VM_MIXEDMAP
 removal
From: Dave Jiang <dave.jiang@intel.com>
References: <153565954666.35458.15832314745699968487.stgit@djiang5-desk3.ch.intel.com>
Message-ID: <6fac48b2-6285-c8b2-a3ef-00a70846bed9@intel.com>
Date: Thu, 30 Aug 2018 13:15:52 -0700
MIME-Version: 1.0
In-Reply-To: <153565954666.35458.15832314745699968487.stgit@djiang5-desk3.ch.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: jack@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, linux-nvdimm@lists.01.org

Please ignore this email. It had malformed mail header. I have resent a
non-broken one, which looks like has been ack'ed by Jeff.


On 08/30/2018 01:05 PM, Dave Jiang wrote:
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
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm
> 
