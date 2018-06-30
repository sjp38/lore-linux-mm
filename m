Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23DB06B0003
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 21:28:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t78-v6so590405pfa.8
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:28:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x2-v6si10480375plv.388.2018.06.29.18.28.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 18:28:30 -0700 (PDT)
Date: Fri, 29 Jun 2018 18:28:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-Id: <20180629182828.1f19b69edb220cd61ae03e4f@linux-foundation.org>
In-Reply-To: <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
	<1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Sat, 30 Jun 2018 06:39:44 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> When running some mmap/munmap scalability tests with large memory (i.e.
> > 300GB), the below hung task issue may happen occasionally.
> 
> INFO: task ps:14018 blocked for more than 120 seconds.
>        Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>  "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
> message.
>  ps              D    0 14018      1 0x00000004
>   ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
>   ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
>   00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
>  Call Trace:
>   [<ffffffff817154d0>] ? __schedule+0x250/0x730
>   [<ffffffff817159e6>] schedule+0x36/0x80
>   [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
>   [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
>   [<ffffffff81717db0>] down_read+0x20/0x40
>   [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
>   [<ffffffff81253c95>] ? do_filp_open+0xa5/0x100
>   [<ffffffff81241d87>] __vfs_read+0x37/0x150
>   [<ffffffff812f824b>] ? security_file_permission+0x9b/0xc0
>   [<ffffffff81242266>] vfs_read+0x96/0x130
>   [<ffffffff812437b5>] SyS_read+0x55/0xc0
>   [<ffffffff8171a6da>] entry_SYSCALL_64_fastpath+0x1a/0xc5
> 
> It is because munmap holds mmap_sem from very beginning to all the way
> down to the end, and doesn't release it in the middle. When unmapping
> large mapping, it may take long time (take ~18 seconds to unmap 320GB
> mapping with every single page mapped on an idle machine).
> 
> It is because munmap holds mmap_sem from very beginning to all the way
> down to the end, and doesn't release it in the middle. When unmapping
> large mapping, it may take long time (take ~18 seconds to unmap 320GB
> mapping with every single page mapped on an idle machine).
> 
> Zapping pages is the most time consuming part, according to the
> suggestion from Michal Hock [1], zapping pages can be done with holding
> read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
> mmap_sem to cleanup vmas. All zapped vmas will have VM_DEAD flag set,
> the page fault to VM_DEAD vma will trigger SIGSEGV.
> 
> Define large mapping size thresh as PUD size or 1GB, just zap pages with
> read mmap_sem for mappings which are >= thresh value.

Perhaps it would be better to treat all mappings in the fashion,
regardless of size.  Simpler code, lesser mmap_sem hold times, much
better testing coverage.  Is there any particular downside to doing
this?

> If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, then just
> fallback to regular path since unmapping those mappings need acquire
> write mmap_sem.

So we'll still get huge latencies an softlockup warnings for some
usecases.  This is a problem!

> For the time being, just do this in munmap syscall path. Other
> vm_munmap() or do_munmap() call sites remain intact for stability
> reason.
> 
> The below is some regression and performance data collected on a machine
> with 32 cores of E5-2680 @ 2.70GHz and 384GB memory.

Where is this "regression and performance data"?  Something mising from
the changelog?

> With the patched kernel, write mmap_sem hold time is dropped to us level
> from second.
> 
> [1] https://lwn.net/Articles/753269/
> 
> ...
>
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2763,6 +2763,128 @@ static int munmap_lookup_vma(struct mm_struct *mm, struct vm_area_struct **vma,
>  	return 1;
>  }
>  
> +/* Consider PUD size or 1GB mapping as large mapping */
> +#ifdef HPAGE_PUD_SIZE
> +#define LARGE_MAP_THRESH	HPAGE_PUD_SIZE
> +#else
> +#define LARGE_MAP_THRESH	(1 * 1024 * 1024 * 1024)
> +#endif
> +
> +/* Unmap large mapping early with acquiring read mmap_sem */
> +static int do_munmap_zap_early(struct mm_struct *mm, unsigned long start,
> +			       size_t len, struct list_head *uf)

Can we have a comment describing what `uf' is and what it does? (at least)

> +{
> +	unsigned long end = 0;
> +	struct vm_area_struct *vma = NULL, *prev, *tmp;

`tmp' is a poor choice of identifier - it doesn't communicate either
the variable's type nor its purpose.

Perhaps rename vma to start_vma(?) and rename tmp to vma?

And declaring start_vma to be const would be a nice readability addition.

> +	bool success = false;
> +	int ret = 0;
> +
> +	if (!munmap_addr_sanity(start, len))
> +		return -EINVAL;
> +
> +	len = PAGE_ALIGN(len);
> +
> +	end = start + len;
> +
> +	/* Just deal with uf in regular path */
> +	if (unlikely(uf))
> +		goto regular_path;
> +
> +	if (len >= LARGE_MAP_THRESH) {
> +		/*
> +		 * need write mmap_sem to split vma and set VM_DEAD flag
> +		 * splitting vma up-front to save PITA to clean if it is failed
> +		 */
> +		down_write(&mm->mmap_sem);
> +		ret = munmap_lookup_vma(mm, &vma, &prev, start, end);
> +		if (ret != 1) {
> +			up_write(&mm->mmap_sem);
> +			return ret;

Can just use `goto out' here, and that would avoid the unpleasing use
of a deeply eembded `return'.

> +		}
> +		/* This ret value might be returned, so reset it */
> +		ret = 0;
> +
> +		/*
> +		 * Unmapping vmas, which has VM_LOCKED|VM_HUGETLB|VM_PFNMAP
> +		 * flag set or has uprobes set, need acquire write map_sem,
> +		 * so skip them in early zap. Just deal with such mapping in
> +		 * regular path.

For each case, please describe *why* mmap_sem must be held for writing.

> +		 * Borrow can_madv_dontneed_vma() to check the conditions.
> +		 */
> +		tmp = vma;
> +		while (tmp && tmp->vm_start < end) {
> +			if (!can_madv_dontneed_vma(tmp) ||
> +			    vma_has_uprobes(tmp, start, end)) {
> +				up_write(&mm->mmap_sem);
> +				goto regular_path;
> +			}
> +			tmp = tmp->vm_next;
> +		}
> +		/*
> +		 * set VM_DEAD flag before tear down them.
> +		 * page fault on VM_DEAD vma will trigger SIGSEGV.
> +		 */
> +		tmp = vma;
> +		for ( ; tmp && tmp->vm_start < end; tmp = tmp->vm_next)
> +			tmp->vm_flags |= VM_DEAD;
> +		up_write(&mm->mmap_sem);
> +
> +		/* zap mappings with read mmap_sem */
> +		down_read(&mm->mmap_sem);

Use downgrade_write()?

> +		zap_page_range(vma, start, len);
> +		/* indicates early zap is success */
> +		success = true;
> +		up_read(&mm->mmap_sem);
> +	}
> +
> +regular_path:
> +	/* hold write mmap_sem for vma manipulation or regular path */
> +	if (down_write_killable(&mm->mmap_sem))
> +		return -EINTR;

Why is this _killable() while the preceding down_write() was not?

> +	if (success) {
> +		/* vmas have been zapped, here clean up pgtable and vmas */
> +		struct vm_area_struct *next = prev ? prev->vm_next : mm->mmap;
> +		struct mmu_gather tlb;
> +		tlb_gather_mmu(&tlb, mm, start, end);
> +		free_pgtables(&tlb, vma, prev ? prev->vm_end : FIRST_USER_ADDRESS,
> +			      next ? next->vm_start : USER_PGTABLES_CEILING);
> +		tlb_finish_mmu(&tlb, start, end);
> +
> +		detach_vmas_to_be_unmapped(mm, vma, prev, end);
> +		arch_unmap(mm, vma, start, end);
> +		remove_vma_list(mm, vma);
> +	} else {
> +		/* vma is VM_LOCKED|VM_HUGETLB|VM_PFNMAP or has uprobe */
> +		if (vma) {
> +			if (unlikely(uf)) {
> +				int ret = userfaultfd_unmap_prep(vma, start,
> +								 end, uf);
> +				if (ret)
> +					goto out;

Bug?  This `ret' shadows the other `ret' in this function.

> +			}
> +			if (mm->locked_vm) {
> +				tmp = vma;
> +				while (tmp && tmp->vm_start < end) {
> +					if (tmp->vm_flags & VM_LOCKED) {
> +						mm->locked_vm -= vma_pages(tmp);
> +						munlock_vma_pages_all(tmp);
> +					}
> +					tmp = tmp->vm_next;
> +				}
> +			}
> +			detach_vmas_to_be_unmapped(mm, vma, prev, end);
> +			unmap_region(mm, vma, prev, start, end);
> +			remove_vma_list(mm, vma);
> +		} else
> +			/* When mapping size < LARGE_MAP_THRESH */
> +			ret = do_munmap(mm, start, len, uf);
> +	}
> +
> +out:
> +	up_write(&mm->mmap_sem);
> +	return ret;
> +}
> +
>  /* Munmap is split into 2 main parts -- this part which finds
>   * what needs doing, and the areas themselves, which do the
>   * work.  This now handles partial unmappings.
> @@ -2829,6 +2951,17 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>  	return 0;
>  }
>  
> +static int vm_munmap_zap_early(unsigned long start, size_t len)
> +{
> +	int ret;
> +	struct mm_struct *mm = current->mm;
> +	LIST_HEAD(uf);
> +
> +	ret = do_munmap_zap_early(mm, start, len, &uf);
> +	userfaultfd_unmap_complete(mm, &uf);
> +	return ret;
> +}
> +
>  int vm_munmap(unsigned long start, size_t len)
>  {
>  	int ret;
> @@ -2848,10 +2981,9 @@ int vm_munmap(unsigned long start, size_t len)
>  SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
>  {
>  	profile_munmap(addr);
> -	return vm_munmap(addr, len);
> +	return vm_munmap_zap_early(addr, len);
>  }
>  
> -
>  /*
>   * Emulation of deprecated remap_file_pages() syscall.
>   */
> -- 
> 1.8.3.1
