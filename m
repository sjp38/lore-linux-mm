Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF0836B0342
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 15:36:31 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x190so6458766qkb.5
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 12:36:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 95si8669020qkp.204.2016.11.04.12.36.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 12:36:30 -0700 (PDT)
Date: Fri, 4 Nov 2016 20:36:26 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb
 for huge page UFFDIO_COPY
Message-ID: <20161104193626.GU4611@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-16-git-send-email-aarcange@redhat.com>
 <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com>
 <c9c59023-35ee-1012-1da7-13c3aa89ba61@oracle.com>
 <31d06dc7-ea2d-4ca3-821a-f14ea69de3e9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <31d06dc7-ea2d-4ca3-821a-f14ea69de3e9@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

On Thu, Nov 03, 2016 at 12:14:15PM -0700, Mike Kravetz wrote:
> +		/* lookup dst_addr as we may have copied some pages */
> +		dst_vma = find_vma(dst_mm, dst_addr);

I put back dst_start here.

> +		if (dst_addr < dst_vma->vm_start ||
> +		    dst_addr + len - (copied * vma_hpagesize) > dst_vma->vm_end)
> +			goto out_unlock;

Actually this introduces a bug: copied * vma_hpagesize in the new
patch is wrong, copied is already in byte units. I rolled back this
one because of the dst_start commented above anyway.

> +	/*
> +	 * Validate alignment based on huge page size
> +	 */
> +	if (dst_addr & (vma_hpagesize - 1) || len & (vma_hpagesize - 1))
> +		goto out_unlock;

If the vma changes under us we an as well fail. So I moved the
alignment checks on dst_start/len before the retry loop and I added a
further WARN_ON check inside the loop on dst_addr/len-copied just in
case but that cannot trigger as we abort if the vma_hpagesize changed
(hence WARN_ON).

If we need to relax this later and handle a change of vma_hpagesize,
it'll be backwards compatible change. I don't think it's needed and
this is more strict behavior.

> +	while (src_addr < src_start + len) {
> +		pte_t dst_pteval;
> +
> +		BUG_ON(dst_addr >= dst_start + len);
> +		dst_addr &= huge_page_mask(h);

The additional mask is superflous here, it was already enforced by the
alignment checks so I turned it into a bugcheck.

This is the current status, I'm sending a full diff against the
previous submit for review of the latest updates. It's easier to
review incrementally I think.

Please test it, I updated the aa.git tree userfault branch in sync
with this.

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 063ccc7..8a0ee3ba 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -628,11 +628,11 @@ void mremap_userfaultfd_prep(struct vm_area_struct *vma,
 	}
 }
 
-void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx vm_ctx,
+void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *vm_ctx,
 				 unsigned long from, unsigned long to,
 				 unsigned long len)
 {
-	struct userfaultfd_ctx *ctx = vm_ctx.ctx;
+	struct userfaultfd_ctx *ctx = vm_ctx->ctx;
 	struct userfaultfd_wait_queue ewq;
 
 	if (!ctx)
@@ -657,6 +657,7 @@ void madvise_userfault_dontneed(struct vm_area_struct *vma,
 				struct vm_area_struct **prev,
 				unsigned long start, unsigned long end)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	struct userfaultfd_ctx *ctx;
 	struct userfaultfd_wait_queue ewq;
 
@@ -665,8 +666,9 @@ void madvise_userfault_dontneed(struct vm_area_struct *vma,
 		return;
 
 	userfaultfd_ctx_get(ctx);
+	up_read(&mm->mmap_sem);
+
 	*prev = NULL; /* We wait for ACK w/o the mmap semaphore */
-	up_read(&vma->vm_mm->mmap_sem);
 
 	msg_init(&ewq.msg);
 
@@ -676,7 +678,7 @@ void madvise_userfault_dontneed(struct vm_area_struct *vma,
 
 	userfaultfd_event_wait_completion(ctx, &ewq);
 
-	down_read(&vma->vm_mm->mmap_sem);
+	down_read(&mm->mmap_sem);
 }
 
 static int userfaultfd_release(struct inode *inode, struct file *file)
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 5caf97f..01a4e98 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -77,7 +77,7 @@ extern void dup_userfaultfd_complete(struct list_head *);
 
 extern void mremap_userfaultfd_prep(struct vm_area_struct *,
 				    struct vm_userfaultfd_ctx *);
-extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx,
+extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *,
 					unsigned long from, unsigned long to,
 					unsigned long len);
 
@@ -143,7 +143,7 @@ static inline void mremap_userfaultfd_prep(struct vm_area_struct *vma,
 {
 }
 
-static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx ctx,
+static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *ctx,
 					       unsigned long from,
 					       unsigned long to,
 					       unsigned long len)
diff --git a/mm/mremap.c b/mm/mremap.c
index 450e811..cef4967 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -592,6 +592,6 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	up_write(&current->mm->mmap_sem);
 	if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
-	mremap_userfaultfd_complete(uf, addr, new_addr, old_len);
+	mremap_userfaultfd_complete(&uf, addr, new_addr, old_len);
 	return ret;
 }
diff --git a/mm/shmem.c b/mm/shmem.c
index 578622e..5d3e8bf 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1609,7 +1609,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 			if (fault_type) {
 				*fault_type |= VM_FAULT_MAJOR;
 				count_vm_event(PGMAJFAULT);
-				mem_cgroup_count_vm_event(vma->vm_mm,
+				mem_cgroup_count_vm_event(charge_mm,
 							  PGMAJFAULT);
 			}
 			/* Here we actually start the io */
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index d47b743..e8d7a89 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -172,8 +172,10 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	 * by THP.  Since we can not reliably insert a zero page, this
 	 * feature is not supported.
 	 */
-	if (zeropage)
+	if (zeropage) {
+		up_read(&dst_mm->mmap_sem);
 		return -EINVAL;
+	}
 
 	src_addr = src_start;
 	dst_addr = dst_start;
@@ -181,6 +183,12 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	page = NULL;
 	vma_hpagesize = vma_kernel_pagesize(dst_vma);
 
+	/*
+	 * Validate alignment based on huge page size
+	 */
+	if (dst_start & (vma_hpagesize - 1) || len & (vma_hpagesize - 1))
+		goto out_unlock;
+
 retry:
 	/*
 	 * On routine entry dst_vma is set.  If we had to drop mmap_sem and
@@ -189,11 +197,15 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	err = -EINVAL;
 	if (!dst_vma) {
 		dst_vma = find_vma(dst_mm, dst_start);
-		vma_hpagesize = vma_kernel_pagesize(dst_vma);
+		if (!dst_vma || !is_vm_hugetlb_page(dst_vma))
+			goto out_unlock;
+
+		if (vma_hpagesize != vma_kernel_pagesize(dst_vma))
+			goto out_unlock;
 
 		/*
-		 * Make sure the vma is not shared, that the dst range is
-		 * both valid and fully within a single existing vma.
+		 * Make sure the vma is not shared, that the remaining dst
+		 * range is both valid and fully within a single existing vma.
 		 */
 		if (dst_vma->vm_flags & VM_SHARED)
 			goto out_unlock;
@@ -202,10 +214,8 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 			goto out_unlock;
 	}
 
-	/*
-	 * Validate alignment based on huge page size
-	 */
-	if (dst_start & (vma_hpagesize - 1) || len & (vma_hpagesize - 1))
+	if (WARN_ON(dst_addr & (vma_hpagesize - 1) ||
+		    (len - copied) & (vma_hpagesize - 1)))
 		goto out_unlock;
 
 	/*
@@ -227,7 +237,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		pte_t dst_pteval;
 
 		BUG_ON(dst_addr >= dst_start + len);
-		dst_addr &= huge_page_mask(h);
+		VM_BUG_ON(dst_addr & ~huge_page_mask(h));
 
 		/*
 		 * Serialize via hugetlb_fault_mutex
@@ -300,17 +310,13 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	return copied ? copied : err;
 }
 #else /* !CONFIG_HUGETLB_PAGE */
-static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
-					      struct vm_area_struct *dst_vma,
-					      unsigned long dst_start,
-					      unsigned long src_start,
-					      unsigned long len,
-					      bool zeropage)
-{
-	up_read(&dst_mm->mmap_sem);	/* HUGETLB not configured */
-	BUG();
-	return -EINVAL;
-}
+/* fail at build time if gcc attempts to use this */
+extern ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
+				      struct vm_area_struct *dst_vma,
+				      unsigned long dst_start,
+				      unsigned long src_start,
+				      unsigned long len,
+				      bool zeropage);
 #endif /* CONFIG_HUGETLB_PAGE */
 
 static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
@@ -360,9 +366,9 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	/*
 	 * If this is a HUGETLB vma, pass off to appropriate routine
 	 */
-	if (dst_vma->vm_flags & VM_HUGETLB)
+	if (is_vm_hugetlb_page(dst_vma))
 		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
-						src_start, len, false);
+						src_start, len, zeropage);
 
 	/*
 	 * Be strict and only allow __mcopy_atomic on userfaultfd
@@ -431,8 +437,11 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 				err = mfill_zeropage_pte(dst_mm, dst_pmd,
 							 dst_vma, dst_addr);
 		} else {
-			err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
-						     dst_addr, src_addr, &page);
+			err = -EINVAL; /* if zeropage is true return -EINVAL */
+			if (likely(!zeropage))
+				err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd,
+							     dst_vma, dst_addr,
+							     src_addr, &page);
 		}
 
 		cond_resched();
diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index fed2119..5a840a6 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -625,6 +625,86 @@ static int faulting_process(void)
 	return 0;
 }
 
+static int uffdio_zeropage(int ufd, unsigned long offset)
+{
+	struct uffdio_zeropage uffdio_zeropage;
+	int ret;
+	unsigned long has_zeropage = EXPECTED_IOCTLS & (1 << _UFFDIO_ZEROPAGE);
+
+	if (offset >= nr_pages * page_size)
+		fprintf(stderr, "unexpected offset %lu\n",
+			offset), exit(1);
+	uffdio_zeropage.range.start = (unsigned long) area_dst + offset;
+	uffdio_zeropage.range.len = page_size;
+	uffdio_zeropage.mode = 0;
+	ret = ioctl(ufd, UFFDIO_ZEROPAGE, &uffdio_zeropage);
+	if (ret) {
+		/* real retval in ufdio_zeropage.zeropage */
+		if (has_zeropage) {
+			if (uffdio_zeropage.zeropage == -EEXIST)
+				fprintf(stderr, "UFFDIO_ZEROPAGE -EEXIST\n"),
+					exit(1);
+			else
+				fprintf(stderr, "UFFDIO_ZEROPAGE error %Ld\n",
+					uffdio_zeropage.zeropage), exit(1);
+		} else {
+			if (uffdio_zeropage.zeropage != -EINVAL)
+				fprintf(stderr,
+					"UFFDIO_ZEROPAGE not -EINVAL %Ld\n",
+					uffdio_zeropage.zeropage), exit(1);
+		}
+	} else if (has_zeropage) {
+		if (uffdio_zeropage.zeropage != page_size) {
+			fprintf(stderr, "UFFDIO_ZEROPAGE unexpected %Ld\n",
+				uffdio_zeropage.zeropage), exit(1);
+		} else
+			return 1;
+	} else {
+		fprintf(stderr,
+			"UFFDIO_ZEROPAGE succeeded %Ld\n",
+			uffdio_zeropage.zeropage), exit(1);
+	}
+
+	return 0;
+}
+
+/* exercise UFFDIO_ZEROPAGE */
+static int userfaultfd_zeropage_test(void)
+{
+	struct uffdio_register uffdio_register;
+	unsigned long expected_ioctls;
+
+	printf("testing UFFDIO_ZEROPAGE: ");
+	fflush(stdout);
+
+	if (release_pages(area_dst))
+		return 1;
+
+	if (userfaultfd_open(0) < 0)
+		return 1;
+	uffdio_register.range.start = (unsigned long) area_dst;
+	uffdio_register.range.len = nr_pages * page_size;
+	uffdio_register.mode = UFFDIO_REGISTER_MODE_MISSING;
+	if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register))
+		fprintf(stderr, "register failure\n"), exit(1);
+
+	expected_ioctls = EXPECTED_IOCTLS;
+	if ((uffdio_register.ioctls & expected_ioctls) !=
+	    expected_ioctls)
+		fprintf(stderr,
+			"unexpected missing ioctl for anon memory\n"),
+			exit(1);
+
+	if (uffdio_zeropage(uffd, 0)) {
+		if (my_bcmp(area_dst, zeropage, page_size))
+			fprintf(stderr, "zeropage is not zero\n"), exit(1);
+	}
+
+	close(uffd);
+	printf("done.\n");
+	return 0;
+}
+
 static int userfaultfd_events_test(void)
 {
 	struct uffdio_register uffdio_register;
@@ -679,6 +759,7 @@ static int userfaultfd_events_test(void)
 	if (pthread_join(uffd_mon, (void **)&userfaults))
 		return 1;
 
+	close(uffd);
 	printf("userfaults: %ld\n", userfaults);
 
 	return userfaults != nr_pages;
@@ -852,7 +933,7 @@ static int userfaultfd_stress(void)
 		return err;
 
 	close(uffd);
-	return userfaultfd_events_test();
+	return userfaultfd_zeropage_test() || userfaultfd_events_test();
 }
 
 #ifndef HUGETLB_TEST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
