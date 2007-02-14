Date: Wed, 14 Feb 2007 00:19:06 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] build error: allnoconfig fails on mincore/swapper_space
In-Reply-To: <20070213144909.70943de2.randy.dunlap@oracle.com>
Message-ID: <Pine.LNX.4.64.0702140009320.21315@blonde.wat.veritas.com>
References: <20070212145040.c3aea56e.randy.dunlap@oracle.com>
 <20070212150802.f240e94f.akpm@linux-foundation.org> <45D12715.4070408@yahoo.com.au>
 <20070213121217.0f4e9f3a.randy.dunlap@oracle.com>
 <Pine.LNX.4.64.0702132224280.3729@blonde.wat.veritas.com>
 <20070213144909.70943de2.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, tony.luck@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Feb 2007, Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Don't check for pte swap entries when CONFIG_SWAP=n.
> And save 'present' in the vec array.
> 
> mm/built-in.o: In function `sys_mincore':
> (.text+0xe584): undefined reference to `swapper_space'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

What you've done there is fine, Randy, thank you.

But I just got out of bed to take another look, and indeed:
what is it doing in the none_mapped !vma->vm_file case?
passing back an uninitialized vector.

Easy enough to fix, but I'd say Nick's patch has by now exceeded
its embarrassment quota, and should be reverted from Linus' tree
for now: clearly none of us have been paying enough attention,
and other eyes are liable to find further errors lurking in it.

Hugh

> ---
>  mm/mincore.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> --- linux-2.6.20-git9.orig/mm/mincore.c
> +++ linux-2.6.20-git9/mm/mincore.c
> @@ -111,6 +111,7 @@ static long do_mincore(unsigned long add
>  			present = mincore_page(vma->vm_file->f_mapping, pgoff);
>  
>  		} else { /* pte is a swap entry */
> +#ifdef CONFIG_SWAP
>  			swp_entry_t entry = pte_to_swp_entry(pte);
>  			if (is_migration_entry(entry)) {
>  				/* migration entries are always uptodate */
> @@ -119,7 +120,11 @@ static long do_mincore(unsigned long add
>  				pgoff = entry.val;
>  				present = mincore_page(&swapper_space, pgoff);
>  			}
> +#else
> +			present = 1;
> +#endif
>  		}
> +		vec[i] = present;
>  	}
>  	pte_unmap_unlock(ptep-1, ptl);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
