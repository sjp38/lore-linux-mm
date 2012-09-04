Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id D3F816B0069
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 18:07:55 -0400 (EDT)
Date: Tue, 4 Sep 2012 15:07:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V1 2/2] mm: Wrap calls to set_pte_at_notify with
 invalidate_range_start and invalidate_range_end
Message-Id: <20120904150754.ea574c4e.akpm@linux-foundation.org>
In-Reply-To: <1346748081-1652-3-git-send-email-haggaie@mellanox.com>
References: <1346748081-1652-1-git-send-email-haggaie@mellanox.com>
	<1346748081-1652-3-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Shachar Raindel <raindel@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>

On Tue,  4 Sep 2012 11:41:21 +0300
Haggai Eran <haggaie@mellanox.com> wrote:

> In order to allow sleeping during invalidate_page mmu notifier calls, we
> need to avoid calling when holding the PT lock. In addition to its
> direct calls, invalidate_page can also be called as a substitute for a
> change_pte call, in case the notifier client hasn't implemented
> change_pte.
> 
> This patch drops the invalidate_page call from change_pte, and instead
> wraps all calls to change_pte with invalidate_range_start and
> invalidate_range_end calls.
> 
> Note that change_pte still cannot sleep after this patch, and that
> clients implementing change_pte should not take action on it in case the
> number of outstanding invalidate_range_start calls is larger than one,
> otherwise they might miss a later invalidation.
> 
> ...
>
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -145,6 +145,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  	/* For try_to_free_swap() and munlock_vma_page() below */
>  	lock_page(page);
>  
> +	mmu_notifier_invalidate_range_start(mm, addr, addr + PAGE_SIZE);
>  	err = -EAGAIN;
>  	ptep = page_check_address(page, mm, addr, &ptl, 0);
>  	if (!ptep)
> @@ -173,6 +174,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  
>  	err = 0;
>   unlock:
> +	mmu_notifier_invalidate_range_end(mm, addr, addr + PAGE_SIZE);
>  	unlock_page(page);
>  	return err;
>  }

Again, now I have to apply the patch and peer at the code to work out
whether `addr' got changed anywhere between these two calls.  And I
somehow need to ensure that `addr' will not get modified in the future
and I can't do that!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
