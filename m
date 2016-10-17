Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1A26B0253
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 12:45:14 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e6so200233209pfk.2
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 09:45:14 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id zr6si26316873pab.86.2016.10.17.09.45.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 09:45:13 -0700 (PDT)
Date: Mon, 17 Oct 2016 10:45:12 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 07/20] mm: Add orig_pte field into vm_fault
Message-ID: <20161017164512.GA25175@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-8-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-8-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:11PM +0200, Jan Kara wrote:
> Add orig_pte field to vm_fault structure to allow ->page_mkwrite
> handlers to fully handle the fault. This also allows us to save some
> passing of extra arguments around.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---

> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index f88b2d3810a7..66bc77f2d1d2 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -890,11 +890,12 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
>  	vmf.pte = pte_offset_map(pmd, address);
>  	for (; vmf.address < address + HPAGE_PMD_NR*PAGE_SIZE;
>  			vmf.pte++, vmf.address += PAGE_SIZE) {
> -		pteval = *vmf.pte;
> +		vmf.orig_pte = *vmf.pte;
> +		pteval = vmf.orig_pte;
>  		if (!is_swap_pte(pteval))
>  			continue;

'pteval' is now only used once.  It's probably cleaner to just remove it and
use vmf.orig_pte for the is_swap_pte() check.

> @@ -3484,8 +3484,7 @@ static int handle_pte_fault(struct vm_fault *vmf)
>  		 * So now it's safe to run pte_offset_map().
>  		 */
>  		vmf->pte = pte_offset_map(vmf->pmd, vmf->address);
> -
> -		entry = *vmf->pte;
> +		vmf->orig_pte = *vmf->pte;
>  
>  		/*
>  		 * some architectures can have larger ptes than wordsize,
> @@ -3496,6 +3495,7 @@ static int handle_pte_fault(struct vm_fault *vmf)
>  		 * ptl lock held. So here a barrier will do.
>  		 */
>  		barrier();
> +		entry = vmf->orig_pte;

This set of 'entry' is now on the other side of the barrier().  I'll admit
that I don't fully grok the need for the barrier. Does it apply to only the
setting of vmf->pte and vmf->orig_pte, or does 'entry' also matter because it
too is of type pte_t, and thus could be bigger than the architecture's word
size?

My guess is that 'entry' matters, too, and should remain before the barrier()
call.  If not, can you help me understand why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
