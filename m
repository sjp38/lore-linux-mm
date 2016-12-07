Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C8F7B6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 07:31:36 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so36679417wma.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 04:31:36 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id i8si24150115wjm.109.2016.12.07.04.31.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 04:31:34 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id he10so35393206wjc.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 04:31:34 -0800 (PST)
Date: Wed, 7 Dec 2016 13:31:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add cond_resched() in gather_pte_stats()
Message-ID: <20161207123132.GA31912@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1612052157400.13021@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1612052157400.13021@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org

On Mon 05-12-16 22:00:22, Hugh Dickins wrote:
> The other pagetable walks in task_mmu.c have a cond_resched() after
> walking their ptes: add a cond_resched() in gather_pte_stats() too,
> for reading /proc/<id>/numa_maps.  Only pagemap_pmd_range() has a
> cond_resched() in its (unusually expensive) pmd_trans_huge case:
> more should probably be added, but leave them unchanged for now.

The patch seems correct, I am just wondering whether pushing the
cond_resched into the pte walk code (walk_pmd_range) would be more
appropriate.
 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Anyway
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
>  fs/proc/task_mmu.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> --- 4.9-rc8/fs/proc/task_mmu.c	2016-10-23 17:33:00.156860538 -0700
> +++ linux/fs/proc/task_mmu.c	2016-12-05 20:27:04.084531599 -0800
> @@ -1588,6 +1588,7 @@ static int gather_pte_stats(pmd_t *pmd,
>  
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	pte_unmap_unlock(orig_pte, ptl);
> +	cond_resched();
>  	return 0;
>  }
>  #ifdef CONFIG_HUGETLB_PAGE
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
