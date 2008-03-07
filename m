Date: Fri, 7 Mar 2008 11:54:32 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] 2/4 move all invalidate_page outside of PT lock (#v9
 was 1/4)
In-Reply-To: <20080307151722.GD24114@v2.random>
Message-ID: <Pine.LNX.4.64.0803071151140.6815@schroedinger.engr.sgi.com>
References: <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random>
 <20080303213707.GA8091@v2.random> <20080303220502.GA5301@v2.random>
 <47CC9B57.5050402@qumranet.com> <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
 <20080304133020.GC5301@v2.random> <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com>
 <20080304222030.GB8951@v2.random> <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com>
 <20080307151722.GD24114@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Andrea Arcangeli wrote:

> This below simple patch invalidates the "invalidate_page" part, the
> next patch will invalidate the RCU part, and btw in a way that doesn't
> forbid unregistering the mmu notifiers at runtime (like your brand new
> EMM does).

Sounds good.

> The reason I keep this incremental (unlike your EMM that does
> everything all at the same time mixed in a single patch) is to
> decrease the non obviously safe mangling over mm/* during .25. The
> below patch is simple, but not as obviously safe as
> s/ptep_clear_flush/ptep_clear_flush_notify/.

There was never a chance to merge for .25. Lets drop that and focus on 
a solution that is good for all.

>  #endif /* _LINUX_MMU_NOTIFIER_H */
> diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
> --- a/mm/filemap_xip.c
> +++ b/mm/filemap_xip.c
> @@ -194,11 +194,13 @@ __xip_unmap (struct address_space * mapp
>  		if (pte) {
>  			/* Nuke the page table entry. */
>  			flush_cache_page(vma, address, pte_pfn(*pte));
> -			pteval = ptep_clear_flush_notify(vma, address, pte);
> +			pteval = ptep_clear_flush(vma, address, pte);
>  			page_remove_rmap(page, vma);
>  			dec_mm_counter(mm, file_rss);
>  			BUG_ON(pte_dirty(pteval));
>  			pte_unmap_unlock(pte, ptl);
> +			/* must invalidate_page _before_ freeing the page */
> +			mmu_notifier_invalidate_page(mm, address);
>  			page_cache_release(page);
>  		}
>  	}

Ok but we still hold the i_mmap_lock here.


> @@ -834,6 +846,8 @@ static void try_to_unmap_cluster(unsigne
>  	if (!pmd_present(*pmd))
>  		return;
>  
> +	start = address;
> +	mmu_notifier_invalidate_range_begin(mm, start, end);

Hmmmm.. Okay you going for range invalidate here like EMM but there are 
still some invalidate_pages() left.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
