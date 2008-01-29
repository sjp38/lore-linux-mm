Date: Tue, 29 Jan 2008 12:30:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080129182831.GS7233@v2.random>
Message-ID: <Pine.LNX.4.64.0801291219030.25629@schroedinger.engr.sgi.com>
References: <20080128202840.974253868@sgi.com> <20080128202923.849058104@sgi.com>
 <20080129162004.GL7233@v2.random> <20080129182831.GS7233@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008, Andrea Arcangeli wrote:

> diff --git a/mm/fremap.c b/mm/fremap.c
> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -212,8 +212,8 @@ asmlinkage long sys_remap_file_pages(uns
>  		spin_unlock(&mapping->i_mmap_lock);
>  	}
>  
> +	err = populate_range(mm, vma, start, size, pgoff);
>  	mmu_notifier(invalidate_range, mm, start, start + size, 0);
> -	err = populate_range(mm, vma, start, size, pgoff);
>  	if (!err && !(flags & MAP_NONBLOCK)) {
>  		if (unlikely(has_write_lock)) {
>  			downgrade_write(&mm->mmap_sem);

We invalidate the range *after* populating it? Isnt it okay to establish 
references while populate_range() runs?

> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1639,8 +1639,6 @@ gotten:
>  	/*
>  	 * Re-check the pte - we dropped the lock
>  	 */
> -	mmu_notifier(invalidate_range, mm, address,
> -				address + PAGE_SIZE - 1, 0);
>  	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
>  	if (likely(pte_same(*page_table, orig_pte))) {
>  		if (old_page) {

What we did is to invalidate the page (?!) before taking the pte lock. In 
the lock we replace the pte to point to another page. This means that we 
need to clear stale information. So we zap it before. If another reference 
is established after taking the spinlock then the pte contents have 
changed at the cirtical section fails.

Before the critical section starts we have gotten an extra refcount on the 
original page so the page cannot vanish from under us.

> @@ -1676,6 +1674,8 @@ gotten:
>  		page_cache_release(old_page);
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
> +	mmu_notifier(invalidate_range, mm, address,
> +				address + PAGE_SIZE - 1, 0);
>  	if (dirty_page) {
>  		if (vma->vm_file)
>  			file_update_time(vma->vm_file);

Now we invalidate the page after the transaction is complete. This means 
external pte can persist while we change the pte? Possibly even dirty the 
page?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
