Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE0A66B007E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 10:24:35 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id j68so243573743qke.1
        for <linux-mm@kvack.org>; Fri, 06 May 2016 07:24:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j6si4906987qgf.34.2016.05.06.07.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 07:24:35 -0700 (PDT)
Date: Fri, 6 May 2016 16:24:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2] ksm: fix conflict between mmput and
 scan_get_next_rmap_item
Message-ID: <20160506142431.GA4855@redhat.com>
References: <1462505256-37301-1-git-send-email-zhouchengming1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462505256-37301-1-git-send-email-zhouchengming1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhou Chengming <zhouchengming1@huawei.com>
Cc: akpm@linux-foundation.org, hughd@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, geliangtang@163.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, dingtianhong@huawei.com, huawei.libin@huawei.com, thunder.leizhen@huawei.com, qiuxishi@huawei.com

On Fri, May 06, 2016 at 11:27:36AM +0800, Zhou Chengming wrote:
> @@ -1650,16 +1647,22 @@ next_mm:
>  		 */
>  		hash_del(&slot->link);
>  		list_del(&slot->mm_list);
> -		spin_unlock(&ksm_mmlist_lock);
>  
>  		free_mm_slot(slot);
>  		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
>  		up_read(&mm->mmap_sem);
>  		mmdrop(mm);
>  	} else {
> -		spin_unlock(&ksm_mmlist_lock);
>  		up_read(&mm->mmap_sem);
>  	}
> +	/*
> +	 * up_read(&mm->mmap_sem) first because after
> +	 * spin_unlock(&ksm_mmlist_lock) run, the "mm" may
> +	 * already have been freed under us by __ksm_exit()
> +	 * because the "mm_slot" is still hashed and
> +	 * ksm_scan.mm_slot doesn't point to it anymore.
> +	 */
> +	spin_unlock(&ksm_mmlist_lock);
>  
>  	/* Repeat until we've completed scanning the whole list */
>  	slot = ksm_scan.mm_slot;

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

While the above patch is correct, I would however prefer if you could
update it to keep releasing the ksm_mmlist_lock as before (I'm talking
only about the quoted part, not the other one not quoted), because
it's "strictier" and it better documents that it's only needed up
until:

  		hash_del(&slot->link);
  		list_del(&slot->mm_list);

It should be also a bit more scalable but to me this is just about
keeping implicit documentation on the locking by keeping it strict.

The fact up_read happens exactly after clear_bit also avoided me to
overlook that it was really needed, same thing with the
ksm_mmlist_lock after list_del, I'd like to keep it there and just
invert the order of spin_unlock; up_read in the else branch.

That should be enough because after hash_del get_mm_slot will return
NULL so the mmdrop will not happen anymore in __ksm_exit, this is
further explicit by the code doing mmdrop itself just after
up_read.

The SMP race condition is fixed by just the two liner that reverse the
order of spin_unlock; up_read without increasing the size of the
spinlock critical section for the ksm_scan.address == 0 case. This is
also why it wasn't reproducible because it's about 1 instruction window.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
