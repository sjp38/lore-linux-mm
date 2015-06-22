Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8BC6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 01:19:24 -0400 (EDT)
Received: by igblr2 with SMTP id lr2so24570400igb.0
        for <linux-mm@kvack.org>; Sun, 21 Jun 2015 22:19:24 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id c9si15544727icf.77.2015.06.21.22.19.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jun 2015 22:19:23 -0700 (PDT)
Message-ID: <55879AD2.30507@codeaurora.org>
Date: Mon, 22 Jun 2015 10:49:14 +0530
From: Susheel Khiani <skhiani@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [Question] ksm: rmap_item pointing to some stale vmas
References: <55268741.8010301@codeaurora.org> <alpine.LSU.2.11.1504101047200.28925@eggly.anvils> <552CBB49.5000308@codeaurora.org> <alpine.LSU.2.11.1504142155010.11693@eggly.anvils> <5541C6AD.8080906@codeaurora.org> <55772FDD.4040302@codeaurora.org>
In-Reply-To: <55772FDD.4040302@codeaurora.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, neilb@suse.de, dhowells@redhat.com, paulmcquad@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 6/9/2015 11:56 PM, Susheel Khiani wrote:
> On 4/30/2015 11:37 AM, Susheel Khiani wrote:
>>> But if I've misunderstood, and you think that what you're seeing
>>> fits with the transient forking bugs I've (not quite) described,
>>> and you can explain why even the transient case is important for
>>> you to have fixed, then I really ought to redouble my efforts.
>>>
>>> Hugh
>
> I was able to root cause the issue as we got few instances of same and
> was frequently getting reproducible on stress tests. The reason why it
> was important was because failure to unmap ksm page was resulting into
> CMA allocation failure for us.
>
> For cases like fork, what we observed is for private mapped file pages,
> stable_node pointed by KSM page won't cover all the mappings until ksmd
> completes one full scan. Only after ksmd scan, new rmap_items pointing
> to mappings in child process would come into existence. So in cases like
> CMA allocations where we can't wait for ksmd to complete one full cycle,
> we can traverse anon_vma tree from parent's anon_vma to find out all the
> pages wheres CMA is mapped.
>
> I have tested the following patch on 3.10 kernel and with this change I
> am able to avoid CMA allocation failure which we were otherwise
> frequently seeing because of not able to unmap KSM page.
>
> Please review and let me know the feedback.
>
>
>
> [PATCH] ksm: Traverse through parent's anon_vma while unmapping
>
> While doing try_to_unmap_ksm, we traverse through
> rmap_item list to find out all the anon_vmas from which
> page needs to be unmapped.
>
> Now as per the design of KSM, it builds up its data
> structures by looking into each mm, and comes back a cycle
> later to find out which data structures are now outdated and
> needs to be updated. So, for cases like fork, what we
> observe is for private mapped file pages stable_node
> pointed by KSM page won't cover all the mappings until
> ksmd completes one full scan. Only after ksmd scan, new
> rmap_items pointing to mappings in child process would come
> into existence.
>
> As a result unmapping of a stable page can't be done until
> ksmd has completed one full scan. This becomes an issue in
> case of CMA where we need to unmap and move a CMA page and
> can't wait for ksmd to complete one cycle. Because of
> new rmap_items for new mapping still not created we won't be
> able to unmap CMA page from all the vmas where it is mapped.
> This would result in frequent CMA allocation failures.
>
> So instead of just relying on rmap_items list which we know
> can contain incomplete list, we also scan anon_vma tree from
> parent's anon_vma to find out all the vmas where CMA page is
> mapped and thereby successfully unmap the page and move it
> to new page.
>
> Change-Id: I97cacf6a73734b10c7098362c20fb3f2d4040c76
> Signed-off-by: Susheel Khiani <skhiani@codeaurora.org>
> ---
>   mm/ksm.c | 58 +++++++++++++++++++++++++++++++++++++++++++++++++++++++---
>   1 file changed, 55 insertions(+), 3 deletions(-)
>
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 11f6293..10d5266 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1956,6 +1956,7 @@ int page_referenced_ksm(struct page *page, struct
> mem_cgroup *memcg,
>       unsigned int mapcount = page_mapcount(page);
>       int referenced = 0;
>       int search_new_forks = 0;
> +    int search_from_root = 0;
>
>       VM_BUG_ON(!PageKsm(page));
>       VM_BUG_ON(!PageLocked(page));
> @@ -1968,9 +1969,20 @@ again:
>           struct anon_vma *anon_vma = rmap_item->anon_vma;
>           struct anon_vma_chain *vmac;
>           struct vm_area_struct *vma;
> +        struct rb_root rb_root;
> +
> +        if (!search_from_root) {
> +            if (anon_vma)
> +                rb_root = anon_vma->rb_root;
> +        }
> +        else {
> +            if (anon_vma && anon_vma->root) {
> +                rb_root = anon_vma->root->rb_root;
> +            }
> +        }
>
>           anon_vma_lock_read(anon_vma);
> -        anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
> +        anon_vma_interval_tree_foreach(vmac, &rb_root,
>                              0, ULONG_MAX) {
>               vma = vmac->vma;
>               if (rmap_item->address < vma->vm_start ||
> @@ -1999,6 +2011,11 @@ again:
>       }
>       if (!search_new_forks++)
>           goto again;
> +
> +    if (!search_from_root++) {
> +        search_new_forks = 0;
> +        goto again;
> +    }
>   out:
>       return referenced;
>   }
> @@ -2010,6 +2027,7 @@ int try_to_unmap_ksm(struct page *page, enum
> ttu_flags flags,
>       struct rmap_item *rmap_item;
>       int ret = SWAP_AGAIN;
>       int search_new_forks = 0;
> +    int search_from_root = 0;
>
>       VM_BUG_ON(!PageKsm(page));
>       VM_BUG_ON(!PageLocked(page));
> @@ -2028,9 +2046,20 @@ again:
>           struct anon_vma *anon_vma = rmap_item->anon_vma;
>           struct anon_vma_chain *vmac;
>           struct vm_area_struct *vma;
> +        struct rb_root rb_root;
> +
> +        if (!search_from_root) {
> +            if (anon_vma)
> +                rb_root = anon_vma->rb_root;
> +        }
> +        else {
> +            if (anon_vma && anon_vma->root) {
> +                rb_root = anon_vma->root->rb_root;
> +            }
> +        }
>
>           anon_vma_lock_read(anon_vma);
> -        anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
> +        anon_vma_interval_tree_foreach(vmac, &rb_root,
>                              0, ULONG_MAX) {
>               vma = vmac->vma;
>               if (rmap_item->address < vma->vm_start ||
> @@ -2056,6 +2085,11 @@ again:
>       }
>       if (!search_new_forks++)
>           goto again;
> +
> +    if(!search_from_root++) {
> +        search_new_forks = 0;
> +        goto again;
> +    }
>   out:
>       return ret;
>   }
> @@ -2068,6 +2102,7 @@ int rmap_walk_ksm(struct page *page, int
> (*rmap_one)(struct page *,
>       struct rmap_item *rmap_item;
>       int ret = SWAP_AGAIN;
>       int search_new_forks = 0;
> +    int search_from_root = 0;
>
>       VM_BUG_ON(!PageKsm(page));
>       VM_BUG_ON(!PageLocked(page));
> @@ -2080,9 +2115,21 @@ again:
>           struct anon_vma *anon_vma = rmap_item->anon_vma;
>           struct anon_vma_chain *vmac;
>           struct vm_area_struct *vma;
> +        struct rb_root rb_root;
> +
> +        if (!search_from_root) {
> +            if (anon_vma)
> +                rb_root = anon_vma->rb_root;
> +        }
> +        else {
> +            if (anon_vma && anon_vma->root) {
> +                rb_root = anon_vma->root->rb_root;
> +            }
> +        }
> +
>
>           anon_vma_lock_read(anon_vma);
> -        anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
> +        anon_vma_interval_tree_foreach(vmac, &rb_root,
>                              0, ULONG_MAX) {
>               vma = vmac->vma;
>               if (rmap_item->address < vma->vm_start ||
> @@ -2107,6 +2154,11 @@ again:
>       }
>       if (!search_new_forks++)
>           goto again;
> +
> +    if (!search_from_root++) {
> +        search_new_forks = 0;
> +        goto again;
> +    }
>   out:
>       return ret;
>   }

Reminder Ping, did you get a chance to look into
the previous mail

-- 
Susheel Khiani

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
