Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id A5D9C6B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 00:21:36 -0400 (EDT)
Date: Fri, 19 Jul 2013 00:21:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH for 3.2] memcg: do not trap chargers with full callstack
 on OOM
Message-ID: <20130719042124.GC17812@cmpxchg.org>
References: <20130709135450.GI20281@dhcp22.suse.cz>
 <20130710182506.F25DF461@pobox.sk>
 <20130711072507.GA21667@dhcp22.suse.cz>
 <20130714012641.C2DA4E05@pobox.sk>
 <20130714015112.FFCB7AF7@pobox.sk>
 <20130715154119.GA32435@dhcp22.suse.cz>
 <20130715160006.GB32435@dhcp22.suse.cz>
 <20130716153544.GX17812@cmpxchg.org>
 <20130716160905.GA20018@dhcp22.suse.cz>
 <20130716164830.GZ17812@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130716164830.GZ17812@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com

On Tue, Jul 16, 2013 at 12:48:30PM -0400, Johannes Weiner wrote:
> On Tue, Jul 16, 2013 at 06:09:05PM +0200, Michal Hocko wrote:
> > On Tue 16-07-13 11:35:44, Johannes Weiner wrote:
> > > On Mon, Jul 15, 2013 at 06:00:06PM +0200, Michal Hocko wrote:
> > > > On Mon 15-07-13 17:41:19, Michal Hocko wrote:
> > > > > On Sun 14-07-13 01:51:12, azurIt wrote:
> > > > > > > CC: "Johannes Weiner" <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "cgroups mailinglist" <cgroups@vger.kernel.org>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com
> > > > > > >> CC: "Johannes Weiner" <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "cgroups mailinglist" <cgroups@vger.kernel.org>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com
> > > > > > >>On Wed 10-07-13 18:25:06, azurIt wrote:
> > > > > > >>> >> Now i realized that i forgot to remove UID from that cgroup before
> > > > > > >>> >> trying to remove it, so cgroup cannot be removed anyway (we are using
> > > > > > >>> >> third party cgroup called cgroup-uid from Andrea Righi, which is able
> > > > > > >>> >> to associate all user's processes with target cgroup). Look here for
> > > > > > >>> >> cgroup-uid patch:
> > > > > > >>> >> https://www.develer.com/~arighi/linux/patches/cgroup-uid/cgroup-uid-v8.patch
> > > > > > >>> >> 
> > > > > > >>> >> ANYWAY, i'm 101% sure that 'tasks' file was empty and 'under_oom' was
> > > > > > >>> >> permanently '1'.
> > > > > > >>> >
> > > > > > >>> >This is really strange. Could you post the whole diff against stable
> > > > > > >>> >tree you are using (except for grsecurity stuff and the above cgroup-uid
> > > > > > >>> >patch)?
> > > > > > >>> 
> > > > > > >>> 
> > > > > > >>> Here are all patches which i applied to kernel 3.2.48 in my last test:
> > > > > > >>> http://watchdog.sk/lkml/patches3/
> > > > > > >>
> > > > > > >>The two patches from Johannes seem correct.
> > > > > > >>
> > > > > > >>From a quick look even grsecurity patchset shouldn't interfere as it
> > > > > > >>doesn't seem to put any code between handle_mm_fault and mm_fault_error
> > > > > > >>and there also doesn't seem to be any new handle_mm_fault call sites.
> > > > > > >>
> > > > > > >>But I cannot tell there aren't other code paths which would lead to a
> > > > > > >>memcg charge, thus oom, without proper FAULT_FLAG_KERNEL handling.
> > > > > > >
> > > > > > >
> > > > > > >Michal,
> > > > > > >
> > > > > > >now i can definitely confirm that problem with unremovable cgroups
> > > > > > >persists. What info do you need from me? I applied also your little
> > > > > > >'WARN_ON' patch.
> > > > > > 
> > > > > > Ok, i think you want this:
> > > > > > http://watchdog.sk/lkml/kern4.log
> > > > > 
> > > > > Jul 14 01:11:39 server01 kernel: [  593.589087] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> > > > > Jul 14 01:11:39 server01 kernel: [  593.589451] [12021]  1333 12021   172027    64723   4       0             0 apache2
> > > > > Jul 14 01:11:39 server01 kernel: [  593.589647] [12030]  1333 12030   172030    64748   2       0             0 apache2
> > > > > Jul 14 01:11:39 server01 kernel: [  593.589836] [12031]  1333 12031   172030    64749   3       0             0 apache2
> > > > > Jul 14 01:11:39 server01 kernel: [  593.590025] [12032]  1333 12032   170619    63428   3       0             0 apache2
> > > > > Jul 14 01:11:39 server01 kernel: [  593.590213] [12033]  1333 12033   167934    60524   2       0             0 apache2
> > > > > Jul 14 01:11:39 server01 kernel: [  593.590401] [12034]  1333 12034   170747    63496   4       0             0 apache2
> > > > > Jul 14 01:11:39 server01 kernel: [  593.590588] [12035]  1333 12035   169659    62451   1       0             0 apache2
> > > > > Jul 14 01:11:39 server01 kernel: [  593.590776] [12036]  1333 12036   167614    60384   3       0             0 apache2
> > > > > Jul 14 01:11:39 server01 kernel: [  593.590984] [12037]  1333 12037   166342    58964   3       0             0 apache2
> > > > > Jul 14 01:11:39 server01 kernel: [  593.591178] Memory cgroup out of memory: Kill process 12021 (apache2) score 847 or sacrifice child
> > > > > Jul 14 01:11:39 server01 kernel: [  593.591370] Killed process 12021 (apache2) total-vm:688108kB, anon-rss:255472kB, file-rss:3420kB
> > > > > Jul 14 01:11:41 server01 kernel: [  595.392920] ------------[ cut here ]------------
> > > > > Jul 14 01:11:41 server01 kernel: [  595.393096] WARNING: at kernel/exit.c:888 do_exit+0x7d0/0x870()
> > > > > Jul 14 01:11:41 server01 kernel: [  595.393256] Hardware name: S5000VSA
> > > > > Jul 14 01:11:41 server01 kernel: [  595.393415] Pid: 12037, comm: apache2 Not tainted 3.2.48-grsec #1
> > > > > Jul 14 01:11:41 server01 kernel: [  595.393577] Call Trace:
> > > > > Jul 14 01:11:41 server01 kernel: [  595.393737]  [<ffffffff8105520a>] warn_slowpath_common+0x7a/0xb0
> > > > > Jul 14 01:11:41 server01 kernel: [  595.393903]  [<ffffffff8105525a>] warn_slowpath_null+0x1a/0x20
> > > > > Jul 14 01:11:41 server01 kernel: [  595.394068]  [<ffffffff81059c50>] do_exit+0x7d0/0x870
> > > > > Jul 14 01:11:41 server01 kernel: [  595.394231]  [<ffffffff81050254>] ? thread_group_times+0x44/0xb0
> > > > > Jul 14 01:11:41 server01 kernel: [  595.394392]  [<ffffffff81059d41>] do_group_exit+0x51/0xc0
> > > > > Jul 14 01:11:41 server01 kernel: [  595.394551]  [<ffffffff81059dc7>] sys_exit_group+0x17/0x20
> > > > > Jul 14 01:11:41 server01 kernel: [  595.394714]  [<ffffffff815caea6>] system_call_fastpath+0x18/0x1d
> > > > > Jul 14 01:11:41 server01 kernel: [  595.394921] ---[ end trace 738570e688acf099 ]---
> > > > > 
> > > > > OK, so you had an OOM which has been handled by in-kernel oom handler
> > > > > (it killed 12021) and 12037 was in the same group. The warning tells us
> > > > > that it went through mem_cgroup_oom as well (otherwise it wouldn't have
> > > > > memcg_oom.wait_on_memcg set and the warning wouldn't trigger) and then
> > > > > it exited on the userspace request (by exit syscall).
> > > > > 
> > > > > I do not see any way how, this could happen though. If mem_cgroup_oom
> > > > > is called then we always return CHARGE_NOMEM which turns into ENOMEM
> > > > > returned by __mem_cgroup_try_charge (invoke_oom must have been set to
> > > > > true).  So if nobody screwed the return value on the way up to page
> > > > > fault handler then there is no way to escape.
> > > > > 
> > > > > I will check the code.
> > > > 
> > > > OK, I guess I found it:
> > > > __do_fault
> > > >   fault = filemap_fault
> > > >   do_async_mmap_readahead
> > > >     page_cache_async_readahead
> > > >       ondemand_readahead
> > > >         __do_page_cache_readahead
> > > >           read_pages
> > > >             readpages = ext3_readpages
> > > >               mpage_readpages			# Doesn't propagate ENOMEM
> > > >                add_to_page_cache_lru
> > > >                  add_to_page_cache
> > > >                    add_to_page_cache_locked
> > > >                      mem_cgroup_cache_charge
> > > > 
> > > > So the read ahead most probably. Again! Duhhh. I will try to think
> > > > about a fix for this. One obvious place is mpage_readpages but
> > > > __do_page_cache_readahead ignores read_pages return value as well and
> > > > page_cache_async_readahead, even worse, is just void and exported as
> > > > such.
> > > > 
> > > > So this smells like a hard to fix bugger. One possible, and really ugly
> > > > way would be calling mem_cgroup_oom_synchronize even if handle_mm_fault
> > > > doesn't return VM_FAULT_ERROR, but that is a crude hack.

I fixed it by disabling the OOM killer altogether for readahead code.
We don't do it globally, we should not do it in the memcg, these are
optional allocations/charges.

I also disabled it for kernel faults triggered from within a syscall
(copy_*user, get_user_pages), which should just return -ENOMEM as
usual (unless it's nested inside a userspace fault).  The only
downside is that we can't get around annotating userspace faults
anymore, so every architecture fault handler now passes
FAULT_FLAG_USER to handle_mm_fault().  Makes the series a little less
self-contained, but it's not unreasonable.

It's easy to detect leaks now by checking if the memcg OOM context is
setup and we are not returning VM_FAULT_OOM.

Here is a combined diff based on 3.2.  azurIt, any chance you could
give this a shot?  I tested it on my local machines, but you have a
known reproducer of fairly unlikely scenarios...

Thanks!
Johannes

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index fadd5f8..fa6b4e4 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -89,6 +89,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	struct mm_struct *mm = current->mm;
 	const struct exception_table_entry *fixup;
 	int fault, si_code = SEGV_MAPERR;
+	unsigned long flags = 0;
 	siginfo_t info;
 
 	/* As of EV6, a load into $31/$f31 is a prefetch, and never faults
@@ -142,10 +143,15 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 			goto bad_area;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (cause > 0)
+		flags |= FAULT_FLAG_WRITE;
+
 	/* If for any reason at all we couldn't handle the fault,
 	   make sure we exit gracefully rather than endlessly redo
 	   the fault.  */
-	fault = handle_mm_fault(mm, vma, address, cause > 0 ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	up_read(&mm->mmap_sem);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index aa33949..31b1e69 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -231,9 +231,10 @@ static inline bool access_error(unsigned int fsr, struct vm_area_struct *vma)
 
 static int __kprobes
 __do_page_fault(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
-		struct task_struct *tsk)
+		struct task_struct *tsk, struct pt_regs *regs)
 {
 	struct vm_area_struct *vma;
+	unsigned long flags = 0;
 	int fault;
 
 	vma = find_vma(mm, addr);
@@ -253,11 +254,16 @@ good_area:
 		goto out;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (fsr & FSR_WRITE)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, (fsr & FSR_WRITE) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, flags);
 	if (unlikely(fault & VM_FAULT_ERROR))
 		return fault;
 	if (fault & VM_FAULT_MAJOR)
@@ -320,7 +326,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 #endif
 	}
 
-	fault = __do_page_fault(mm, addr, fsr, tsk);
+	fault = __do_page_fault(mm, addr, fsr, tsk, regs);
 	up_read(&mm->mmap_sem);
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, addr);
diff --git a/arch/avr32/mm/fault.c b/arch/avr32/mm/fault.c
index f7040a1..ada6237 100644
--- a/arch/avr32/mm/fault.c
+++ b/arch/avr32/mm/fault.c
@@ -59,6 +59,7 @@ asmlinkage void do_page_fault(unsigned long ecr, struct pt_regs *regs)
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	const struct exception_table_entry *fixup;
+	unsigned long flags = 0;
 	unsigned long address;
 	unsigned long page;
 	int writeaccess;
@@ -127,12 +128,17 @@ good_area:
 		panic("Unhandled case %lu in do_page_fault!", ecr);
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (writeaccess)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, writeaccess ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
index 9dcac8e..35d096a 100644
--- a/arch/cris/mm/fault.c
+++ b/arch/cris/mm/fault.c
@@ -55,6 +55,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int fault;
 
@@ -156,13 +157,18 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 			goto bad_area;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (writeaccess & 1)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address, (writeaccess & 1) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/frv/mm/fault.c b/arch/frv/mm/fault.c
index a325d57..2dbf219 100644
--- a/arch/frv/mm/fault.c
+++ b/arch/frv/mm/fault.c
@@ -35,6 +35,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 	struct vm_area_struct *vma;
 	struct mm_struct *mm;
 	unsigned long _pme, lrai, lrad, fixup;
+	unsigned long flags = 0;
 	siginfo_t info;
 	pgd_t *pge;
 	pud_t *pue;
@@ -158,12 +159,17 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 		break;
 	}
 
+	if (user_mode(__frame))
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, ear0, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, ear0, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index c10b76f..e56baf3 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -52,6 +52,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 	siginfo_t info;
 	int si_code = SEGV_MAPERR;
 	int fault;
+	unsigned long flags = 0;
 	const struct exception_table_entry *fixup;
 
 	/*
@@ -96,7 +97,12 @@ good_area:
 		break;
 	}
 
-	fault = handle_mm_fault(mm, vma, address, (cause > 0));
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (cause > 0)
+		flags |= FAULT_FLAG_WRITE;
+
+	fault = handle_mm_fault(mm, vma, address, flags);
 
 	/* The most common case -- we are done. */
 	if (likely(!(fault & VM_FAULT_ERROR))) {
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 20b3593..ad9ef9d 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -79,6 +79,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	int signal = SIGSEGV, code = SEGV_MAPERR;
 	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm = current->mm;
+	unsigned long flags = 0;
 	struct siginfo si;
 	unsigned long mask;
 	int fault;
@@ -149,12 +150,17 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	if ((vma->vm_flags & mask) != mask)
 		goto bad_area;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (mask & VM_WRITE)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, (mask & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
 		 * We ran out of memory, or some other thing happened
diff --git a/arch/m32r/mm/fault.c b/arch/m32r/mm/fault.c
index 2c9aeb4..e74f6fa 100644
--- a/arch/m32r/mm/fault.c
+++ b/arch/m32r/mm/fault.c
@@ -79,6 +79,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
 	unsigned long page, addr;
+	unsigned long flags = 0;
 	int write;
 	int fault;
 	siginfo_t info;
@@ -188,6 +189,11 @@ good_area:
 	if ((error_code & ACE_INSTRUCTION) && !(vma->vm_flags & VM_EXEC))
 	  goto bad_area;
 
+	if (error_code & ACE_USERMODE)
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
@@ -195,7 +201,7 @@ good_area:
 	 */
 	addr = (address & PAGE_MASK);
 	set_thread_fault_code(error_code);
-	fault = handle_mm_fault(mm, vma, addr, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, addr, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index 2db6099..ab88a91 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -73,6 +73,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct * vma;
+	unsigned long flags = 0;
 	int write, fault;
 
 #ifdef DEBUG
@@ -134,13 +135,18 @@ good_area:
 				goto acc_err;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 #ifdef DEBUG
 	printk("handle_mm_fault returns %d\n",fault);
 #endif
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index ae97d2c..b002612 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -89,6 +89,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 {
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int code = SEGV_MAPERR;
 	int is_write = error_code & ESR_S;
@@ -206,12 +207,17 @@ good_area:
 			goto bad_area;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (is_write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, is_write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 937cf33..e5b9fed 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -40,6 +40,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs, unsigned long writ
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 	const int field = sizeof(unsigned long) * 2;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int fault;
 
@@ -139,12 +140,17 @@ good_area:
 		}
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index 0945409..031be56 100644
--- a/arch/mn10300/mm/fault.c
+++ b/arch/mn10300/mm/fault.c
@@ -121,6 +121,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
 {
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
+	unsigned long flags = 0;
 	struct mm_struct *mm;
 	unsigned long page;
 	siginfo_t info;
@@ -247,12 +248,17 @@ good_area:
 		break;
 	}
 
+	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR)
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
@@ -329,9 +335,10 @@ no_context:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	printk(KERN_ALERT "VM: killing process %s\n", tsk->comm);
-	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR)
-		do_exit(SIGKILL);
+	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR) {
+		pagefault_out_of_memory();
+		return;
+	}
 	goto no_context;
 
 do_sigbus:
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index a5dce82..d586119 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -52,6 +52,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int fault;
 
@@ -153,13 +154,18 @@ good_area:
 	if ((vector == 0x400) && !(vma->vm_page_prot.pgprot & _PAGE_EXEC))
 		goto bad_area;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (write_acc)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address, write_acc);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
@@ -246,10 +252,10 @@ out_of_memory:
 	__asm__ __volatile__("l.nop 1");
 
 	up_read(&mm->mmap_sem);
-	printk("VM: killing process %s\n", tsk->comm);
-	if (user_mode(regs))
-		do_exit(SIGKILL);
-	goto no_context;
+	if (!user_mode(regs))
+		goto no_context;
+	pagefault_out_of_memory();
+	return;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index 18162ce..a151e87 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -173,6 +173,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 	struct vm_area_struct *vma, *prev_vma;
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
+	unsigned long flags = 0;
 	unsigned long acc_type;
 	int fault;
 
@@ -195,13 +196,18 @@ good_area:
 	if ((vma->vm_flags & acc_type) != acc_type)
 		goto bad_area;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (acc_type & VM_WRITE)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address, (acc_type & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
 		 * We hit a shared mapping outside of the file, or some
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 5efe8c9..2bf339c 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -122,6 +122,7 @@ int __kprobes do_page_fault(struct pt_regs *regs, unsigned long address,
 {
 	struct vm_area_struct * vma;
 	struct mm_struct *mm = current->mm;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int code = SEGV_MAPERR;
 	int is_write = 0, ret;
@@ -305,12 +306,17 @@ good_area:
 			goto bad_area;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (is_write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	ret = handle_mm_fault(mm, vma, address, is_write ? FAULT_FLAG_WRITE : 0);
+	ret = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(ret & VM_FAULT_ERROR)) {
 		if (ret & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index a9a3018..fe6109c 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -301,6 +301,8 @@ static inline int do_exception(struct pt_regs *regs, int access,
 	address = trans_exc_code & __FAIL_ADDR_MASK;
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 	flags = FAULT_FLAG_ALLOW_RETRY;
+	if (regs->psw.mask & PSW_MASK_PSTATE)
+		flags |= FAULT_FLAG_USER;
 	if (access == VM_WRITE || (trans_exc_code & store_indication) == 0x400)
 		flags |= FAULT_FLAG_WRITE;
 	down_read(&mm->mmap_sem);
diff --git a/arch/score/mm/fault.c b/arch/score/mm/fault.c
index 47b600e..2ca5ae5 100644
--- a/arch/score/mm/fault.c
+++ b/arch/score/mm/fault.c
@@ -47,6 +47,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long write,
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 	const int field = sizeof(unsigned long) * 2;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int fault;
 
@@ -101,12 +102,16 @@ good_area:
 	}
 
 survive:
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
 	/*
 	* If for any reason at all we couldn't handle the fault,
 	* make sure we exit gracefully rather than endlessly redo
 	* the fault.
 	*/
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
@@ -172,10 +177,10 @@ out_of_memory:
 		down_read(&mm->mmap_sem);
 		goto survive;
 	}
-	printk("VM: killing process %s\n", tsk->comm);
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);
-	goto no_context;
+	if (!user_mode(regs))
+		goto no_context;
+	pagefault_out_of_memory();
+	return;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
diff --git a/arch/sh/mm/fault_32.c b/arch/sh/mm/fault_32.c
index 7bebd04..a61b803 100644
--- a/arch/sh/mm/fault_32.c
+++ b/arch/sh/mm/fault_32.c
@@ -126,6 +126,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
+	unsigned long flags = 0;
 	int si_code;
 	int fault;
 	siginfo_t info;
@@ -195,12 +196,17 @@ good_area:
 			goto bad_area;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (writeaccess)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, writeaccess ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sh/mm/tlbflush_64.c b/arch/sh/mm/tlbflush_64.c
index e3430e0..0a9d645 100644
--- a/arch/sh/mm/tlbflush_64.c
+++ b/arch/sh/mm/tlbflush_64.c
@@ -96,6 +96,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long writeaccess,
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
 	const struct exception_table_entry *fixup;
+	unsigned long flags = 0;
 	pte_t *pte;
 	int fault;
 
@@ -184,12 +185,17 @@ good_area:
 		}
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (writeaccess)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, writeaccess ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index 8023fd7..efa3d48 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -222,6 +222,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	struct vm_area_struct *vma;
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
+	unsigned long flags = 0;
 	unsigned int fixup;
 	unsigned long g2;
 	int from_user = !(regs->psr & PSR_PS);
@@ -285,12 +286,17 @@ good_area:
 			goto bad_area;
 	}
 
+	if (from_user)
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 504c062..bc536ea 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -276,6 +276,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	unsigned long flags = 0;
 	unsigned int insn = 0;
 	int si_code, fault_code, fault;
 	unsigned long address, mm_rss;
@@ -423,7 +424,12 @@ good_area:
 			goto bad_area;
 	}
 
-	fault = handle_mm_fault(mm, vma, address, (fault_code & FAULT_CODE_WRITE) ? FAULT_FLAG_WRITE : 0);
+	if (!(regs->tstate & TSTATE_PRIV))
+		flags |= FAULT_FLAG_USER;
+	if (fault_code & FAULT_CODE_WRITE)
+		flags |= FAULT_FLAG_WRITE;
+
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
index 25b7b90..b2a7fd5 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -263,6 +263,7 @@ static int handle_page_fault(struct pt_regs *regs,
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	unsigned long stack_offset;
+	unsigned long flags = 0;
 	int fault;
 	int si_code;
 	int is_kernel_mode;
@@ -415,12 +416,16 @@ good_area:
 	}
 
  survive:
+	if (!is_kernel_mode)
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
@@ -540,10 +545,10 @@ out_of_memory:
 		down_read(&mm->mmap_sem);
 		goto survive;
 	}
-	pr_alert("VM: killing process %s\n", tsk->comm);
-	if (!is_kernel_mode)
-		do_group_exit(SIGKILL);
-	goto no_context;
+	if (is_kernel_mode)
+		goto no_context;
+	pagefault_out_of_memory();
+	return 0;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index dafc947..626a85e 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -25,6 +25,7 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	unsigned long flags = 0;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
@@ -62,10 +63,15 @@ good_area:
 	if (!is_write && !(vma->vm_flags & (VM_READ | VM_EXEC)))
 		goto out;
 
+	if (is_user)
+		flags |= FAULT_FLAG_USER;
+	if (is_write)
+		flags |= FAULT_FLAG_WRITE;
+
 	do {
 		int fault;
 
-		fault = handle_mm_fault(mm, vma, address, is_write ? FAULT_FLAG_WRITE : 0);
+		fault = handle_mm_fault(mm, vma, address, flags);
 		if (unlikely(fault & VM_FAULT_ERROR)) {
 			if (fault & VM_FAULT_OOM) {
 				goto out_of_memory;
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 283aa4b..3026943 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -169,9 +169,10 @@ static inline bool access_error(unsigned int fsr, struct vm_area_struct *vma)
 }
 
 static int __do_pf(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
-		struct task_struct *tsk)
+		   struct task_struct *tsk, struct pt_regs *regs)
 {
 	struct vm_area_struct *vma;
+	unsigned long flags = 0;
 	int fault;
 
 	vma = find_vma(mm, addr);
@@ -191,12 +192,16 @@ good_area:
 		goto out;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (!(fsr ^ 0x12))
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK,
-			    (!(fsr ^ 0x12)) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, flags);
 	if (unlikely(fault & VM_FAULT_ERROR))
 		return fault;
 	if (fault & VM_FAULT_MAJOR)
@@ -252,7 +257,7 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 #endif
 	}
 
-	fault = __do_pf(mm, addr, fsr, tsk);
+	fault = __do_pf(mm, addr, fsr, tsk, regs);
 	up_read(&mm->mmap_sem);
 
 	/*
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 5db0490..90248c9 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -846,17 +846,6 @@ static noinline int
 mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 	       unsigned long address, unsigned int fault)
 {
-	/*
-	 * Pagefault was interrupted by SIGKILL. We have no reason to
-	 * continue pagefault.
-	 */
-	if (fatal_signal_pending(current)) {
-		if (!(fault & VM_FAULT_RETRY))
-			up_read(&current->mm->mmap_sem);
-		if (!(error_code & PF_USER))
-			no_context(regs, error_code, address);
-		return 1;
-	}
 	if (!(fault & VM_FAULT_ERROR))
 		return 0;
 
@@ -999,8 +988,7 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	struct mm_struct *mm;
 	int fault;
 	int write = error_code & PF_WRITE;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-					(write ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1160,6 +1148,11 @@ good_area:
 		return;
 	}
 
+	if (error_code & PF_USER)
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index e367e30..7db9fbe 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -41,6 +41,7 @@ void do_page_fault(struct pt_regs *regs)
 	struct mm_struct *mm = current->mm;
 	unsigned int exccause = regs->exccause;
 	unsigned int address = regs->excvaddr;
+	unsigned long flags = 0;
 	siginfo_t info;
 
 	int is_write, is_exec;
@@ -101,11 +102,16 @@ good_area:
 		if (!(vma->vm_flags & (VM_READ | VM_WRITE)))
 			goto bad_area;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (is_write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/* If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, is_write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b87068a..b92e5e7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -120,6 +120,17 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 
+static inline unsigned int mem_cgroup_xchg_may_oom(struct task_struct *p,
+						   unsigned int new)
+{
+	unsigned int old;
+
+	old = p->memcg_oom.may_oom;
+	p->memcg_oom.may_oom = new;
+
+	return old;
+}
+bool mem_cgroup_oom_synchronize(void);
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
@@ -333,6 +344,17 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
+static inline unsigned int mem_cgroup_xchg_may_oom(struct task_struct *p,
+						   unsigned int new)
+{
+	return 0;
+}
+
+static inline bool mem_cgroup_oom_synchronize(void)
+{
+	return false;
+}
+
 static inline void mem_cgroup_inc_page_stat(struct page *page,
 					    enum mem_cgroup_page_stat_item idx)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4baadd1..846b82b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -156,6 +156,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_ALLOW_RETRY	0x08	/* Retry fault if blocking */
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
+#define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
 
 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1c4f3e9..a77d198 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -91,6 +91,7 @@ struct sched_param {
 #include <linux/latencytop.h>
 #include <linux/cred.h>
 #include <linux/llist.h>
+#include <linux/stacktrace.h>
 
 #include <asm/processor.h>
 
@@ -1568,6 +1569,14 @@ struct task_struct {
 		unsigned long nr_pages;	/* uncharged usage */
 		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
 	} memcg_batch;
+	struct memcg_oom_info {
+		unsigned int may_oom:1;
+		unsigned int in_memcg_oom:1;
+		struct stack_trace trace;
+		unsigned long trace_entries[16];
+		int wakeups;
+		struct mem_cgroup *wait_on_memcg;
+	} memcg_oom;
 #endif
 #ifdef CONFIG_HAVE_HW_BREAKPOINT
 	atomic_t ptrace_bp_refcnt;
diff --git a/mm/filemap.c b/mm/filemap.c
index 5f0a3c9..d18bd47 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1660,6 +1660,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct file_ra_state *ra = &file->f_ra;
 	struct inode *inode = mapping->host;
 	pgoff_t offset = vmf->pgoff;
+	unsigned int may_oom;
 	struct page *page;
 	pgoff_t size;
 	int ret = 0;
@@ -1669,7 +1670,12 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		return VM_FAULT_SIGBUS;
 
 	/*
-	 * Do we have something in the page cache already?
+	 * Do we have something in the page cache already?  Either
+	 * way, try readahead, but disable the memcg OOM killer for it
+	 * as readahead is optional and no errors are propagated up
+	 * the fault stack, which does not allow proper unwinding of a
+	 * memcg OOM state.  The OOM killer is enabled while trying to
+	 * instantiate the faulting page individually below.
 	 */
 	page = find_get_page(mapping, offset);
 	if (likely(page)) {
@@ -1677,10 +1683,14 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		 * We found the page, so try async readahead before
 		 * waiting for the lock.
 		 */
+		may_oom = mem_cgroup_xchg_may_oom(current, 0);
 		do_async_mmap_readahead(vma, ra, file, page, offset);
+		mem_cgroup_xchg_may_oom(current, may_oom);
 	} else {
-		/* No page in the page cache at all */
+		/* No page in the page cache at all. */
+		may_oom = mem_cgroup_xchg_may_oom(current, 0);
 		do_sync_mmap_readahead(vma, ra, file, offset);
+		mem_cgroup_xchg_may_oom(current, may_oom);
 		count_vm_event(PGMAJFAULT);
 		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
diff --git a/mm/ksm.c b/mm/ksm.c
index 310544a..ae7e4ae 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -338,7 +338,7 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 			break;
 		if (PageKsm(page))
 			ret = handle_mm_fault(vma->vm_mm, vma, addr,
-							FAULT_FLAG_WRITE);
+					FAULT_FLAG_WRITE);
 		else
 			ret = VM_FAULT_WRITE;
 		put_page(page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b63f5f7..c47c77e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -49,6 +49,7 @@
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
+#include <linux/stacktrace.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -249,6 +250,7 @@ struct mem_cgroup {
 
 	bool		oom_lock;
 	atomic_t	under_oom;
+	atomic_t	oom_wakeups;
 
 	atomic_t	refcnt;
 
@@ -1846,6 +1848,7 @@ static int memcg_oom_wake_function(wait_queue_t *wait,
 
 static void memcg_wakeup_oom(struct mem_cgroup *memcg)
 {
+	atomic_inc(&memcg->oom_wakeups);
 	/* for filtering, pass "memcg" as argument. */
 	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
 }
@@ -1857,30 +1860,26 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 }
 
 /*
- * try to call OOM killer. returns false if we should exit memory-reclaim loop.
+ * try to call OOM killer
  */
-bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
+static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask)
 {
-	struct oom_wait_info owait;
-	bool locked, need_to_kill;
+	bool locked, need_to_kill = true;
 
-	owait.mem = memcg;
-	owait.wait.flags = 0;
-	owait.wait.func = memcg_oom_wake_function;
-	owait.wait.private = current;
-	INIT_LIST_HEAD(&owait.wait.task_list);
-	need_to_kill = true;
-	mem_cgroup_mark_under_oom(memcg);
+	if (!current->memcg_oom.may_oom)
+		return;
+
+	current->memcg_oom.in_memcg_oom = 1;
+
+	current->memcg_oom.trace.nr_entries = 0;
+	current->memcg_oom.trace.max_entries = 16;
+	current->memcg_oom.trace.entries = current->memcg_oom.trace_entries;
+	current->memcg_oom.trace.skip = 1;
+	save_stack_trace(&current->memcg_oom.trace);
 
 	/* At first, try to OOM lock hierarchy under memcg.*/
 	spin_lock(&memcg_oom_lock);
 	locked = mem_cgroup_oom_lock(memcg);
-	/*
-	 * Even if signal_pending(), we can't quit charge() loop without
-	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
-	 * under OOM is always welcomed, use TASK_KILLABLE here.
-	 */
-	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
 	if (!locked || memcg->oom_kill_disable)
 		need_to_kill = false;
 	if (locked)
@@ -1888,24 +1887,86 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
 	spin_unlock(&memcg_oom_lock);
 
 	if (need_to_kill) {
-		finish_wait(&memcg_oom_waitq, &owait.wait);
 		mem_cgroup_out_of_memory(memcg, mask);
 	} else {
-		schedule();
-		finish_wait(&memcg_oom_waitq, &owait.wait);
+		/*
+		 * A system call can just return -ENOMEM, but if this
+		 * is a page fault and somebody else is handling the
+		 * OOM already, we need to sleep on the OOM waitqueue
+		 * for this memcg until the situation is resolved.
+		 * Which can take some time because it might be
+		 * handled by a userspace task.
+		 *
+		 * However, this is the charge context, which means
+		 * that we may sit on a large call stack and hold
+		 * various filesystem locks, the mmap_sem etc. and we
+		 * don't want the OOM handler to deadlock on them
+		 * while we sit here and wait.  Store the current OOM
+		 * context in the task_struct, then return -ENOMEM.
+		 * At the end of the page fault handler, with the
+		 * stack unwound, pagefault_out_of_memory() will check
+		 * back with us by calling
+		 * mem_cgroup_oom_synchronize(), possibly putting the
+		 * task to sleep.
+		 */
+		mem_cgroup_mark_under_oom(memcg);
+		current->memcg_oom.wakeups = atomic_read(&memcg->oom_wakeups);
+		css_get(&memcg->css);
+		current->memcg_oom.wait_on_memcg = memcg;
 	}
-	spin_lock(&memcg_oom_lock);
-	if (locked)
+
+	if (locked) {
+		spin_lock(&memcg_oom_lock);
 		mem_cgroup_oom_unlock(memcg);
-	memcg_wakeup_oom(memcg);
-	spin_unlock(&memcg_oom_lock);
+		/*
+		 * Sleeping tasks might have been killed, make sure
+		 * they get scheduled so they can exit.
+		 */
+		if (need_to_kill)
+			memcg_oom_recover(memcg);
+		spin_unlock(&memcg_oom_lock);
+	}
+}
 
-	mem_cgroup_unmark_under_oom(memcg);
+bool mem_cgroup_oom_synchronize(void)
+{
+	struct oom_wait_info owait;
+	struct mem_cgroup *memcg;
 
-	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
+	/* OOM is global, do not handle */
+	if (!current->memcg_oom.in_memcg_oom)
 		return false;
-	/* Give chance to dying process */
-	schedule_timeout_uninterruptible(1);
+
+	/*
+	 * We invoked the OOM killer but there is a chance that a kill
+	 * did not free up any charges.  Everybody else might already
+	 * be sleeping, so restart the fault and keep the rampage
+	 * going until some charges are released.
+	 */
+	memcg = current->memcg_oom.wait_on_memcg;
+	if (!memcg)
+		goto out;
+
+	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
+		goto out_put;
+
+	owait.mem = memcg;
+	owait.wait.flags = 0;
+	owait.wait.func = memcg_oom_wake_function;
+	owait.wait.private = current;
+	INIT_LIST_HEAD(&owait.wait.task_list);
+
+	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
+	/* Only sleep if we didn't miss any wakeups since OOM */
+	if (atomic_read(&memcg->oom_wakeups) == current->memcg_oom.wakeups)
+		schedule();
+	finish_wait(&memcg_oom_waitq, &owait.wait);
+out_put:
+	mem_cgroup_unmark_under_oom(memcg);
+	css_put(&memcg->css);
+	current->memcg_oom.wait_on_memcg = NULL;
+out:
+	current->memcg_oom.in_memcg_oom = 0;
 	return true;
 }
 
@@ -2195,11 +2256,10 @@ enum {
 	CHARGE_RETRY,		/* need to retry but retry is not bad */
 	CHARGE_NOMEM,		/* we can't do more. return -ENOMEM */
 	CHARGE_WOULDBLOCK,	/* GFP_WAIT wasn't set and no enough res. */
-	CHARGE_OOM_DIE,		/* the current is killed because of OOM */
 };
 
 static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
-				unsigned int nr_pages, bool oom_check)
+				unsigned int nr_pages, bool invoke_oom)
 {
 	unsigned long csize = nr_pages * PAGE_SIZE;
 	struct mem_cgroup *mem_over_limit;
@@ -2257,14 +2317,10 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (mem_cgroup_wait_acct_move(mem_over_limit))
 		return CHARGE_RETRY;
 
-	/* If we don't need to call oom-killer at el, return immediately */
-	if (!oom_check)
-		return CHARGE_NOMEM;
-	/* check OOM */
-	if (!mem_cgroup_handle_oom(mem_over_limit, gfp_mask))
-		return CHARGE_OOM_DIE;
+	if (invoke_oom)
+		mem_cgroup_oom(mem_over_limit, gfp_mask);
 
-	return CHARGE_RETRY;
+	return CHARGE_NOMEM;
 }
 
 /*
@@ -2349,7 +2405,7 @@ again:
 	}
 
 	do {
-		bool oom_check;
+		bool invoke_oom = oom && !nr_oom_retries;
 
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current)) {
@@ -2357,13 +2413,7 @@ again:
 			goto bypass;
 		}
 
-		oom_check = false;
-		if (oom && !nr_oom_retries) {
-			oom_check = true;
-			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
-		}
-
-		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch, oom_check);
+		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch, invoke_oom);
 		switch (ret) {
 		case CHARGE_OK:
 			break;
@@ -2376,16 +2426,12 @@ again:
 			css_put(&memcg->css);
 			goto nomem;
 		case CHARGE_NOMEM: /* OOM routine works */
-			if (!oom) {
+			if (!oom || invoke_oom) {
 				css_put(&memcg->css);
 				goto nomem;
 			}
-			/* If oom, we never return -ENOMEM */
 			nr_oom_retries--;
 			break;
-		case CHARGE_OOM_DIE: /* Killed by OOM Killer */
-			css_put(&memcg->css);
-			goto bypass;
 		}
 	} while (ret != CHARGE_OK);
 
diff --git a/mm/memory.c b/mm/memory.c
index 829d437..fc6d741 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/stacktrace.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3439,22 +3440,14 @@ unlock:
 /*
  * By the time we get here, we already hold the mm semaphore
  */
-int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags)
+static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+			     unsigned long address, unsigned int flags)
 {
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
-	__set_current_state(TASK_RUNNING);
-
-	count_vm_event(PGFAULT);
-	mem_cgroup_count_vm_event(mm, PGFAULT);
-
-	/* do counter updates before entering really critical section. */
-	check_sync_rss_stat(current);
-
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, flags);
 
@@ -3503,6 +3496,39 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }
 
+int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		    unsigned long address, unsigned int flags)
+{
+	int userfault = flags & FAULT_FLAG_USER;
+	int ret;
+
+	__set_current_state(TASK_RUNNING);
+
+	count_vm_event(PGFAULT);
+	mem_cgroup_count_vm_event(mm, PGFAULT);
+
+	/* do counter updates before entering really critical section. */
+	check_sync_rss_stat(current);
+
+	if (userfault)
+		WARN_ON(mem_cgroup_xchg_may_oom(current, 1) == 1);
+
+	ret = __handle_mm_fault(mm, vma, address, flags);
+
+	if (userfault)
+		WARN_ON(mem_cgroup_xchg_may_oom(current, 0) == 0);
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	if (WARN(!(ret & VM_FAULT_OOM) && current->memcg_oom.in_memcg_oom,
+		 "Fixing unhandled memcg OOM context, set up from:\n")) {
+		print_stack_trace(&current->memcg_oom.trace, 0);
+		mem_cgroup_oom_synchronize();
+	}
+#endif
+
+	return ret;
+}
+
 #ifndef __PAGETABLE_PUD_FOLDED
 /*
  * Allocate page upper directory.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 069b64e..aa60863 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -785,6 +785,8 @@ out:
  */
 void pagefault_out_of_memory(void)
 {
+	if (mem_cgroup_oom_synchronize())
+		return;
 	if (try_set_system_oom()) {
 		out_of_memory(NULL, 0, 0, NULL);
 		clear_system_oom();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
