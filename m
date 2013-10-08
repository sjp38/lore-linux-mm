Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 59E2F6B0032
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 10:27:24 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so8902058pab.18
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 07:27:24 -0700 (PDT)
Date: Tue, 08 Oct 2013 10:26:42 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1381242402-j6a9e6ew-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20131008090237.062907670@gmail.com>
References: <20131008090019.527108154@gmail.com>
 <20131008090237.062907670@gmail.com>
Subject: Re: [patch 2/3] [PATCH] mm: pagemap -- Inspect _PAGE_SOFT_DIRTY only
 on present pages
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Andy Lutomirski <luto@amacapital.net>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Tue, Oct 08, 2013 at 01:00:21PM +0400, Cyrill Gorcunov wrote:
> In case if a page we are inspecting is laying in swap we may
> occasionally report it as having soft dirty bit (even if it
> is clean). pte_soft_dirty helper should be called on present
> pte only.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> Cc: Marcelo Tosatti <mtosatti@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Looks nice to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  fs/proc/task_mmu.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.git/fs/proc/task_mmu.c
> ===================================================================
> --- linux-2.6.git.orig/fs/proc/task_mmu.c
> +++ linux-2.6.git/fs/proc/task_mmu.c
> @@ -941,6 +941,8 @@ static void pte_to_pagemap_entry(pagemap
>  		frame = pte_pfn(pte);
>  		flags = PM_PRESENT;
>  		page = vm_normal_page(vma, addr, pte);
> +		if (pte_soft_dirty(pte))
> +			flags2 |= __PM_SOFT_DIRTY;
>  	} else if (is_swap_pte(pte)) {
>  		swp_entry_t entry;
>  		if (pte_swp_soft_dirty(pte))
> @@ -960,7 +962,7 @@ static void pte_to_pagemap_entry(pagemap
>  
>  	if (page && !PageAnon(page))
>  		flags |= PM_FILE;
> -	if ((vma->vm_flags & VM_SOFTDIRTY) || pte_soft_dirty(pte))
> +	if ((vma->vm_flags & VM_SOFTDIRTY))
>  		flags2 |= __PM_SOFT_DIRTY;
>  
>  	*pme = make_pme(PM_PFRAME(frame) | PM_STATUS2(pm->v2, flags2) | flags);
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
