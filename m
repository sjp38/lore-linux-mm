Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E51A6B0253
	for <linux-mm@kvack.org>; Thu,  5 May 2016 17:57:35 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id v81so219697462ywa.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 14:57:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j44si7517474qgd.86.2016.05.05.14.57.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 14:57:34 -0700 (PDT)
Date: Thu, 5 May 2016 23:57:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] ksm: fix conflict between mmput and
 scan_get_next_rmap_item
Message-ID: <20160505215731.GK28755@redhat.com>
References: <1462452176-33462-1-git-send-email-zhouchengming1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462452176-33462-1-git-send-email-zhouchengming1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhou Chengming <zhouchengming1@huawei.com>
Cc: akpm@linux-foundation.org, hughd@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, geliangtang@163.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, dingtianhong@huawei.com, huawei.libin@huawei.com, thunder.leizhen@huawei.com, qiuxishi@huawei.com

Hello Zhou,

Great catch.

On Thu, May 05, 2016 at 08:42:56PM +0800, Zhou Chengming wrote:
>  	remove_trailing_rmap_items(slot, ksm_scan.rmap_list);
> +	up_read(&mm->mmap_sem);
>  
>  	spin_lock(&ksm_mmlist_lock);
>  	ksm_scan.mm_slot = list_entry(slot->mm_list.next,
> @@ -1666,16 +1667,12 @@ next_mm:
>  		 */
>  		hash_del(&slot->link);
>  		list_del(&slot->mm_list);
> -		spin_unlock(&ksm_mmlist_lock);
>  
>  		free_mm_slot(slot);
>  		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
> -		up_read(&mm->mmap_sem);
>  		mmdrop(mm);

I thought the mmap_sem for reading prevented a race of the above
clear_bit against a concurrent madvise(MADV_MERGEABLE) which takes the
mmap_sem for writing. After this change can't __ksm_enter run
concurrently with the clear_bit above introducing a different SMP race
condition?

> -	} else {
> -		spin_unlock(&ksm_mmlist_lock);
> -		up_read(&mm->mmap_sem);

The strict obviously safe fix is just to invert the above two,
up_read; spin_unlock.

Then I found another instance of this same SMP race condition in
unmerge_and_remove_all_rmap_items() that you didn't fix.

Actually for the other instance of the bug the implementation above
that releases the mmap_sem early sounds safe, because it's a
ksm_text_exit that takes the clear_bit path, not just the fact we
didn't find a vma with VM_MERGEABLE set and we garbage collect the
mm_slot, while the "mm" may still alive. In the other case the "mm"
isn't alive anymore so the race with MADV_MERGEABLE shouldn't be
possible to materialize.

Could you fix it by just inverting the up_read/spin_unlock order, in
the place you patched, and add this comment:

	} else {
		/*
		 * up_read(&mm->mmap_sem) first because after
		 * spin_unlock(&ksm_mmlist_lock) run, the "mm" may
		 * already have been freed under us by __ksm_exit()
		 * because the "mm_slot" is still hashed and
		 * ksm_scan.mm_slot doesn't point to it anymore.
		 */
		up_read(&mm->mmap_sem);
		spin_unlock(&ksm_mmlist_lock);
	}

And in unmerge_and_remove_all_rmap_items() same thing, except there
you can apply your up_read() early and you can just drop the "else"
clause.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
