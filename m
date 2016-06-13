Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CDEF76B0274
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 15:48:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k184so34243524wme.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:48:01 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id b207si264418wmb.77.2016.06.13.12.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 12:48:00 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id m124so17266326wme.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:48:00 -0700 (PDT)
From: Topi Miettinen <toiwoton@gmail.com>
Subject: [RFC 12/18] limits: track RLIMIT_MEMLOCK actual max
Date: Mon, 13 Jun 2016 22:44:19 +0300
Message-Id: <1465847065-3577-13-git-send-email-toiwoton@gmail.com>
In-Reply-To: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
References: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Topi Miettinen <toiwoton@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Alexei Starovoitov <ast@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Jiri Slaby <jslaby@suse.cz>, Cyrill Gorcunov <gorcunov@openvz.org>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Nikhil Rao <nikhil.rao@intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, "open list:IA64 Itanium PLATFORM" <linux-ia64@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE KVM FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE KVM" <kvm@vger.kernel.org>, "open list:LINUX FOR POWERPC 32-BIT AND 64-BIT" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:BPF Safe dynamic programs and tools" <netdev@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Track maximum size of locked memory, presented in /proc/self/limits.

Signed-off-by: Topi Miettinen <toiwoton@gmail.com>
---
 arch/ia64/kernel/perfmon.c                 |  1 +
 arch/powerpc/kvm/book3s_64_vio.c           |  1 +
 arch/powerpc/mm/mmu_context_iommu.c        |  1 +
 drivers/infiniband/core/umem.c             |  1 +
 drivers/infiniband/hw/hfi1/user_pages.c    |  1 +
 drivers/infiniband/hw/qib/qib_user_pages.c |  1 +
 drivers/infiniband/hw/usnic/usnic_uiom.c   |  2 ++
 drivers/misc/mic/scif/scif_rma.c           |  1 +
 drivers/vfio/vfio_iommu_spapr_tce.c        |  2 ++
 drivers/vfio/vfio_iommu_type1.c            |  2 ++
 include/linux/sched.h                      | 10 ++++++++--
 kernel/bpf/syscall.c                       |  6 ++++++
 kernel/events/core.c                       |  1 +
 mm/mlock.c                                 |  7 +++++++
 mm/mmap.c                                  |  3 +++
 mm/mremap.c                                |  3 +++
 16 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 2436ad5..d05ff3b 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2341,6 +2341,7 @@ pfm_smpl_buffer_alloc(struct task_struct *task, struct file *filp, pfm_context_t
 	ctx->ctx_smpl_vaddr = (void *)vma->vm_start;
 	*(unsigned long *)user_vaddr = vma->vm_start;
 
+	task_bump_rlimit(task, RLIMIT_MEMLOCK, size);
 	return 0;
 
 error:
diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
index 18cf6d1..2714bbf 100644
--- a/arch/powerpc/kvm/book3s_64_vio.c
+++ b/arch/powerpc/kvm/book3s_64_vio.c
@@ -71,6 +71,7 @@ static long kvmppc_account_memlimit(unsigned long stt_pages, bool inc)
 			ret = -ENOMEM;
 		else
 			current->mm->locked_vm += stt_pages;
+		bump_rlimit(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
 	} else {
 		if (WARN_ON_ONCE(stt_pages > current->mm->locked_vm))
 			stt_pages = current->mm->locked_vm;
diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index da6a216..ace8b9d 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -46,6 +46,7 @@ static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
 			ret = -ENOMEM;
 		else
 			mm->locked_vm += npages;
+		bump_rlimit(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
 	} else {
 		if (WARN_ON_ONCE(npages > mm->locked_vm))
 			npages = mm->locked_vm;
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index fe4d2e1..9bd9638 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -224,6 +224,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 
 	ret = 0;
 
+	bump_rlimit(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
 out:
 	if (ret < 0) {
 		if (need_release)
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index 88e10b5f..096910d7 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -111,6 +111,7 @@ int hfi1_acquire_user_pages(unsigned long vaddr, size_t npages, bool writable,
 
 	down_write(&current->mm->mmap_sem);
 	current->mm->pinned_vm += ret;
+	bump_rlimit(RLIMIT_MEMLOCK, current->mm->pinned_vm << PAGE_SHIFT);
 	up_write(&current->mm->mmap_sem);
 
 	return ret;
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 2d2b94f..06f93de 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -74,6 +74,7 @@ static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
 	}
 
 	current->mm->pinned_vm += num_pages;
+	bump_rlimit(RLIMIT_MEMLOCK, current->mm->pinned_vm << PAGE_SHIFT);
 
 	ret = 0;
 	goto bail;
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index a0b6ebe..83409dc 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -178,6 +178,8 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 		ret = 0;
 	}
 
+	bump_rlimit(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
+
 out:
 	if (ret < 0)
 		usnic_uiom_put_pages(chunk_list, 0);
diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index e0203b1..1d6315a 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -306,6 +306,7 @@ static inline int __scif_check_inc_pinned_vm(struct mm_struct *mm,
 		return -ENOMEM;
 	}
 	mm->pinned_vm = locked;
+	bump_rlimit(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
 	return 0;
 }
 
diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
index 80378dd..769a5b8 100644
--- a/drivers/vfio/vfio_iommu_spapr_tce.c
+++ b/drivers/vfio/vfio_iommu_spapr_tce.c
@@ -55,6 +55,8 @@ static long try_increment_locked_vm(long npages)
 			rlimit(RLIMIT_MEMLOCK),
 			ret ? " - exceeded" : "");
 
+	bump_rlimit(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
+
 	up_write(&current->mm->mmap_sem);
 
 	return ret;
diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 2ba1942..4c6e7a3 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -312,6 +312,8 @@ static long vfio_pin_pages(unsigned long vaddr, long npage,
 		}
 	}
 
+	bump_rlimit(RLIMIT_MEMLOCK, (current->mm->locked_vm + i) << PAGE_SHIFT);
+
 	if (!rsvd)
 		vfio_lock_acct(i);
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index feb9bb7..d3f3c9f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -3378,10 +3378,16 @@ static inline unsigned long rlimit_max(unsigned int limit)
 	return task_rlimit_max(current, limit);
 }
 
+static inline void task_bump_rlimit(struct task_struct *tsk,
+				    unsigned int limit, unsigned long r)
+{
+	if (READ_ONCE(tsk->signal->rlim_curmax[limit]) < r)
+		tsk->signal->rlim_curmax[limit] = r;
+}
+
 static inline void bump_rlimit(unsigned int limit, unsigned long r)
 {
-	if (READ_ONCE(current->signal->rlim_curmax[limit]) < r)
-		current->signal->rlim_curmax[limit] = r;
+	return task_bump_rlimit(current, limit, r);
 }
 
 #ifdef CONFIG_CPU_FREQ
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 46ecce4..192001e 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -76,6 +76,9 @@ static int bpf_map_charge_memlock(struct bpf_map *map)
 		return -EPERM;
 	}
 	map->user = user;
+	/* XXX resource limits apply per task, not per user */
+	bump_rlimit(RLIMIT_MEMLOCK, atomic_long_read(&user->locked_vm) <<
+		    PAGE_SHIFT);
 	return 0;
 }
 
@@ -601,6 +604,9 @@ static int bpf_prog_charge_memlock(struct bpf_prog *prog)
 		return -EPERM;
 	}
 	prog->aux->user = user;
+	/* XXX resource limits apply per task, not per user */
+	bump_rlimit(RLIMIT_MEMLOCK, atomic_long_read(&user->locked_vm) <<
+		    PAGE_SHIFT);
 	return 0;
 }
 
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 9c51ec3..92467e8 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5075,6 +5075,7 @@ accounting:
 		if (!ret)
 			rb->aux_mmap_locked = extra;
 	}
+	bump_rlimit(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
 
 unlock:
 	if (!ret) {
diff --git a/mm/mlock.c b/mm/mlock.c
index ef8dc9f..554bee9 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -648,6 +648,8 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	if (error)
 		return error;
 
+	bump_rlimit(RLIMIT_MEMLOCK, locked << PAGE_SHIFT);
+
 	error = __mm_populate(start, len, 0);
 	if (error)
 		return __mlock_posix_error_return(error);
@@ -761,6 +763,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	if (!ret && (flags & MCL_CURRENT))
 		mm_populate(0, TASK_SIZE);
 
+	bump_rlimit(RLIMIT_MEMLOCK, current->mm->total_vm << PAGE_SHIFT);
+
 	return ret;
 }
 
@@ -798,6 +802,9 @@ int user_shm_lock(size_t size, struct user_struct *user)
 	get_uid(user);
 	user->locked_shm += locked;
 	allowed = 1;
+
+	/* XXX resource limits apply per task, not per user */
+	bump_rlimit(RLIMIT_MEMLOCK, user->locked_shm << PAGE_SHIFT);
 out:
 	spin_unlock(&shmlock_user_lock);
 	return allowed;
diff --git a/mm/mmap.c b/mm/mmap.c
index 0963e7f..4e683dd 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2020,6 +2020,9 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 		return -ENOMEM;
 
 	bump_rlimit(RLIMIT_STACK, actual_size);
+	if (vma->vm_flags & VM_LOCKED)
+		bump_rlimit(RLIMIT_MEMLOCK,
+			    (mm->locked_vm + grow) << PAGE_SHIFT);
 
 	return 0;
 }
diff --git a/mm/mremap.c b/mm/mremap.c
index 1f157ad..ade3e13 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -394,6 +394,9 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 		*p = charged;
 	}
 
+	if (vma->vm_flags & VM_LOCKED)
+		bump_rlimit(RLIMIT_MEMLOCK, (mm->locked_vm << PAGE_SHIFT) +
+			    new_len - old_len);
 	return vma;
 }
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
