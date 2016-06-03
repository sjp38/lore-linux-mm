Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D4D486B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 04:43:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g64so96282598pfb.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 01:43:52 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id t6si4530794paa.6.2016.06.03.01.43.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 01:43:51 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id gp3so5464478pac.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 01:43:51 -0700 (PDT)
Date: Fri, 3 Jun 2016 17:43:47 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [linux-next: Tree for Jun 1] __khugepaged_exit
 rwsem_down_write_failed lockup
Message-ID: <20160603084347.GA502@swordfish>
References: <20160601131122.7dbb0a65@canb.auug.org.au>
 <20160602014835.GA635@swordfish>
 <20160602092113.GH1995@dhcp22.suse.cz>
 <20160603071551.GA453@swordfish>
 <20160603072536.GB20676@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160603072536.GB20676@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On (06/03/16 09:25), Michal Hocko wrote:
> > it's quite hard to trigger the bug (somehow), so I can't
> > follow up with more information as of now.

either I did something very silly fixing up the patch, or the
patch may be causing general protection faults on my system.

RIP collect_mm_slot() + 0x42/0x84
	khugepaged
	prepare_to_wait_event
	maybe_pmd_mkwrite
	kthread
	_raw_sin_unlock_irq
	ret_from_fork
	kthread_create_on_node

collect_mm_slot() + 0x42/0x84 is

0000000000000328 <collect_mm_slot>:
     328:       55                      push   %rbp
     329:       48 89 e5                mov    %rsp,%rbp
     32c:       53                      push   %rbx
     32d:       48 8b 5f 20             mov    0x20(%rdi),%rbx
     331:       8b 43 48                mov    0x48(%rbx),%eax
     334:       ff c8                   dec    %eax
     336:       7f 71                   jg     3a9 <collect_mm_slot+0x81>
     338:       48 8b 57 08             mov    0x8(%rdi),%rdx
     33c:       48 85 d2                test   %rdx,%rdx
     33f:       74 1e                   je     35f <collect_mm_slot+0x37>
     341:       48 8b 07                mov    (%rdi),%rax
     344:       48 85 c0                test   %rax,%rax
     347:       48 89 02                mov    %rax,(%rdx)
     34a:       74 04                   je     350 <collect_mm_slot+0x28>
     34c:       48 89 50 08             mov    %rdx,0x8(%rax)
     350:       48 c7 07 00 00 00 00    movq   $0x0,(%rdi)
     357:       48 c7 47 08 00 00 00    movq   $0x0,0x8(%rdi)
     35e:       00 
     35f:       48 8b 57 10             mov    0x10(%rdi),%rdx
     363:       48 8b 47 18             mov    0x18(%rdi),%rax
     367:       48 89 fe                mov    %rdi,%rsi
     36a:       48 89 42 08             mov    %rax,0x8(%rdx)
		^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
     36e:       48 89 10                mov    %rdx,(%rax)
     371:       48 b8 00 01 00 00 00    movabs $0xdead000000000100,%rax
     378:       00 ad de 
     37b:       48 89 47 10             mov    %rax,0x10(%rdi)
     37f:       48 b8 00 02 00 00 00    movabs $0xdead000000000200,%rax
     386:       00 ad de 
     389:       48 89 47 18             mov    %rax,0x18(%rdi)
     38d:       48 8b 3d 00 00 00 00    mov    0x0(%rip),%rdi        # 394 <collect_mm_slot+0x6c>
     394:       e8 00 00 00 00          callq  399 <collect_mm_slot+0x71>
     399:       f0 ff 4b 4c             lock decl 0x4c(%rbx)
     39d:       74 02                   je     3a1 <collect_mm_slot+0x79>
     39f:       eb 08                   jmp    3a9 <collect_mm_slot+0x81>
     3a1:       48 89 df                mov    %rbx,%rdi
     3a4:       e8 00 00 00 00          callq  3a9 <collect_mm_slot+0x81>
     3a9:       5b                      pop    %rbx
     3aa:       5d                      pop    %rbp
     3ab:       c3                      retq

which is list_del(&mm_slot->mm_node), I believe.


I attached the patch (just in case).

---
 mm/huge_memory.c | 87 +++++++++++++++++++++++++-------------------------------
 1 file changed, 39 insertions(+), 48 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 292cedd..1c82fa4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1938,7 +1938,8 @@ static void insert_to_mm_slots_hash(struct mm_struct *mm,
 
 static inline int khugepaged_test_exit(struct mm_struct *mm)
 {
-	return atomic_read(&mm->mm_users) == 0;
+	/* the only pin is from khugepaged_scan_mm_slot */
+	return atomic_read(&mm->mm_users) <= 1;
 }
 
 int __khugepaged_enter(struct mm_struct *mm)
@@ -1950,8 +1951,6 @@ int __khugepaged_enter(struct mm_struct *mm)
 	if (!mm_slot)
 		return -ENOMEM;
 
-	/* __khugepaged_exit() must not run from under us */
-	VM_BUG_ON_MM(khugepaged_test_exit(mm), mm);
 	if (unlikely(test_and_set_bit(MMF_VM_HUGEPAGE, &mm->flags))) {
 		free_mm_slot(mm_slot);
 		return 0;
@@ -1994,36 +1993,40 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 	return 0;
 }
 
-void __khugepaged_exit(struct mm_struct *mm)
+static void collect_mm_slot(struct mm_slot *mm_slot)
 {
-	struct mm_slot *mm_slot;
-	int free = 0;
+	struct mm_struct *mm = mm_slot->mm;
 
-	spin_lock(&khugepaged_mm_lock);
-	mm_slot = get_mm_slot(mm);
-	if (mm_slot && khugepaged_scan.mm_slot != mm_slot) {
+	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
+
+	if (khugepaged_test_exit(mm)) {
+		/* free mm_slot */
 		hash_del(&mm_slot->hash);
 		list_del(&mm_slot->mm_node);
-		free = 1;
-	}
-	spin_unlock(&khugepaged_mm_lock);
 
-	if (free) {
-		clear_bit(MMF_VM_HUGEPAGE, &mm->flags);
-		free_mm_slot(mm_slot);
-		mmdrop(mm);
-	} else if (mm_slot) {
 		/*
-		 * This is required to serialize against
-		 * khugepaged_test_exit() (which is guaranteed to run
-		 * under mmap sem read mode). Stop here (after we
-		 * return all pagetables will be destroyed) until
-		 * khugepaged has finished working on the pagetables
-		 * under the mmap_sem.
+		 * Not strictly needed because the mm exited already.
+		 *
+		 * clear_bit(MMF_VM_HUGEPAGE, &mm->flags);
 		 */
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
+
+		/* khugepaged_mm_lock actually not necessary for the below */
+		free_mm_slot(mm_slot);
+		mmdrop(mm);
+	}
+}
+
+void __khugepaged_exit(struct mm_struct *mm)
+{
+	struct mm_slot *mm_slot;
+
+	spin_lock(&khugepaged_mm_lock);
+	mm_slot = get_mm_slot(mm);
+	if (mm_slot) {
+		collect_mm_slot(mm_slot);
+		clear_bit(MMF_VM_HUGEPAGE, &mm->flags);
 	}
+	spin_unlock(&khugepaged_mm_lock);
 }
 
 static void release_pte_page(struct page *page)
@@ -2738,29 +2741,6 @@ out:
 	return ret;
 }
 
-static void collect_mm_slot(struct mm_slot *mm_slot)
-{
-	struct mm_struct *mm = mm_slot->mm;
-
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
-
-	if (khugepaged_test_exit(mm)) {
-		/* free mm_slot */
-		hash_del(&mm_slot->hash);
-		list_del(&mm_slot->mm_node);
-
-		/*
-		 * Not strictly needed because the mm exited already.
-		 *
-		 * clear_bit(MMF_VM_HUGEPAGE, &mm->flags);
-		 */
-
-		/* khugepaged_mm_lock actually not necessary for the below */
-		free_mm_slot(mm_slot);
-		mmdrop(mm);
-	}
-}
-
 static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 					    struct page **hpage)
 	__releases(&khugepaged_mm_lock)
@@ -2782,6 +2762,16 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 		khugepaged_scan.address = 0;
 		khugepaged_scan.mm_slot = mm_slot;
 	}
+
+	/*
+	 * Do not even try to do anything if the current mm is already
+	 * dead. khugepaged_mm_lock will make sure only this or
+	 * __khugepaged_exit does the unhasing.
+	 */
+	if (!atomic_inc_not_zero(&mm_slot->mm->mm_users)) {
+		collect_mm_slot(mm_slot);
+		return progress;
+	}
 	spin_unlock(&khugepaged_mm_lock);
 
 	mm = mm_slot->mm;
@@ -2865,6 +2855,7 @@ breakouterloop_mmap_sem:
 
 		collect_mm_slot(mm_slot);
 	}
+	mmput_async(mm);
 
 	return progress;
 }
-- 
2.9.0.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
