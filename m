Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 752EB6B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 12:56:53 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id o10so6113718iod.21
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:56:53 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0052.hostedemail.com. [216.40.44.52])
        by mx.google.com with ESMTPS id 124-v6si2688249itu.33.2018.03.15.09.56.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 09:56:51 -0700 (PDT)
Message-ID: <1521133006.22221.35.camel@perches.com>
Subject: rfc: remove print_vma_addr ? (was Re: [PATCH 00/16] remove eight
 obsolete architectures)
From: Joe Perches <joe@perches.com>
Date: Thu, 15 Mar 2018 09:56:46 -0700
In-Reply-To: <CAMuHMdXcxuzCOnFCNm4NXDv-wfYJDO5GQpB_ECu7j=2BjMhNpA@mail.gmail.com>
References: <20180314143529.1456168-1-arnd@arndb.de>
	 <2929.1521106970@warthog.procyon.org.uk>
	 <CAMuHMdXcxuzCOnFCNm4NXDv-wfYJDO5GQpB_ECu7j=2BjMhNpA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>, David Howells <dhowells@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Linux-Arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, linux-block@vger.kernel.org, linux-ide@vger.kernel.org, linux-input@vger.kernel.org, netdev <netdev@vger.kernel.org>, linux-wireless <linux-wireless@vger.kernel.org>, Linux PWM List <linux-pwm@vger.kernel.org>, linux-rtc@vger.kernel.org, linux-spi <linux-spi@vger.kernel.org>, USB list <linux-usb@vger.kernel.org>, DRI Development <dri-devel@lists.freedesktop.org>, Linux Fbdev development list <linux-fbdev@vger.kernel.org>, Linux Watchdog Mailing List <linux-watchdog@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, 2018-03-15 at 10:48 +0100, Geert Uytterhoeven wrote:
> Hi David,
> 
> On Thu, Mar 15, 2018 at 10:42 AM, David Howells <dhowells@redhat.com> wrote:
> > Do we have anything left that still implements NOMMU?
> 
> Sure: arm, c6x, m68k, microblaze, and  sh.

I have a patchset that creates a vsprintf extension for
print_vma_addr and removes all the uses similar to the
print_symbol() removal.

This now avoids any possible printk interleaving.

Unfortunately, without some #ifdef in vsprintf, which
I would like to avoid, it increases the nommu kernel
size by ~500 bytes.

Anyone think this is acceptable?

Here's the overall patch, but I have it as a series
---
 Documentation/core-api/printk-formats.rst |  9 +++++
 arch/arm64/kernel/traps.c                 | 13 +++----
 arch/mips/mm/fault.c                      | 16 ++++-----
 arch/parisc/mm/fault.c                    | 15 ++++----
 arch/riscv/kernel/traps.c                 | 11 +++---
 arch/s390/mm/fault.c                      |  7 ++--
 arch/sparc/mm/fault_32.c                  |  8 ++---
 arch/sparc/mm/fault_64.c                  |  8 ++---
 arch/tile/kernel/signal.c                 |  9 ++---
 arch/um/kernel/trap.c                     | 13 +++----
 arch/x86/kernel/signal.c                  | 10 ++----
 arch/x86/kernel/traps.c                   | 18 ++++------
 arch/x86/mm/fault.c                       | 12 +++----
 include/linux/mm.h                        |  1 -
 lib/vsprintf.c                            | 58 ++++++++++++++++++++++++++-----
 mm/memory.c                               | 33 ------------------
 16 files changed, 112 insertions(+), 129 deletions(-)

diff --git a/Documentation/core-api/printk-formats.rst b/Documentation/core-api/printk-formats.rst
index 934559b3c130..10a91da1bc83 100644
--- a/Documentation/core-api/printk-formats.rst
+++ b/Documentation/core-api/printk-formats.rst
@@ -157,6 +157,15 @@ DMA address types dma_addr_t
 For printing a dma_addr_t type which can vary based on build options,
 regardless of the width of the CPU data path.
 
+VMA name and address
+----------------------------
+
+::
+
+	%pav	<name>[hexstart+hexsize] or ?[0+0] if unavailable
+
+For any address, print the vma's name and its starting address and size
+
 Passed by reference.
 
 Raw buffer as an escaped string
diff --git a/arch/arm64/kernel/traps.c b/arch/arm64/kernel/traps.c
index 2b478565d774..48edf812ce8b 100644
--- a/arch/arm64/kernel/traps.c
+++ b/arch/arm64/kernel/traps.c
@@ -242,13 +242,14 @@ void arm64_force_sig_info(struct siginfo *info, const char *str,
 	if (!show_unhandled_signals_ratelimited())
 		goto send_sig;
 
-	pr_info("%s[%d]: unhandled exception: ", tsk->comm, task_pid_nr(tsk));
 	if (esr)
-		pr_cont("%s, ESR 0x%08x, ", esr_get_class_string(esr), esr);
-
-	pr_cont("%s", str);
-	print_vma_addr(KERN_CONT " in ", regs->pc);
-	pr_cont("\n");
+		pr_info("%s[%d]: unhandled exception: %s, ESR 0x%08x, %s in %pav\n",
+			tsk->comm, task_pid_nr(tsk),
+			esr_get_class_string(esr), esr,
+			str, &regs->pc);
+	else
+		pr_info("%s[%d]: unhandled exception: %s in %pav\n",
+			tsk->comm, task_pid_nr(tsk), str, &regs->pc);
 	__show_regs(regs);
 
 send_sig:
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 4f8f5bf46977..ce7bf077a0f5 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -213,14 +213,14 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 				tsk->comm,
 				write ? "write access to" : "read access from",
 				field, address);
-			pr_info("epc = %0*lx in", field,
-				(unsigned long) regs->cp0_epc);
-			print_vma_addr(KERN_CONT " ", regs->cp0_epc);
-			pr_cont("\n");
-			pr_info("ra  = %0*lx in", field,
-				(unsigned long) regs->regs[31]);
-			print_vma_addr(KERN_CONT " ", regs->regs[31]);
-			pr_cont("\n");
+			pr_info("epc = %0*lx in %pav\n",
+				field,
+				(unsigned long)regs->cp0_epc,
+				&regs->cp0_epc);
+			pr_info("ra  = %0*lx in %pav\n",
+				field,
+				(unsigned long)regs->regs[31],
+				&regs->regs[31]);
 		}
 		current->thread.trap_nr = (regs->cp0_cause >> 2) & 0x1f;
 		info.si_signo = SIGSEGV;
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index e247edbca68e..877cea702714 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -240,17 +240,14 @@ show_signal_msg(struct pt_regs *regs, unsigned long code,
 	if (!printk_ratelimit())
 		return;
 
-	pr_warn("\n");
-	pr_warn("do_page_fault() command='%s' type=%lu address=0x%08lx",
-	    tsk->comm, code, address);
-	print_vma_addr(KERN_CONT " in ", regs->iaoq[0]);
-
-	pr_cont("\ntrap #%lu: %s%c", code, trap_name(code),
-		vma ? ',':'\n');
+	pr_warn("do_page_fault() command='%s' type=%lu address=0x%08lx in %pav\n",
+		tsk->comm, code, address, &regs->iaoq[0]);
 
 	if (vma)
-		pr_cont(" vm_start = 0x%08lx, vm_end = 0x%08lx\n",
-			vma->vm_start, vma->vm_end);
+		pr_warn("trap #%lu: %s%c, vm_start = 0x%08lx, vm_end = 0x%08lx\n",
+			code, trap_name(code), vma->vm_start, vma->vm_end);
+	else
+		pr_warn("trap #%lu: %s%c\n", code, trap_name(code));
 
 	show_regs(regs);
 }
diff --git a/arch/riscv/kernel/traps.c b/arch/riscv/kernel/traps.c
index 93132cb59184..16609dcb2546 100644
--- a/arch/riscv/kernel/traps.c
+++ b/arch/riscv/kernel/traps.c
@@ -78,12 +78,11 @@ static inline void do_trap_siginfo(int signo, int code,
 void do_trap(struct pt_regs *regs, int signo, int code,
 	unsigned long addr, struct task_struct *tsk)
 {
-	if (show_unhandled_signals && unhandled_signal(tsk, signo)
-	    && printk_ratelimit()) {
-		pr_info("%s[%d]: unhandled signal %d code 0x%x at 0x" REG_FMT,
-			tsk->comm, task_pid_nr(tsk), signo, code, addr);
-		print_vma_addr(KERN_CONT " in ", GET_IP(regs));
-		pr_cont("\n");
+	if (show_unhandled_signals && unhandled_signal(tsk, signo) &&
+	    printk_ratelimit()) {
+		pr_info("%s[%d]: unhandled signal %d code 0x%x at 0x" REG_FMT " in %pav\n",
+			tsk->comm, task_pid_nr(tsk), signo, code, addr,
+			&GET_IP(regs));
 		show_regs(regs);
 	}
 
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 93faeca52284..3b1d6d618af2 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -250,10 +250,9 @@ void report_user_fault(struct pt_regs *regs, long signr, int is_mm_fault)
 		return;
 	if (!printk_ratelimit())
 		return;
-	printk(KERN_ALERT "User process fault: interruption code %04x ilc:%d ",
-	       regs->int_code & 0xffff, regs->int_code >> 17);
-	print_vma_addr(KERN_CONT "in ", regs->psw.addr);
-	printk(KERN_CONT "\n");
+	printk(KERN_ALERT "User process fault: interruption code %04x ilc:%d in %pav\n",
+	       regs->int_code & 0xffff, regs->int_code >> 17,
+	       &regs->psw.addr);
 	if (is_mm_fault)
 		dump_fault_info(regs);
 	show_regs(regs);
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index a8103a84b4ac..206ec5a1c915 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -113,15 +113,11 @@ show_signal_msg(struct pt_regs *regs, int sig, int code,
 	if (!printk_ratelimit())
 		return;
 
-	printk("%s%s[%d]: segfault at %lx ip %px (rpc %px) sp %px error %x",
+	printk("%s%s[%d]: segfault at %lx ip %px (rpc %px) sp %px error %x in %pav\n",
 	       task_pid_nr(tsk) > 1 ? KERN_INFO : KERN_EMERG,
 	       tsk->comm, task_pid_nr(tsk), address,
 	       (void *)regs->pc, (void *)regs->u_regs[UREG_I7],
-	       (void *)regs->u_regs[UREG_FP], code);
-
-	print_vma_addr(KERN_CONT " in ", regs->pc);
-
-	printk(KERN_CONT "\n");
+	       (void *)regs->u_regs[UREG_FP], code, &regs->pc);
 }
 
 static void __do_fault_siginfo(int code, int sig, struct pt_regs *regs,
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 41363f46797b..a21199329ebe 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -154,15 +154,11 @@ show_signal_msg(struct pt_regs *regs, int sig, int code,
 	if (!printk_ratelimit())
 		return;
 
-	printk("%s%s[%d]: segfault at %lx ip %px (rpc %px) sp %px error %x",
+	printk("%s%s[%d]: segfault at %lx ip %px (rpc %px) sp %px error %x in %pav\b",
 	       task_pid_nr(tsk) > 1 ? KERN_INFO : KERN_EMERG,
 	       tsk->comm, task_pid_nr(tsk), address,
 	       (void *)regs->tpc, (void *)regs->u_regs[UREG_I7],
-	       (void *)regs->u_regs[UREG_FP], code);
-
-	print_vma_addr(KERN_CONT " in ", regs->tpc);
-
-	printk(KERN_CONT "\n");
+	       (void *)regs->u_regs[UREG_FP], code, &regs->tpc);
 }
 
 static void do_fault_siginfo(int code, int sig, struct pt_regs *regs,
diff --git a/arch/tile/kernel/signal.c b/arch/tile/kernel/signal.c
index f2bf557bb005..0556106dfe8a 100644
--- a/arch/tile/kernel/signal.c
+++ b/arch/tile/kernel/signal.c
@@ -383,13 +383,10 @@ void trace_unhandled_signal(const char *type, struct pt_regs *regs,
 	if (show_unhandled_signals <= 1 && !printk_ratelimit())
 		return;
 
-	printk("%s%s[%d]: %s at %lx pc "REGFMT" signal %d",
+	printk("%s%s[%d]: %s at %lx pc " REGFMT " signal %d in %pav\n",
 	       task_pid_nr(tsk) > 1 ? KERN_INFO : KERN_EMERG,
-	       tsk->comm, task_pid_nr(tsk), type, address, regs->pc, sig);
-
-	print_vma_addr(KERN_CONT " in ", regs->pc);
-
-	printk(KERN_CONT "\n");
+	       tsk->comm, task_pid_nr(tsk), type, address, regs->pc, sig,
+	       &regs->pc);
 
 	if (show_unhandled_signals > 1) {
 		switch (sig) {
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index b2b02df9896e..9281248972c0 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -150,14 +150,11 @@ static void show_segv_info(struct uml_pt_regs *regs)
 	if (!printk_ratelimit())
 		return;
 
-	printk("%s%s[%d]: segfault at %lx ip %px sp %px error %x",
-		task_pid_nr(tsk) > 1 ? KERN_INFO : KERN_EMERG,
-		tsk->comm, task_pid_nr(tsk), FAULT_ADDRESS(*fi),
-		(void *)UPT_IP(regs), (void *)UPT_SP(regs),
-		fi->error_code);
-
-	print_vma_addr(KERN_CONT " in ", UPT_IP(regs));
-	printk(KERN_CONT "\n");
+	printk("%s%s[%d]: segfault at %lx ip %px sp %px error %x in %pav\n",
+	       task_pid_nr(tsk) > 1 ? KERN_INFO : KERN_EMERG,
+	       tsk->comm, task_pid_nr(tsk), FAULT_ADDRESS(*fi),
+	       (void *)UPT_IP(regs), (void *)UPT_SP(regs),
+	       fi->error_code, &UPT_IP(regs));
 }
 
 static void bad_segv(struct faultinfo fi, unsigned long ip)
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index 4cdc0b27ec82..9ab0c5c50b29 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -841,15 +841,11 @@ void signal_fault(struct pt_regs *regs, void __user *frame, char *where)
 {
 	struct task_struct *me = current;
 
-	if (show_unhandled_signals && printk_ratelimit()) {
-		printk("%s"
-		       "%s[%d] bad frame in %s frame:%p ip:%lx sp:%lx orax:%lx",
+	if (show_unhandled_signals && printk_ratelimit())
+		printk("%s%s[%d] bad frame in %s frame:%p ip:%lx sp:%lx orax:%lx in %pav\n",
 		       task_pid_nr(current) > 1 ? KERN_INFO : KERN_EMERG,
 		       me->comm, me->pid, where, frame,
-		       regs->ip, regs->sp, regs->orig_ax);
-		print_vma_addr(KERN_CONT " in ", regs->ip);
-		pr_cont("\n");
-	}
+		       regs->ip, regs->sp, regs->orig_ax, &regs->ip);
 
 	force_sig(SIGSEGV, me);
 }
diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
index 3d9b2308e7fa..c6e3d02759e5 100644
--- a/arch/x86/kernel/traps.c
+++ b/arch/x86/kernel/traps.c
@@ -270,13 +270,10 @@ do_trap(int trapnr, int signr, char *str, struct pt_regs *regs,
 	tsk->thread.trap_nr = trapnr;
 
 	if (show_unhandled_signals && unhandled_signal(tsk, signr) &&
-	    printk_ratelimit()) {
-		pr_info("%s[%d] trap %s ip:%lx sp:%lx error:%lx",
+	    printk_ratelimit())
+		pr_info("%s[%d] trap %s ip:%lx sp:%lx error:%lx in %pav\n",
 			tsk->comm, tsk->pid, str,
-			regs->ip, regs->sp, error_code);
-		print_vma_addr(KERN_CONT " in ", regs->ip);
-		pr_cont("\n");
-	}
+			regs->ip, regs->sp, error_code, &regs->ip);
 
 	force_sig_info(signr, info ?: SEND_SIG_PRIV, tsk);
 }
@@ -565,13 +562,10 @@ do_general_protection(struct pt_regs *regs, long error_code)
 	tsk->thread.trap_nr = X86_TRAP_GP;
 
 	if (show_unhandled_signals && unhandled_signal(tsk, SIGSEGV) &&
-			printk_ratelimit()) {
-		pr_info("%s[%d] general protection ip:%lx sp:%lx error:%lx",
+			printk_ratelimit())
+		pr_info("%s[%d] general protection ip:%lx sp:%lx error:%lx in %pav\n",
 			tsk->comm, task_pid_nr(tsk),
-			regs->ip, regs->sp, error_code);
-		print_vma_addr(KERN_CONT " in ", regs->ip);
-		pr_cont("\n");
-	}
+			regs->ip, regs->sp, error_code, &regs->ip);
 
 	force_sig_info(SIGSEGV, SEND_SIG_PRIV, tsk);
 }
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index e6af2b464c3d..b629319e621a 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -857,14 +857,10 @@ show_signal_msg(struct pt_regs *regs, unsigned long error_code,
 	if (!printk_ratelimit())
 		return;
 
-	printk("%s%s[%d]: segfault at %lx ip %px sp %px error %lx",
-		task_pid_nr(tsk) > 1 ? KERN_INFO : KERN_EMERG,
-		tsk->comm, task_pid_nr(tsk), address,
-		(void *)regs->ip, (void *)regs->sp, error_code);
-
-	print_vma_addr(KERN_CONT " in ", regs->ip);
-
-	printk(KERN_CONT "\n");
+	printk("%s%s[%d]: segfault at %lx ip %px sp %px error %lx in %pav\n",
+	       task_pid_nr(tsk) > 1 ? KERN_INFO : KERN_EMERG,
+	       tsk->comm, task_pid_nr(tsk), address,
+	       (void *)regs->ip, (void *)regs->sp, error_code, &regs->ip);
 }
 
 static void
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9f1270360983..9584bd3e8c25 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2537,7 +2537,6 @@ extern int randomize_va_space;
 #endif
 
 const char * arch_vma_name(struct vm_area_struct *vma);
-void print_vma_addr(char *prefix, unsigned long rip);
 
 void sparse_mem_maps_populate_node(struct page **map_map,
 				   unsigned long pnum_begin,
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 942b5234a59b..9081476ea4ea 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -35,6 +35,8 @@
 #include <net/addrconf.h>
 #include <linux/siphash.h>
 #include <linux/compiler.h>
+#include <linux/mm_types.h>
+
 #ifdef CONFIG_BLOCK
 #include <linux/blkdev.h>
 #endif
@@ -407,6 +409,11 @@ struct printf_spec {
 #define FIELD_WIDTH_MAX ((1 << 23) - 1)
 #define PRECISION_MAX ((1 << 15) - 1)
 
+static const struct printf_spec strspec = {
+	.field_width = -1,
+	.precision = -1,
+};
+
 static noinline_for_stack
 char *number(char *buf, char *end, unsigned long long num,
 	     struct printf_spec spec)
@@ -1427,6 +1434,45 @@ char *netdev_bits(char *buf, char *end, const void *addr, const char *fmt)
 	return special_hex_number(buf, end, num, size);
 }
 
+static noinline_for_stack
+char *vma_addr(char *buf, char *end, const void *addr)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	char *page;
+	char tbuf[2 * sizeof(unsigned long) * 2 + 4];
+	const char *output = "?[0+0]";
+
+	/*
+	 * we might be running from an atomic context so we cannot sleep
+	 */
+	if (!down_read_trylock(&mm->mmap_sem))
+		goto output;
+
+	vma = find_vma(mm, *(unsigned long *)addr);
+	if (!vma || !vma->vm_file)
+		goto up_read;
+
+	page = (char *)__get_free_page(GFP_ATOMIC | __GFP_NOWARN);
+	if (page) {
+		char *fp;
+
+		fp = file_path(vma->vm_file, page, PAGE_SIZE);
+		if (IS_ERR(fp))
+			fp = "?";
+		buf = string(buf, end, kbasename(fp), strspec);
+		sprintf(tbuf, "[%lx+%lx]",
+			vma->vm_start, vma->vm_end - vma->vm_start);
+		output = tbuf;
+		free_page((unsigned long)page);
+	}
+
+up_read:
+	up_read(&mm->mmap_sem);
+output:
+	return string(buf, end, output, strspec);
+}
+
 static noinline_for_stack
 char *address_val(char *buf, char *end, const void *addr, const char *fmt)
 {
@@ -1434,6 +1480,8 @@ char *address_val(char *buf, char *end, const void *addr, const char *fmt)
 	int size;
 
 	switch (fmt[1]) {
+	case 'v':
+		return vma_addr(buf, end, addr);
 	case 'd':
 		num = *(const dma_addr_t *)addr;
 		size = sizeof(dma_addr_t);
@@ -1474,11 +1522,7 @@ char *format_flags(char *buf, char *end, unsigned long flags,
 					const struct trace_print_flags *names)
 {
 	unsigned long mask;
-	const struct printf_spec strspec = {
-		.field_width = -1,
-		.precision = -1,
-	};
-	const struct printf_spec numspec = {
+	static const struct printf_spec numspec = {
 		.flags = SPECIAL|SMALL,
 		.field_width = -1,
 		.precision = -1,
@@ -1548,10 +1592,6 @@ char *device_node_gen_full_name(const struct device_node *np, char *buf, char *e
 {
 	int depth;
 	const struct device_node *parent = np->parent;
-	static const struct printf_spec strspec = {
-		.field_width = -1,
-		.precision = -1,
-	};
 
 	/* special case for root node */
 	if (!parent)
diff --git a/mm/memory.c b/mm/memory.c
index bc760df8a7f4..f1f922421bde 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4502,39 +4502,6 @@ int access_process_vm(struct task_struct *tsk, unsigned long addr,
 }
 EXPORT_SYMBOL_GPL(access_process_vm);
 
-/*
- * Print the name of a VMA.
- */
-void print_vma_addr(char *prefix, unsigned long ip)
-{
-	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma;
-
-	/*
-	 * we might be running from an atomic context so we cannot sleep
-	 */
-	if (!down_read_trylock(&mm->mmap_sem))
-		return;
-
-	vma = find_vma(mm, ip);
-	if (vma && vma->vm_file) {
-		struct file *f = vma->vm_file;
-		char *buf = (char *)__get_free_page(GFP_NOWAIT);
-		if (buf) {
-			char *p;
-
-			p = file_path(f, buf, PAGE_SIZE);
-			if (IS_ERR(p))
-				p = "?";
-			printk("%s%s[%lx+%lx]", prefix, kbasename(p),
-					vma->vm_start,
-					vma->vm_end - vma->vm_start);
-			free_page((unsigned long)buf);
-		}
-	}
-	up_read(&mm->mmap_sem);
-}
-
 #if defined(CONFIG_PROVE_LOCKING) || defined(CONFIG_DEBUG_ATOMIC_SLEEP)
 void __might_fault(const char *file, int line)
 {
