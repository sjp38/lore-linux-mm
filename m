Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7FD6B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 10:25:59 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so4406800wgg.24
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 07:25:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s19si2847303wik.76.2014.07.25.07.25.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 07:25:53 -0700 (PDT)
Date: Fri, 25 Jul 2014 16:25:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] shmem: fix faulting into a hole, not taking i_mutex
Message-ID: <20140725142546.GB4844@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils>
 <alpine.LSU.2.11.1407150329250.2584@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1407150329250.2584@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 15-07-14 03:31:11, Hugh Dickins wrote:
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
> 
> This involves further use of i_lock to guard against the races: lockdep
> has been happy so far, and I see fs/inode.c:unlock_new_inode() holds
> i_lock around wake_up_bit(), which is comparable to what we do here.
> i_lock is more convenient, but we could switch to shmem's info->lock.
> 
> This issue has been tagged with CVE-2014-4171, which will require
> f00cdc6df7d7 and this and the following patch to be backported: we
> suggest to 3.1+, though in fact the trinity forkbomb effect might go
> back as far as 2.6.16, when madvise(,,MADV_REMOVE) came in - or might
> not, since much has changed, with i_mmap_mutex a spinlock before 3.0.
> Anyone running trinity on 3.0 and earlier?  I don't think we need care.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Lukas Czerner <lczerner@redhat.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: <stable@vger.kernel.org>	[3.1+]

Feel free to add
Reviewed-by: Michal Hocko <mhocko@suse.cz>

for the UNINTERUPTIBLE sleep version.

> ---
> Please replace mmotm's
> revert-shmem-fix-faulting-into-a-hole-while-its-punched.patch
> by this patch.
> 
>  mm/shmem.c |   78 ++++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 52 insertions(+), 26 deletions(-)
> 
> --- 3.16-rc5/mm/shmem.c	2014-07-06 13:25:19.688009119 -0700
> +++ 3.16-rc5+/mm/shmem.c	2014-07-14 20:34:28.196153828 -0700
> @@ -85,7 +85,7 @@ static struct vfsmount *shm_mnt;
>   * a time): we would prefer not to enlarge the shmem inode just for that.
>   */
>  struct shmem_falloc {
> -	int	mode;		/* FALLOC_FL mode currently operating */
> +	wait_queue_head_t *waitq; /* faults into hole wait for punch to end */
>  	pgoff_t start;		/* start of range currently being fallocated */
>  	pgoff_t next;		/* the next page offset to be fallocated */
>  	pgoff_t nr_falloced;	/* how many new pages have been fallocated */
> @@ -760,7 +760,7 @@ static int shmem_writepage(struct page *
>  			spin_lock(&inode->i_lock);
>  			shmem_falloc = inode->i_private;
>  			if (shmem_falloc &&
> -			    !shmem_falloc->mode &&
> +			    !shmem_falloc->waitq &&
>  			    index >= shmem_falloc->start &&
>  			    index < shmem_falloc->next)
>  				shmem_falloc->nr_unswapped++;
> @@ -1248,38 +1248,58 @@ static int shmem_fault(struct vm_area_st
>  	 * Trinity finds that probing a hole which tmpfs is punching can
>  	 * prevent the hole-punch from ever completing: which in turn
>  	 * locks writers out with its hold on i_mutex.  So refrain from
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
>  	 */
>  	if (unlikely(inode->i_private)) {
>  		struct shmem_falloc *shmem_falloc;
>  
>  		spin_lock(&inode->i_lock);
>  		shmem_falloc = inode->i_private;
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
> +		    vmf->pgoff >= shmem_falloc->start &&
> +		    vmf->pgoff < shmem_falloc->next) {
> +			wait_queue_head_t *shmem_falloc_waitq;
> +			DEFINE_WAIT(shmem_fault_wait);
> +
> +			ret = VM_FAULT_NOPAGE;
>  			if ((vmf->flags & FAULT_FLAG_ALLOW_RETRY) &&
>  			   !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
> +				/* It's polite to up mmap_sem if we can */
>  				up_read(&vma->vm_mm->mmap_sem);
> -				mutex_lock(&inode->i_mutex);
> -				mutex_unlock(&inode->i_mutex);
> -				return VM_FAULT_RETRY;
> +				ret = VM_FAULT_RETRY;
>  			}
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
>  		}
> +		spin_unlock(&inode->i_lock);
>  	}
>  
>  	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, &ret);
> @@ -1774,13 +1794,13 @@ static long shmem_fallocate(struct file
>  
>  	mutex_lock(&inode->i_mutex);
>  
> -	shmem_falloc.mode = mode & ~FALLOC_FL_KEEP_SIZE;
> -
>  	if (mode & FALLOC_FL_PUNCH_HOLE) {
>  		struct address_space *mapping = file->f_mapping;
>  		loff_t unmap_start = round_up(offset, PAGE_SIZE);
>  		loff_t unmap_end = round_down(offset + len, PAGE_SIZE) - 1;
> +		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(shmem_falloc_waitq);
>  
> +		shmem_falloc.waitq = &shmem_falloc_waitq;
>  		shmem_falloc.start = unmap_start >> PAGE_SHIFT;
>  		shmem_falloc.next = (unmap_end + 1) >> PAGE_SHIFT;
>  		spin_lock(&inode->i_lock);
> @@ -1792,8 +1812,13 @@ static long shmem_fallocate(struct file
>  					    1 + unmap_end - unmap_start, 0);
>  		shmem_truncate_range(inode, offset, offset + len - 1);
>  		/* No need to unmap again: hole-punching leaves COWed pages */
> +
> +		spin_lock(&inode->i_lock);
> +		inode->i_private = NULL;
> +		wake_up_all(&shmem_falloc_waitq);
> +		spin_unlock(&inode->i_lock);
>  		error = 0;
> -		goto undone;
> +		goto out;
>  	}
>  
>  	/* We need to check rlimit even when FALLOC_FL_KEEP_SIZE */
> @@ -1809,6 +1834,7 @@ static long shmem_fallocate(struct file
>  		goto out;
>  	}
>  
> +	shmem_falloc.waitq = NULL;
>  	shmem_falloc.start = start;
>  	shmem_falloc.next  = start;
>  	shmem_falloc.nr_falloced = 0;
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
