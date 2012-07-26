Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 507646B0044
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 12:01:10 -0400 (EDT)
Message-ID: <501169C0.3070805@redhat.com>
Date: Thu, 26 Jul 2012 12:01:04 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH] mm: hugetlbfs: Close race during teardown of hugetlbfs
 shared page tables v2
References: <20120720134937.GG9222@suse.de>
In-Reply-To: <20120720134937.GG9222@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On 07/20/2012 09:49 AM, Mel Gorman wrote:
> +retry:
>   	mutex_lock(&mapping->i_mmap_mutex);
>   	vma_prio_tree_foreach(svma,&iter,&mapping->i_mmap, idx, idx) {
>   		if (svma == vma)
>   			continue;
> +		if (svma->vm_mm == vma->vm_mm)
> +			continue;
> +
> +		/*
> +		 * The target mm could be in the process of tearing down
> +		 * its page tables and the i_mmap_mutex on its own is
> +		 * not sufficient. To prevent races against teardown and
> +		 * pagetable updates, we acquire the mmap_sem and pagetable
> +		 * lock of the remote address space. down_read_trylock()
> +		 * is necessary as the other process could also be trying
> +		 * to share pagetables with the current mm. In the fork
> +		 * case, we are already both mm's so check for that
> +		 */
> +		if (locked_mm != svma->vm_mm) {
> +			if (!down_read_trylock(&svma->vm_mm->mmap_sem)) {
> +				mutex_unlock(&mapping->i_mmap_mutex);
> +				goto retry;
> +			}
> +			smmap_sem =&svma->vm_mm->mmap_sem;
> +		}
> +
> +		spage_table_lock =&svma->vm_mm->page_table_lock;
> +		spin_lock_nested(spage_table_lock, SINGLE_DEPTH_NESTING);
>
>   		saddr = page_table_shareable(svma, vma, addr, idx);
>   		if (saddr) {

Hi Mel, FYI I tried this and ran into a problem.  When there are 
multiple processes
in huge_pmd_share() just faulting in the same i_map they all have their 
mmap_sem
down for write so the down_read_trylock(&svma->vm_mm->mmap_sem) never
succeeds.  What am I missing?

Thanks, Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
