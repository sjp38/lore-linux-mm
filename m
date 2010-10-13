Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 329D76B0129
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 19:18:50 -0400 (EDT)
Date: Wed, 13 Oct 2010 16:17:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] Retry page fault when blocking on disk transfer.
Message-Id: <20101013161753.ba54ff50.akpm@linux-foundation.org>
In-Reply-To: <20101009012204.GA17458@google.com>
References: <1286265215-9025-1-git-send-email-walken@google.com>
	<1286265215-9025-3-git-send-email-walken@google.com>
	<4CAB628D.3030205@redhat.com>
	<AANLkTimdACZ9Xm01DM2+E64+T5XfLffrkFBhf7CJ286p@mail.gmail.com>
	<20101008043956.GA25662@google.com>
	<4CAF1B90.3080703@redhat.com>
	<AANLkTinWxTT=+m_fAudc080OUMwacSefnMbSMBFZgPMH@mail.gmail.com>
	<20101009012204.GA17458@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, 8 Oct 2010 18:22:04 -0700
Michel Lespinasse <walken@google.com> wrote:

> 
> Second try on adding the VM_FAULT_RETRY functionality to the swap in path.
> 
> This proposal would replace [patch 2/3] of this series (the initial
> version of it, which was approved by linus / rik / hpa).
> 
> Changes since the approved version:
> 
> - split lock_page_or_retry() into an inline function in  pagemap.h,
>   handling the trylock_page() fast path, and __lock_page_or_retry() in
>   filemap.c, handling the blocking path (with or without retry).
> 
> - make do_swap_page() call lock_page_or_retry() in place of lock_page(),
>   and handle the retry case.
>
> ...
> 
> @@ -1550,7 +1563,8 @@ retry_find:
>  			goto no_cached_page;
>  	}
>  
> -	lock_page(page);
> +	if (!lock_page_or_retry(page, &vma->vm_mm, vmf->flags))
> +		return ret | VM_FAULT_RETRY;
>  
>  	/* Did it get truncated? */
>  	if (unlikely(page->mapping != mapping)) {

mm/filemap.c: In function 'filemap_fault':
mm/filemap.c:1577: warning: passing argument 2 of 'lock_page_or_retry' from incompatible pointer type

--- a/mm/filemap.c~mm-retry-page-fault-when-blocking-on-disk-transfer-update-fix
+++ a/mm/filemap.c
@@ -1574,7 +1574,7 @@ retry_find:
 			goto no_cached_page;
 	}
 
-	if (!lock_page_or_retry(page, &vma->vm_mm, vmf->flags))
+	if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags))
 		return ret | VM_FAULT_RETRY;
 
 	/* Did it get truncated? */
_

the runtime effects are rather ghastly - a null-pointer deref deep in
the bowels of lockdep, early during /sbin/init execution (below).  But
for some reason the kernel then runs OK (!).

Probably you sent an older version of the patch by mistake.  Can you
please check whether anything else was missed?  I've appended my
current copy of this patch: it's a rollup of
mm-retry-page-fault-when-blocking-on-disk-transfer.patch,
mm-retry-page-fault-when-blocking-on-disk-transfer-update.patch and
mm-retry-page-fault-when-blocking-on-disk-transfer-update-fix.patch.



[   25.970482] =====================================
[   25.970804] [ BUG: bad unlock balance detected! ]
[   25.970968] -------------------------------------
[   25.971132] init/1 is trying to release lock (
[   25.971190] BUG: unable to handle kernel paging request at 0000000000876000
[   25.971594] IP: [<ffffffff8119089f>] strnlen+0x15/0x22
[   25.971807] PGD 255ea9067 PUD 255fb0067 PMD 0 
[   25.972104] Oops: 0000 [#1] SMP 
[   25.972352] last sysfs file: /sys/block/sdb/dev
[   25.972516] CPU 5 
[   25.972563] Modules linked in: ehci_hcd ohci_hcd uhci_hcd
[   25.973052] 
[   25.973212] Pid: 1, comm: init Not tainted 2.6.36-rc7-mm1 #14 /
[   25.973376] RIP: 0010:[<ffffffff8119089f>]  [<ffffffff8119089f>] strnlen+0x15/0x22
[   25.973702] RSP: 0018:ffff8802578d34d8  EFLAGS: 00010012
[   25.973861] RAX: 0000000000875fff RBX: 0000000000000000 RCX: ffffffffff0a0004
[   25.973956] RDX: 0000000000876000 RSI: ffffffffffffffff RDI: 0000000000876000
[   25.973956] RBP: ffff8802578d34d8 R08: 0000000000000002 R09: 0000000000000000
[   25.973956] R10: 0000000000000001 R11: ffff880255de6900 R12: ffffffff81ac9940
[   25.973956] R13: 0000000000876000 R14: 000000000000ffff R15: ffffffff81ac9d40
[   25.973956] FS:  0000000000000000(0000) GS:ffff88009e800000(0000) knlGS:0000000000000000
[   25.973956] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   25.973956] CR2: 0000000000876000 CR3: 0000000255916000 CR4: 00000000000006e0
[   25.973956] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   25.973956] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   25.973956] Process init (pid: 1, threadinfo ffff8802578d2000, task ffff8802578d0040)
[   25.973956] Stack:
[   25.973956]  ffff8802578d3518 ffffffff811912f2 ffffffff81ac9940 ffff8802578d36e8
[   25.973956] <0> ffffffff81ac9940 ffffffff81549849 ffffffff81ac9d40 ffffffff81ac9940
[   25.973956] <0> ffff8802578d3578 ffffffff8119283a 0000000000000400 ffffffff8154984b
[   25.973956] Call Trace:
[   25.973956]  [<ffffffff811912f2>] string+0x51/0xb5
[   25.973956]  [<ffffffff8119283a>] vsnprintf+0x1d7/0x42e
[   25.973956]  [<ffffffff81192bee>] vscnprintf+0xf/0x21
[   25.973956]  [<ffffffff810387cd>] vprintk+0x1c2/0x3be
[   25.973956]  [<ffffffff81386a74>] ? _raw_spin_unlock_irqrestore+0x38/0x47
[   25.973956]  [<ffffffff8103846b>] ? release_console_sem+0x1ad/0x1ba
[   25.973956]  [<ffffffff813868af>] ? _raw_spin_unlock_irq+0x29/0x2f
[   25.973956]  [<ffffffff8105d83a>] ? trace_hardirqs_on+0xd/0xf
[   25.973956]  [<ffffffff813868af>] ? _raw_spin_unlock_irq+0x29/0x2f
[   25.973956]  [<ffffffff8117d0ae>] ? __make_request+0x409/0x42a
[   25.973956]  [<ffffffff8108d97c>] ? __lock_page_or_retry+0x25/0x41
[   25.973956]  [<ffffffff81038a30>] printk+0x67/0x69
[   25.973956]  [<ffffffff8108d97c>] ? __lock_page_or_retry+0x25/0x41
[   25.973956]  [<ffffffff81038a30>] ? printk+0x67/0x69
[   25.973956]  [<ffffffff8108cf0e>] ? add_to_page_cache_locked+0xa0/0xca
[   25.973956]  [<ffffffff8105a650>] print_lockdep_cache+0x2e/0x30
[   25.973956]  [<ffffffff810eb822>] ? mpage_bio_submit+0x22/0x26
[   25.973956]  [<ffffffff810ec054>] ? mpage_readpages+0xff/0x113
[   25.973956]  [<ffffffff81121b01>] ? ext3_get_block+0x0/0xf5
[   25.973956]  [<ffffffff81121b01>] ? ext3_get_block+0x0/0xf5
[   25.973956]  [<ffffffff81053b32>] ? sched_clock_local+0xe/0x73
[   25.973956]  [<ffffffff81053cd7>] ? sched_clock_cpu+0xba/0xc5
[   25.973956]  [<ffffffff8105bade>] print_unlock_inbalance_bug+0x7b/0xde
[   25.973956]  [<ffffffff8105fc03>] lock_release_non_nested+0xb8/0x23d
[   25.973956]  [<ffffffff81053b32>] ? sched_clock_local+0xe/0x73
[   25.973956]  [<ffffffff8108d97c>] ? __lock_page_or_retry+0x25/0x41
[   25.973956]  [<ffffffff8105aaae>] ? trace_hardirqs_off+0xd/0xf
[   25.973956]  [<ffffffff81053d0d>] ? local_clock+0x2b/0x3c
[   25.973956]  [<ffffffff8108d97c>] ? __lock_page_or_retry+0x25/0x41
[   25.973956]  [<ffffffff8105fedb>] lock_release+0x153/0x181
[   25.973956]  [<ffffffff8105292f>] up_read+0x1c/0x35
[   25.973956]  [<ffffffff8108d97c>] __lock_page_or_retry+0x25/0x41
[   25.973956]  [<ffffffff8108db67>] filemap_fault+0x1cf/0x363
[   25.973956]  [<ffffffff810a20ab>] __do_fault+0x54/0x40f
[   25.973956]  [<ffffffff810a50dd>] handle_mm_fault+0x1d5/0x7af
[   25.973956]  [<ffffffff81389d06>] do_page_fault+0x2c9/0x429
[   25.973956]  [<ffffffff810a77c4>] ? vma_link+0x85/0x96
[   25.973956]  [<ffffffff81053b32>] ? sched_clock_local+0xe/0x73
[   25.973956]  [<ffffffff81053cd7>] ? sched_clock_cpu+0xba/0xc5
[   25.973956]  [<ffffffff8105aaae>] ? trace_hardirqs_off+0xd/0xf
[   25.973956]  [<ffffffff81053d0d>] ? local_clock+0x2b/0x3c
[   25.973956]  [<ffffffff8138600b>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[   25.973956]  [<ffffffff81386f5f>] page_fault+0x1f/0x30
[   25.973956]  [<ffffffff811940b4>] ? __clear_user+0x2e/0x50
[   25.973956]  [<ffffffff81194098>] ? __clear_user+0x12/0x50
[   25.973956]  [<ffffffff81194200>] clear_user+0x2b/0x33
[   25.973956]  [<ffffffff810fc2cb>] padzero+0x1b/0x2b
[   25.973956]  [<ffffffff810fd294>] load_elf_binary+0x8e0/0x16c7
[   25.973956]  [<ffffffff8105aaae>] ? trace_hardirqs_off+0xd/0xf
[   25.973956]  [<ffffffff81053d0d>] ? local_clock+0x2b/0x3c
[   25.973956]  [<ffffffff810fc9b4>] ? load_elf_binary+0x0/0x16c7
[   25.973956]  [<ffffffff810c7aa4>] search_binary_handler+0xc3/0x288
[   25.973956]  [<ffffffff810c7e09>] do_execve+0x1a0/0x266
[   25.973956]  [<ffffffff81009586>] sys_execve+0x3c/0x57
[   25.973956]  [<ffffffff81002ecc>] stub_execve+0x6c/0xc0
[   25.973956] Code: 03 48 ff c7 48 0f b6 07 f6 80 a0 55 42 81 20 75 f0 c9 48 89 f8 c3 55 48 89 fa 48 89 e5 eb 03 48 ff c2 48 8d 04 37 48 39 c2 74 05 <80> 3a 00 75 ef c9 48 29 fa 48 89 d0 c3 55 31 c0 48 89 e5 eb 13 
[   25.973956] RIP  [<ffffffff8119089f>] strnlen+0x15/0x22
[   25.973956]  RSP <ffff8802578d34d8>
[   25.973956] CR2: 0000000000876000




 arch/x86/mm/fault.c     |   38 ++++++++++++++++++++++++++------------
 include/linux/mm.h      |    2 ++
 include/linux/pagemap.h |   13 +++++++++++++
 mm/filemap.c            |   16 +++++++++++++++-
 mm/memory.c             |   10 ++++++++--
 5 files changed, 64 insertions(+), 15 deletions(-)

diff -puN arch/x86/mm/fault.c~mm-retry-page-fault-when-blocking-on-disk-transfer arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~mm-retry-page-fault-when-blocking-on-disk-transfer
+++ a/arch/x86/mm/fault.c
@@ -943,8 +943,10 @@ do_page_fault(struct pt_regs *regs, unsi
 	struct task_struct *tsk;
 	unsigned long address;
 	struct mm_struct *mm;
-	int write;
 	int fault;
+	int write = error_code & PF_WRITE;
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY |
+					(write ? FAULT_FLAG_WRITE : 0);
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1055,6 +1057,7 @@ do_page_fault(struct pt_regs *regs, unsi
 			bad_area_nosemaphore(regs, error_code, address);
 			return;
 		}
+retry:
 		down_read(&mm->mmap_sem);
 	} else {
 		/*
@@ -1098,8 +1101,6 @@ do_page_fault(struct pt_regs *regs, unsi
 	 * we can handle it..
 	 */
 good_area:
-	write = error_code & PF_WRITE;
-
 	if (unlikely(access_error(error_code, write, vma))) {
 		bad_area_access_error(regs, error_code, address);
 		return;
@@ -1110,21 +1111,34 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault:
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, error_code, address, fault);
 		return;
 	}
 
-	if (fault & VM_FAULT_MAJOR) {
-		tsk->maj_flt++;
-		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ, 1, 0,
-				     regs, address);
-	} else {
-		tsk->min_flt++;
-		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN, 1, 0,
-				     regs, address);
+	/*
+	 * Major/minor page fault accounting is only done on the
+	 * initial attempt. If we go through a retry, it is extremely
+	 * likely that the page will be found in page cache at that point.
+	 */
+	if (flags & FAULT_FLAG_ALLOW_RETRY) {
+		if (fault & VM_FAULT_MAJOR) {
+			tsk->maj_flt++;
+			perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ, 1, 0,
+				      regs, address);
+		} else {
+			tsk->min_flt++;
+			perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN, 1, 0,
+				      regs, address);
+		}
+		if (fault & VM_FAULT_RETRY) {
+			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
+			 * of starvation. */
+			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			goto retry;
+		}
 	}
 
 	check_v8086_mode(regs, address, tsk);
diff -puN include/linux/mm.h~mm-retry-page-fault-when-blocking-on-disk-transfer include/linux/mm.h
--- a/include/linux/mm.h~mm-retry-page-fault-when-blocking-on-disk-transfer
+++ a/include/linux/mm.h
@@ -144,6 +144,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
 #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
 #define FAULT_FLAG_MKWRITE	0x04	/* Fault was mkwrite of existing pte */
+#define FAULT_FLAG_ALLOW_RETRY	0x08	/* Retry fault if blocking */
 
 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
@@ -723,6 +724,7 @@ static inline int page_mapped(struct pag
 
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
+#define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
 
 #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
 
diff -puN mm/filemap.c~mm-retry-page-fault-when-blocking-on-disk-transfer mm/filemap.c
--- a/mm/filemap.c~mm-retry-page-fault-when-blocking-on-disk-transfer
+++ a/mm/filemap.c
@@ -623,6 +623,19 @@ void __lock_page_nosync(struct page *pag
 							TASK_UNINTERRUPTIBLE);
 }
 
+int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
+			 unsigned int flags)
+{
+	if (!(flags & FAULT_FLAG_ALLOW_RETRY)) {
+		__lock_page(page);
+		return 1;
+	} else {
+		up_read(&mm->mmap_sem);
+		wait_on_page_locked(page);
+		return 0;
+	}
+}
+
 /**
  * find_get_page - find and get a page reference
  * @mapping: the address_space to search
@@ -1561,7 +1574,8 @@ retry_find:
 			goto no_cached_page;
 	}
 
-	lock_page(page);
+	if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags))
+		return ret | VM_FAULT_RETRY;
 
 	/* Did it get truncated? */
 	if (unlikely(page->mapping != mapping)) {
diff -puN mm/memory.c~mm-retry-page-fault-when-blocking-on-disk-transfer mm/memory.c
--- a/mm/memory.c~mm-retry-page-fault-when-blocking-on-disk-transfer
+++ a/mm/memory.c
@@ -2627,6 +2627,7 @@ static int do_swap_page(struct mm_struct
 	struct page *page, *swapcache = NULL;
 	swp_entry_t entry;
 	pte_t pte;
+	int locked;
 	struct mem_cgroup *ptr = NULL;
 	int exclusive = 0;
 	int ret = 0;
@@ -2677,8 +2678,12 @@ static int do_swap_page(struct mm_struct
 		goto out_release;
 	}
 
-	lock_page(page);
+	locked = lock_page_or_retry(page, mm, flags);
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+	if (!locked) {
+		ret |= VM_FAULT_RETRY;
+		goto out_release;
+	}
 
 	/*
 	 * Make sure try_to_free_swap or reuse_swap_page or swapoff did not
@@ -2927,7 +2932,8 @@ static int __do_fault(struct mm_struct *
 	vmf.page = NULL;
 
 	ret = vma->vm_ops->fault(vma, &vmf);
-	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
+			    VM_FAULT_RETRY)))
 		return ret;
 
 	if (unlikely(PageHWPoison(vmf.page))) {
diff -puN include/linux/pagemap.h~mm-retry-page-fault-when-blocking-on-disk-transfer include/linux/pagemap.h
--- a/include/linux/pagemap.h~mm-retry-page-fault-when-blocking-on-disk-transfer
+++ a/include/linux/pagemap.h
@@ -299,6 +299,8 @@ static inline pgoff_t linear_page_index(
 extern void __lock_page(struct page *page);
 extern int __lock_page_killable(struct page *page);
 extern void __lock_page_nosync(struct page *page);
+extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
+				unsigned int flags);
 extern void unlock_page(struct page *page);
 
 static inline void __set_page_locked(struct page *page)
@@ -351,6 +353,17 @@ static inline void lock_page_nosync(stru
 }
 	
 /*
+ * lock_page_or_retry - Lock the page, unless this would block and the
+ * caller indicated that it can handle a retry.
+ */
+static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
+				     unsigned int flags)
+{
+	might_sleep();
+	return trylock_page(page) || __lock_page_or_retry(page, mm, flags);
+}
+
+/*
  * This is exported only for wait_on_page_locked/wait_on_page_writeback.
  * Never use this directly!
  */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
