Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4662D6B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 20:23:34 -0400 (EDT)
Date: Wed, 16 Sep 2009 08:23:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] hwpoison: fix uninitialized warning
Message-ID: <20090916002329.GA8476@localhost>
References: <Pine.LNX.4.64.0909152206220.28874@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0909152206220.28874@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 16, 2009 at 05:19:07AM +0800, Hugh Dickins wrote:
> Fix mmotm build warning, presumably also in linux-next:
> mm/memory.c: In function `do_swap_page':
> mm/memory.c:2498: warning: `pte' may be used uninitialized in this function
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
> I've only noticed this warning on one machine, the powerpc: certainly it
> needs CONFIG_MIGRATION or CONFIG_MEMORY_FAILURE to see it, but I thought
> I had one of those set on other machines - just musing in case it's being
> masked elsewhere by some other bug...
> 
>  mm/memory.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- mmotm/mm/memory.c	2009-09-14 16:34:37.000000000 +0100
> +++ linux/mm/memory.c	2009-09-15 22:00:48.000000000 +0100
> @@ -2495,7 +2495,7 @@ static int do_swap_page(struct mm_struct
>  		} else if (is_hwpoison_entry(entry)) {
>  			ret = VM_FAULT_HWPOISON;
>  		} else {
> -			print_bad_pte(vma, address, pte, NULL);
> +			print_bad_pte(vma, address, orig_pte, NULL);
>  			ret = VM_FAULT_OOM;
>  		}

The lines was introduced in this patch:

        entry = pte_to_swp_entry(orig_pte);                                                                                          
-       if (is_migration_entry(entry)) {                                                                                             
-               migration_entry_wait(mm, pmd, address);                                                                              
+       if (unlikely(non_swap_entry(entry))) {                                                                                       
+               if (is_migration_entry(entry)) {                                                                                     
+                       migration_entry_wait(mm, pmd, address);                                                                      
+               } else if (is_hwpoison_entry(entry)) {                                                                               
+                       ret = VM_FAULT_HWPOISON;                                                                                     
+               } else {                                                                                                             
+                       print_bad_pte(vma, address, pte, NULL);                                                                      
+                       ret = VM_FAULT_OOM;                                                                                          
+               }                                                                                                                    
                goto out;                                                                                                            
        }                                                                                                                            

Given that currently there are only two types of non swap entries:
migration/hwpoison, the last 'else' block is in fact dead code..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
