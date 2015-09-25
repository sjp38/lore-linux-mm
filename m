Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 814036B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 08:57:32 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so19352427wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 05:57:32 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id e5si4509747wiy.59.2015.09.25.05.57.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 05:57:31 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so18449115wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 05:57:31 -0700 (PDT)
Date: Fri, 25 Sep 2015 14:57:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 2/4] mm, proc: account for shmem swap in
 /proc/pid/smaps
Message-ID: <20150925125729.GI16497@dhcp22.suse.cz>
References: <1438779685-5227-1-git-send-email-vbabka@suse.cz>
 <1438779685-5227-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438779685-5227-3-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Minchan Kim <minchan@kernel.org>

[Sorry for a really long delay]

On Wed 05-08-15 15:01:23, Vlastimil Babka wrote:
> Currently, /proc/pid/smaps will always show "Swap: 0 kB" for shmem-backed
> mappings, even if the mapped portion does contain pages that were swapped out.
> This is because unlike private anonymous mappings, shmem does not change pte
> to swap entry, but pte_none when swapping the page out. In the smaps page
> walk, such page thus looks like it was never faulted in.
>
> This patch changes smaps_pte_entry() to determine the swap status for such
> pte_none entries for shmem mappings, similarly to how mincore_page() does it.
> Swapped out pages are thus accounted for.
> 
> The accounting is arguably still not as precise as for private anonymous
> mappings, since now we will count also pages that the process in question never
> accessed, but only another process populated them and then let them become
> swapped out.
>
> I believe it is still less confusing and subtle than not showing
> any swap usage by shmem mappings at all. Also, swapped out pages only becomee a
> performance issue for future accesses, and we cannot predict those for neither
> kind of mapping.

Yes I agree.

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
[...]
> @@ -625,6 +626,41 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
>  	seq_putc(m, '\n');
>  }
>  
> +#if defined(CONFIG_SHMEM) && defined(CONFIG_SWAP)
> +static unsigned long smaps_shmem_swap(struct vm_area_struct *vma)
> +{
> +	struct inode *inode;
> +	unsigned long swapped;
> +	pgoff_t start, end;
> +
> +	if (!vma->vm_file)
> +		return 0;
> +
> +	inode = file_inode(vma->vm_file);

Why don't we need to take i_mutex here? What prevents from a parallel
truncate? I guess we do not care because radix_tree_for_each_slot would
cope with a truncated portion of the range, right?
It would deserve a comment I guess.

> +
> +	if (!shmem_mapping(inode->i_mapping))
> +		return 0;
> +
> +	swapped = shmem_swap_usage(inode);
> +
> +	if (swapped == 0)
> +		return 0;
> +
> +	if (vma->vm_end - vma->vm_start >= inode->i_size)
> +		return swapped;
> +
> +	start = linear_page_index(vma, vma->vm_start);
> +	end = linear_page_index(vma, vma->vm_end);
> +
> +	return shmem_partial_swap_usage(inode->i_mapping, start, end);
> +}
[...]
> +unsigned long shmem_partial_swap_usage(struct address_space *mapping,
> +						pgoff_t start, pgoff_t end)
> +{
> +	struct radix_tree_iter iter;
> +	void **slot;
> +	struct page *page;
> +	unsigned long swapped = 0;
> +
> +	rcu_read_lock();
> +
> +restart:
> +	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> +		if (iter.index >= end)
> +			break;
> +
> +		page = radix_tree_deref_slot(slot);
> +
> +		/*
> +		 * This should only be possible to happen at index 0, so we
> +		 * don't need to reset the counter, nor do we risk infinite
> +		 * restarts.
> +		 */
> +		if (radix_tree_deref_retry(page))
> +			goto restart;
> +
> +		if (radix_tree_exceptional_entry(page))
> +			swapped++;
> +
> +		if (need_resched()) {
> +			cond_resched_rcu();
> +			start = iter.index + 1;
> +			goto restart;
> +		}
> +	}
> +
> +	rcu_read_unlock();
> +
> +	return swapped << PAGE_SHIFT;
> +}
> +#endif
> +
>  /*
>   * SysV IPC SHM_UNLOCK restore Unevictable pages to their evictable lists.
>   */
> -- 
> 2.4.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
