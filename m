Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E45FA6B0263
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:37:45 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id f199so4843325lfg.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:37:45 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id l141si3155134wmg.20.2016.07.15.03.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 03:37:44 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id o80so1747554wme.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:37:44 -0700 (PDT)
From: Topi Miettinen <toiwoton@gmail.com>
Subject: [PATCH 09/14] resource limits: track highwater mark of locked memory
Date: Fri, 15 Jul 2016 13:35:56 +0300
Message-Id: <1468578983-28229-10-git-send-email-toiwoton@gmail.com>
In-Reply-To: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Topi Miettinen <toiwoton@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Alexander Graf <agraf@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "open list:IA64 Itanium PLATFORM" <linux-ia64@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE KVM" <kvm@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE KVM FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open list:LINUX FOR POWERPC 32-BIT AND 64-BIT" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:BPF Safe dynamic programs and tools" <netdev@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Track maximum size of locked memory, to be able to configure
RLIMIT_MEMLOCK resource limits. The information is available
with taskstats and cgroupstats netlink socket.

Signed-off-by: Topi Miettinen <toiwoton@gmail.com>
---
 arch/ia64/kernel/perfmon.c                 | 1 +
 arch/powerpc/kvm/book3s_64_vio.c           | 2 ++
 arch/powerpc/mm/mmu_context_iommu.c        | 2 ++
 drivers/infiniband/core/umem.c             | 1 +
 drivers/infiniband/hw/hfi1/user_pages.c    | 2 ++
 drivers/infiniband/hw/qib/qib_user_pages.c | 2 ++
 drivers/infiniband/hw/usnic/usnic_uiom.c   | 2 ++
 drivers/misc/mic/scif/scif_rma.c           | 1 +
 drivers/vfio/vfio_iommu_spapr_tce.c        | 2 ++
 drivers/vfio/vfio_iommu_type1.c            | 5 +++++
 kernel/bpf/syscall.c                       | 8 ++++++++
 kernel/events/core.c                       | 1 +
 mm/mlock.c                                 | 8 ++++++++
 mm/mmap.c                                  | 4 ++++
 mm/mremap.c                                | 4 ++++
 15 files changed, 45 insertions(+)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 2436ad5..7c6ae72 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2341,6 +2341,7 @@ pfm_smpl_buffer_alloc(struct task_struct *task, struct file *filp, pfm_context_t
 	ctx->ctx_smpl_vaddr = (void *)vma->vm_start;
 	*(unsigned long *)user_vaddr = vma->vm_start;
 
+	task_update_resource_highwatermark(task, RLIMIT_MEMLOCK, size);
 	return 0;
 
 error:
diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
index 18cf6d1..40ea177 100644
--- a/arch/powerpc/kvm/book3s_64_vio.c
+++ b/arch/powerpc/kvm/book3s_64_vio.c
@@ -71,6 +71,8 @@ static long kvmppc_account_memlimit(unsigned long stt_pages, bool inc)
 			ret = -ENOMEM;
 		else
 			current->mm->locked_vm += stt_pages;
+		update_resource_highwatermark(RLIMIT_MEMLOCK,
+					      locked << PAGE_SHIFT);
 	} else {
 		if (WARN_ON_ONCE(stt_pages > current->mm->locked_vm))
 			stt_pages = current->mm->locked_vm;
diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index da6a216..8c6bcbf 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -46,6 +46,8 @@ static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
 			ret = -ENOMEM;
 		else
 			mm->locked_vm += npages;
+		update_resource_highwatermark(RLIMIT_MEMLOCK,
+					      locked << PAGE_SHIFT);
 	} else {
 		if (WARN_ON_ONCE(npages > mm->locked_vm))
 			npages = mm->locked_vm;
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index fe4d2e1..3c454eb 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -224,6 +224,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 
 	ret = 0;
 
+	update_resource_highwatermark(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
 out:
 	if (ret < 0) {
 		if (need_release)
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index 88e10b5f..ca55f8c 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -111,6 +111,8 @@ int hfi1_acquire_user_pages(unsigned long vaddr, size_t npages, bool writable,
 
 	down_write(&current->mm->mmap_sem);
 	current->mm->pinned_vm += ret;
+	update_resource_highwatermark(RLIMIT_MEMLOCK,
+				      current->mm->pinned_vm << PAGE_SHIFT);
 	up_write(&current->mm->mmap_sem);
 
 	return ret;
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 2d2b94f..3a103c4 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -74,6 +74,8 @@ static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
 	}
 
 	current->mm->pinned_vm += num_pages;
+	update_resource_highwatermark(RLIMIT_MEMLOCK,
+				      current->mm->pinned_vm << PAGE_SHIFT);
 
 	ret = 0;
 	goto bail;
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index a0b6ebe..6180654 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -178,6 +178,8 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 		ret = 0;
 	}
 
+	update_resource_highwatermark(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
+
 out:
 	if (ret < 0)
 		usnic_uiom_put_pages(chunk_list, 0);
diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index e0203b1..acb970a 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -306,6 +306,7 @@ static inline int __scif_check_inc_pinned_vm(struct mm_struct *mm,
 		return -ENOMEM;
 	}
 	mm->pinned_vm = locked;
+	update_resource_highwatermark(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
 	return 0;
 }
 
diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
index 80378dd..13ee9e9 100644
--- a/drivers/vfio/vfio_iommu_spapr_tce.c
+++ b/drivers/vfio/vfio_iommu_spapr_tce.c
@@ -55,6 +55,8 @@ static long try_increment_locked_vm(long npages)
 			rlimit(RLIMIT_MEMLOCK),
 			ret ? " - exceeded" : "");
 
+	update_resource_highwatermark(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
+
 	up_write(&current->mm->mmap_sem);
 
 	return ret;
diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 2ba1942..e868ae5 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -145,6 +145,8 @@ static void vfio_lock_acct_bg(struct work_struct *work)
 	mm = vwork->mm;
 	down_write(&mm->mmap_sem);
 	mm->locked_vm += vwork->npage;
+	update_resource_highwatermark(RLIMIT_MEMLOCK,
+				      current->mm->locked_vm << PAGE_SHIFT);
 	up_write(&mm->mmap_sem);
 	mmput(mm);
 	kfree(vwork);
@@ -160,6 +162,9 @@ static void vfio_lock_acct(long npage)
 
 	if (down_write_trylock(&current->mm->mmap_sem)) {
 		current->mm->locked_vm += npage;
+		update_resource_highwatermark(RLIMIT_MEMLOCK,
+					      current->mm->locked_vm <<
+					      PAGE_SHIFT);
 		up_write(&current->mm->mmap_sem);
 		return;
 	}
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 46ecce4..0efa1c3 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -76,6 +76,10 @@ static int bpf_map_charge_memlock(struct bpf_map *map)
 		return -EPERM;
 	}
 	map->user = user;
+
+	update_resource_highwatermark(RLIMIT_MEMLOCK,
+				      atomic_long_read(&user->locked_vm) <<
+				      PAGE_SHIFT);
 	return 0;
 }
 
@@ -601,6 +605,10 @@ static int bpf_prog_charge_memlock(struct bpf_prog *prog)
 		return -EPERM;
 	}
 	prog->aux->user = user;
+
+	update_resource_highwatermark(RLIMIT_MEMLOCK,
+				      atomic_long_read(&user->locked_vm) <<
+				      PAGE_SHIFT);
 	return 0;
 }
 
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 43d43a2d..4b8b143 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5096,6 +5096,7 @@ accounting:
 		if (!ret)
 			rb->aux_mmap_locked = extra;
 	}
+	update_resource_highwatermark(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
 
 unlock:
 	if (!ret) {
diff --git a/mm/mlock.c b/mm/mlock.c
index ef8dc9f..eb45857 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -648,6 +648,8 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	if (error)
 		return error;
 
+	update_resource_highwatermark(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
+
 	error = __mm_populate(start, len, 0);
 	if (error)
 		return __mlock_posix_error_return(error);
@@ -761,6 +763,9 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	if (!ret && (flags & MCL_CURRENT))
 		mm_populate(0, TASK_SIZE);
 
+	update_resource_highwatermark(RLIMIT_MEMLOCK,
+				      current->mm->total_vm << PAGE_SHIFT);
+
 	return ret;
 }
 
@@ -798,6 +803,9 @@ int user_shm_lock(size_t size, struct user_struct *user)
 	get_uid(user);
 	user->locked_shm += locked;
 	allowed = 1;
+
+	update_resource_highwatermark(RLIMIT_MEMLOCK,
+				      user->locked_shm << PAGE_SHIFT);
 out:
 	spin_unlock(&shmlock_user_lock);
 	return allowed;
diff --git a/mm/mmap.c b/mm/mmap.c
index 305c456..c37f599 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2020,6 +2020,10 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 		return -ENOMEM;
 
 	update_resource_highwatermark(RLIMIT_STACK, actual_size);
+	if (vma->vm_flags & VM_LOCKED)
+		update_resource_highwatermark(RLIMIT_MEMLOCK,
+					      (mm->locked_vm + grow) <<
+					      PAGE_SHIFT);
 
 	return 0;
 }
diff --git a/mm/mremap.c b/mm/mremap.c
index 1f157ad..f1821335 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -394,6 +394,10 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 		*p = charged;
 	}
 
+	if (vma->vm_flags & VM_LOCKED)
+		update_resource_highwatermark(RLIMIT_MEMLOCK,
+					      (mm->locked_vm << PAGE_SHIFT) +
+					      new_len - old_len);
 	return vma;
 }
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
