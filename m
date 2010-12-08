Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 135066B0089
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 18:27:53 -0500 (EST)
Date: Wed, 8 Dec 2010 15:27:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/6] mlock: only hold mmap_sem in shared mode when
 faulting in pages
Message-Id: <20101208152740.ac449c3d.akpm@linux-foundation.org>
In-Reply-To: <1291335412-16231-2-git-send-email-walken@google.com>
References: <1291335412-16231-1-git-send-email-walken@google.com>
	<1291335412-16231-2-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Currently mlock() holds mmap_sem in exclusive mode while the pages get
> faulted in. In the case of a large mlock, this can potentially take a
> very long time, during which various commands such as 'ps auxw' will
> block. This makes sysadmins unhappy:
>
> real    14m36.232s
> user    0m0.003s
> sys     0m0.015s
>(output from 'time ps auxw' while a 20GB file was being mlocked without
> being previously preloaded into page cache)

The kernel holds down_write(mmap_sem) for 14m36s?

geeze you guys are picky - that's less than a quarter hour!

On Thu,  2 Dec 2010 16:16:47 -0800
Michel Lespinasse <walken@google.com> wrote:

> Before this change, mlock() holds mmap_sem in exclusive mode while the
> pages get faulted in. In the case of a large mlock, this can potentially
> take a very long time. Various things will block while mmap_sem is held,
> including 'ps auxw'. This can make sysadmins angry.
> 
> I propose that mlock() could release mmap_sem after the VM_LOCKED bits
> have been set in all appropriate VMAs. Then a second pass could be done
> to actually mlock the pages with mmap_sem held for reads only. We need
> to recheck the vma flags after we re-acquire mmap_sem, but this is easy.
> 
> In the case where a vma has been munlocked before mlock completes,
> pages that were already marked as PageMlocked() are handled by the
> munlock() call, and mlock() is careful to not mark new page batches
> as PageMlocked() after the munlock() call has cleared the VM_LOCKED
> vma flags. So, the end result will be identical to what'd happen if
> munlock() had executed after the mlock() call.
> 
> In a later change, I will allow the second pass to release mmap_sem when
> blocking on disk accesses or when it is otherwise contended, so that
> it won't be held for long periods of time even in shared mode.
> 
> ...
>
> +static int do_mlock_pages(unsigned long start, size_t len)
> +{
> +	struct mm_struct *mm = current->mm;
> +	unsigned long end, nstart, nend;
> +	struct vm_area_struct *vma = NULL;
> +	int ret = 0;
> +
> +	VM_BUG_ON(start & ~PAGE_MASK);
> +	VM_BUG_ON(len != PAGE_ALIGN(len));
> +	end = start + len;
> +
> +	down_read(&mm->mmap_sem);
> +	for (nstart = start; nstart < end; nstart = nend) {
> +		/*
> +		 * We want to fault in pages for [nstart; end) address range.
> +		 * Find first corresponding VMA.
> +		 */
> +		if (!vma)
> +			vma = find_vma(mm, nstart);
> +		else
> +			vma = vma->vm_next;
> +		if (!vma || vma->vm_start >= end)
> +			break;
> +		/*
> +		 * Set [nstart; nend) to intersection of desired address
> +		 * range with the first VMA. Also, skip undesirable VMA types.
> +		 */
> +		nend = min(end, vma->vm_end);
> +		if (vma->vm_flags & (VM_IO | VM_PFNMAP))
> +			continue;
> +		if (nstart < vma->vm_start)
> +			nstart = vma->vm_start;
> +		/*
> +		 * Now fault in a range of pages within the first VMA.
> +		 */
> +		if (vma->vm_flags & VM_LOCKED) {
> +			ret = __mlock_vma_pages_range(vma, nstart, nend);
> +			if (ret) {
> +				ret = __mlock_posix_error_return(ret);
> +				break;
> +			}
> +		} else
> +			make_pages_present(nstart, nend);
> +	}
> +	up_read(&mm->mmap_sem);
> +	return ret;	/* 0 or negative error code */
> +}

Am I correct in believing that we'll still hold down_read(mmap_sem) for
a quarter hour?

If so, that's still pretty obnoxious behaviour - presumably there are
workloads which will hurt like hell from that.

We don't need to hold mmap_sem at all while faulting in those pages,
do we?  We could just do

	for (addr = start, addr < end; addr += PAGE_SIZE)
		get_user(x, addr);

and voila.  If the pages are in cache and the ptes are set up then that
will be *vastly* faster than the proposed code.  If the get_user()
takes a minor fault then it'll be slower.  If it's a major fault then
the difference probably doesn't matter much.

But whatever.  Is this patchset a half-fix, and should we rather be
looking for a full-fix?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
