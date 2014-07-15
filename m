Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7C40F6B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:07:07 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id w62so2403756wes.22
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 09:07:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eu4si20438813wjd.51.2014.07.15.09.07.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 09:07:06 -0700 (PDT)
Message-ID: <53C551A8.2040400@suse.cz>
Date: Tue, 15 Jul 2014 18:07:04 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] shmem: fix faulting into a hole, not taking i_mutex
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <alpine.LSU.2.11.1407150329250.2584@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407150329250.2584@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/15/2014 12:31 PM, Hugh Dickins wrote:
> f00cdc6df7d7 ("shmem: fix faulting into a hole while it's punched") was
> buggy: Sasha sent a lockdep report to remind us that grabbing i_mutex in
> the fault path is a no-no (write syscall may already hold i_mutex while
> faulting user buffer).
>
> We tried a completely different approach (see following patch) but that
> proved inadequate: good enough for a rational workload, but not good
> enough against trinity - which forks off so many mappings of the object
> that contention on i_mmap_mutex while hole-puncher holds i_mutex builds
> into serious starvation when concurrent faults force the puncher to fall
> back to single-page unmap_mapping_range() searches of the i_mmap tree.
>
> So return to the original umbrella approach, but keep away from i_mutex
> this time.  We really don't want to bloat every shmem inode with a new
> mutex or completion, just to protect this unlikely case from trinity.
> So extend the original with wait_queue_head on stack at the hole-punch
> end, and wait_queue item on the stack at the fault end.

Hi, thanks a lot, I will definitely test it soon, although my reproducer 
is rather limited - it already works fine with the current kernel. 
Trinity will be more useful here. But there's something that caught my 
eye so I though I would raise the concern now.

> @@ -760,7 +760,7 @@ static int shmem_writepage(struct page *
>   			spin_lock(&inode->i_lock);
>   			shmem_falloc = inode->i_private;

Without ACCESS_ONCE, can shmem_falloc potentially become an alias on 
inode->i_private and later become re-read outside of the lock?

>   			if (shmem_falloc &&
> -			    !shmem_falloc->mode &&
> +			    !shmem_falloc->waitq &&
>   			    index >= shmem_falloc->start &&
>   			    index < shmem_falloc->next)
>   				shmem_falloc->nr_unswapped++;
> @@ -1248,38 +1248,58 @@ static int shmem_fault(struct vm_area_st
>   	 * Trinity finds that probing a hole which tmpfs is punching can
>   	 * prevent the hole-punch from ever completing: which in turn
>   	 * locks writers out with its hold on i_mutex.  So refrain from
> -	 * faulting pages into the hole while it's being punched, and
> -	 * wait on i_mutex to be released if vmf->flags permits.
> +	 * faulting pages into the hole while it's being punched.  Although
> +	 * shmem_undo_range() does remove the additions, it may be unable to
> +	 * keep up, as each new page needs its own unmap_mapping_range() call,
> +	 * and the i_mmap tree grows ever slower to scan if new vmas are added.
> +	 *
> +	 * It does not matter if we sometimes reach this check just before the
> +	 * hole-punch begins, so that one fault then races with the punch:
> +	 * we just need to make racing faults a rare case.
> +	 *
> +	 * The implementation below would be much simpler if we just used a
> +	 * standard mutex or completion: but we cannot take i_mutex in fault,
> +	 * and bloating every shmem inode for this unlikely case would be sad.
>   	 */
>   	if (unlikely(inode->i_private)) {
>   		struct shmem_falloc *shmem_falloc;
>
>   		spin_lock(&inode->i_lock);
>   		shmem_falloc = inode->i_private;

Same here.

> -		if (!shmem_falloc ||
> -		    shmem_falloc->mode != FALLOC_FL_PUNCH_HOLE ||
> -		    vmf->pgoff < shmem_falloc->start ||
> -		    vmf->pgoff >= shmem_falloc->next)
> -			shmem_falloc = NULL;
> -		spin_unlock(&inode->i_lock);
> -		/*
> -		 * i_lock has protected us from taking shmem_falloc seriously
> -		 * once return from shmem_fallocate() went back up that stack.
> -		 * i_lock does not serialize with i_mutex at all, but it does
> -		 * not matter if sometimes we wait unnecessarily, or sometimes
> -		 * miss out on waiting: we just need to make those cases rare.
> -		 */
> -		if (shmem_falloc) {
> +		if (shmem_falloc &&
> +		    shmem_falloc->waitq &&

Here it's operating outside of lock.

> +		    vmf->pgoff >= shmem_falloc->start &&
> +		    vmf->pgoff < shmem_falloc->next) {
> +			wait_queue_head_t *shmem_falloc_waitq;
> +			DEFINE_WAIT(shmem_fault_wait);
> +
> +			ret = VM_FAULT_NOPAGE;
>   			if ((vmf->flags & FAULT_FLAG_ALLOW_RETRY) &&
>   			   !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
> +				/* It's polite to up mmap_sem if we can */
>   				up_read(&vma->vm_mm->mmap_sem);
> -				mutex_lock(&inode->i_mutex);
> -				mutex_unlock(&inode->i_mutex);
> -				return VM_FAULT_RETRY;
> +				ret = VM_FAULT_RETRY;
>   			}
> -			/* cond_resched? Leave that to GUP or return to user */
> -			return VM_FAULT_NOPAGE;
> +
> +			shmem_falloc_waitq = shmem_falloc->waitq;
> +			prepare_to_wait(shmem_falloc_waitq, &shmem_fault_wait,
> +					TASK_KILLABLE);
> +			spin_unlock(&inode->i_lock);
> +			schedule();
> +
> +			/*
> +			 * shmem_falloc_waitq points into the shmem_fallocate()
> +			 * stack of the hole-punching task: shmem_falloc_waitq
> +			 * is usually invalid by the time we reach here, but
> +			 * finish_wait() does not dereference it in that case;
> +			 * though i_lock needed lest racing with wake_up_all().
> +			 */
> +			spin_lock(&inode->i_lock);
> +			finish_wait(shmem_falloc_waitq, &shmem_fault_wait);
> +			spin_unlock(&inode->i_lock);
> +			return ret;
>   		}
> +		spin_unlock(&inode->i_lock);
>   	}
>
>   	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, &ret);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
