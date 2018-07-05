Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Thu, 5 Jul 2018 10:12:13 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
 <063c785caa11b8e1c421c656b2a030d45d6eb68f.camel@perches.com>
 <20180704070305.GB4352@rapoport-lnx>
 <d9bc90af283e03226bcc632e5c8bdf3b5d654b63.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9bc90af283e03226bcc632e5c8bdf3b5d654b63.camel@perches.com>
Message-Id: <20180705071212.GA20591@rapoport-lnx>
Sender: linux-kernel-owner@vger.kernel.org
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 04, 2018 at 10:22:32AM -0700, Joe Perches wrote:
> On Wed, 2018-07-04 at 10:03 +0300, Mike Rapoport wrote:
> > On Tue, Jul 03, 2018 at 01:24:07PM -0700, Joe Perches wrote:
> > > On Tue, 2018-07-03 at 12:57 -0700, Andrew Morton wrote:
> > > > Did you see all this checkpatch noise?
> > > > 
> > > > : WARNING: Deprecated vsprintf pointer extension '%pF' - use %pS instead
> > > > : #54: FILE: mm/memblock.c:1348:
> > > > : +	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
> > > > : +		     __func__, (u64)size, (u64)align, nid, &min_addr,
> > > > : +		     &max_addr, (void *)_RET_IP_);
> > > > : ...
> > > 
> > > %p[Ff] got deprecated by commit 04b8eb7a4ccd9ef9343e2720ccf2a5db8cfe2f67
> > > 
> > > I think it'd be simplest to just convert
> > > all the %pF and %pf uses all at once.
> > > 
> > > $ git grep --name-only "%p[Ff]" | \
> > >   xargs sed -i -e 's/%pF/%pS/' -e 's/%pf/%ps/'
> > > 
> > > and remove the appropriate Documentation bit.
> > > 
> > 
> > Something like this:
> 
> not quite as you either need to run the command
> multiple times or use

You are right. I've just blindly copied the command from email without
thinking :(
 
> $ git grep --name-only "%p[Ff]" | \
>   xargs sed -i -e 's/%pF/%pS/g' -e 's/%pf/%ps/g'

Here's the updated version:

>From 5920af255b14ad41f031210e29157484aeeffbf1 Mon Sep 17 00:00:00 2001
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Wed, 4 Jul 2018 09:55:50 +0300
Subject: [PATCH] treewide: retire '%pF/%pf'

%p[Ff] got deprecated by commit 04b8eb7a4ccd9ef9343e2720ccf2a5db8cfe2f67
("symbol lookup: introduce dereference_symbol_descriptor()")

Replace their uses with %p[Ss] with

$ git grep --name-only "%p[Ff]" | \
  xargs sed -i -e 's/%pF/%pS/g' -e 's/%pf/%ps/g'

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/core-api/printk-formats.rst | 10 ----------
 arch/alpha/kernel/pci_iommu.c             | 20 ++++++++++----------
 arch/arm/mm/alignment.c                   |  2 +-
 arch/arm/nwfpe/fpmodule.c                 |  2 +-
 arch/microblaze/mm/pgtable.c              |  2 +-
 arch/sparc/kernel/ds.c                    |  2 +-
 arch/um/kernel/sysrq.c                    |  2 +-
 arch/x86/include/asm/trace/exceptions.h   |  2 +-
 arch/x86/kernel/irq_64.c                  |  2 +-
 arch/x86/mm/extable.c                     |  4 ++--
 arch/x86/xen/multicalls.c                 |  2 +-
 drivers/acpi/device_pm.c                  |  2 +-
 drivers/base/power/main.c                 |  6 +++---
 drivers/base/syscore.c                    | 12 ++++++------
 drivers/block/drbd/drbd_receiver.c        |  2 +-
 drivers/block/floppy.c                    | 10 +++++-----
 drivers/cpufreq/cpufreq.c                 |  2 +-
 drivers/md/bcache/closure.c               |  4 ++--
 drivers/mmc/core/quirks.h                 |  2 +-
 drivers/nvdimm/bus.c                      |  2 +-
 drivers/nvdimm/dimm_devs.c                |  2 +-
 drivers/pci/pci-driver.c                  | 14 +++++++-------
 drivers/pci/quirks.c                      |  4 ++--
 drivers/pnp/quirks.c                      |  2 +-
 drivers/scsi/esp_scsi.c                   |  2 +-
 fs/btrfs/tests/free-space-tree-tests.c    |  4 ++--
 fs/f2fs/f2fs.h                            |  2 +-
 fs/pstore/inode.c                         |  2 +-
 fs/xfs/scrub/trace.h                      |  2 +-
 include/trace/events/btrfs.h              |  2 +-
 include/trace/events/cpuhp.h              |  4 ++--
 include/trace/events/preemptirq.h         |  2 +-
 include/trace/events/rcu.h                |  4 ++--
 include/trace/events/sunrpc.h             |  2 +-
 include/trace/events/timer.h              |  8 ++++----
 include/trace/events/vmscan.h             |  4 ++--
 include/trace/events/workqueue.h          |  4 ++--
 include/trace/events/xen.h                |  2 +-
 init/main.c                               |  6 +++---
 kernel/async.c                            |  4 ++--
 kernel/events/uprobes.c                   |  2 +-
 kernel/fail_function.c                    |  2 +-
 kernel/irq/debugfs.c                      |  2 +-
 kernel/irq/handle.c                       |  2 +-
 kernel/irq/manage.c                       |  2 +-
 kernel/irq/spurious.c                     |  4 ++--
 kernel/rcu/tree.c                         |  2 +-
 kernel/stop_machine.c                     |  2 +-
 kernel/time/sched_clock.c                 |  2 +-
 kernel/time/timer.c                       |  2 +-
 kernel/workqueue.c                        | 12 ++++++------
 lib/error-inject.c                        |  2 +-
 lib/percpu-refcount.c                     |  4 ++--
 lib/vsprintf.c                            |  8 ++------
 mm/memblock.c                             | 16 ++++++++--------
 mm/memory.c                               |  2 +-
 mm/vmscan.c                               |  2 +-
 net/ceph/osd_client.c                     |  2 +-
 net/core/net-procfs.c                     |  2 +-
 net/core/netpoll.c                        |  4 ++--
 tools/lib/traceevent/event-parse.c        |  4 ++--
 61 files changed, 117 insertions(+), 131 deletions(-)

diff --git a/Documentation/core-api/printk-formats.rst b/Documentation/core-api/printk-formats.rst
index 25dc591..302af61 100644
--- a/Documentation/core-api/printk-formats.rst
+++ b/Documentation/core-api/printk-formats.rst
@@ -70,8 +70,6 @@ Symbols/Function Pointers
 
 	%pS	versatile_init+0x0/0x110
 	%ps	versatile_init
-	%pF	versatile_init+0x0/0x110
-	%pf	versatile_init
 	%pSR	versatile_init+0x9/0x110
 		(with __builtin_extract_return_addr() translation)
 	%pB	prev_fn_of_versatile_init+0x88/0x88
@@ -81,14 +79,6 @@ The ``S`` and ``s`` specifiers are used for printing a pointer in symbolic
 format. They result in the symbol name with (S) or without (s)
 offsets. If KALLSYMS are disabled then the symbol address is printed instead.
 
-Note, that the ``F`` and ``f`` specifiers are identical to ``S`` (``s``)
-and thus deprecated. We have ``F`` and ``f`` because on ia64, ppc64 and
-parisc64 function pointers are indirect and, in fact, are function
-descriptors, which require additional dereferencing before we can lookup
-the symbol. As of now, ``S`` and ``s`` perform dereferencing on those
-platforms (when needed), so ``F`` and ``f`` exist for compatibility
-reasons only.
-
 The ``B`` specifier results in the symbol name with offsets and should be
 used when printing stack backtraces. The specifier takes into
 consideration the effect of compiler optimisations which may occur
diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
index 6923b0d..8afb14c 100644
--- a/arch/alpha/kernel/pci_iommu.c
+++ b/arch/alpha/kernel/pci_iommu.c
@@ -237,7 +237,7 @@ static int pci_dac_dma_supported(struct pci_dev *dev, u64 mask)
 		ok = 0;
 
 	/* If both conditions above are met, we are fine. */
-	DBGA("pci_dac_dma_supported %s from %pf\n",
+	DBGA("pci_dac_dma_supported %s from %ps\n",
 	     ok ? "yes" : "no", __builtin_return_address(0));
 
 	return ok;
@@ -269,7 +269,7 @@ pci_map_single_1(struct pci_dev *pdev, void *cpu_addr, size_t size,
 	    && paddr + size <= __direct_map_size) {
 		ret = paddr + __direct_map_base;
 
-		DBGA2("pci_map_single: [%p,%zx] -> direct %llx from %pf\n",
+		DBGA2("pci_map_single: [%p,%zx] -> direct %llx from %ps\n",
 		      cpu_addr, size, ret, __builtin_return_address(0));
 
 		return ret;
@@ -280,7 +280,7 @@ pci_map_single_1(struct pci_dev *pdev, void *cpu_addr, size_t size,
 	if (dac_allowed) {
 		ret = paddr + alpha_mv.pci_dac_offset;
 
-		DBGA2("pci_map_single: [%p,%zx] -> DAC %llx from %pf\n",
+		DBGA2("pci_map_single: [%p,%zx] -> DAC %llx from %ps\n",
 		      cpu_addr, size, ret, __builtin_return_address(0));
 
 		return ret;
@@ -317,7 +317,7 @@ pci_map_single_1(struct pci_dev *pdev, void *cpu_addr, size_t size,
 	ret = arena->dma_base + dma_ofs * PAGE_SIZE;
 	ret += (unsigned long)cpu_addr & ~PAGE_MASK;
 
-	DBGA2("pci_map_single: [%p,%zx] np %ld -> sg %llx from %pf\n",
+	DBGA2("pci_map_single: [%p,%zx] np %ld -> sg %llx from %ps\n",
 	      cpu_addr, size, npages, ret, __builtin_return_address(0));
 
 	return ret;
@@ -384,14 +384,14 @@ static void alpha_pci_unmap_page(struct device *dev, dma_addr_t dma_addr,
 	    && dma_addr < __direct_map_base + __direct_map_size) {
 		/* Nothing to do.  */
 
-		DBGA2("pci_unmap_single: direct [%llx,%zx] from %pf\n",
+		DBGA2("pci_unmap_single: direct [%llx,%zx] from %ps\n",
 		      dma_addr, size, __builtin_return_address(0));
 
 		return;
 	}
 
 	if (dma_addr > 0xffffffff) {
-		DBGA2("pci64_unmap_single: DAC [%llx,%zx] from %pf\n",
+		DBGA2("pci64_unmap_single: DAC [%llx,%zx] from %ps\n",
 		      dma_addr, size, __builtin_return_address(0));
 		return;
 	}
@@ -423,7 +423,7 @@ static void alpha_pci_unmap_page(struct device *dev, dma_addr_t dma_addr,
 
 	spin_unlock_irqrestore(&arena->lock, flags);
 
-	DBGA2("pci_unmap_single: sg [%llx,%zx] np %ld from %pf\n",
+	DBGA2("pci_unmap_single: sg [%llx,%zx] np %ld from %ps\n",
 	      dma_addr, size, npages, __builtin_return_address(0));
 }
 
@@ -446,7 +446,7 @@ static void *alpha_pci_alloc_coherent(struct device *dev, size_t size,
 	cpu_addr = (void *)__get_free_pages(gfp, order);
 	if (! cpu_addr) {
 		printk(KERN_INFO "pci_alloc_consistent: "
-		       "get_free_pages failed from %pf\n",
+		       "get_free_pages failed from %ps\n",
 			__builtin_return_address(0));
 		/* ??? Really atomic allocation?  Otherwise we could play
 		   with vmalloc and sg if we can't find contiguous memory.  */
@@ -465,7 +465,7 @@ static void *alpha_pci_alloc_coherent(struct device *dev, size_t size,
 		goto try_again;
 	}
 
-	DBGA2("pci_alloc_consistent: %zx -> [%p,%llx] from %pf\n",
+	DBGA2("pci_alloc_consistent: %zx -> [%p,%llx] from %ps\n",
 	      size, cpu_addr, *dma_addrp, __builtin_return_address(0));
 
 	return cpu_addr;
@@ -485,7 +485,7 @@ static void alpha_pci_free_coherent(struct device *dev, size_t size,
 	pci_unmap_single(pdev, dma_addr, size, PCI_DMA_BIDIRECTIONAL);
 	free_pages((unsigned long)cpu_addr, get_order(size));
 
-	DBGA2("pci_free_consistent: [%llx,%zx] from %pf\n",
+	DBGA2("pci_free_consistent: [%llx,%zx] from %ps\n",
 	      dma_addr, size, __builtin_return_address(0));
 }
 
diff --git a/arch/arm/mm/alignment.c b/arch/arm/mm/alignment.c
index bd2c739..3086d01 100644
--- a/arch/arm/mm/alignment.c
+++ b/arch/arm/mm/alignment.c
@@ -133,7 +133,7 @@ static const char *usermode_action[] = {
 static int alignment_proc_show(struct seq_file *m, void *v)
 {
 	seq_printf(m, "User:\t\t%lu\n", ai_user);
-	seq_printf(m, "System:\t\t%lu (%pF)\n", ai_sys, ai_sys_last_pc);
+	seq_printf(m, "System:\t\t%lu (%pS)\n", ai_sys, ai_sys_last_pc);
 	seq_printf(m, "Skipped:\t%lu\n", ai_skipped);
 	seq_printf(m, "Half:\t\t%lu\n", ai_half);
 	seq_printf(m, "Word:\t\t%lu\n", ai_word);
diff --git a/arch/arm/nwfpe/fpmodule.c b/arch/arm/nwfpe/fpmodule.c
index 1365e86..ee34c76 100644
--- a/arch/arm/nwfpe/fpmodule.c
+++ b/arch/arm/nwfpe/fpmodule.c
@@ -147,7 +147,7 @@ void float_raise(signed char flags)
 #ifdef CONFIG_DEBUG_USER
 	if (flags & debug)
  		printk(KERN_DEBUG
-		       "NWFPE: %s[%d] takes exception %08x at %pf from %08lx\n",
+		       "NWFPE: %s[%d] takes exception %08x at %ps from %08lx\n",
 		       current->comm, current->pid, flags,
 		       __builtin_return_address(0), GET_USERREG()->ARM_pc);
 #endif
diff --git a/arch/microblaze/mm/pgtable.c b/arch/microblaze/mm/pgtable.c
index 7f52596..67e9818 100644
--- a/arch/microblaze/mm/pgtable.c
+++ b/arch/microblaze/mm/pgtable.c
@@ -75,7 +75,7 @@ static void __iomem *__ioremap(phys_addr_t addr, unsigned long size,
 		p >= memory_start && p < virt_to_phys(high_memory) &&
 		!(p >= __virt_to_phys((phys_addr_t)__bss_stop) &&
 		p < __virt_to_phys((phys_addr_t)__bss_stop))) {
-		pr_warn("__ioremap(): phys addr "PTE_FMT" is RAM lr %pf\n",
+		pr_warn("__ioremap(): phys addr "PTE_FMT" is RAM lr %ps\n",
 			(unsigned long)p, __builtin_return_address(0));
 		return NULL;
 	}
diff --git a/arch/sparc/kernel/ds.c b/arch/sparc/kernel/ds.c
index f87265a..cad08cc 100644
--- a/arch/sparc/kernel/ds.c
+++ b/arch/sparc/kernel/ds.c
@@ -876,7 +876,7 @@ void ldom_power_off(void)
 
 static void ds_conn_reset(struct ds_info *dp)
 {
-	printk(KERN_ERR "ds-%llu: ds_conn_reset() from %pf\n",
+	printk(KERN_ERR "ds-%llu: ds_conn_reset() from %ps\n",
 	       dp->id, __builtin_return_address(0));
 }
 
diff --git a/arch/um/kernel/sysrq.c b/arch/um/kernel/sysrq.c
index 6b995e8..05585ee 100644
--- a/arch/um/kernel/sysrq.c
+++ b/arch/um/kernel/sysrq.c
@@ -20,7 +20,7 @@
 
 static void _print_addr(void *data, unsigned long address, int reliable)
 {
-	pr_info(" [<%08lx>] %s%pF\n", address, reliable ? "" : "? ",
+	pr_info(" [<%08lx>] %s%pS\n", address, reliable ? "" : "? ",
 		(void *)address);
 }
 
diff --git a/arch/x86/include/asm/trace/exceptions.h b/arch/x86/include/asm/trace/exceptions.h
index 69615e3..fd5b0a0 100644
--- a/arch/x86/include/asm/trace/exceptions.h
+++ b/arch/x86/include/asm/trace/exceptions.h
@@ -30,7 +30,7 @@ DECLARE_EVENT_CLASS(x86_exceptions,
 		__entry->error_code = error_code;
 	),
 
-	TP_printk("address=%pf ip=%pf error_code=0x%lx",
+	TP_printk("address=%ps ip=%ps error_code=0x%lx",
 		  (void *)__entry->address, (void *)__entry->ip,
 		  __entry->error_code) );
 
diff --git a/arch/x86/kernel/irq_64.c b/arch/x86/kernel/irq_64.c
index d86e344..468ef75 100644
--- a/arch/x86/kernel/irq_64.c
+++ b/arch/x86/kernel/irq_64.c
@@ -57,7 +57,7 @@ static inline void stack_overflow_check(struct pt_regs *regs)
 	if (regs->sp >= estack_top && regs->sp <= estack_bottom)
 		return;
 
-	WARN_ONCE(1, "do_IRQ(): %s has overflown the kernel stack (cur:%Lx,sp:%lx,irq stk top-bottom:%Lx-%Lx,exception stk top-bottom:%Lx-%Lx,ip:%pF)\n",
+	WARN_ONCE(1, "do_IRQ(): %s has overflown the kernel stack (cur:%Lx,sp:%lx,irq stk top-bottom:%Lx-%Lx,exception stk top-bottom:%Lx-%Lx,ip:%pS)\n",
 		current->comm, curbase, regs->sp,
 		irq_stack_top, irq_stack_bottom,
 		estack_top, estack_bottom, (void *)regs->ip);
diff --git a/arch/x86/mm/extable.c b/arch/x86/mm/extable.c
index 45f5d6c..e81fd9d 100644
--- a/arch/x86/mm/extable.c
+++ b/arch/x86/mm/extable.c
@@ -121,7 +121,7 @@ EXPORT_SYMBOL(ex_handler_ext);
 __visible bool ex_handler_rdmsr_unsafe(const struct exception_table_entry *fixup,
 				       struct pt_regs *regs, int trapnr)
 {
-	if (pr_warn_once("unchecked MSR access error: RDMSR from 0x%x at rIP: 0x%lx (%pF)\n",
+	if (pr_warn_once("unchecked MSR access error: RDMSR from 0x%x at rIP: 0x%lx (%pS)\n",
 			 (unsigned int)regs->cx, regs->ip, (void *)regs->ip))
 		show_stack_regs(regs);
 
@@ -136,7 +136,7 @@ EXPORT_SYMBOL(ex_handler_rdmsr_unsafe);
 __visible bool ex_handler_wrmsr_unsafe(const struct exception_table_entry *fixup,
 				       struct pt_regs *regs, int trapnr)
 {
-	if (pr_warn_once("unchecked MSR access error: WRMSR to 0x%x (tried to write 0x%08x%08x) at rIP: 0x%lx (%pF)\n",
+	if (pr_warn_once("unchecked MSR access error: WRMSR to 0x%x (tried to write 0x%08x%08x) at rIP: 0x%lx (%pS)\n",
 			 (unsigned int)regs->cx, (unsigned int)regs->dx,
 			 (unsigned int)regs->ax,  regs->ip, (void *)regs->ip))
 		show_stack_regs(regs);
diff --git a/arch/x86/xen/multicalls.c b/arch/x86/xen/multicalls.c
index dc502ca..10e836a 100644
--- a/arch/x86/xen/multicalls.c
+++ b/arch/x86/xen/multicalls.c
@@ -104,7 +104,7 @@ void xen_mc_flush(void)
 			       ret, smp_processor_id());
 			dump_stack();
 			for (i = 0; i < b->mcidx; i++) {
-				printk(KERN_DEBUG "  call %2d/%d: op=%lu arg=[%lx] result=%ld\t%pF\n",
+				printk(KERN_DEBUG "  call %2d/%d: op=%lu arg=[%lx] result=%ld\t%pS\n",
 				       i+1, b->mcidx,
 				       b->debug[i].op,
 				       b->debug[i].args[0],
diff --git a/drivers/acpi/device_pm.c b/drivers/acpi/device_pm.c
index a7c2673..c9817f9 100644
--- a/drivers/acpi/device_pm.c
+++ b/drivers/acpi/device_pm.c
@@ -413,7 +413,7 @@ static void acpi_pm_notify_handler(acpi_handle handle, u32 val, void *not_used)
 	if (adev->wakeup.flags.notifier_present) {
 		pm_wakeup_ws_event(adev->wakeup.ws, 0, acpi_s2idle_wakeup());
 		if (adev->wakeup.context.func) {
-			acpi_handle_debug(handle, "Running %pF for %s\n",
+			acpi_handle_debug(handle, "Running %pS for %s\n",
 					  adev->wakeup.context.func,
 					  dev_name(adev->wakeup.context.dev));
 			adev->wakeup.context.func(&adev->wakeup.context);
diff --git a/drivers/base/power/main.c b/drivers/base/power/main.c
index 3f68e29..60ec1da 100644
--- a/drivers/base/power/main.c
+++ b/drivers/base/power/main.c
@@ -197,7 +197,7 @@ static ktime_t initcall_debug_start(struct device *dev, void *cb)
 	if (!pm_print_times_enabled)
 		return 0;
 
-	dev_info(dev, "calling %pF @ %i, parent: %s\n", cb,
+	dev_info(dev, "calling %pS @ %i, parent: %s\n", cb,
 		 task_pid_nr(current),
 		 dev->parent ? dev_name(dev->parent) : "none");
 	return ktime_get();
@@ -215,7 +215,7 @@ static void initcall_debug_report(struct device *dev, ktime_t calltime,
 	rettime = ktime_get();
 	nsecs = (s64) ktime_to_ns(ktime_sub(rettime, calltime));
 
-	dev_info(dev, "%pF returned %d after %Ld usecs\n", cb, error,
+	dev_info(dev, "%pS returned %d after %Ld usecs\n", cb, error,
 		 (unsigned long long)nsecs >> 10);
 }
 
@@ -2047,7 +2047,7 @@ EXPORT_SYMBOL_GPL(dpm_suspend_start);
 void __suspend_report_result(const char *function, void *fn, int ret)
 {
 	if (ret)
-		printk(KERN_ERR "%s(): %pF returns %d\n", function, fn, ret);
+		printk(KERN_ERR "%s(): %pS returns %d\n", function, fn, ret);
 }
 EXPORT_SYMBOL_GPL(__suspend_report_result);
 
diff --git a/drivers/base/syscore.c b/drivers/base/syscore.c
index 6e076f3..0d346a3 100644
--- a/drivers/base/syscore.c
+++ b/drivers/base/syscore.c
@@ -62,19 +62,19 @@ int syscore_suspend(void)
 	list_for_each_entry_reverse(ops, &syscore_ops_list, node)
 		if (ops->suspend) {
 			if (initcall_debug)
-				pr_info("PM: Calling %pF\n", ops->suspend);
+				pr_info("PM: Calling %pS\n", ops->suspend);
 			ret = ops->suspend();
 			if (ret)
 				goto err_out;
 			WARN_ONCE(!irqs_disabled(),
-				"Interrupts enabled after %pF\n", ops->suspend);
+				"Interrupts enabled after %pS\n", ops->suspend);
 		}
 
 	trace_suspend_resume(TPS("syscore_suspend"), 0, false);
 	return 0;
 
  err_out:
-	pr_err("PM: System core suspend callback %pF failed.\n", ops->suspend);
+	pr_err("PM: System core suspend callback %pS failed.\n", ops->suspend);
 
 	list_for_each_entry_continue(ops, &syscore_ops_list, node)
 		if (ops->resume)
@@ -100,10 +100,10 @@ void syscore_resume(void)
 	list_for_each_entry(ops, &syscore_ops_list, node)
 		if (ops->resume) {
 			if (initcall_debug)
-				pr_info("PM: Calling %pF\n", ops->resume);
+				pr_info("PM: Calling %pS\n", ops->resume);
 			ops->resume();
 			WARN_ONCE(!irqs_disabled(),
-				"Interrupts enabled after %pF\n", ops->resume);
+				"Interrupts enabled after %pS\n", ops->resume);
 		}
 	trace_suspend_resume(TPS("syscore_resume"), 0, false);
 }
@@ -122,7 +122,7 @@ void syscore_shutdown(void)
 	list_for_each_entry_reverse(ops, &syscore_ops_list, node)
 		if (ops->shutdown) {
 			if (initcall_debug)
-				pr_info("PM: Calling %pF\n", ops->shutdown);
+				pr_info("PM: Calling %pS\n", ops->shutdown);
 			ops->shutdown();
 		}
 
diff --git a/drivers/block/drbd/drbd_receiver.c b/drivers/block/drbd/drbd_receiver.c
index be9450f..fad9806 100644
--- a/drivers/block/drbd/drbd_receiver.c
+++ b/drivers/block/drbd/drbd_receiver.c
@@ -5924,7 +5924,7 @@ int drbd_ack_receiver(struct drbd_thread *thi)
 
 			err = cmd->fn(connection, &pi);
 			if (err) {
-				drbd_err(connection, "%pf failed\n", cmd->fn);
+				drbd_err(connection, "%ps failed\n", cmd->fn);
 				goto reconnect;
 			}
 
diff --git a/drivers/block/floppy.c b/drivers/block/floppy.c
index 8871b50..b823360 100644
--- a/drivers/block/floppy.c
+++ b/drivers/block/floppy.c
@@ -1696,7 +1696,7 @@ irqreturn_t floppy_interrupt(int irq, void *dev_id)
 		/* we don't even know which FDC is the culprit */
 		pr_info("DOR0=%x\n", fdc_state[0].dor);
 		pr_info("floppy interrupt on bizarre fdc %d\n", fdc);
-		pr_info("handler=%pf\n", handler);
+		pr_info("handler=%ps\n", handler);
 		is_alive(__func__, "bizarre fdc");
 		return IRQ_NONE;
 	}
@@ -1755,7 +1755,7 @@ static void reset_interrupt(void)
 	debugt(__func__, "");
 	result();		/* get the status ready for set_fdc */
 	if (FDCS->reset) {
-		pr_info("reset set in interrupt, calling %pf\n", cont->error);
+		pr_info("reset set in interrupt, calling %ps\n", cont->error);
 		cont->error();	/* a reset just after a reset. BAD! */
 	}
 	cont->redo();
@@ -1796,7 +1796,7 @@ static void show_floppy(void)
 	pr_info("\n");
 	pr_info("floppy driver state\n");
 	pr_info("-------------------\n");
-	pr_info("now=%lu last interrupt=%lu diff=%lu last called handler=%pf\n",
+	pr_info("now=%lu last interrupt=%lu diff=%lu last called handler=%ps\n",
 		jiffies, interruptjiffies, jiffies - interruptjiffies,
 		lasthandler);
 
@@ -1815,9 +1815,9 @@ static void show_floppy(void)
 	pr_info("status=%x\n", fd_inb(FD_STATUS));
 	pr_info("fdc_busy=%lu\n", fdc_busy);
 	if (do_floppy)
-		pr_info("do_floppy=%pf\n", do_floppy);
+		pr_info("do_floppy=%ps\n", do_floppy);
 	if (work_pending(&floppy_work))
-		pr_info("floppy_work.func=%pf\n", floppy_work.func);
+		pr_info("floppy_work.func=%ps\n", floppy_work.func);
 	if (delayed_work_pending(&fd_timer))
 		pr_info("delayed work.function=%p expires=%ld\n",
 		       fd_timer.work.func,
diff --git a/drivers/cpufreq/cpufreq.c b/drivers/cpufreq/cpufreq.c
index b0dfd32..10dd4dc 100644
--- a/drivers/cpufreq/cpufreq.c
+++ b/drivers/cpufreq/cpufreq.c
@@ -431,7 +431,7 @@ static void cpufreq_list_transition_notifiers(void)
 	mutex_lock(&cpufreq_transition_notifier_list.mutex);
 
 	for (nb = cpufreq_transition_notifier_list.head; nb; nb = nb->next)
-		pr_info("%pF\n", nb->notifier_call);
+		pr_info("%pS\n", nb->notifier_call);
 
 	mutex_unlock(&cpufreq_transition_notifier_list.mutex);
 }
diff --git a/drivers/md/bcache/closure.c b/drivers/md/bcache/closure.c
index 0e14969..ddc7815 100644
--- a/drivers/md/bcache/closure.c
+++ b/drivers/md/bcache/closure.c
@@ -167,7 +167,7 @@ static int debug_seq_show(struct seq_file *f, void *data)
 	list_for_each_entry(cl, &closure_list, all) {
 		int r = atomic_read(&cl->remaining);
 
-		seq_printf(f, "%p: %pF -> %pf p %p r %i ",
+		seq_printf(f, "%p: %pS -> %ps p %p r %i ",
 			   cl, (void *) cl->ip, cl->fn, cl->parent,
 			   r & CLOSURE_REMAINING_MASK);
 
@@ -177,7 +177,7 @@ static int debug_seq_show(struct seq_file *f, void *data)
 			   r & CLOSURE_RUNNING	? "R" : "");
 
 		if (r & CLOSURE_WAITING)
-			seq_printf(f, " W %pF\n",
+			seq_printf(f, " W %pS\n",
 				   (void *) cl->waiting_on);
 
 		seq_printf(f, "\n");
diff --git a/drivers/mmc/core/quirks.h b/drivers/mmc/core/quirks.h
index dd2f73a..2d2d9ea8 100644
--- a/drivers/mmc/core/quirks.h
+++ b/drivers/mmc/core/quirks.h
@@ -159,7 +159,7 @@ static inline void mmc_fixup_device(struct mmc_card *card,
 		    (f->ext_csd_rev == EXT_CSD_REV_ANY ||
 		     f->ext_csd_rev == card->ext_csd.rev) &&
 		    rev >= f->rev_start && rev <= f->rev_end) {
-			dev_dbg(&card->dev, "calling %pf\n", f->vendor_fixup);
+			dev_dbg(&card->dev, "calling %ps\n", f->vendor_fixup);
 			f->vendor_fixup(card, f->data);
 		}
 	}
diff --git a/drivers/nvdimm/bus.c b/drivers/nvdimm/bus.c
index 27902a8..27a1f48 100644
--- a/drivers/nvdimm/bus.c
+++ b/drivers/nvdimm/bus.c
@@ -547,7 +547,7 @@ int __nd_driver_register(struct nd_device_driver *nd_drv, struct module *owner,
 	struct device_driver *drv = &nd_drv->drv;
 
 	if (!nd_drv->type) {
-		pr_debug("driver type bitmask not set (%pf)\n",
+		pr_debug("driver type bitmask not set (%ps)\n",
 				__builtin_return_address(0));
 		return -EINVAL;
 	}
diff --git a/drivers/nvdimm/dimm_devs.c b/drivers/nvdimm/dimm_devs.c
index 8d348b2..d30d65f 100644
--- a/drivers/nvdimm/dimm_devs.c
+++ b/drivers/nvdimm/dimm_devs.c
@@ -53,7 +53,7 @@ static int validate_dimm(struct nvdimm_drvdata *ndd)
 
 	rc = nvdimm_check_config_data(ndd->dev);
 	if (rc)
-		dev_dbg(ndd->dev, "%pf: %s error: %d\n",
+		dev_dbg(ndd->dev, "%ps: %s error: %d\n",
 				__builtin_return_address(0), __func__, rc);
 	return rc;
 }
diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
index c125d53..29fcc54 100644
--- a/drivers/pci/pci-driver.c
+++ b/drivers/pci/pci-driver.c
@@ -577,7 +577,7 @@ static int pci_legacy_suspend(struct device *dev, pm_message_t state)
 		if (!pci_dev->state_saved && pci_dev->current_state != PCI_D0
 		    && pci_dev->current_state != PCI_UNKNOWN) {
 			WARN_ONCE(pci_dev->current_state != prev,
-				"PCI PM: Device state not saved by %pF\n",
+				"PCI PM: Device state not saved by %pS\n",
 				drv->suspend);
 		}
 	}
@@ -604,7 +604,7 @@ static int pci_legacy_suspend_late(struct device *dev, pm_message_t state)
 		if (!pci_dev->state_saved && pci_dev->current_state != PCI_D0
 		    && pci_dev->current_state != PCI_UNKNOWN) {
 			WARN_ONCE(pci_dev->current_state != prev,
-				"PCI PM: Device state not saved by %pF\n",
+				"PCI PM: Device state not saved by %pS\n",
 				drv->suspend_late);
 			goto Fixup;
 		}
@@ -772,7 +772,7 @@ static int pci_pm_suspend(struct device *dev)
 		if (!pci_dev->state_saved && pci_dev->current_state != PCI_D0
 		    && pci_dev->current_state != PCI_UNKNOWN) {
 			WARN_ONCE(pci_dev->current_state != prev,
-				"PCI PM: State of device not saved by %pF\n",
+				"PCI PM: State of device not saved by %pS\n",
 				pm->suspend);
 		}
 	}
@@ -820,7 +820,7 @@ static int pci_pm_suspend_noirq(struct device *dev)
 		if (!pci_dev->state_saved && pci_dev->current_state != PCI_D0
 		    && pci_dev->current_state != PCI_UNKNOWN) {
 			WARN_ONCE(pci_dev->current_state != prev,
-				"PCI PM: State of device not saved by %pF\n",
+				"PCI PM: State of device not saved by %pS\n",
 				pm->suspend_noirq);
 			goto Fixup;
 		}
@@ -1262,10 +1262,10 @@ static int pci_pm_runtime_suspend(struct device *dev)
 		 * log level.
 		 */
 		if (error == -EBUSY || error == -EAGAIN)
-			dev_dbg(dev, "can't suspend now (%pf returned %d)\n",
+			dev_dbg(dev, "can't suspend now (%ps returned %d)\n",
 				pm->runtime_suspend, error);
 		else
-			dev_err(dev, "can't suspend (%pf returned %d)\n",
+			dev_err(dev, "can't suspend (%ps returned %d)\n",
 				pm->runtime_suspend, error);
 
 		return error;
@@ -1276,7 +1276,7 @@ static int pci_pm_runtime_suspend(struct device *dev)
 	if (!pci_dev->state_saved && pci_dev->current_state != PCI_D0
 	    && pci_dev->current_state != PCI_UNKNOWN) {
 		WARN_ONCE(pci_dev->current_state != prev,
-			"PCI PM: State of device not saved by %pF\n",
+			"PCI PM: State of device not saved by %pS\n",
 			pm->runtime_suspend);
 		return 0;
 	}
diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index f439de8..a1e43da 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -34,7 +34,7 @@ static ktime_t fixup_debug_start(struct pci_dev *dev,
 				 void (*fn)(struct pci_dev *dev))
 {
 	if (initcall_debug)
-		pci_info(dev, "calling  %pF @ %i\n", fn, task_pid_nr(current));
+		pci_info(dev, "calling  %pS @ %i\n", fn, task_pid_nr(current));
 
 	return ktime_get();
 }
@@ -49,7 +49,7 @@ static void fixup_debug_report(struct pci_dev *dev, ktime_t calltime,
 	delta = ktime_sub(rettime, calltime);
 	duration = (unsigned long long) ktime_to_ns(delta) >> 10;
 	if (initcall_debug || duration > 10000)
-		pci_info(dev, "%pF took %lld usecs\n", fn, duration);
+		pci_info(dev, "%pS took %lld usecs\n", fn, duration);
 }
 
 static void pci_do_fixups(struct pci_dev *dev, struct pci_fixup *f,
diff --git a/drivers/pnp/quirks.c b/drivers/pnp/quirks.c
index 803666a..de99f37 100644
--- a/drivers/pnp/quirks.c
+++ b/drivers/pnp/quirks.c
@@ -458,7 +458,7 @@ void pnp_fixup_device(struct pnp_dev *dev)
 	for (f = pnp_fixups; *f->id; f++) {
 		if (!compare_pnp_id(dev->id, f->id))
 			continue;
-		pnp_dbg(&dev->dev, "%s: calling %pF\n", f->id,
+		pnp_dbg(&dev->dev, "%s: calling %pS\n", f->id,
 			f->quirk_function);
 		f->quirk_function(dev);
 	}
diff --git a/drivers/scsi/esp_scsi.c b/drivers/scsi/esp_scsi.c
index c3fc34b..77cc77f 100644
--- a/drivers/scsi/esp_scsi.c
+++ b/drivers/scsi/esp_scsi.c
@@ -1032,7 +1032,7 @@ static int esp_check_spur_intr(struct esp *esp)
 
 static void esp_schedule_reset(struct esp *esp)
 {
-	esp_log_reset("esp_schedule_reset() from %pf\n",
+	esp_log_reset("esp_schedule_reset() from %ps\n",
 		      __builtin_return_address(0));
 	esp->flags |= ESP_FLAG_RESETTING;
 	esp_event(esp, ESP_EVENT_RESET);
diff --git a/fs/btrfs/tests/free-space-tree-tests.c b/fs/btrfs/tests/free-space-tree-tests.c
index 89346da..f7a969b 100644
--- a/fs/btrfs/tests/free-space-tree-tests.c
+++ b/fs/btrfs/tests/free-space-tree-tests.c
@@ -539,7 +539,7 @@ static int run_test_both_formats(test_func_t test_func, u32 sectorsize,
 	ret = run_test(test_func, 0, sectorsize, nodesize, alignment);
 	if (ret) {
 		test_err(
-	"%pf failed with extents, sectorsize=%u, nodesize=%u, alignment=%u",
+	"%ps failed with extents, sectorsize=%u, nodesize=%u, alignment=%u",
 			 test_func, sectorsize, nodesize, alignment);
 		test_ret = ret;
 	}
@@ -547,7 +547,7 @@ static int run_test_both_formats(test_func_t test_func, u32 sectorsize,
 	ret = run_test(test_func, 1, sectorsize, nodesize, alignment);
 	if (ret) {
 		test_err(
-	"%pf failed with bitmaps, sectorsize=%u, nodesize=%u, alignment=%u",
+	"%ps failed with bitmaps, sectorsize=%u, nodesize=%u, alignment=%u",
 			 test_func, sectorsize, nodesize, alignment);
 		test_ret = ret;
 	}
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 4d8b1de..9d7beaa 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -1278,7 +1278,7 @@ struct f2fs_sb_info {
 
 #ifdef CONFIG_F2FS_FAULT_INJECTION
 #define f2fs_show_injection_info(type)				\
-	printk("%sF2FS-fs : inject %s in %s of %pF\n",		\
+	printk("%sF2FS-fs : inject %s in %s of %pS\n",		\
 		KERN_INFO, fault_name[type],			\
 		__func__, __builtin_return_address(0))
 static inline bool time_to_inject(struct f2fs_sb_info *sbi, int type)
diff --git a/fs/pstore/inode.c b/fs/pstore/inode.c
index 5fcb845..1062d08 100644
--- a/fs/pstore/inode.c
+++ b/fs/pstore/inode.c
@@ -115,7 +115,7 @@ static int pstore_ftrace_seq_show(struct seq_file *s, void *v)
 
 	rec = (struct pstore_ftrace_record *)(ps->record->buf + data->off);
 
-	seq_printf(s, "CPU:%d ts:%llu %08lx  %08lx  %pf <- %pF\n",
+	seq_printf(s, "CPU:%d ts:%llu %08lx  %08lx  %ps <- %pS\n",
 		   pstore_ftrace_decode_cpu(rec),
 		   pstore_ftrace_read_timestamp(rec),
 		   rec->ip, rec->parent_ip, (void *)rec->ip,
diff --git a/fs/xfs/scrub/trace.h b/fs/xfs/scrub/trace.h
index cec3e5e..0b2b1da 100644
--- a/fs/xfs/scrub/trace.h
+++ b/fs/xfs/scrub/trace.h
@@ -473,7 +473,7 @@ TRACE_EVENT(xfs_scrub_xref_error,
 		__entry->error = error;
 		__entry->ret_ip = ret_ip;
 	),
-	TP_printk("dev %d:%d type %u xref error %d ret_ip %pF",
+	TP_printk("dev %d:%d type %u xref error %d ret_ip %pS",
 		  MAJOR(__entry->dev), MINOR(__entry->dev),
 		  __entry->type,
 		  __entry->error,
diff --git a/include/trace/events/btrfs.h b/include/trace/events/btrfs.h
index 39b94ec..5f97fa1 100644
--- a/include/trace/events/btrfs.h
+++ b/include/trace/events/btrfs.h
@@ -1343,7 +1343,7 @@ DECLARE_EVENT_CLASS(btrfs__work,
 		__entry->normal_work	= &work->normal_work;
 	),
 
-	TP_printk_btrfs("work=%p (normal_work=%p) wq=%p func=%pf ordered_func=%p "
+	TP_printk_btrfs("work=%p (normal_work=%p) wq=%p func=%ps ordered_func=%p "
 		  "ordered_free=%p",
 		  __entry->work, __entry->normal_work, __entry->wq,
 		   __entry->func, __entry->ordered_func, __entry->ordered_free)
diff --git a/include/trace/events/cpuhp.h b/include/trace/events/cpuhp.h
index fe1d6e8..ad16f77 100644
--- a/include/trace/events/cpuhp.h
+++ b/include/trace/events/cpuhp.h
@@ -30,7 +30,7 @@ TRACE_EVENT(cpuhp_enter,
 		__entry->fun	= fun;
 	),
 
-	TP_printk("cpu: %04u target: %3d step: %3d (%pf)",
+	TP_printk("cpu: %04u target: %3d step: %3d (%ps)",
 		  __entry->cpu, __entry->target, __entry->idx, __entry->fun)
 );
 
@@ -58,7 +58,7 @@ TRACE_EVENT(cpuhp_multi_enter,
 		__entry->fun	= fun;
 	),
 
-	TP_printk("cpu: %04u target: %3d step: %3d (%pf)",
+	TP_printk("cpu: %04u target: %3d step: %3d (%ps)",
 		  __entry->cpu, __entry->target, __entry->idx, __entry->fun)
 );
 
diff --git a/include/trace/events/preemptirq.h b/include/trace/events/preemptirq.h
index 9c4eb33..c88a8cb 100644
--- a/include/trace/events/preemptirq.h
+++ b/include/trace/events/preemptirq.h
@@ -27,7 +27,7 @@ DECLARE_EVENT_CLASS(preemptirq_template,
 		__entry->parent_offs = (u32)(parent_ip - (unsigned long)_stext);
 	),
 
-	TP_printk("caller=%pF parent=%pF",
+	TP_printk("caller=%pS parent=%pS",
 		  (void *)((unsigned long)(_stext) + __entry->caller_offs),
 		  (void *)((unsigned long)(_stext) + __entry->parent_offs))
 );
diff --git a/include/trace/events/rcu.h b/include/trace/events/rcu.h
index 5936aac..b311070 100644
--- a/include/trace/events/rcu.h
+++ b/include/trace/events/rcu.h
@@ -494,7 +494,7 @@ TRACE_EVENT(rcu_callback,
 		__entry->qlen = qlen;
 	),
 
-	TP_printk("%s rhp=%p func=%pf %ld/%ld",
+	TP_printk("%s rhp=%p func=%ps %ld/%ld",
 		  __entry->rcuname, __entry->rhp, __entry->func,
 		  __entry->qlen_lazy, __entry->qlen)
 );
@@ -590,7 +590,7 @@ TRACE_EVENT(rcu_invoke_callback,
 		__entry->func = rhp->func;
 	),
 
-	TP_printk("%s rhp=%p func=%pf",
+	TP_printk("%s rhp=%p func=%ps",
 		  __entry->rcuname, __entry->rhp, __entry->func)
 );
 
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index bbb08a3..da732cf 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -126,7 +126,7 @@ DECLARE_EVENT_CLASS(rpc_task_running,
 		__entry->flags = task->tk_flags;
 		),
 
-	TP_printk("task:%u@%d flags=%4.4x state=%4.4lx status=%d action=%pf",
+	TP_printk("task:%u@%d flags=%4.4x state=%4.4lx status=%d action=%ps",
 		__entry->task_id, __entry->client_id,
 		__entry->flags,
 		__entry->runstate,
diff --git a/include/trace/events/timer.h b/include/trace/events/timer.h
index a57e4ee..6785065 100644
--- a/include/trace/events/timer.h
+++ b/include/trace/events/timer.h
@@ -73,7 +73,7 @@ TRACE_EVENT(timer_start,
 		__entry->flags		= flags;
 	),
 
-	TP_printk("timer=%p function=%pf expires=%lu [timeout=%ld] cpu=%u idx=%u flags=%s",
+	TP_printk("timer=%p function=%ps expires=%lu [timeout=%ld] cpu=%u idx=%u flags=%s",
 		  __entry->timer, __entry->function, __entry->expires,
 		  (long)__entry->expires - __entry->now,
 		  __entry->flags & TIMER_CPUMASK,
@@ -105,7 +105,7 @@ TRACE_EVENT(timer_expire_entry,
 		__entry->function	= timer->function;
 	),
 
-	TP_printk("timer=%p function=%pf now=%lu", __entry->timer, __entry->function,__entry->now)
+	TP_printk("timer=%p function=%ps now=%lu", __entry->timer, __entry->function,__entry->now)
 );
 
 /**
@@ -210,7 +210,7 @@ TRACE_EVENT(hrtimer_start,
 		__entry->mode		= mode;
 	),
 
-	TP_printk("hrtimer=%p function=%pf expires=%llu softexpires=%llu "
+	TP_printk("hrtimer=%p function=%ps expires=%llu softexpires=%llu "
 		  "mode=%s", __entry->hrtimer, __entry->function,
 		  (unsigned long long) __entry->expires,
 		  (unsigned long long) __entry->softexpires,
@@ -243,7 +243,7 @@ TRACE_EVENT(hrtimer_expire_entry,
 		__entry->function	= hrtimer->function;
 	),
 
-	TP_printk("hrtimer=%p function=%pf now=%llu", __entry->hrtimer, __entry->function,
+	TP_printk("hrtimer=%p function=%ps now=%llu", __entry->hrtimer, __entry->function,
 		  (unsigned long long) __entry->now)
 );
 
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a1cb913..252327d 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -226,7 +226,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 		__entry->priority = priority;
 	),
 
-	TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s cache items %ld delta %lld total_scan %ld priority %d",
+	TP_printk("%pS %p: nid: %d objects to shrink %ld gfp_flags %s cache items %ld delta %lld total_scan %ld priority %d",
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
@@ -265,7 +265,7 @@ TRACE_EVENT(mm_shrink_slab_end,
 		__entry->total_scan = total_scan;
 	),
 
-	TP_printk("%pF %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+	TP_printk("%pS %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
diff --git a/include/trace/events/workqueue.h b/include/trace/events/workqueue.h
index 9a761bc..e172549 100644
--- a/include/trace/events/workqueue.h
+++ b/include/trace/events/workqueue.h
@@ -60,7 +60,7 @@ TRACE_EVENT(workqueue_queue_work,
 		__entry->cpu		= pwq->pool->cpu;
 	),
 
-	TP_printk("work struct=%p function=%pf workqueue=%p req_cpu=%u cpu=%u",
+	TP_printk("work struct=%p function=%ps workqueue=%p req_cpu=%u cpu=%u",
 		  __entry->work, __entry->function, __entry->workqueue,
 		  __entry->req_cpu, __entry->cpu)
 );
@@ -102,7 +102,7 @@ TRACE_EVENT(workqueue_execute_start,
 		__entry->function	= work->func;
 	),
 
-	TP_printk("work struct %p: function %pf", __entry->work, __entry->function)
+	TP_printk("work struct %p: function %ps", __entry->work, __entry->function)
 );
 
 /**
diff --git a/include/trace/events/xen.h b/include/trace/events/xen.h
index fdcf88b..9a0e8af 100644
--- a/include/trace/events/xen.h
+++ b/include/trace/events/xen.h
@@ -73,7 +73,7 @@ TRACE_EVENT(xen_mc_callback,
 		    __entry->fn = fn;
 		    __entry->data = data;
 		    ),
-	    TP_printk("callback %pf, data %p",
+	    TP_printk("callback %ps, data %p",
 		      __entry->fn, __entry->data)
 	);
 
diff --git a/init/main.c b/init/main.c
index 3b4ada1..fae35cb 100644
--- a/init/main.c
+++ b/init/main.c
@@ -823,7 +823,7 @@ trace_initcall_start_cb(void *data, initcall_t fn)
 {
 	ktime_t *calltime = (ktime_t *)data;
 
-	printk(KERN_DEBUG "calling  %pF @ %i\n", fn, task_pid_nr(current));
+	printk(KERN_DEBUG "calling  %pS @ %i\n", fn, task_pid_nr(current));
 	*calltime = ktime_get();
 }
 
@@ -837,7 +837,7 @@ trace_initcall_finish_cb(void *data, initcall_t fn, int ret)
 	rettime = ktime_get();
 	delta = ktime_sub(rettime, *calltime);
 	duration = (unsigned long long) ktime_to_ns(delta) >> 10;
-	printk(KERN_DEBUG "initcall %pF returned %d after %lld usecs\n",
+	printk(KERN_DEBUG "initcall %pS returned %d after %lld usecs\n",
 		 fn, ret, duration);
 }
 
@@ -894,7 +894,7 @@ int __init_or_module do_one_initcall(initcall_t fn)
 		strlcat(msgbuf, "disabled interrupts ", sizeof(msgbuf));
 		local_irq_enable();
 	}
-	WARN(msgbuf[0], "initcall %pF returned with %s\n", fn, msgbuf);
+	WARN(msgbuf[0], "initcall %pS returned with %s\n", fn, msgbuf);
 
 	add_latent_entropy();
 	return ret;
diff --git a/kernel/async.c b/kernel/async.c
index a893d61..0babf1b 100644
--- a/kernel/async.c
+++ b/kernel/async.c
@@ -119,7 +119,7 @@ static void async_run_entry_fn(struct work_struct *work)
 
 	/* 1) run (and print duration) */
 	if (initcall_debug && system_state < SYSTEM_RUNNING) {
-		pr_debug("calling  %lli_%pF @ %i\n",
+		pr_debug("calling  %lli_%pS @ %i\n",
 			(long long)entry->cookie,
 			entry->func, task_pid_nr(current));
 		calltime = ktime_get();
@@ -128,7 +128,7 @@ static void async_run_entry_fn(struct work_struct *work)
 	if (initcall_debug && system_state < SYSTEM_RUNNING) {
 		rettime = ktime_get();
 		delta = ktime_sub(rettime, calltime);
-		pr_debug("initcall %lli_%pF returned 0 after %lld usecs\n",
+		pr_debug("initcall %lli_%pS returned 0 after %lld usecs\n",
 			(long long)entry->cookie,
 			entry->func,
 			(long long)ktime_to_ns(delta) >> 10);
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index ccc579a..d7e8da3 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1771,7 +1771,7 @@ static void handler_chain(struct uprobe *uprobe, struct pt_regs *regs)
 		if (uc->handler) {
 			rc = uc->handler(uc, regs);
 			WARN(rc & ~UPROBE_HANDLER_MASK,
-				"bad rc=0x%x from %pf()\n", rc, uc->handler);
+				"bad rc=0x%x from %ps()\n", rc, uc->handler);
 		}
 
 		if (uc->ret_handler)
diff --git a/kernel/fail_function.c b/kernel/fail_function.c
index 5349c91..a4cb66d 100644
--- a/kernel/fail_function.c
+++ b/kernel/fail_function.c
@@ -214,7 +214,7 @@ static int fei_seq_show(struct seq_file *m, void *v)
 {
 	struct fei_attr *attr = list_entry(v, struct fei_attr, list);
 
-	seq_printf(m, "%pf\n", attr->kp.addr);
+	seq_printf(m, "%ps\n", attr->kp.addr);
 	return 0;
 }
 
diff --git a/kernel/irq/debugfs.c b/kernel/irq/debugfs.c
index 6f63613..30c7cf6 100644
--- a/kernel/irq/debugfs.c
+++ b/kernel/irq/debugfs.c
@@ -150,7 +150,7 @@ static int irq_debug_show(struct seq_file *m, void *p)
 
 	raw_spin_lock_irq(&desc->lock);
 	data = irq_desc_get_irq_data(desc);
-	seq_printf(m, "handler:  %pf\n", desc->handle_irq);
+	seq_printf(m, "handler:  %ps\n", desc->handle_irq);
 	seq_printf(m, "device:   %s\n", desc->dev_name);
 	seq_printf(m, "status:   0x%08x\n", desc->status_use_accessors);
 	irq_debug_show_bits(m, 0, desc->status_use_accessors, irqdesc_states,
diff --git a/kernel/irq/handle.c b/kernel/irq/handle.c
index 38554bc..232a906 100644
--- a/kernel/irq/handle.c
+++ b/kernel/irq/handle.c
@@ -149,7 +149,7 @@ irqreturn_t __handle_irq_event_percpu(struct irq_desc *desc, unsigned int *flags
 		res = action->handler(irq, action->dev_id);
 		trace_irq_handler_exit(irq, action, res);
 
-		if (WARN_ONCE(!irqs_disabled(),"irq %u handler %pF enabled interrupts\n",
+		if (WARN_ONCE(!irqs_disabled(),"irq %u handler %pS enabled interrupts\n",
 			      irq, action->handler))
 			local_irq_disable();
 
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index daeabd7..8b7afe6 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -737,7 +737,7 @@ int __irq_set_trigger(struct irq_desc *desc, unsigned long flags)
 		ret = 0;
 		break;
 	default:
-		pr_err("Setting trigger mode %lu for irq %u failed (%pF)\n",
+		pr_err("Setting trigger mode %lu for irq %u failed (%pS)\n",
 		       flags, irq_desc_get_irq(desc), chip->irq_set_type);
 	}
 	if (unmask)
diff --git a/kernel/irq/spurious.c b/kernel/irq/spurious.c
index d867d6d..c4f6564 100644
--- a/kernel/irq/spurious.c
+++ b/kernel/irq/spurious.c
@@ -212,9 +212,9 @@ static void __report_bad_irq(struct irq_desc *desc, irqreturn_t action_ret)
 	 */
 	raw_spin_lock_irqsave(&desc->lock, flags);
 	for_each_action_of_desc(desc, action) {
-		printk(KERN_ERR "[<%p>] %pf", action->handler, action->handler);
+		printk(KERN_ERR "[<%p>] %ps", action->handler, action->handler);
 		if (action->thread_fn)
-			printk(KERN_CONT " threaded [<%p>] %pf",
+			printk(KERN_CONT " threaded [<%p>] %ps",
 					action->thread_fn, action->thread_fn);
 		printk(KERN_CONT "\n");
 	}
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index aa7cade..1f3b93f 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -2909,7 +2909,7 @@ __call_rcu(struct rcu_head *head, rcu_callback_t func,
 		 * Use rcu:rcu_callback trace event to find the previous
 		 * time callback was passed to __call_rcu().
 		 */
-		WARN_ONCE(1, "__call_rcu(): Double-freed CB %p->%pF()!!!\n",
+		WARN_ONCE(1, "__call_rcu(): Double-freed CB %p->%pS()!!!\n",
 			  head, head->func);
 		WRITE_ONCE(head->func, rcu_leak_callback);
 		return;
diff --git a/kernel/stop_machine.c b/kernel/stop_machine.c
index f89014a..33f3e5c 100644
--- a/kernel/stop_machine.c
+++ b/kernel/stop_machine.c
@@ -494,7 +494,7 @@ static void cpu_stopper_thread(unsigned int cpu)
 		}
 		preempt_count_dec();
 		WARN_ONCE(preempt_count(),
-			  "cpu_stop: %pf(%p) leaked preempt count\n", fn, arg);
+			  "cpu_stop: %ps(%p) leaked preempt count\n", fn, arg);
 		goto repeat;
 	}
 }
diff --git a/kernel/time/sched_clock.c b/kernel/time/sched_clock.c
index 2d8f05a..e570845 100644
--- a/kernel/time/sched_clock.c
+++ b/kernel/time/sched_clock.c
@@ -234,7 +234,7 @@ sched_clock_register(u64 (*read)(void), int bits, unsigned long rate)
 	if (irqtime > 0 || (irqtime == -1 && rate >= 1000000))
 		enable_sched_clock_irqtime();
 
-	pr_debug("Registered %pF as sched_clock source\n", read);
+	pr_debug("Registered %pS as sched_clock source\n", read);
 }
 
 void __init sched_clock_postinit(void)
diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index cc2d23e..489cbea 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -1329,7 +1329,7 @@ static void call_timer_fn(struct timer_list *timer, void (*fn)(struct timer_list
 	lock_map_release(&lockdep_map);
 
 	if (count != preempt_count()) {
-		WARN_ONCE(1, "timer: %pF preempt leak: %08x -> %08x\n",
+		WARN_ONCE(1, "timer: %pS preempt leak: %08x -> %08x\n",
 			  fn, count, preempt_count());
 		/*
 		 * Restore the preempt count. That gives us a decent
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 78b1920..25f4f97 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2161,7 +2161,7 @@ __acquires(&pool->lock)
 
 	if (unlikely(in_atomic() || lockdep_depth(current) > 0)) {
 		pr_err("BUG: workqueue leaked lock or atomic: %s/0x%08x/%d\n"
-		       "     last function: %pf\n",
+		       "     last function: %ps\n",
 		       current->comm, preempt_count(), task_pid_nr(current),
 		       worker->current_func);
 		debug_show_held_locks(current);
@@ -2477,11 +2477,11 @@ static void check_flush_dependency(struct workqueue_struct *target_wq,
 	worker = current_wq_worker();
 
 	WARN_ONCE(current->flags & PF_MEMALLOC,
-		  "workqueue: PF_MEMALLOC task %d(%s) is flushing !WQ_MEM_RECLAIM %s:%pf",
+		  "workqueue: PF_MEMALLOC task %d(%s) is flushing !WQ_MEM_RECLAIM %s:%ps",
 		  current->pid, current->comm, target_wq->name, target_func);
 	WARN_ONCE(worker && ((worker->current_pwq->wq->flags &
 			      (WQ_MEM_RECLAIM | __WQ_LEGACY)) == WQ_MEM_RECLAIM),
-		  "workqueue: WQ_MEM_RECLAIM %s:%pf is flushing !WQ_MEM_RECLAIM %s:%pf",
+		  "workqueue: WQ_MEM_RECLAIM %s:%ps is flushing !WQ_MEM_RECLAIM %s:%ps",
 		  worker->current_pwq->wq->name, worker->current_func,
 		  target_wq->name, target_func);
 }
@@ -4406,7 +4406,7 @@ void print_worker_info(const char *log_lvl, struct task_struct *task)
 	probe_kernel_read(desc, worker->desc, sizeof(desc) - 1);
 
 	if (fn || name[0] || desc[0]) {
-		printk("%sWorkqueue: %s %pf", log_lvl, name, fn);
+		printk("%sWorkqueue: %s %ps", log_lvl, name, fn);
 		if (strcmp(name, desc))
 			pr_cont(" (%s)", desc);
 		pr_cont("\n");
@@ -4431,7 +4431,7 @@ static void pr_cont_work(bool comma, struct work_struct *work)
 		pr_cont("%s BAR(%d)", comma ? "," : "",
 			task_pid_nr(barr->task));
 	} else {
-		pr_cont("%s %pf", comma ? "," : "", work->func);
+		pr_cont("%s %ps", comma ? "," : "", work->func);
 	}
 }
 
@@ -4463,7 +4463,7 @@ static void show_pwq(struct pool_workqueue *pwq)
 			if (worker->current_pwq != pwq)
 				continue;
 
-			pr_cont("%s %d%s:%pf", comma ? "," : "",
+			pr_cont("%s %d%s:%ps", comma ? "," : "",
 				task_pid_nr(worker->task),
 				worker == pwq->wq->rescuer ? "(RESCUER)" : "",
 				worker->current_func);
diff --git a/lib/error-inject.c b/lib/error-inject.c
index c0d4600..aa63751 100644
--- a/lib/error-inject.c
+++ b/lib/error-inject.c
@@ -189,7 +189,7 @@ static int ei_seq_show(struct seq_file *m, void *v)
 {
 	struct ei_entry *ent = list_entry(v, struct ei_entry, list);
 
-	seq_printf(m, "%pf\t%s\n", (void *)ent->start_addr,
+	seq_printf(m, "%ps\t%s\n", (void *)ent->start_addr,
 		   error_type_string(ent->etype));
 	return 0;
 }
diff --git a/lib/percpu-refcount.c b/lib/percpu-refcount.c
index 9f96fa7..f46e0ab 100644
--- a/lib/percpu-refcount.c
+++ b/lib/percpu-refcount.c
@@ -151,7 +151,7 @@ static void percpu_ref_switch_to_atomic_rcu(struct rcu_head *rcu)
 	atomic_long_add((long)count - PERCPU_COUNT_BIAS, &ref->count);
 
 	WARN_ONCE(atomic_long_read(&ref->count) <= 0,
-		  "percpu ref (%pf) <= 0 (%ld) after switching to atomic",
+		  "percpu ref (%ps) <= 0 (%ld) after switching to atomic",
 		  ref->release, atomic_long_read(&ref->count));
 
 	/* @ref is viewed as dead on all CPUs, send out switch confirmation */
@@ -333,7 +333,7 @@ void percpu_ref_kill_and_confirm(struct percpu_ref *ref,
 	spin_lock_irqsave(&percpu_ref_switch_lock, flags);
 
 	WARN_ONCE(ref->percpu_count_ptr & __PERCPU_REF_DEAD,
-		  "%s called more than once on %pf!", __func__, ref->release);
+		  "%s called more than once on %ps!", __func__, ref->release);
 
 	ref->percpu_count_ptr |= __PERCPU_REF_DEAD;
 	__percpu_ref_switch_mode(ref, confirm_kill);
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index a48aaa7..43a40f4 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -662,7 +662,7 @@ char *bdev_name(char *buf, char *end, struct block_device *bdev,
 		struct printf_spec spec, const char *fmt)
 {
 	struct gendisk *hd = bdev->bd_disk;
-	
+
 	buf = string(buf, end, hd->disk_name, spec);
 	if (bdev->bd_part->partno) {
 		if (isdigit(hd->disk_name[strlen(hd->disk_name)-1])) {
@@ -1726,9 +1726,7 @@ static char *ptr_to_id(char *buf, char *end, void *ptr, struct printf_spec spec)
  *
  * - 'S' For symbolic direct pointers (or function descriptors) with offset
  * - 's' For symbolic direct pointers (or function descriptors) without offset
- * - 'F' Same as 'S'
- * - 'f' Same as 's'
- * - '[FfSs]R' as above with __builtin_extract_return_addr() translation
+ * - '[Ss]R' as above with __builtin_extract_return_addr() translation
  * - 'B' For backtraced symbolic direct pointers with offset
  * - 'R' For decoded struct resource, e.g., [mem 0x0-0x1f 64bit pref]
  * - 'r' For raw struct resource, e.g., [mem 0x0-0x1f flags 0x201]
@@ -1844,8 +1842,6 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 	}
 
 	switch (*fmt) {
-	case 'F':
-	case 'f':
 	case 'S':
 	case 's':
 		ptr = dereference_symbol_descriptor(ptr);
diff --git a/mm/memblock.c b/mm/memblock.c
index 03d48d8..4947829 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -598,7 +598,7 @@ int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t end = base + size - 1;
 
-	memblock_dbg("memblock_add: [%pa-%pa] %pF\n",
+	memblock_dbg("memblock_add: [%pa-%pa] %pS\n",
 		     &base, &end, (void *)_RET_IP_);
 
 	return memblock_add_range(&memblock.memory, base, size, MAX_NUMNODES, 0);
@@ -710,7 +710,7 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t end = base + size - 1;
 
-	memblock_dbg("   memblock_free: [%pa-%pa] %pF\n",
+	memblock_dbg("   memblock_free: [%pa-%pa] %pS\n",
 		     &base, &end, (void *)_RET_IP_);
 
 	kmemleak_free_part_phys(base, size);
@@ -721,7 +721,7 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t end = base + size - 1;
 
-	memblock_dbg("memblock_reserve: [%pa-%pa] %pF\n",
+	memblock_dbg("memblock_reserve: [%pa-%pa] %pS\n",
 		     &base, &end, (void *)_RET_IP_);
 
 	return memblock_add_range(&memblock.reserved, base, size, MAX_NUMNODES, 0);
@@ -1343,7 +1343,7 @@ void * __init memblock_virt_alloc_try_nid_raw(
 {
 	void *ptr;
 
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pS\n",
 		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
 		     (u64)max_addr, (void *)_RET_IP_);
 
@@ -1380,7 +1380,7 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
 {
 	void *ptr;
 
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pS\n",
 		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
 		     (u64)max_addr, (void *)_RET_IP_);
 
@@ -1416,7 +1416,7 @@ void * __init memblock_virt_alloc_try_nid(
 {
 	void *ptr;
 
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pS\n",
 		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
 		     (u64)max_addr, (void *)_RET_IP_);
 	ptr = memblock_virt_alloc_internal(size, align,
@@ -1442,7 +1442,7 @@ void * __init memblock_virt_alloc_try_nid(
  */
 void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
 {
-	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
+	memblock_dbg("%s: [%#016llx-%#016llx] %pS\n",
 		     __func__, (u64)base, (u64)base + size - 1,
 		     (void *)_RET_IP_);
 	kmemleak_free_part_phys(base, size);
@@ -1462,7 +1462,7 @@ void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
 {
 	u64 cursor, end;
 
-	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
+	memblock_dbg("%s: [%#016llx-%#016llx] %pS\n",
 		     __func__, (u64)base, (u64)base + size - 1,
 		     (void *)_RET_IP_);
 	kmemleak_free_part_phys(base, size);
diff --git a/mm/memory.c b/mm/memory.c
index 7206a63..aff7c29 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -766,7 +766,7 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 		dump_page(page, "bad pte");
 	pr_alert("addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
 		 (void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
-	pr_alert("file:%pD fault:%pf mmap:%pf readpage:%pf\n",
+	pr_alert("file:%pD fault:%ps mmap:%ps readpage:%ps\n",
 		 vma->vm_file,
 		 vma->vm_ops ? vma->vm_ops->fault : NULL,
 		 vma->vm_file ? vma->vm_file->f_op->mmap : NULL,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 03822f8..ce2f985 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -388,7 +388,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	do_div(delta, shrinker->seeks);
 	total_scan += delta;
 	if (total_scan < 0) {
-		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
+		pr_err("shrink_slab: %pS negative objects to delete nr=%ld\n",
 		       shrinker->scan_objects, total_scan);
 		total_scan = freeable;
 		next_deferred = nr;
diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
index a00c74f..6c2729a 100644
--- a/net/ceph/osd_client.c
+++ b/net/ceph/osd_client.c
@@ -2312,7 +2312,7 @@ static void finish_request(struct ceph_osd_request *req)
 
 static void __complete_request(struct ceph_osd_request *req)
 {
-	dout("%s req %p tid %llu cb %pf result %d\n", __func__, req,
+	dout("%s req %p tid %llu cb %ps result %d\n", __func__, req,
 	     req->r_tid, req->r_callback, req->r_result);
 
 	if (req->r_callback)
diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index 63881f7..3634793 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -258,7 +258,7 @@ static int ptype_seq_show(struct seq_file *seq, void *v)
 		else
 			seq_printf(seq, "%04x", ntohs(pt->type));
 
-		seq_printf(seq, " %-8s %pf\n",
+		seq_printf(seq, " %-8s %ps\n",
 			   pt->dev ? pt->dev->name : "", pt->func);
 	}
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 57557a6..d378d18 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -168,7 +168,7 @@ static void poll_one_napi(struct napi_struct *napi)
 	 * indicate that we are clearing the Tx path only.
 	 */
 	work = napi->poll(napi, 0);
-	WARN_ONCE(work, "%pF exceeded budget in poll\n", napi->poll);
+	WARN_ONCE(work, "%pS exceeded budget in poll\n", napi->poll);
 	trace_napi_poll(napi, work, 0);
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
@@ -369,7 +369,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 		}
 
 		WARN_ONCE(!irqs_disabled(),
-			"netpoll_send_skb_on_dev(): %s enabled interrupts in poll (%pF)\n",
+			"netpoll_send_skb_on_dev(): %s enabled interrupts in poll (%pS)\n",
 			dev->name, dev->netdev_ops->ndo_start_xmit);
 
 	}
diff --git a/tools/lib/traceevent/event-parse.c b/tools/lib/traceevent/event-parse.c
index e5f2acb..3ed5e88 100644
--- a/tools/lib/traceevent/event-parse.c
+++ b/tools/lib/traceevent/event-parse.c
@@ -4425,12 +4425,12 @@ get_bprint_format(void *data, int size __maybe_unused,
 
 	printk = find_printk(pevent, addr);
 	if (!printk) {
-		if (asprintf(&format, "%%pf: (NO FORMAT FOUND at %llx)\n", addr) < 0)
+		if (asprintf(&format, "%%ps: (NO FORMAT FOUND at %llx)\n", addr) < 0)
 			return NULL;
 		return format;
 	}
 
-	if (asprintf(&format, "%s: %s", "%pf", printk->printk) < 0)
+	if (asprintf(&format, "%s: %s", "%ps", printk->printk) < 0)
 		return NULL;
 
 	return format;
-- 
2.7.4

-- 
Sincerely yours,
Mike.
