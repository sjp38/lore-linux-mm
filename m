Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8FEE36B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 19:14:19 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB10EGo3009517
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 09:14:17 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C618D45DE4F
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:14:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 867C745DE52
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:14:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F6B81DB8012
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:14:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DDF44E78004
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:14:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] mlock: release mmap_sem every 256 faulted pages
In-Reply-To: <20101123050052.GA24039@google.com>
References: <20101123050052.GA24039@google.com>
Message-Id: <20101130204820.8325.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Dec 2010 09:14:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@kernel.dk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi

Sorry fot the delay. I reviewed this one.


> Hi,
> 
> I'd like to sollicit comments on this proposal:
> 
> Currently mlock() holds mmap_sem in exclusive mode while the pages get
> faulted in. In the case of a large mlock, this can potentially take a
> very long time.
> 
> I propose that mlock() could release mmap_sem after the VM_LOCKED bits
> have been set in all appropriate VMAs. Then a second pass could be done
> to actually mlock the pages, in small batches, never holding mmap_sem
> for longer than it takes to process one single batch. We need to recheck
> the vma flags whenever we re-acquire mmap_sem, but this is not difficult.
> 
> This is only an RFC rather than an actual submission, as I think this
> could / should be completed to handle more than the mlock() and
> mlockall() cases (there are many call sites to mlock_vma_pages_range()
> that should ideally be converted as well), and maybe use the fault retry
> mechanism to drop mmap_sem when blocking on disk access rather than
> using an arbitrary page batch size.
> 
> Patch is against v2.6.36, but should apply to linus tree too.
> 
> ------------------------------- 8< -----------------------------
> 
> Let mlock / mlockall release mmap_sem after the vmas have been marked
> as VM_LOCKED. Then, mark the vmas as mlocked in small batches.
> For every batch, we need to grab mmap_sem in read mode, check that the
> vma has not been munlocked, and mlock the pages.
> 
> In the case where a vma has been munlocked before mlock completes,
> pages that were already marked as PageMlocked() are handled by the
> munlock() call, and mlock() is careful to not mark new page batches
> as PageMlocked() after the munlock() call has cleared the VM_LOCKED
> vma flags. So, the end result will be identical to what'd happen if
> munlock() had executed after the mlock() call.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

Looks good.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


some nit.


> ---
>  mm/mlock.c |   79 +++++++++++++++++++++++++++++++++++++++++++++++------------
>  1 files changed, 63 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index b70919c..0aa4df5 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -373,17 +373,11 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
>  	int lock = newflags & VM_LOCKED;
>  
>  	if (newflags == vma->vm_flags ||
> -			(vma->vm_flags & (VM_IO | VM_PFNMAP)))
> +	    (vma->vm_flags & (VM_IO | VM_PFNMAP |
> +			      VM_DONTEXPAND | VM_RESERVED)) ||
> +	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current))
>  		goto out;	/* don't set VM_LOCKED,  don't count */
>  
> -	if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
> -			is_vm_hugetlb_page(vma) ||
> -			vma == get_gate_vma(current)) {
> -		if (lock)
> -			make_pages_present(start, end);
> -		goto out;	/* don't set VM_LOCKED,  don't count */
> -	}
> -
>  	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
>  	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
>  			  vma->vm_file, pgoff, vma_policy(vma));
> @@ -419,14 +413,10 @@ success:
>  	 * set VM_LOCKED, __mlock_vma_pages_range will bring it back.
>  	 */
>  
> -	if (lock) {
> +	if (lock)
>  		vma->vm_flags = newflags;
> -		ret = __mlock_vma_pages_range(vma, start, end);
> -		if (ret < 0)
> -			ret = __mlock_posix_error_return(ret);
> -	} else {
> +	else
>  		munlock_vma_pages_range(vma, start, end);
> -	}
>  
>  out:
>  	*prev = vma;
> @@ -439,7 +429,8 @@ static int do_mlock(unsigned long start, size_t len, int on)
>  	struct vm_area_struct * vma, * prev;
>  	int error;
>  
> -	len = PAGE_ALIGN(len);
> +	VM_BUG_ON(start & ~PAGE_MASK);
> +	VM_BUG_ON(len != PAGE_ALIGN(len));

good cleanup. but please separate this. I think this change is unrelated 256 batch concept.


>  	end = start + len;
>  	if (end < start)
>  		return -EINVAL;
> @@ -482,6 +473,58 @@ static int do_mlock(unsigned long start, size_t len, int on)
>  	return error;
>  }
>  
> +static int do_mlock_pages(unsigned long start, size_t len)
> +{
> +	struct mm_struct *mm = current->mm;
> +	unsigned long end, nstart, nend, nfault;
> +	struct vm_area_struct *vma;
> +	int error = 0;
> +
> +	VM_BUG_ON(start & ~PAGE_MASK);
> +	VM_BUG_ON(len != PAGE_ALIGN(len));
> +	end = start + len;
> +
> +	for (nstart = start; nstart < end; nstart = nend) {
> +		down_read(&mm->mmap_sem);
> +		nend = end;
> +		vma = find_vma_intersection(mm, nstart, nend);
> +		if (!vma)
> +			goto up;

every exception check branch need comments. 


> +		if (vma->vm_end < nend)
> +			nend = vma->vm_end;
> +		if (vma->vm_flags & (VM_IO | VM_PFNMAP))
> +			goto up;

vm_flags should be checked at first. because we don't need nend adjustment.



> +		if (nstart < vma->vm_start)
> +			nstart = vma->vm_start;
> +
> +		/*
> +		 * Limit batch size to 256 pages in order to reduce
> +		 * mmap_sem hold time.
> +		 */
> +		nfault = nstart + 256 * PAGE_SIZE;

We don't need nfault variable. maybe.


> +
> +		/*
> +		 * Now fault in a batch of pages. We need to check the vma
> +		 * flags again, as we've not been holding mmap_sem.
> +		 */
> +		if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
> +		    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current)) {
> +			if (nfault < nend)
> +				nend = nfault;
> +			make_pages_present(nstart, nend);
> +		} else if (vma->vm_flags & VM_LOCKED) {
> +			if (nfault < nend)
> +				nend = nfault;

Both branch has the same "nfault < nend" check. We can unify it.


> +			error = __mlock_vma_pages_range(vma, nstart, nend);
> +		}
> +	up:
> +		up_read(&mm->mmap_sem);
> +		if (error)
> +			return __mlock_posix_error_return(error);

Now, __mlock_posix_error_return() can be moved into __mlock_vma_pages_range().


> +	}
> +	return 0;
> +}
> +
>  SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
>  {
>  	unsigned long locked;
> @@ -507,6 +550,8 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
>  	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
>  		error = do_mlock(start, len, 1);
>  	up_write(&current->mm->mmap_sem);
> +	if (!error)
> +		error = do_mlock_pages(start, len);
>  	return error;
>  }
>  
> @@ -571,6 +616,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
>  	    capable(CAP_IPC_LOCK))
>  		ret = do_mlockall(flags);
>  	up_write(&current->mm->mmap_sem);
> +	if (!ret && (flags & MCL_CURRENT))
> +		ret = do_mlock_pages(0, TASK_SIZE);
>  out:
>  	return ret;
>  }


So, I'm waiting your testcase.
below is for explanation code. but you can ignore this. I don't think
your patch doesn't work.


Thanks.



(BFrom e4253f161d9c17ba67cd9a445c8b8f556f87ad8c Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 25 Dec 2010 04:12:21 +0900
Subject: [PATCH] cleanup

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mlock.c |   67 ++++++++++++++++++++++++++++++++---------------------------
 1 files changed, 36 insertions(+), 31 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 0aa4df5..e44b7ac 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -142,6 +142,18 @@ static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long add
 		!vma_stack_continue(vma->vm_prev, addr);
 }
 
+/*
+ * convert get_user_pages() return value to posix mlock() error
+ */
+static int __mlock_posix_error_return(long retval)
+{
+	if (retval == -EFAULT)
+		retval = -ENOMEM;
+	else if (retval == -ENOMEM)
+		retval = -EAGAIN;
+	return retval;
+}
+
 /**
  * __mlock_vma_pages_range() -  mlock a range of pages in the vma.
  * @vma:   target vma
@@ -236,19 +248,7 @@ static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 		ret = 0;
 	}
 
-	return ret;	/* 0 or negative error code */
-}
-
-/*
- * convert get_user_pages() return value to posix mlock() error
- */
-static int __mlock_posix_error_return(long retval)
-{
-	if (retval == -EFAULT)
-		retval = -ENOMEM;
-	else if (retval == -ENOMEM)
-		retval = -EAGAIN;
-	return retval;
+	return __mlock_posix_error_return(ret);
 }
 
 /**
@@ -476,53 +476,58 @@ static int do_mlock(unsigned long start, size_t len, int on)
 static int do_mlock_pages(unsigned long start, size_t len)
 {
 	struct mm_struct *mm = current->mm;
-	unsigned long end, nstart, nend, nfault;
+	unsigned long end, nstart, nend;
 	struct vm_area_struct *vma;
 	int error = 0;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(len != PAGE_ALIGN(len));
-	end = start + len;
+	end = nend = start + len;
 
-	for (nstart = start; nstart < end; nstart = nend) {
+	for (nstart = start; nstart < end; nstart = nend, nend = end) {
 		down_read(&mm->mmap_sem);
-		nend = end;
 		vma = find_vma_intersection(mm, nstart, nend);
+
+		/* VMA gone. We don't need anything. */
 		if (!vma)
 			goto up;
-		if (vma->vm_end < nend)
+
+		/* IO mapped area can't be populated. skip it. */
+		if (vma->vm_flags & (VM_IO | VM_PFNMAP)) {
 			nend = vma->vm_end;
-		if (vma->vm_flags & (VM_IO | VM_PFNMAP))
 			goto up;
-		if (nstart < vma->vm_start)
-			nstart = vma->vm_start;
+		}
 
 		/*
 		 * Limit batch size to 256 pages in order to reduce
 		 * mmap_sem hold time.
 		 */
-		nfault = nstart + 256 * PAGE_SIZE;
+		nend = nstart + 256 * PAGE_SIZE;
+		if (nstart < vma->vm_start)
+			nstart = vma->vm_start;
+		if (vma->vm_end < nend)
+			nend = vma->vm_end;
 
 		/*
 		 * Now fault in a batch of pages. We need to check the vma
 		 * flags again, as we've not been holding mmap_sem.
 		 */
 		if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
-		    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current)) {
-			if (nfault < nend)
-				nend = nfault;
+		    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current))
+			/* The vma has special attributes. Don't use PG_mlocked. */
 			make_pages_present(nstart, nend);
-		} else if (vma->vm_flags & VM_LOCKED) {
-			if (nfault < nend)
-				nend = nfault;
+		else if (vma->vm_flags & VM_LOCKED)
 			error = __mlock_vma_pages_range(vma, nstart, nend);
-		}
+		else
+			/* VM_LOCKED has been lost. we can skip this vma. */
+			nend = vma->vm_end;
 	up:
 		up_read(&mm->mmap_sem);
 		if (error)
-			return __mlock_posix_error_return(error);
+			break;
 	}
-	return 0;
+
+	return error;
 }
 
 SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
