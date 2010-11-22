Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7414E6B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 16:06:15 -0500 (EST)
Date: Mon, 22 Nov 2010 13:05:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] Cross Memory Attach v2 (resend)
Message-Id: <20101122130527.c13c99d3.akpm@linux-foundation.org>
In-Reply-To: <20101122122847.3585b447@lilo>
References: <20101122122847.3585b447@lilo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Brice Goglin <Brice.Goglin@inria.fr>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2010 12:28:47 +1030
Christopher Yeoh <cyeoh@au1.ibm.com> wrote:

> Resending just in case the previous mail was missed rather than ignored :-)
> I'd appreciate any comments....

Fear, uncertainty, doubt and resistance!

We have a bit of a track record of adding cool-looking syscalls and
then regretting it a few years later.  Few people use them, and maybe
they weren't so cool after all, and we have to maintain them for ever. 
Bugs (sometimes security-relevant ones) remain undiscovered for long
periods because few people use (or care about) the code.

So I think the bar is a high one - higher than it used to be.  Convince
us that this feature is so important that it's worth all that overhead
and risk?

(All that being said, the ability to copy memory from one process to
another is a pretty basic and obvious one).

>
> ...
>
> HPCC results:
> =============
> 
> MB/s			Num Processes	
> Naturally Ordered	4	8	16	32
> Base			1235	935	622	419
> CMA			4741	3769	1977	703
> 
> 			
> MB/s			Num Processes	
> Randomly Ordered	4	8	16	32
> Base			1227	947	638	412
> CMA			4666	3682	1978	710
> 				
> MB/s			Num Processes	
> Max Ping Pong		4	8	16	32
> Base			2028	1938	1928	1882
> CMA			7424	7510	7598	7708

So with the "Naturally ordered" testcase, it got 4741/1235 times faster
with four processes?

>
> ...
>
> +asmlinkage long sys_process_vm_readv(pid_t pid,
> +				     const struct iovec __user *lvec,
> +				     unsigned long liovcnt,
> +				     const struct iovec __user *rvec,
> +				     unsigned long riovcnt,
> +				     unsigned long flags);
> +asmlinkage long sys_process_vm_writev(pid_t pid,
> +				      const struct iovec __user *lvec,
> +				      unsigned long liovcnt,
> +				      const struct iovec __user *rvec,
> +				      unsigned long riovcnt,
> +				      unsigned long flags);

I have a vague feeling that some architectures have issues with six or
more syscall args.  Or maybe it was seven.

>
> ...
>
> +static int process_vm_rw_pages(struct task_struct *task,
> +			       struct page **process_pages,
> +			       unsigned long pa,
> +			       unsigned long start_offset,
> +			       unsigned long len,
> +			       struct iovec *lvec,
> +			       unsigned long lvec_cnt,
> +			       unsigned long *lvec_current,
> +			       size_t *lvec_offset,
> +			       int vm_write,
> +			       unsigned int nr_pages_to_copy)
> +{
> +	int pages_pinned;
> +	void *target_kaddr;
> +	int i = 0;
> +	int j;
> +	int ret;
> +	unsigned long bytes_to_copy;
> +	unsigned long bytes_copied = 0;
> +	int rc = -EFAULT;
> +
> +	/* Get the pages we're interested in */
> +	pages_pinned = get_user_pages(task, task->mm, pa,
> +				      nr_pages_to_copy,
> +				      vm_write, 0, process_pages, NULL);
> +
> +	if (pages_pinned != nr_pages_to_copy)
> +		goto end;
> +
> +	/* Do the copy for each page */
> +	for (i = 0; (i < nr_pages_to_copy) && (*lvec_current < lvec_cnt); i++) {
> +		/* Make sure we have a non zero length iovec */
> +		while (*lvec_current < lvec_cnt
> +		       && lvec[*lvec_current].iov_len == 0)
> +			(*lvec_current)++;
> +		if (*lvec_current == lvec_cnt)
> +			break;
> +
> +		/* Will copy smallest of:
> +		   - bytes remaining in page
> +		   - bytes remaining in destination iovec */
> +		bytes_to_copy = min(PAGE_SIZE - start_offset,
> +				    len - bytes_copied);
> +		bytes_to_copy = min((size_t)bytes_to_copy,
> +				    lvec[*lvec_current].iov_len - *lvec_offset);

Use of min_t() is conventional.

> +
> +
> +		target_kaddr = kmap(process_pages[i]) + start_offset;

kmap() is slow.  But only on i386, really.  If i386 mattered any more
then perhaps we should jump through hoops with kmap_atomic() and
copy_*_user_inatomic().  Probably not worth bothering nowadays.

> +		if (vm_write)
> +			ret = copy_from_user(target_kaddr,
> +					     lvec[*lvec_current].iov_base
> +					     + *lvec_offset,
> +					     bytes_to_copy);
> +		else
> +			ret = copy_to_user(lvec[*lvec_current].iov_base
> +					   + *lvec_offset,
> +					   target_kaddr, bytes_to_copy);
> +		kunmap(process_pages[i]);
> +		if (ret) {
> +			i++;
> +			goto end;
> +		}
> +		bytes_copied += bytes_to_copy;
> +		*lvec_offset += bytes_to_copy;
> +		if (*lvec_offset == lvec[*lvec_current].iov_len) {
> +			/* Need to copy remaining part of page into
> +			   the next iovec if there are any bytes left in page */
> +			(*lvec_current)++;
> +			*lvec_offset = 0;
> +			start_offset = (start_offset + bytes_to_copy)
> +				% PAGE_SIZE;
> +			if (start_offset)
> +				i--;
> +		} else {
> +			if (start_offset)
> +				start_offset = 0;
> +		}
> +	}
> +
> +	rc = bytes_copied;
> +
> +end:
> +	for (j = 0; j < pages_pinned; j++) {
> +		if (vm_write && j < i)
> +			set_page_dirty_lock(process_pages[j]);
> +		put_page(process_pages[j]);
> +	}

It might be a little more efficient to do


	if (vm_write) {
		for (j = 0; j < pages_pinned; j++) {
			if (j < i)
				set_page_dirty_lock(process_pages[j]);
			put_page(process_pages[j]);
	} else {
		for (j = 0; j < pages_pinned; j++)
			put_page(process_pages[j]);
	}

and it is hopefully more efficient still to use release_pages() for the
second loop.

This code would have been clearer if a better identifier than `i' had
been chosen.

> +	return rc;
> +}
> +
> +
> +

One newline will suffice ;)

> +static int process_vm_rw(pid_t pid, unsigned long addr,
> +			 unsigned long len,
> +			 struct iovec *lvec,
> +			 unsigned long lvec_cnt,
> +			 unsigned long *lvec_current,
> +			 size_t *lvec_offset,
> +			 struct page **process_pages,
> +			 struct mm_struct *mm,
> +			 struct task_struct *task,
> +			 unsigned long flags, int vm_write)
> +{
> +	unsigned long pa = addr & PAGE_MASK;
> +	unsigned long start_offset = addr - pa;
> +	int nr_pages;
> +	unsigned long bytes_copied = 0;
> +	int rc;
> +	unsigned int nr_pages_copied = 0;
> +	unsigned int nr_pages_to_copy;

What prevents me from copying more than 2^32 pages?

> +	unsigned int max_pages_per_loop = (PAGE_SIZE * 2)
> +		/ sizeof(struct pages *);
> +
> +
> +	/* Work out address and page range required */
> +	if (len == 0)
> +		return 0;
> +	nr_pages = (addr + len - 1) / PAGE_SIZE - addr / PAGE_SIZE + 1;
> +
> +
> +	down_read(&mm->mmap_sem);
> +	while ((nr_pages_copied < nr_pages) && (*lvec_current < lvec_cnt)) {
> +		nr_pages_to_copy = min(nr_pages - nr_pages_copied,
> +				       max_pages_per_loop);
> +
> +		rc = process_vm_rw_pages(task, process_pages, pa,
> +					 start_offset, len,
> +					 lvec, lvec_cnt,
> +					 lvec_current, lvec_offset,
> +					 vm_write, nr_pages_to_copy);
> +		start_offset = 0;
> +
> +		if (rc == -EFAULT)

It would be more future-safe to use

		if (rc < 0)

> +			goto free_mem;
> +		else {
> +			bytes_copied += rc;
> +			len -= rc;
> +			nr_pages_copied += nr_pages_to_copy;
> +			pa += nr_pages_to_copy * PAGE_SIZE;
> +		}
> +	}
> +
> +	rc = bytes_copied;
> +
> +free_mem:
> +	up_read(&mm->mmap_sem);
> +
> +	return rc;
> +}
> +
> +static int process_vm_rw_v(pid_t pid, const struct iovec __user *lvec,
> +			   unsigned long liovcnt,
> +			   const struct iovec __user *rvec,
> +			   unsigned long riovcnt,
> +			   unsigned long flags, int vm_write)
> +{
> +	struct task_struct *task;
> +	struct page **process_pages = NULL;
> +	struct mm_struct *mm;
> +	int i;
> +	int rc;
> +	int bytes_copied;

This was unsigned long in process_vm_rw().  Please review all these
types for appropriate size and signedness.

> +	struct iovec iovstack_l[UIO_FASTIOV];
> +	struct iovec iovstack_r[UIO_FASTIOV];
> +	struct iovec *iov_l = iovstack_l;
> +	struct iovec *iov_r = iovstack_r;
> +	unsigned int nr_pages = 0;
> +	unsigned int nr_pages_iov;
> +	unsigned long iov_l_curr_idx = 0;
> +	size_t iov_l_curr_offset = 0;
> +	int iov_len_total = 0;
> +
> +	/* Get process information */
> +	rcu_read_lock();
> +	task = find_task_by_vpid(pid);
> +	if (task)
> +		get_task_struct(task);
> +	rcu_read_unlock();
> +	if (!task)
> +		return -ESRCH;
> +
> +	task_lock(task);
> +	if (__ptrace_may_access(task, PTRACE_MODE_ATTACH)) {
> +		task_unlock(task);
> +		rc = -EPERM;
> +		goto end;
> +	}
> +	mm = task->mm;
> +
> +	if (!mm) {
> +		rc = -EINVAL;
> +		goto end;
> +	}
> +
> +	atomic_inc(&mm->mm_users);
> +	task_unlock(task);
> +
> +
> +	if ((liovcnt > UIO_MAXIOV) || (riovcnt > UIO_MAXIOV)) {
> +		rc = -EINVAL;
> +		goto release_mm;
> +	}
> +
> +	if (liovcnt > UIO_FASTIOV)
> +		iov_l = kmalloc(liovcnt*sizeof(struct iovec), GFP_KERNEL);
> +
> +	if (riovcnt > UIO_FASTIOV)
> +		iov_r = kmalloc(riovcnt*sizeof(struct iovec), GFP_KERNEL);
> +
> +	if (iov_l == NULL || iov_r == NULL) {
> +		rc = -ENOMEM;
> +		goto free_iovecs;
> +	}
> +
> +	rc = copy_from_user(iov_l, lvec, liovcnt*sizeof(*lvec));
> +	if (rc) {
> +		rc = -EFAULT;
> +		goto free_iovecs;
> +	}
> +	rc = copy_from_user(iov_r, rvec, riovcnt*sizeof(*lvec));
> +	if (rc) {
> +		rc = -EFAULT;
> +		goto free_iovecs;
> +	}
> +
> +	/* Work out how many pages of struct pages we're going to need
> +	   when eventually calling get_user_pages */
> +	for (i = 0; i < riovcnt; i++) {
> +		if (iov_r[i].iov_len > 0) {
> +			nr_pages_iov = ((unsigned long)iov_r[i].iov_base
> +					+ iov_r[i].iov_len) /
> +				PAGE_SIZE - (unsigned long)iov_r[i].iov_base
> +				/ PAGE_SIZE + 1;
> +			nr_pages = max(nr_pages, nr_pages_iov);
> +			iov_len_total += iov_r[i].iov_len;
> +			if (iov_len_total < 0) {
> +				rc = -EINVAL;
> +				goto free_iovecs;
> +			}
> +		}
> +	}
> +
> +	if (nr_pages == 0)
> +		goto free_iovecs;
> +
> +	/* For reliability don't try to kmalloc more than 2 pages worth */
> +	process_pages = kmalloc(min((size_t)PAGE_SIZE * 2,

min_t()

> +				    sizeof(struct pages *) * nr_pages),
> +				GFP_KERNEL);
> +
> +	if (!process_pages) {
> +		rc = -ENOMEM;
> +		goto free_iovecs;
> +	}
> +
> +	rc = 0;
> +	for (i = 0; i < riovcnt && iov_l_curr_idx < liovcnt; i++) {
> +		bytes_copied = process_vm_rw(pid,
> +					     (unsigned long)iov_r[i].iov_base,
> +					     iov_r[i].iov_len,
> +					     iov_l, liovcnt,
> +					     &iov_l_curr_idx,
> +					     &iov_l_curr_offset,
> +					     process_pages, mm,
> +					     task, flags, vm_write);
> +		if (bytes_copied < 0) {
> +			rc = bytes_copied;
> +			goto free_proc_pages;
> +		} else {
> +			rc += bytes_copied;
> +		}
> +	}
> +
> +
> +free_proc_pages:
> +	kfree(process_pages);
> +
> +free_iovecs:
> +	if (riovcnt > UIO_FASTIOV)
> +		kfree(iov_r);
> +	if (liovcnt > UIO_FASTIOV)
> +		kfree(iov_l);
> +
> +release_mm:
> +	mmput(mm);
> +
> +end:
> +	put_task_struct(task);
> +	return rc;
> +}
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
