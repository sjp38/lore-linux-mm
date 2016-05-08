Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 97A496B0005
	for <linux-mm@kvack.org>; Sun,  8 May 2016 08:09:53 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m64so67390745lfd.1
        for <linux-mm@kvack.org>; Sun, 08 May 2016 05:09:53 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id b83si20667222wme.3.2016.05.08.05.09.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 08 May 2016 05:09:52 -0700 (PDT)
Message-ID: <572F2C64.6040901@huawei.com>
Date: Sun, 8 May 2016 20:09:08 +0800
From: zhouchengming <zhouchengming1@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] ksm: fix conflict between mmput and scan_get_next_rmap_item
References: <1462690586-50973-1-git-send-email-zhouchengming1@huawei.com>
In-Reply-To: <1462690586-50973-1-git-send-email-zhouchengming1@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhou Chengming <zhouchengming1@huawei.com>
Cc: akpm@linux-foundation.org, hughd@google.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, geliangtang@163.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, dingtianhong@huawei.com, huawei.libin@huawei.com, thunder.leizhen@huawei.com, qiuxishi@huawei.com

Please ignore this patch v3. I forgot to change the function
unmerge_and_remove_all_rmap_items(). Patch v4 will be the
final version, I think.. Sorry for my carelessness.

Thanks!

On 2016/5/8 14:56, Zhou Chengming wrote:
> A concurrency issue about KSM in the function scan_get_next_rmap_item.
>
> task A (ksmd):				|task B (the mm's task):
> 					|
> mm = slot->mm;				|
> down_read(&mm->mmap_sem);		|
> 					|
> ...					|
> 					|
> spin_lock(&ksm_mmlist_lock);		|
> 					|
> ksm_scan.mm_slot go to the next slot;	|
> 					|
> spin_unlock(&ksm_mmlist_lock);		|
> 					|mmput() ->
> 					|	ksm_exit():
> 					|
> 					|spin_lock(&ksm_mmlist_lock);
> 					|if (mm_slot&&  ksm_scan.mm_slot != mm_slot) {
> 					|	if (!mm_slot->rmap_list) {
> 					|		easy_to_free = 1;
> 					|		...
> 					|
> 					|if (easy_to_free) {
> 					|	mmdrop(mm);
> 					|	...
> 					|
> 					|So this mm_struct may be freed in the mmput().
> 					|
> up_read(&mm->mmap_sem);			|
>
> As we can see above, the ksmd thread may access a mm_struct that already
> been freed to the kmem_cache.
> Suppose a fork will get this mm_struct from the kmem_cache, the ksmd thread
> then call up_read(&mm->mmap_sem), will cause mmap_sem.count to become -1.
>> From the suggestion of Andrea Arcangeli, unmerge_and_remove_all_rmap_items
> has the same SMP race condition, so fix it too. My prev fix in function
> scan_get_next_rmap_item will introduce a different SMP race condition,
> so just invert the up_read/spin_unlock order as Andrea Arcangeli said.
>
> Signed-off-by: Zhou Chengming<zhouchengming1@huawei.com>
> Suggested-by: Andrea Arcangeli<aarcange@redhat.com>
> Reviewed-by: Andrea Arcangeli<aarcange@redhat.com>
> ---
>   mm/ksm.c |   16 ++++++++++------
>   1 files changed, 10 insertions(+), 6 deletions(-)
>
> diff --git a/mm/ksm.c b/mm/ksm.c
> index ca6d2a0..b6dc387 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -777,6 +777,7 @@ static int unmerge_and_remove_all_rmap_items(void)
>   		}
>
>   		remove_trailing_rmap_items(mm_slot,&mm_slot->rmap_list);
> +		up_read(&mm->mmap_sem);
>
>   		spin_lock(&ksm_mmlist_lock);
>   		ksm_scan.mm_slot = list_entry(mm_slot->mm_list.next,
> @@ -784,16 +785,12 @@ static int unmerge_and_remove_all_rmap_items(void)
>   		if (ksm_test_exit(mm)) {
>   			hash_del(&mm_slot->link);
>   			list_del(&mm_slot->mm_list);
> -			spin_unlock(&ksm_mmlist_lock);
>
>   			free_mm_slot(mm_slot);
>   			clear_bit(MMF_VM_MERGEABLE,&mm->flags);
> -			up_read(&mm->mmap_sem);
>   			mmdrop(mm);
> -		} else {
> -			spin_unlock(&ksm_mmlist_lock);
> -			up_read(&mm->mmap_sem);
>   		}
> +		spin_unlock(&ksm_mmlist_lock);
>   	}
>
>   	/* Clean up stable nodes, but don't worry if some are still busy */
> @@ -1657,8 +1654,15 @@ next_mm:
>   		up_read(&mm->mmap_sem);
>   		mmdrop(mm);
>   	} else {
> -		spin_unlock(&ksm_mmlist_lock);
>   		up_read(&mm->mmap_sem);
> +		/*
> +		 * up_read(&mm->mmap_sem) first because after
> +		 * spin_unlock(&ksm_mmlist_lock) run, the "mm" may
> +		 * already have been freed under us by __ksm_exit()
> +		 * because the "mm_slot" is still hashed and
> +		 * ksm_scan.mm_slot doesn't point to it anymore.
> +		 */
> +		spin_unlock(&ksm_mmlist_lock);
>   	}
>
>   	/* Repeat until we've completed scanning the whole list */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
