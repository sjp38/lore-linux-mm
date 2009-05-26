Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 47BC76B005A
	for <linux-mm@kvack.org>; Tue, 26 May 2009 08:54:43 -0400 (EDT)
Received: from mlsv1.hitachi.co.jp (unknown [133.144.234.166])
	by mail4.hitachi.co.jp (Postfix) with ESMTP id 8888633CC4
	for <linux-mm@kvack.org>; Tue, 26 May 2009 21:55:33 +0900 (JST)
Message-ID: <4A1BE6BE.90209@hitachi.com>
Date: Tue, 26 May 2009 21:55:26 +0900
From: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [7/16] POISON: Add basic support for poisoned pages in
    fault handler
References: <20090407509.382219156@firstfloor.org>
    <20090407151004.2F5D21D0470@basil.firstfloor.org>
In-Reply-To: <20090407151004.2F5D21D0470@basil.firstfloor.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

> - Add a new VM_FAULT_POISON error code to handle_mm_fault. Right now
> architectures have to explicitely enable poison page support, so
> this is forward compatible to all architectures. They only need
> to add it when they enable poison page support.
> - Add poison page handling in swap in fault code
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> ---
>  include/linux/mm.h |    3 ++-
>  mm/memory.c        |   17 ++++++++++++++---
>  2 files changed, 16 insertions(+), 4 deletions(-)
> 
> Index: linux/mm/memory.c
> ===================================================================
> --- linux.orig/mm/memory.c	2009-04-07 16:39:24.000000000 +0200
> +++ linux/mm/memory.c	2009-04-07 16:43:06.000000000 +0200
> @@ -1315,7 +1315,8 @@
>  				if (ret & VM_FAULT_ERROR) {
>  					if (ret & VM_FAULT_OOM)
>  						return i ? i : -ENOMEM;
> -					else if (ret & VM_FAULT_SIGBUS)
> +					if (ret &
> +					    (VM_FAULT_POISON|VM_FAULT_SIGBUS))
>  						return i ? i : -EFAULT;
>  					BUG();
>  				}
> @@ -2426,8 +2427,15 @@
>  		goto out;
>  
>  	entry = pte_to_swp_entry(orig_pte);
> -	if (is_migration_entry(entry)) {
> -		migration_entry_wait(mm, pmd, address);
> +	if (unlikely(non_swap_entry(entry))) {
> +		if (is_migration_entry(entry)) {
> +			migration_entry_wait(mm, pmd, address);
> +		} else if (is_poison_entry(entry)) {
> +			ret = VM_FAULT_POISON;
> +		} else {
> +			print_bad_pte(vma, address, pte, NULL);
> +			ret = VM_FAULT_OOM;
> +		}
>  		goto out;
>  	}
>  	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> @@ -2451,6 +2459,9 @@
>  		/* Had to read the page from swap area: Major fault */
>  		ret = VM_FAULT_MAJOR;
>  		count_vm_event(PGMAJFAULT);
> +	} else if (PagePoison(page)) {
> +		ret = VM_FAULT_POISON;

delayacct_clear_flag(DELAYACCT_PF_SWAPIN) would be needed here.

> +		goto out;
>  	}
>  
>  	lock_page(page);

Regards,
-- 
Hidehiro Kawai
Hitachi, Systems Development Laboratory
Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
