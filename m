Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FEBEC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:00:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CB9420818
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:00:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CB9420818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECDB38E00E1; Wed,  6 Feb 2019 13:00:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E87948E00D1; Wed,  6 Feb 2019 13:00:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF4928E00E1; Wed,  6 Feb 2019 13:00:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 849E18E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 13:00:03 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id g9so5773851pfe.7
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 10:00:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=RXBW1DWRMZIUr9A+lZvRZCrW1Nuhf8GWt3nfO6WGsWI=;
        b=i6FXQuPxio9XUQ+l4+HkBZ0OVhpoTzOdQq/qUXJD6LOvVcnXyCWeuKZnKzEHHe1XPw
         nX27IgQbwrTI5NAciuFY3K54BeK81+KZ8TvXmU3XhJ9h03CDCtbJ8dKOivpX/sRyf0gk
         kxxAMkYf02jr3dyE63vbyCBCJ8RQ0atJGEBt04WyrCmNxIjpeYfL8oOstJzJV0x/2Lra
         fRcy/zZizXyNdeEpJd41X0j1px7+9FgoAKD4H74I6h0/3o2URW9/3UXxR8NViusIXI/A
         Am6LownGpO270Pw+yR2Ewi0hIkaXLGR+EDmpRHFTol43Nl6SAhSDzcselFeV3EZ1W6R3
         82Og==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAuac43i0auNY7AvwtZ2qXil9xzY7Z9tKtxBfrx5zzpd/NYiBrzT3
	uJ4elmeTUUt22OzXw2aKrwI6IXqkeW5BHSpkJuTIC/4LgjpBDSb/41yKJ/OBljaZRpW+rwiYK2/
	JcjJ2tENJq8n13MnBcpVnv5NdXVn/H3Osd/7/JOyhRqA4tv4sKx+LXd1tNRbVMVk=
X-Received: by 2002:a63:1647:: with SMTP id 7mr2356283pgw.53.1549476003135;
        Wed, 06 Feb 2019 10:00:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibhn9RnYtIk4ICcVROnzI5SPW3uPCuIZusdRcqYmYYx+2+lyl2d/bDuqKwOW8ClUYU4qUd1
X-Received: by 2002:a63:1647:: with SMTP id 7mr2356157pgw.53.1549476001247;
        Wed, 06 Feb 2019 10:00:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549476001; cv=none;
        d=google.com; s=arc-20160816;
        b=bYqaUlzout1a83b4PE9WLzwdZL6jScdhP9iPQa6dObCEE8AsVbi5uehv2inKI6ow+E
         FF34mKNMLIZUKe1nfZgeq0+E4ZsAjEkgGTTV7+iZO+C+FhcjaqBKo87ceIJqLkuzoo/5
         ekyom3wr8LVC9RAaVnQRYqyGxWku2u1sZtvhOXMb/iOdb3PbHhikwpthaGtw9waIppno
         uyiaIqiYGIrchJe15CY0u7rRt3qXpRQEKDb9cXIgka3Lk12McPnvIo3B9nlhy7+azpYo
         PKA/r+VrYdLzu2x2aK5ucuCZNl5ypPhp/j+HaM+hna6lzb+LdtJSKw0IeHYOOsFDsRf+
         rtmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=RXBW1DWRMZIUr9A+lZvRZCrW1Nuhf8GWt3nfO6WGsWI=;
        b=d4e4suKcLU1I3q4JJfiUk2eOGG6F73vAdiEnpvGUUmX75T0ldlZbzxVJSrzJjWRWqB
         Pc7ClrvMHZNYUxxxcY2Lp00qOblkxscJAcgVpvJDOrkqQvaMCglLt5QYKLfkUVzQpVVc
         bA1AcDTUGpUdP7d0sxncCGckr/hMFI0Vn9XacEUGdVFNTxERPiv4QNiKd6x+OfUTUzCD
         Y/e82MXl2nOv+9rU9acbegOimpLj9F1vz8YTa2muG5yAlHEhSZDuhpA8FSe2Ea9v6LME
         Rm9eaeluVk8oMzkM8BpiGkfm2jm9KF4xZDIKrZX9hFRy8w/kky6yD+5y793EpiyLIe0Y
         NlZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id p11si6350101plk.191.2019.02.06.10.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 10:00:01 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Wed, 06 Feb 2019 18:59:58 +0100
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Wed, 06 Feb 2019 17:59:38 +0000
From: Davidlohr Bueso <dave@stgolabs.net>
To: jgg@ziepe.ca,
	akpm@linux-foundation.org
Cc: dledford@redhat.com,
	jgg@mellanox.com,
	jack@suse.cz,
	willy@infradead.org,
	ira.weiny@intel.com,
	linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	dave@stgolabs.net,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 1/6] mm: make mm->pinned_vm an atomic64 counter
Date: Wed,  6 Feb 2019 09:59:15 -0800
Message-Id: <20190206175920.31082-2-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190206175920.31082-1-dave@stgolabs.net>
References: <20190206175920.31082-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Taking a sleeping lock to _only_ increment a variable is quite the
overkill, and pretty much all users do this. Furthermore, some drivers
(ie: infiniband and scif) that need pinned semantics can go to quite
some trouble to actually delay via workqueue (un)accounting for pinned
pages when not possible to acquire it.

By making the counter atomic we no longer need to hold the mmap_sem
and can simply some code around it for pinned_vm users. The counter
is 64-bit such that we need not worry about overflows such as rdma
user input controlled from userspace.

Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: Christoph Lameter <cl@linux.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/infiniband/core/umem.c             | 12 ++++++------
 drivers/infiniband/hw/hfi1/user_pages.c    |  6 +++---
 drivers/infiniband/hw/qib/qib_user_pages.c |  4 ++--
 drivers/infiniband/hw/usnic/usnic_uiom.c   |  8 ++++----
 drivers/misc/mic/scif/scif_rma.c           |  6 +++---
 fs/proc/task_mmu.c                         |  2 +-
 include/linux/mm_types.h                   |  2 +-
 kernel/events/core.c                       |  8 ++++----
 kernel/fork.c                              |  2 +-
 mm/debug.c                                 |  5 +++--
 10 files changed, 28 insertions(+), 27 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 1efe0a74e06b..678abe1afcba 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -166,13 +166,13 @@ struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
 	down_write(&mm->mmap_sem);
-	if (check_add_overflow(mm->pinned_vm, npages, &new_pinned) ||
-	    (new_pinned > lock_limit && !capable(CAP_IPC_LOCK))) {
+	new_pinned = atomic64_read(&mm->pinned_vm) + npages;
+	if (new_pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
 		up_write(&mm->mmap_sem);
 		ret = -ENOMEM;
 		goto out;
 	}
-	mm->pinned_vm = new_pinned;
+	atomic64_set(&mm->pinned_vm, new_pinned);
 	up_write(&mm->mmap_sem);
 
 	cur_base = addr & PAGE_MASK;
@@ -234,7 +234,7 @@ struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
 	__ib_umem_release(context->device, umem, 0);
 vma:
 	down_write(&mm->mmap_sem);
-	mm->pinned_vm -= ib_umem_num_pages(umem);
+	atomic64_sub(ib_umem_num_pages(umem), &mm->pinned_vm);
 	up_write(&mm->mmap_sem);
 out:
 	if (vma_list)
@@ -263,7 +263,7 @@ static void ib_umem_release_defer(struct work_struct *work)
 	struct ib_umem *umem = container_of(work, struct ib_umem, work);
 
 	down_write(&umem->owning_mm->mmap_sem);
-	umem->owning_mm->pinned_vm -= ib_umem_num_pages(umem);
+	atomic64_sub(ib_umem_num_pages(umem), &umem->owning_mm->pinned_vm);
 	up_write(&umem->owning_mm->mmap_sem);
 
 	__ib_umem_release_tail(umem);
@@ -302,7 +302,7 @@ void ib_umem_release(struct ib_umem *umem)
 	} else {
 		down_write(&umem->owning_mm->mmap_sem);
 	}
-	umem->owning_mm->pinned_vm -= ib_umem_num_pages(umem);
+	atomic64_sub(ib_umem_num_pages(umem), &umem->owning_mm->pinned_vm);
 	up_write(&umem->owning_mm->mmap_sem);
 
 	__ib_umem_release_tail(umem);
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index e341e6dcc388..40a6e434190f 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -92,7 +92,7 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 	size = DIV_ROUND_UP(size, PAGE_SIZE);
 
 	down_read(&mm->mmap_sem);
-	pinned = mm->pinned_vm;
+	pinned = atomic64_read(&mm->pinned_vm);
 	up_read(&mm->mmap_sem);
 
 	/* First, check the absolute limit against all pinned pages. */
@@ -112,7 +112,7 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 		return ret;
 
 	down_write(&mm->mmap_sem);
-	mm->pinned_vm += ret;
+	atomic64_add(ret, &mm->pinned_vm);
 	up_write(&mm->mmap_sem);
 
 	return ret;
@@ -131,7 +131,7 @@ void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 
 	if (mm) { /* during close after signal, mm can be NULL */
 		down_write(&mm->mmap_sem);
-		mm->pinned_vm -= npages;
+		atomic64_sub(npages, &mm->pinned_vm);
 		up_write(&mm->mmap_sem);
 	}
 }
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 075f09fb7ce3..c6c81022d313 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -75,7 +75,7 @@ static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
 			goto bail_release;
 	}
 
-	current->mm->pinned_vm += num_pages;
+	atomic64_add(num_pages, &current->mm->pinned_vm);
 
 	ret = 0;
 	goto bail;
@@ -156,7 +156,7 @@ void qib_release_user_pages(struct page **p, size_t num_pages)
 	__qib_release_user_pages(p, num_pages, 1);
 
 	if (current->mm) {
-		current->mm->pinned_vm -= num_pages;
+		atomic64_sub(num_pages, &current->mm->pinned_vm);
 		up_write(&current->mm->mmap_sem);
 	}
 }
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index ce01a59fccc4..854436a2b437 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -129,7 +129,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	uiomr->owning_mm = mm = current->mm;
 	down_write(&mm->mmap_sem);
 
-	locked = npages + current->mm->pinned_vm;
+	locked = npages + atomic64_read(&current->mm->pinned_vm);
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
 	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
@@ -187,7 +187,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	if (ret < 0)
 		usnic_uiom_put_pages(chunk_list, 0);
 	else {
-		mm->pinned_vm = locked;
+		atomic64_set(&mm->pinned_vm, locked);
 		mmgrab(uiomr->owning_mm);
 	}
 
@@ -441,7 +441,7 @@ static void usnic_uiom_release_defer(struct work_struct *work)
 		container_of(work, struct usnic_uiom_reg, work);
 
 	down_write(&uiomr->owning_mm->mmap_sem);
-	uiomr->owning_mm->pinned_vm -= usnic_uiom_num_pages(uiomr);
+	atomic64_sub(usnic_uiom_num_pages(uiomr), &uiomr->owning_mm->pinned_vm);
 	up_write(&uiomr->owning_mm->mmap_sem);
 
 	__usnic_uiom_release_tail(uiomr);
@@ -469,7 +469,7 @@ void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr,
 	} else {
 		down_write(&uiomr->owning_mm->mmap_sem);
 	}
-	uiomr->owning_mm->pinned_vm -= usnic_uiom_num_pages(uiomr);
+	atomic64_sub(usnic_uiom_num_pages(uiomr), &uiomr->owning_mm->pinned_vm);
 	up_write(&uiomr->owning_mm->mmap_sem);
 
 	__usnic_uiom_release_tail(uiomr);
diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index 749321eb91ae..2448368f181e 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -285,7 +285,7 @@ __scif_dec_pinned_vm_lock(struct mm_struct *mm,
 	} else {
 		down_write(&mm->mmap_sem);
 	}
-	mm->pinned_vm -= nr_pages;
+	atomic64_sub(nr_pages, &mm->pinned_vm);
 	up_write(&mm->mmap_sem);
 	return 0;
 }
@@ -299,7 +299,7 @@ static inline int __scif_check_inc_pinned_vm(struct mm_struct *mm,
 		return 0;
 
 	locked = nr_pages;
-	locked += mm->pinned_vm;
+	locked += atomic64_read(&mm->pinned_vm);
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
 		dev_err(scif_info.mdev.this_device,
@@ -307,7 +307,7 @@ static inline int __scif_check_inc_pinned_vm(struct mm_struct *mm,
 			locked, lock_limit);
 		return -ENOMEM;
 	}
-	mm->pinned_vm = locked;
+	atomic64_set(&mm->pinned_vm, locked);
 	return 0;
 }
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f0ec9edab2f3..d2902962244d 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -59,7 +59,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	SEQ_PUT_DEC("VmPeak:\t", hiwater_vm);
 	SEQ_PUT_DEC(" kB\nVmSize:\t", total_vm);
 	SEQ_PUT_DEC(" kB\nVmLck:\t", mm->locked_vm);
-	SEQ_PUT_DEC(" kB\nVmPin:\t", mm->pinned_vm);
+	SEQ_PUT_DEC(" kB\nVmPin:\t", atomic64_read(&mm->pinned_vm));
 	SEQ_PUT_DEC(" kB\nVmHWM:\t", hiwater_rss);
 	SEQ_PUT_DEC(" kB\nVmRSS:\t", total_rss);
 	SEQ_PUT_DEC(" kB\nRssAnon:\t", anon);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2c471a2c43fa..acea2ea2d6c4 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -405,7 +405,7 @@ struct mm_struct {
 
 		unsigned long total_vm;	   /* Total pages mapped */
 		unsigned long locked_vm;   /* Pages that have PG_mlocked set */
-		unsigned long pinned_vm;   /* Refcount permanently increased */
+		atomic64_t    pinned_vm;   /* Refcount permanently increased */
 		unsigned long data_vm;	   /* VM_WRITE & ~VM_SHARED & ~VM_STACK */
 		unsigned long exec_vm;	   /* VM_EXEC & ~VM_WRITE & ~VM_STACK */
 		unsigned long stack_vm;	   /* VM_STACK */
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 3cd13a30f732..8df0b77a4687 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5459,7 +5459,7 @@ static void perf_mmap_close(struct vm_area_struct *vma)
 
 		/* now it's safe to free the pages */
 		atomic_long_sub(rb->aux_nr_pages, &mmap_user->locked_vm);
-		vma->vm_mm->pinned_vm -= rb->aux_mmap_locked;
+		atomic64_sub(rb->aux_mmap_locked, &vma->vm_mm->pinned_vm);
 
 		/* this has to be the last one */
 		rb_free_aux(rb);
@@ -5532,7 +5532,7 @@ static void perf_mmap_close(struct vm_area_struct *vma)
 	 */
 
 	atomic_long_sub((size >> PAGE_SHIFT) + 1, &mmap_user->locked_vm);
-	vma->vm_mm->pinned_vm -= mmap_locked;
+	atomic64_sub(mmap_locked, &vma->vm_mm->pinned_vm);
 	free_uid(mmap_user);
 
 out_put:
@@ -5680,7 +5680,7 @@ static int perf_mmap(struct file *file, struct vm_area_struct *vma)
 
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
-	locked = vma->vm_mm->pinned_vm + extra;
+	locked = atomic64_read(&vma->vm_mm->pinned_vm) + extra;
 
 	if ((locked > lock_limit) && perf_paranoid_tracepoint_raw() &&
 		!capable(CAP_IPC_LOCK)) {
@@ -5721,7 +5721,7 @@ static int perf_mmap(struct file *file, struct vm_area_struct *vma)
 unlock:
 	if (!ret) {
 		atomic_long_add(user_extra, &user->locked_vm);
-		vma->vm_mm->pinned_vm += extra;
+		atomic64_add(extra, &vma->vm_mm->pinned_vm);
 
 		atomic_inc(&event->mmap_count);
 	} else if (rb) {
diff --git a/kernel/fork.c b/kernel/fork.c
index a60459947f18..fe4a051a8d15 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -980,7 +980,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm_pgtables_bytes_init(mm);
 	mm->map_count = 0;
 	mm->locked_vm = 0;
-	mm->pinned_vm = 0;
+	atomic64_set(&mm->pinned_vm, 0);
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
 	spin_lock_init(&mm->arg_lock);
diff --git a/mm/debug.c b/mm/debug.c
index 0abb987dad9b..7d13941a72f9 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -135,7 +135,7 @@ void dump_mm(const struct mm_struct *mm)
 		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
 		"pgd %px mm_users %d mm_count %d pgtables_bytes %lu map_count %d\n"
 		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
-		"pinned_vm %lx data_vm %lx exec_vm %lx stack_vm %lx\n"
+		"pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
 		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
 		"start_brk %lx brk %lx start_stack %lx\n"
 		"arg_start %lx arg_end %lx env_start %lx env_end %lx\n"
@@ -166,7 +166,8 @@ void dump_mm(const struct mm_struct *mm)
 		mm_pgtables_bytes(mm),
 		mm->map_count,
 		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm,
-		mm->pinned_vm, mm->data_vm, mm->exec_vm, mm->stack_vm,
+		atomic64_read(&mm->pinned_vm),
+		mm->data_vm, mm->exec_vm, mm->stack_vm,
 		mm->start_code, mm->end_code, mm->start_data, mm->end_data,
 		mm->start_brk, mm->brk, mm->start_stack,
 		mm->arg_start, mm->arg_end, mm->env_start, mm->env_end,
-- 
2.16.4

