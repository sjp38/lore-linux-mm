Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 37BE96B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 13:51:54 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so2622642pab.18
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 10:51:53 -0700 (PDT)
Received: from mail-pa0-x249.google.com (mail-pa0-x249.google.com [2607:f8b0:400e:c03::249])
        by mx.google.com with ESMTPS id v9si35997041pdp.136.2014.09.17.10.51.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 10:51:53 -0700 (PDT)
Received: by mail-pa0-f73.google.com with SMTP id kx10so561926pab.2
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 10:51:53 -0700 (PDT)
From: Andres Lagar-Cavilla <andreslc@google.com>
Subject: [PATCH v2] kvm: Faults which trigger IO release the mmap_sem
Date: Wed, 17 Sep 2014 10:51:48 -0700
Message-Id: <1410976308-7683-1-git-send-email-andreslc@google.com>
In-Reply-To: <1410811885-17267-1-git-send-email-andreslc@google.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andres Lagar-Cavilla <andreslc@google.com>

When KVM handles a tdp fault it uses FOLL_NOWAIT. If the guest memory
has been swapped out or is behind a filemap, this will trigger async
readahead and return immediately. The rationale is that KVM will kick
back the guest with an "async page fault" and allow for some other
guest process to take over.

If async PFs are enabled the fault is retried asap from an async
workqueue. If not, it's retried immediately in the same code path. In
either case the retry will not relinquish the mmap semaphore and will
block on the IO. This is a bad thing, as other mmap semaphore users
now stall as a function of swap or filemap latency.

This patch ensures both the regular and async PF path re-enter the
fault allowing for the mmap semaphore to be relinquished in the case
of IO wait.

Reviewed-by: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>

---
v1 -> v2

* WARN_ON_ONCE -> VM_WARN_ON_ONCE
* pagep =3D=3D NULL skips the final retry
* kvm_gup_retry -> kvm_gup_io
* Comment updates throughout
---
 include/linux/kvm_host.h | 11 +++++++++++
 include/linux/mm.h       |  1 +
 mm/gup.c                 |  4 ++++
 virt/kvm/async_pf.c      |  4 +---
 virt/kvm/kvm_main.c      | 49 ++++++++++++++++++++++++++++++++++++++++++=
+++---
 5 files changed, 63 insertions(+), 6 deletions(-)

diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 3addcbc..4c1991b 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -198,6 +198,17 @@ int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t =
gva, unsigned long hva,
 int kvm_async_pf_wakeup_all(struct kvm_vcpu *vcpu);
 #endif
=20
+/*
+ * Carry out a gup that requires IO. Allow the mm to relinquish the mmap
+ * semaphore if the filemap/swap has to wait on a page lock. pagep =3D=3D=
 NULL
+ * controls whether we retry the gup one more time to completion in that=
 case.
+ * Typically this is called after a FAULT_FLAG_RETRY_NOWAIT in the main =
tdp
+ * handler.
+ */
+int kvm_get_user_page_io(struct task_struct *tsk, struct mm_struct *mm,
+			 unsigned long addr, bool write_fault,
+			 struct page **pagep);
+
 enum {
 	OUTSIDE_GUEST_MODE,
 	IN_GUEST_MODE,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ebc5f90..13e585f7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2011,6 +2011,7 @@ static inline struct page *follow_page(struct vm_ar=
ea_struct *vma,
 #define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
 #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
 #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry=
 */
+#define FOLL_TRIED	0x800	/* a retry, previous pass started an IO */
=20
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
diff --git a/mm/gup.c b/mm/gup.c
index 91d044b..af7ea3e 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -281,6 +281,10 @@ static int faultin_page(struct task_struct *tsk, str=
uct vm_area_struct *vma,
 		fault_flags |=3D FAULT_FLAG_ALLOW_RETRY;
 	if (*flags & FOLL_NOWAIT)
 		fault_flags |=3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
+	if (*flags & FOLL_TRIED) {
+		VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
+		fault_flags |=3D FAULT_FLAG_TRIED;
+	}
=20
 	ret =3D handle_mm_fault(mm, vma, address, fault_flags);
 	if (ret & VM_FAULT_ERROR) {
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index d6a3d09..5ff7f7f 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -80,9 +80,7 @@ static void async_pf_execute(struct work_struct *work)
=20
 	might_sleep();
=20
-	down_read(&mm->mmap_sem);
-	get_user_pages(NULL, mm, addr, 1, 1, 0, NULL, NULL);
-	up_read(&mm->mmap_sem);
+	kvm_get_user_page_io(NULL, mm, addr, 1, NULL);
 	kvm_async_page_present_sync(vcpu, apf);
=20
 	spin_lock(&vcpu->async_pf.lock);
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 7ef6b48..fa8a565 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1115,6 +1115,43 @@ static int get_user_page_nowait(struct task_struct=
 *tsk, struct mm_struct *mm,
 	return __get_user_pages(tsk, mm, start, 1, flags, page, NULL, NULL);
 }
=20
+int kvm_get_user_page_io(struct task_struct *tsk, struct mm_struct *mm,
+			 unsigned long addr, bool write_fault,
+			 struct page **pagep)
+{
+	int npages;
+	int locked =3D 1;
+	int flags =3D FOLL_TOUCH | FOLL_HWPOISON |
+		    (pagep ? FOLL_GET : 0) |
+		    (write_fault ? FOLL_WRITE : 0);
+
+	/*
+	 * If retrying the fault, we get here *not* having allowed the filemap
+	 * to wait on the page lock. We should now allow waiting on the IO with
+	 * the mmap semaphore released.
+	 */
+	down_read(&mm->mmap_sem);
+	npages =3D __get_user_pages(tsk, mm, addr, 1, flags, pagep, NULL,
+				  &locked);
+	if (!locked) {
+		VM_BUG_ON(npages !=3D -EBUSY);
+
+		if (!pagep)
+			return 0;
+
+		/*
+		 * The previous call has now waited on the IO. Now we can
+		 * retry and complete. Pass TRIED to ensure we do not re
+		 * schedule async IO (see e.g. filemap_fault).
+		 */
+		down_read(&mm->mmap_sem);
+		npages =3D __get_user_pages(tsk, mm, addr, 1, flags | FOLL_TRIED,
+					  pagep, NULL, NULL);
+	}
+	up_read(&mm->mmap_sem);
+	return npages;
+}
+
 static inline int check_user_page_hwpoison(unsigned long addr)
 {
 	int rc, flags =3D FOLL_TOUCH | FOLL_HWPOISON | FOLL_WRITE;
@@ -1177,9 +1214,15 @@ static int hva_to_pfn_slow(unsigned long addr, boo=
l *async, bool write_fault,
 		npages =3D get_user_page_nowait(current, current->mm,
 					      addr, write_fault, page);
 		up_read(&current->mm->mmap_sem);
-	} else
-		npages =3D get_user_pages_fast(addr, 1, write_fault,
-					     page);
+	} else {
+		/*
+		 * By now we have tried gup_fast, and possibly async_pf, and we
+		 * are certainly not atomic. Time to retry the gup, allowing
+		 * mmap semaphore to be relinquished in the case of IO.
+		 */
+		npages =3D kvm_get_user_page_io(current, current->mm, addr,
+					      write_fault, page);
+	}
 	if (npages !=3D 1)
 		return npages;
=20
--=20
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
