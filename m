Subject: [PATCH] Prefix each line of multiline printk(KERN_<level>
	"foo\nbar") with KERN_<level>
From: Joe Perches <joe@perches.com>
Content-Type: text/plain
Date: Fri, 24 Aug 2007 16:44:58 -0700
Message-Id: <1187999098.32738.179.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: blinux-list@redhat.com, cluster-devel@redhat.com, discuss@x86-64.org, jffs-dev@axis.com, linux-acpi@vger.kernel.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-scsi@vger.kernel.org, mpt_linux_developer@lsi.com, netdev@vger.kernel.org, osst-users@lists.sourceforge.net, parisc-linux@parisc-linux.org, tpmdd-devel@lists.sourceforge.net, uclinux-dist-devel@blackfin.uclinux.org
List-ID: <linux-mm.kvack.org>

Corrected printk calls with multiple output lines which
did not correctly preface each line with KERN_<level>

Fixed uses of some single lines with too many KERN_<level>

Please pull from:
git://repo.or.cz/linux-2.6/trivial-mods.git pr_newlines

Signed-off-by: Joe Perches <joe@perches.com>

 arch/arm/kernel/ecard.c                  |    3 ++-
 arch/blackfin/kernel/dualcore_test.c     |    3 ++-
 arch/blackfin/kernel/traps.c             |    4 +++-
 arch/h8300/kernel/setup.c                |    4 +++-
 arch/i386/kernel/io_apic.c               |    3 ++-
 arch/m68knommu/kernel/setup.c            |    4 +++-
 arch/m68knommu/kernel/traps.c            |    5 +++--
 arch/m68knommu/mm/init.c                 |    9 ++++++---
 arch/m68knommu/platform/68328/config.c   |    3 ++-
 arch/m68knommu/platform/68360/config.c   |    3 ++-
 arch/m68knommu/platform/68EZ328/config.c |    3 ++-
 arch/mips/vr41xx/common/pmu.c            |    9 ++++++---
 arch/parisc/kernel/traps.c               |    3 ++-
 arch/parisc/math-emu/driver.c            |    5 +++--
 arch/v850/kernel/setup.c                 |    6 ++++--
 arch/x86_64/kernel/io_apic.c             |    3 ++-
 arch/x86_64/kernel/mpparse.c             |    3 ++-
 drivers/acpi/acpi_memhotplug.c           |    3 ++-
 drivers/char/dtlk.c                      |    3 ++-
 drivers/char/tpm/tpm_bios.c              |    2 +-
 drivers/ide/ide-cd.c                     |    3 ++-
 drivers/input/serio/hil_mlc.c            |    2 +-
 drivers/message/fusion/mptlan.c          |    3 ++-
 drivers/mtd/maps/cdb89712.c              |    5 ++++-
 drivers/net/cs89x0.c                     |    2 +-
 drivers/net/dgrs.c                       |    3 ++-
 drivers/net/wireless/arlan-main.c        |    2 +-
 drivers/net/wireless/arlan-proc.c        |   19 ++++++++++---------
 drivers/parisc/led.c                     |    3 ++-
 drivers/scsi/aha152x.c                   |   16 +++++++++++-----
 drivers/scsi/dpt_i2o.c                   |    3 ++-
 drivers/scsi/mac_scsi.c                  |    3 ++-
 drivers/scsi/megaraid.c                  |    3 ++-
 drivers/scsi/megaraid/megaraid_sas.c     |   25 ++++++++++++++++---------
 drivers/scsi/osst.c                      |    3 ++-
 drivers/scsi/zalon.c                     |    2 +-
 drivers/video/savage/savagefb_driver.c   |   21 ++++++++++++---------
 fs/dlm/dlm_internal.h                    |    9 +++++----
 fs/freevxfs/vxfs_bmap.c                  |    8 ++++++--
 fs/jffs2/wbuf.c                          |    3 ++-
 mm/slub.c                                |   18 ++++++++++++------
 41 files changed, 152 insertions(+), 85 deletions(-)

diff --git a/arch/arm/kernel/ecard.c b/arch/arm/kernel/ecard.c
index f56d48c..6402ad2 100644
--- a/arch/arm/kernel/ecard.c
+++ b/arch/arm/kernel/ecard.c
@@ -547,7 +547,8 @@ static void ecard_check_lockup(struct irq_desc *desc)
 	if (last == jiffies) {
 		lockup += 1;
 		if (lockup > 1000000) {
-			printk(KERN_ERR "\nInterrupt lockup detected - "
+			printk(KERN_ERR "\n"
+			       KERN_ERR "Interrupt lockup detected - "
 			       "disabling all expansion card interrupts\n");
 
 			desc->chip->mask(IRQ_EXPANSIONCARD);
diff --git a/arch/blackfin/kernel/dualcore_test.c b/arch/blackfin/kernel/dualcore_test.c
index 0fcba74..3c94199 100644
--- a/arch/blackfin/kernel/dualcore_test.c
+++ b/arch/blackfin/kernel/dualcore_test.c
@@ -35,7 +35,8 @@ static int *testarg = (int *)0xfeb00000;
 static int test_init(void)
 {
 	*testarg = 1;
-	printk(KERN_INFO "Dual core test module inserted: set testarg = [%d]\n @ [%p]\n",
+	printk(KERN_INFO "Dual core test module inserted: set testarg = [%d]\n"
+	       KERN_INFO "@ [%p]\n",
 	       *testarg, testarg);
 	return 0;
 }
diff --git a/arch/blackfin/kernel/traps.c b/arch/blackfin/kernel/traps.c
index 792a841..9255012 100644
--- a/arch/blackfin/kernel/traps.c
+++ b/arch/blackfin/kernel/traps.c
@@ -351,7 +351,9 @@ asmlinkage void trap_c(struct pt_regs *fp)
 		info.si_code = ILL_CPLB_MULHIT;
 #ifdef CONFIG_DEBUG_HUNT_FOR_ZERO
 		sig = SIGSEGV;
-		printk(KERN_EMERG "\n\nJump to address 0 - 0x0fff\n");
+		printk(KERN_EMERG "\n"
+		       KERN_EMERG "\n"
+		       KERN_EMERG "Jump to address 0 - 0x0fff\n");
 #else
 		sig = SIGILL;
 		printk(KERN_EMERG EXC_0x2D);
diff --git a/arch/h8300/kernel/setup.c b/arch/h8300/kernel/setup.c
index b2e86d0..cb45404 100644
--- a/arch/h8300/kernel/setup.c
+++ b/arch/h8300/kernel/setup.c
@@ -127,7 +127,9 @@ void __init setup_arch(char **cmdline_p)
 	register_console((struct console *)&gdb_console);
 #endif
 
-	printk(KERN_INFO "\r\n\nuClinux " CPU "\n");
+	printk(KERN_INFO "\r\n"
+	       KERN_INFO "\n"
+	       KERN_INFO "uClinux " CPU "\n");
 	printk(KERN_INFO "Target Hardware: %s\n",_target_name);
 	printk(KERN_INFO "Flat model support (C) 1998,1999 Kenneth Albanowski, D. Jeff Dionne\n");
 	printk(KERN_INFO "H8/300 series support by Yoshinori Sato <ysato@users.sourceforge.jp>\n");
diff --git a/arch/i386/kernel/io_apic.c b/arch/i386/kernel/io_apic.c
index 4b8a8da..856f127 100644
--- a/arch/i386/kernel/io_apic.c
+++ b/arch/i386/kernel/io_apic.c
@@ -1618,7 +1618,8 @@ void /*__init*/ print_PIC(void)
 	if (apic_verbosity == APIC_QUIET)
 		return;
 
-	printk(KERN_DEBUG "\nprinting PIC contents\n");
+	printk(KERN_DEBUG "\n"
+	       KERN_DEBUG "printing PIC contents\n");
 
 	spin_lock_irqsave(&i8259A_lock, flags);
 
diff --git a/arch/m68knommu/kernel/setup.c b/arch/m68knommu/kernel/setup.c
index 3f86ade..7c0dd75 100644
--- a/arch/m68knommu/kernel/setup.c
+++ b/arch/m68knommu/kernel/setup.c
@@ -135,7 +135,9 @@ void setup_arch(char **cmdline_p)
 	command_line[sizeof(command_line) - 1] = 0;
 #endif
 
-	printk(KERN_INFO "\x0F\r\n\nuClinux/" CPU "\n");
+	printk(KERN_INFO "\x0F\r\n"
+	       KERN_INFO "\n"
+	       KERN_INFO "uClinux/" CPU "\n");
 
 #ifdef CONFIG_UCDIMM
 	printk(KERN_INFO "uCdimm by Lineo, Inc. <www.lineo.com>\n");
diff --git a/arch/m68knommu/kernel/traps.c b/arch/m68knommu/kernel/traps.c
index 437a061..a66c348 100644
--- a/arch/m68knommu/kernel/traps.c
+++ b/arch/m68knommu/kernel/traps.c
@@ -71,8 +71,9 @@ void die_if_kernel(char *str, struct pt_regs *fp, int nr)
 
 	console_verbose();
 	printk(KERN_EMERG "%s: %08x\n",str,nr);
-	printk(KERN_EMERG "PC: [<%08lx>]\nSR: %04x  SP: %p  a2: %08lx\n",
-	       fp->pc, fp->sr, fp, fp->a2);
+	printk(KERN_EMERG "PC: [<%08lx>]\n", fp->pc);
+	printk(KERN_EMERG "SR: %04x  SP: %p  a2: %08lx\n",
+	       fp->sr, fp, fp->a2);
 	printk(KERN_EMERG "d0: %08lx    d1: %08lx    d2: %08lx    d3: %08lx\n",
 	       fp->d0, fp->d1, fp->d2, fp->d3);
 	printk(KERN_EMERG "d4: %08lx    d5: %08lx    a0: %08lx    a1: %08lx\n",
diff --git a/arch/m68knommu/mm/init.c b/arch/m68knommu/mm/init.c
index 06e538d..970f1a1 100644
--- a/arch/m68knommu/mm/init.c
+++ b/arch/m68knommu/mm/init.c
@@ -68,7 +68,8 @@ void show_mem(void)
     int free = 0, total = 0, reserved = 0, shared = 0;
     int cached = 0;
 
-    printk(KERN_INFO "\nMem-info:\n");
+    printk(KERN_INFO "\n"
+	   KERN_INFO "Mem-info:\n");
     show_free_areas();
     i = max_mapnr;
     while (i-- > 0) {
@@ -110,7 +111,8 @@ void paging_init(void)
 	unsigned long end_mem   = memory_end & PAGE_MASK;
 
 #ifdef DEBUG
-	printk (KERN_DEBUG "start_mem is %#lx\nvirtual_end is %#lx\n",
+	printk (KERN_DEBUG "start_mem is %#lx\n"
+		KERN_DEBUG "virtual_end is %#lx\n",
 		start_mem, end_mem);
 #endif
 
@@ -131,7 +133,8 @@ void paging_init(void)
 #ifdef DEBUG
 	printk (KERN_DEBUG "before free_area_init\n");
 
-	printk (KERN_DEBUG "free_area_init -> start_mem is %#lx\nvirtual_end is %#lx\n",
+	printk (KERN_DEBUG "free_area_init -> start_mem is %#lx\n"
+		KERN_DEBUG "virtual_end is %#lx\n",
 		start_mem, end_mem);
 #endif
 
diff --git a/arch/m68knommu/platform/68328/config.c b/arch/m68knommu/platform/68328/config.c
index e5c537d..07c73c9 100644
--- a/arch/m68knommu/platform/68328/config.c
+++ b/arch/m68knommu/platform/68328/config.c
@@ -55,7 +55,8 @@ void m68328_reset (void)
 
 void config_BSP(char *command, int len)
 {
-  printk(KERN_INFO "\n68328 support D. Jeff Dionne <jeff@uclinux.org>\n");
+  printk(KERN_INFO "\n"
+	 KERN_INFO "68328 support D. Jeff Dionne <jeff@uclinux.org>\n");
   printk(KERN_INFO "68328 support Kenneth Albanowski <kjahds@kjshds.com>\n");
   printk(KERN_INFO "68328/Pilot support Bernhard Kuhn <kuhn@lpr.e-technik.tu-muenchen.de>\n");
 
diff --git a/arch/m68knommu/platform/68360/config.c b/arch/m68knommu/platform/68360/config.c
index 155b72f..2392fc0 100644
--- a/arch/m68knommu/platform/68360/config.c
+++ b/arch/m68knommu/platform/68360/config.c
@@ -183,7 +183,8 @@ void config_BSP(char *command, int len)
      }
   }
 
-  printk(KERN_INFO "\n68360 QUICC support (C) 2000 Lineo Inc.\n");
+  printk(KERN_INFO "\n"
+	 KERN_INFO "68360 QUICC support (C) 2000 Lineo Inc.\n");
 
 #if defined(CONFIG_UCQUICC) && 0
   printk(KERN_INFO "uCquicc serial string [%s]\n",getserialnum());
diff --git a/arch/m68knommu/platform/68EZ328/config.c b/arch/m68knommu/platform/68EZ328/config.c
index ab36551..f344edf 100644
--- a/arch/m68knommu/platform/68EZ328/config.c
+++ b/arch/m68knommu/platform/68EZ328/config.c
@@ -66,7 +66,8 @@ void config_BSP(char *command, int len)
 {
   unsigned char *p;
 
-  printk(KERN_INFO "\n68EZ328 DragonBallEZ support (C) 1999 Rt-Control, Inc\n");
+  printk(KERN_INFO "\n"
+	 KERN_INFO "68EZ328 DragonBallEZ support (C) 1999 Rt-Control, Inc\n");
 
 #ifdef CONFIG_UCSIMM
   printk(KERN_INFO "uCsimm serial string [%s]\n",getserialnum());
diff --git a/arch/mips/vr41xx/common/pmu.c b/arch/mips/vr41xx/common/pmu.c
index 5e46979..ada7f15 100644
--- a/arch/mips/vr41xx/common/pmu.c
+++ b/arch/mips/vr41xx/common/pmu.c
@@ -65,21 +65,24 @@ static void vr41xx_restart(char *command)
 {
 	local_irq_disable();
 	software_reset();
-	printk(KERN_NOTICE "\nYou can reset your system\n");
+	printk(KERN_NOTICE "\n"
+	       KERN_NOTICE "You can reset your system\n");
 	while (1) ;
 }
 
 static void vr41xx_halt(void)
 {
 	local_irq_disable();
-	printk(KERN_NOTICE "\nYou can turn off the power supply\n");
+	printk(KERN_NOTICE "\n"
+	       KERN_NOTICE "You can turn off the power supply\n");
 	while (1) ;
 }
 
 static void vr41xx_power_off(void)
 {
 	local_irq_disable();
-	printk(KERN_NOTICE "\nYou can turn off the power supply\n");
+	printk(KERN_NOTICE "\n"
+	       KERN_NOTICE "You can turn off the power supply\n");
 	while (1) ;
 }
 
diff --git a/arch/parisc/kernel/traps.c b/arch/parisc/kernel/traps.c
index bbf029a..6a29d4c 100644
--- a/arch/parisc/kernel/traps.c
+++ b/arch/parisc/kernel/traps.c
@@ -746,7 +746,8 @@ void handle_interruption(int code, struct pt_regs *regs)
 	default:
 		if (user_mode(regs)) {
 #ifdef PRINT_USER_FAULTS
-			printk(KERN_DEBUG "\nhandle_interruption() pid=%d command='%s'\n",
+			printk(KERN_DEBUG "\n"
+			       KERN_DEBUG "handle_interruption() pid=%d command='%s'\n",
 			    current->pid, current->comm);
 			show_regs(regs);
 #endif
diff --git a/arch/parisc/math-emu/driver.c b/arch/parisc/math-emu/driver.c
index 09ef413..534ce20 100644
--- a/arch/parisc/math-emu/driver.c
+++ b/arch/parisc/math-emu/driver.c
@@ -98,9 +98,10 @@ handle_fpe(struct pt_regs *regs)
 	memcpy(&orig_sw, frcopy, sizeof(orig_sw));
 
 	if (FPUDEBUG) {
-		printk(KERN_DEBUG "FP VZOUICxxxxCQCQCQCQCQCRMxxTDVZOUI ->\n   ");
+		printk(KERN_DEBUG "FP VZOUICxxxxCQCQCQCQCQCRMxxTDVZOUI ->\n"
+		       KERN_DEBUG "   ");
 		printbinary(orig_sw, 32);
-		printk(KERN_DEBUG "\n");
+		printk("\n");
 	}
 
 	signalcode = decode_fpu(frcopy, 0x666);
diff --git a/arch/v850/kernel/setup.c b/arch/v850/kernel/setup.c
index a914f24..35cf93a 100644
--- a/arch/v850/kernel/setup.c
+++ b/arch/v850/kernel/setup.c
@@ -79,7 +79,8 @@ void __init setup_arch (char **cmdline)
 	/* ... and tell the kernel about it.  */
 	init_mem_alloc (ram_start, ram_len);
 
-	printk (KERN_INFO "CPU: %s\nPlatform: %s\n",
+	printk (KERN_INFO "CPU: %s\n"
+		KERN_INFO "Platform: %s\n",
 		CPU_MODEL_LONG, PLATFORM_LONG);
 
 	/* do machine-specific setups.  */
@@ -304,7 +305,8 @@ void show_mem(void)
     int free = 0, total = 0, reserved = 0, shared = 0;
     int cached = 0;
 
-    printk(KERN_INFO "\nMem-info:\n");
+    printk(KERN_INFO "\n"
+	   KERN_INFO "Mem-info:\n");
     show_free_areas();
     i = max_mapnr;
     while (i-- > 0) {
diff --git a/arch/x86_64/kernel/io_apic.c b/arch/x86_64/kernel/io_apic.c
index f57f8b9..6b2c8a3 100644
--- a/arch/x86_64/kernel/io_apic.c
+++ b/arch/x86_64/kernel/io_apic.c
@@ -1142,7 +1142,8 @@ void __apicdebuginit print_PIC(void)
 	if (apic_verbosity == APIC_QUIET)
 		return;
 
-	printk(KERN_DEBUG "\nprinting PIC contents\n");
+	printk(KERN_DEBUG "\n"
+	       KERN_DEBUG "printing PIC contents\n");
 
 	spin_lock_irqsave(&i8259A_lock, flags);
 
diff --git a/arch/x86_64/kernel/mpparse.c b/arch/x86_64/kernel/mpparse.c
index 8bf0ca0..d32e640 100644
--- a/arch/x86_64/kernel/mpparse.c
+++ b/arch/x86_64/kernel/mpparse.c
@@ -411,7 +411,8 @@ static inline void __init construct_default_ISA_mptable(int mpc_default_type)
 	bus.mpc_busid = 0;
 	switch (mpc_default_type) {
 		default:
-			printk(KERN_ERR "???\nUnknown standard configuration %d\n",
+			printk(KERN_ERR "\n"
+			       KERN_ERR "???Unknown standard configuration %d\n",
 				mpc_default_type);
 			/* fall through */
 		case 1:
diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 5f1127a..61e51ca 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -185,7 +185,8 @@ acpi_memory_get_device(acpi_handle handle,
       end:
 	*mem_device = acpi_driver_data(device);
 	if (!(*mem_device)) {
-		printk(KERN_ERR "\n driver data not found");
+		printk(KERN_ERR "\n"
+		       KERN_ERR "driver data not found");
 		return -ENODEV;
 	}
 
diff --git a/drivers/char/dtlk.c b/drivers/char/dtlk.c
index abde6dd..0bf01c6 100644
--- a/drivers/char/dtlk.c
+++ b/drivers/char/dtlk.c
@@ -495,7 +495,8 @@ for (i = 0; i < 10; i++)			\
 /*
    static void dtlk_handle_error(char op, char rc, unsigned int minor)
    {
-   printk(KERN_INFO"\nDoubleTalk PC - MINOR: %d, OPCODE: %d, ERROR: %d\n", 
+   printk(KERN_INFO "\n"
+          KERN_INFO "DoubleTalk PC - MINOR: %d, OPCODE: %d, ERROR: %d\n", 
    minor, op, rc);
    return;
    }
diff --git a/drivers/char/tpm/tpm_bios.c b/drivers/char/tpm/tpm_bios.c
index 60a2d26..c0b4fa1 100644
--- a/drivers/char/tpm/tpm_bios.c
+++ b/drivers/char/tpm/tpm_bios.c
@@ -321,7 +321,7 @@ static int tpm_ascii_bios_measurements_show(struct seq_file *m, void *v)
 
 	eventname = kmalloc(MAX_TEXT_EVENT, GFP_KERNEL);
 	if (!eventname) {
-		printk(KERN_ERR "%s: ERROR - No Memory for event name\n ",
+		printk(KERN_ERR "%s: ERROR - No Memory for event name\n",
 		       __func__);
 		return -EFAULT;
 	}
diff --git a/drivers/ide/ide-cd.c b/drivers/ide/ide-cd.c
index ca84352..31fcbe8 100644
--- a/drivers/ide/ide-cd.c
+++ b/drivers/ide/ide-cd.c
@@ -541,7 +541,8 @@ void cdrom_analyze_sense_data(ide_drive_t *drive,
 					lo = mid+1;
 			}
 
-			printk (KERN_ERR "  The failed \"%s\" packet command was: \n  \"", s);
+			printk (KERN_ERR "  The failed \"%s\" packet command was:\n"
+				KERN_ERR "  \"", s);
 			for (i=0; i<sizeof (failed_command->cmd); i++)
 				printk ("%02x ", failed_command->cmd[i]);
 			printk ("\"\n");
diff --git a/drivers/input/serio/hil_mlc.c b/drivers/input/serio/hil_mlc.c
index 93a1a6b..ef31148 100644
--- a/drivers/input/serio/hil_mlc.c
+++ b/drivers/input/serio/hil_mlc.c
@@ -625,7 +625,7 @@ static int hilse_donode(hil_mlc *mlc)
 #ifdef HIL_MLC_DEBUG
 	if (mlc->seidx && mlc->seidx != seidx &&
 	    mlc->seidx != 41 && mlc->seidx != 42 && mlc->seidx != 43) {
-		printk(KERN_DEBUG PREFIX "z%i \n {%i}", doze, mlc->seidx);
+		printk(KERN_DEBUG PREFIX "z%i\t{%i}\n", doze, mlc->seidx);
 		doze = 0;
 	}
 
diff --git a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
index 01fc397..59df21e 100644
--- a/drivers/message/fusion/mptlan.c
+++ b/drivers/message/fusion/mptlan.c
@@ -1318,7 +1318,8 @@ mpt_lan_post_receive_buckets(struct mpt_lan_priv *priv)
 
 		pRecvReq->BucketCount = cpu_to_le32(i);
 
-/*	printk(KERN_INFO MYNAM ": posting buckets\n   ");
+/*	printk(KERN_INFO MYNAM ": posting buckets\n");
+ *	printk(KERN_INFO "   ");
  *	for (i = 0; i < j + 2; i ++)
  *	    printk (" %08x", le32_to_cpu(msg[i]));
  *	printk ("\n");
diff --git a/drivers/mtd/maps/cdb89712.c b/drivers/mtd/maps/cdb89712.c
index 9f17bb6..2a15cc9 100644
--- a/drivers/mtd/maps/cdb89712.c
+++ b/drivers/mtd/maps/cdb89712.c
@@ -225,7 +225,10 @@ out:
 static int __init init_cdb89712_maps(void)
 {
 
-       	printk(KERN_INFO "Cirrus CDB89712 MTD mappings:\n  Flash 0x%x at 0x%x\n  SRAM 0x%x at 0x%x\n  BootROM 0x%x at 0x%x\n",
+	printk(KERN_INFO "Cirrus CDB89712 MTD mappings:\n"
+	       KERN_INFO "  Flash 0x%x at 0x%x\n"
+	       KERN_INFO "  SRAM 0x%x at 0x%x\n"
+	       KERN_INFO "  BootROM 0x%x at 0x%x\n",
 	       FLASH_SIZE, FLASH_START, SRAM_SIZE, SRAM_START, BOOTROM_SIZE, BOOTROM_START);
 
 	init_cdb89712_flash();
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 9774bb1..536d29f 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -731,7 +731,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 	if ((readreg(dev, PP_SelfST) & EEPROM_PRESENT) == 0)
 		printk(KERN_WARNING "cs89x0: No EEPROM, relying on command line....\n");
 	else if (get_eeprom_data(dev, START_EEPROM_DATA,CHKSUM_LEN,eeprom_buff) < 0) {
-		printk(KERN_WARNING "\ncs89x0: EEPROM read failed, relying on command line.\n");
+		printk(KERN_WARNING "cs89x0: EEPROM read failed, relying on command line.\n");
         } else if (get_eeprom_cksum(START_EEPROM_DATA,CHKSUM_LEN,eeprom_buff) < 0) {
 		/* Check if the chip was able to read its own configuration starting
 		   at 0 in the EEPROM*/
diff --git a/drivers/net/dgrs.c b/drivers/net/dgrs.c
index df62c02..28c7bc9 100644
--- a/drivers/net/dgrs.c
+++ b/drivers/net/dgrs.c
@@ -1583,7 +1583,8 @@ static int __init dgrs_init_module (void)
 
 	if (dgrs_debug)
 	{
-		printk(KERN_INFO "dgrs: SW=%s FW=Build %d %s\nFW Version=%s\n",
+		printk(KERN_INFO "dgrs: SW=%s FW=Build %d %s\n"
+		       KERN_INFO "FW Version=%s\n",
 		       version, dgrs_firmnum, dgrs_firmdate, dgrs_firmver);
 	}
 
diff --git a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
index 498e848..00edf9a 100644
--- a/drivers/net/wireless/arlan-main.c
+++ b/drivers/net/wireless/arlan-main.c
@@ -1082,7 +1082,7 @@ static int __init arlan_probe_here(struct net_device *dev,
 	if (arlan_check_fingerprint(memaddr))
 		return -ENODEV;
 
-	printk(KERN_NOTICE "%s: Arlan found at %x, \n ", dev->name, 
+	printk(KERN_NOTICE "%s: Arlan found at %x, \n", dev->name, 
 	       (int) virt_to_phys((void*)memaddr));
 
 	ap->card = (void *) memaddr;
diff --git a/drivers/net/wireless/arlan-proc.c b/drivers/net/wireless/arlan-proc.c
index 015abd9..6effdf6 100644
--- a/drivers/net/wireless/arlan-proc.c
+++ b/drivers/net/wireless/arlan-proc.c
@@ -418,13 +418,14 @@ static int arlan_sysctl_info(ctl_table * ctl, int write, struct file *filp,
 	}
 	if (ctl->procname == NULL || arlan_drive_info == NULL)
 	{
-		printk(KERN_WARNING " procname is NULL in sysctl_table or arlan_drive_info is NULL \n at arlan module\n ");
+		printk(KERN_WARNING " procname is NULL in sysctl_table or arlan_drive_info is NULL\n"
+		       KERN_WARNING " at arlan module\n");
 		return -1;
 	}
 	devnum = ctl->procname[5] - '0';
 	if (devnum < 0 || devnum > MAX_ARLANS - 1)
 	{
-		printk(KERN_WARNING "too strange devnum in procfs parse\n ");
+		printk(KERN_WARNING "too strange devnum in procfs parse\n");
 		return -1;
 	}
 	else if (arlan_device[devnum] == NULL)
@@ -439,7 +440,7 @@ static int arlan_sysctl_info(ctl_table * ctl, int write, struct file *filp,
 
 	if (priva == NULL)
 	{
-		printk(KERN_WARNING " Could not find the device private in arlan procsys, bad\n ");
+		printk(KERN_WARNING "Could not find the device private in arlan procsys, bad\n");
 		return -1;
 	}
 	dev = arlan_device[devnum];
@@ -657,7 +658,7 @@ static int arlan_sysctl_info161719(ctl_table * ctl, int write, struct file *filp
 		priva = arlan_device[devnum]->priv;
 	if (priva == NULL)
 	{
-		printk(KERN_WARNING " Could not find the device private in arlan procsys, bad\n ");
+		printk(KERN_WARNING "Could not find the device private in arlan procsys, bad\n");
 		return -1;
 	}
 	memcpy_fromio(priva->conf, priva->card, sizeof(struct arlan_shmem));
@@ -691,7 +692,7 @@ static int arlan_sysctl_infotxRing(ctl_table * ctl, int write, struct file *filp
 		priva = arlan_device[devnum]->priv;
 	if (priva == NULL)
 	{
-		printk(KERN_WARNING " Could not find the device private in arlan procsys, bad\n ");
+		printk(KERN_WARNING "Could not find the device private in arlan procsys, bad\n");
 		return -1;
 	}
 	memcpy_fromio(priva->conf, priva->card, sizeof(struct arlan_shmem));
@@ -719,7 +720,7 @@ static int arlan_sysctl_inforxRing(ctl_table * ctl, int write, struct file *filp
 		priva = arlan_device[devnum]->priv;
 	if (priva == NULL)
 	{
-		printk(KERN_WARNING " Could not find the device private in arlan procsys, bad\n ");
+		printk(KERN_WARNING "Could not find the device private in arlan procsys, bad\n");
 		return -1;
 	}
 	memcpy_fromio(priva->conf, priva->card, sizeof(struct arlan_shmem));
@@ -748,7 +749,7 @@ static int arlan_sysctl_info18(ctl_table * ctl, int write, struct file *filp,
 		priva = arlan_device[devnum]->priv;
 	if (priva == NULL)
 	{
-		printk(KERN_WARNING " Could not find the device private in arlan procsys, bad\n ");
+		printk(KERN_WARNING "Could not find the device private in arlan procsys, bad\n");
 		return -1;
 	}
 	memcpy_fromio(priva->conf, priva->card, sizeof(struct arlan_shmem));
@@ -775,7 +776,7 @@ static int arlan_configure(ctl_table * ctl, int write, struct file *filp,
 
 	if (devnum < 0 || devnum > MAX_ARLANS - 1)
 	{
-		  printk(KERN_WARNING "too strange devnum in procfs parse\n ");
+		  printk(KERN_WARNING "too strange devnum in procfs parse\n");
 		  return -1;
 	}
 	else if (arlan_device[devnum] != NULL)
@@ -800,7 +801,7 @@ static int arlan_sysctl_reset(ctl_table * ctl, int write, struct file *filp,
 
 	if (devnum < 0 || devnum > MAX_ARLANS - 1)
 	{
-		  printk(KERN_WARNING "too strange devnum in procfs parse\n ");
+		  printk(KERN_WARNING "too strange devnum in procfs parse\n");
 		  return -1;
 	}
 	else if (arlan_device[devnum] != NULL)
diff --git a/drivers/parisc/led.c b/drivers/parisc/led.c
index e5d7ed9..9053933 100644
--- a/drivers/parisc/led.c
+++ b/drivers/parisc/led.c
@@ -230,7 +230,8 @@ static int led_proc_write(struct file *file, const char *buf,
 
 parse_error:
 	if ((long)data == LED_NOLCD)
-		printk(KERN_CRIT "Parse error: expect \"n n n\" (n == 0 or 1) for heartbeat,\ndisk io and lan tx/rx indicators\n");
+		printk(KERN_CRIT "Parse error: expect \"n n n\" (n == 0 or 1) for heartbeat,\n"
+		       KERN_CRIT "disk io and lan tx/rx indicators\n");
 	return -EINVAL;
 }
 
diff --git a/drivers/scsi/aha152x.c b/drivers/scsi/aha152x.c
index d30a307..0a96ff4 100644
--- a/drivers/scsi/aha152x.c
+++ b/drivers/scsi/aha152x.c
@@ -2647,7 +2647,8 @@ static void is_complete(struct Scsi_Host *shpnt)
  */
 static void aha152x_error(struct Scsi_Host *shpnt, char *msg)
 {
-	printk(KERN_EMERG "\naha152x%d: %s\n", HOSTNO, msg);
+	printk(KERN_EMERG "\n"
+	       KERN_EMERG "aha152x%d: %s\n", HOSTNO, msg);
 	show_queues(shpnt);
 	panic("aha152x panic\n");
 }
@@ -2973,7 +2974,9 @@ static void show_queues(struct Scsi_Host *shpnt)
 	unsigned long flags;
 
 	DO_LOCK(flags);
-	printk(KERN_DEBUG "\nqueue status:\nissue_SC:\n");
+	printk(KERN_DEBUG "\n"
+	       KERN_DEBUG "queue status:\n"
+	       KERN_DEBUG "issue_SC:\n");
 	for (ptr = ISSUE_SC; ptr; ptr = SCNEXT(ptr))
 		show_command(ptr);
 	DO_UNLOCK(flags);
@@ -3663,7 +3666,8 @@ static int __init aha152x_init(void)
 
 		for (i = 0; i<setup_count; i++) {
 			if (!checksetup(&setup[i])) {
-				printk(KERN_ERR "\naha152x: %s\n", setup[i].conf);
+				printk(KERN_ERR "\n"
+				       KERN_ERR "aha152x: %s\n", setup[i].conf);
 				printk(KERN_ERR "aha152x: invalid line\n");
 			}
 		}
@@ -3676,7 +3680,8 @@ static int __init aha152x_init(void)
 
 		if (setup_count == 0 || (override.io_port != setup[0].io_port)) {
 			if (!checksetup(&override)) {
-				printk(KERN_ERR "\naha152x: invalid override SETUP0={0x%x,%d,%d,%d,%d,%d,%d,%d}\n",
+				printk(KERN_ERR "\n"
+				       KERN_ERR "aha152x: invalid override SETUP0={0x%x,%d,%d,%d,%d,%d,%d,%d}\n",
 				       override.io_port,
 				       override.irq,
 				       override.scsiid,
@@ -3697,7 +3702,8 @@ static int __init aha152x_init(void)
 
 		if (setup_count == 0 || (override.io_port != setup[0].io_port)) {
 			if (!checksetup(&override)) {
-				printk(KERN_ERR "\naha152x: invalid override SETUP1={0x%x,%d,%d,%d,%d,%d,%d,%d}\n",
+				printk(KERN_ERR "\n"
+				       KERN_ERR "aha152x: invalid override SETUP1={0x%x,%d,%d,%d,%d,%d,%d,%d}\n",
 				       override.io_port,
 				       override.irq,
 				       override.scsiid,
diff --git a/drivers/scsi/dpt_i2o.c b/drivers/scsi/dpt_i2o.c
index 502732a..b40efe0 100644
--- a/drivers/scsi/dpt_i2o.c
+++ b/drivers/scsi/dpt_i2o.c
@@ -3148,7 +3148,8 @@ static int adpt_i2o_issue_params(int cmd, adpt_hba* pHba, int tid,
 	}
 
 	if (res[1]&0x00FF0000) { 	/* BlockStatus != SUCCESS */
-		printk(KERN_WARNING "%s: %s - Error:\n  ErrorInfoSize = 0x%02x, "
+		printk(KERN_WARNING "%s: %s - Error:\n"
+		       KERN_WARNING "  ErrorInfoSize = 0x%02x, "
 			"BlockStatus = 0x%02x, BlockSize = 0x%04x\n",
 			pHba->name,
 			(cmd == I2O_CMD_UTIL_PARAMS_SET) ? "PARAMS_SET"
diff --git a/drivers/scsi/mac_scsi.c b/drivers/scsi/mac_scsi.c
index cdbcaa5..1afcb6c 100644
--- a/drivers/scsi/mac_scsi.c
+++ b/drivers/scsi/mac_scsi.c
@@ -311,7 +311,8 @@ int macscsi_detect(struct scsi_host_template * tpnt)
 	printk (KERN_INFO " %d", instance->irq);
     printk(KERN_INFO " options CAN_QUEUE=%d CMD_PER_LUN=%d release=%d",
 	   instance->can_queue, instance->cmd_per_lun, MACSCSI_PUBLIC_RELEASE);
-    printk(KERN_INFO "\nscsi%d:", instance->host_no);
+    printk(KERN_INFO "\n"
+	   KERN_INFO "scsi%d:", instance->host_no);
     NCR5380_print_options(instance);
     printk("\n");
     called = 1;
diff --git a/drivers/scsi/megaraid.c b/drivers/scsi/megaraid.c
index 3907f67..a3083a6 100644
--- a/drivers/scsi/megaraid.c
+++ b/drivers/scsi/megaraid.c
@@ -2077,7 +2077,8 @@ mega_create_proc_entry(int index, struct proc_dir_entry *parent)
 		adapter->controller_proc_dir_entry = proc_mkdir(string, parent);
 
 	if(!controller_proc_dir_entry) {
-		printk(KERN_WARNING "\nmegaraid: proc_mkdir failed\n");
+		printk(KERN_WARNING "\n"
+		       KERN_WARNING "megaraid: proc_mkdir failed\n");
 		return;
 	}
 	adapter->proc_read = CREATE_READ_PROC("config", proc_read_config);
diff --git a/drivers/scsi/megaraid/megaraid_sas.c b/drivers/scsi/megaraid/megaraid_sas.c
index ebb948c..fe05e86 100644
--- a/drivers/scsi/megaraid/megaraid_sas.c
+++ b/drivers/scsi/megaraid/megaraid_sas.c
@@ -744,12 +744,14 @@ megasas_dump_pending_frames(struct megasas_instance *instance)
 	u32 sgcount;
 	u32 max_cmd = instance->max_fw_cmds;
 
-	printk(KERN_ERR "\nmegasas[%d]: Dumping Frame Phys Address of all pending cmds in FW\n",instance->host->host_no);
+	printk(KERN_ERR "\n"
+	       KERN_ERR "megasas[%d]: Dumping Frame Phys Address of all pending cmds in FW\n",instance->host->host_no);
 	printk(KERN_ERR "megasas[%d]: Total OS Pending cmds : %d\n",instance->host->host_no,atomic_read(&instance->fw_outstanding));
+	printk(KERN_ERR "\n");
 	if (IS_DMA64)
-		printk(KERN_ERR "\nmegasas[%d]: 64 bit SGLs were sent to FW\n",instance->host->host_no);
+		printk(KERN_ERR "megasas[%d]: 64 bit SGLs were sent to FW\n",instance->host->host_no);
 	else
-		printk(KERN_ERR "\nmegasas[%d]: 32 bit SGLs were sent to FW\n",instance->host->host_no);
+		printk(KERN_ERR "megasas[%d]: 32 bit SGLs were sent to FW\n",instance->host->host_no);
 
 	printk(KERN_ERR "megasas[%d]: Pending OS cmds in FW : \n",instance->host->host_no);
 	for (i = 0; i < max_cmd; i++) {
@@ -770,25 +772,30 @@ megasas_dump_pending_frames(struct megasas_instance *instance)
 			printk(KERN_ERR "megasas[%d]: frame count : 0x%x, Cmd : 0x%x, Tgt id : 0x%x, lun : 0x%x, cdb_len : 0x%x, data xfer len : 0x%x, sense_buf addr : 0x%x,sge count : 0x%x\n",instance->host->host_no,cmd->frame_count,pthru->cmd,pthru->target_id,pthru->lun,pthru->cdb_len , pthru->data_xfer_len,pthru->sense_buf_phys_addr_lo,sgcount);
 		}
 	if(megasas_dbg_lvl & MEGASAS_DBG_LVL){
+		printk(KERN_ERR "megasas:");
 		for (n = 0; n < sgcount; n++){
 			if (IS_DMA64)
-				printk(KERN_ERR "megasas: sgl len : 0x%x, sgl addr : 0x%08lx ",mfi_sgl->sge64[n].length , (unsigned long)mfi_sgl->sge64[n].phys_addr) ;
+				printk(" sgl len : 0x%x, sgl addr : 0x%08lx",mfi_sgl->sge64[n].length , (unsigned long)mfi_sgl->sge64[n].phys_addr) ;
 			else
-				printk(KERN_ERR "megasas: sgl len : 0x%x, sgl addr : 0x%x ",mfi_sgl->sge32[n].length , mfi_sgl->sge32[n].phys_addr) ;
+				printk(" sgl len : 0x%x, sgl addr : 0x%x",mfi_sgl->sge32[n].length , mfi_sgl->sge32[n].phys_addr) ;
 			}
 		}
-		printk(KERN_ERR "\n");
+		printk("\n");
 	} /*for max_cmd*/
-	printk(KERN_ERR "\nmegasas[%d]: Pending Internal cmds in FW : \n",instance->host->host_no);
+	printk(KERN_ERR "\n"
+	       KERN_ERR "megasas[%d]: Pending Internal cmds in FW : \n",instance->host->host_no);
+	printk(KERN_ERR);
 	for (i = 0; i < max_cmd; i++) {
 
 		cmd = instance->cmd_list[i];
 
 		if(cmd->sync_cmd == 1){
-			printk(KERN_ERR "0x%08lx : ", (unsigned long)cmd->frame_phys_addr);
+			printk("0x%08lx : ", (unsigned long)cmd->frame_phys_addr);
 		}
 	}
-	printk(KERN_ERR "megasas[%d]: Dumping Done.\n\n",instance->host->host_no);
+	printk("\n");
+	printk(KERN_ERR "megasas[%d]: Dumping Done.\n"
+	       KERN_ERR "\n",instance->host->host_no);
 }
 
 /**
diff --git a/drivers/scsi/osst.c b/drivers/scsi/osst.c
index 08060fb..43bc5d8 100644
--- a/drivers/scsi/osst.c
+++ b/drivers/scsi/osst.c
@@ -5936,7 +5936,8 @@ static int __init init_osst(void)
 {
 	int err;
 
-	printk(KERN_INFO "osst :I: Tape driver with OnStream support version %s\nosst :I: %s\n", osst_version, cvsid);
+	printk(KERN_INFO "osst :I: Tape driver with OnStream support version %s\n"
+	       KERN_INFO "osst :I: %s\n", osst_version, cvsid);
 
 	validate_options();
 
diff --git a/drivers/scsi/zalon.c b/drivers/scsi/zalon.c
index 4b5f908..24f0b9e 100644
--- a/drivers/scsi/zalon.c
+++ b/drivers/scsi/zalon.c
@@ -137,7 +137,7 @@ zalon_probe(struct parisc_device *dev)
 		goto fail;
 
 	if (request_irq(dev->irq, ncr53c8xx_intr, IRQF_SHARED, "zalon", host)) {
-		printk(KERN_ERR "%s: irq problem with %d, detaching\n ",
+		printk(KERN_ERR "%s: irq problem with %d, detaching\n",
 			dev->dev.bus_id, dev->irq);
 		goto fail;
 	}
diff --git a/drivers/video/savage/savagefb_driver.c b/drivers/video/savage/savagefb_driver.c
index b855f4a..b60c32b 100644
--- a/drivers/video/savage/savagefb_driver.c
+++ b/drivers/video/savage/savagefb_driver.c
@@ -515,27 +515,30 @@ static void SavagePrintRegs(struct savagefb_par *par)
 	int vgaCRIndex = 0x3d4;
 	int vgaCRReg = 0x3d5;
 
-	printk(KERN_DEBUG "SR    x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 xA xB xC xD xE "
-	       "xF");
+	printk(KERN_DEBUG
+	       "SR    x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 xA xB xC xD xE xF");
 
 	for (i = 0; i < 0x70; i++) {
 		if (!(i % 16))
-			printk(KERN_DEBUG "\nSR%xx ", i >> 4);
+			printk("\n" KERN_DEBUG "SR%xx ", i >> 4);
 		vga_out8(0x3c4, i, par);
-		printk(KERN_DEBUG " %02x", vga_in8(0x3c5, par));
+		printk(" %02x", vga_in8(0x3c5, par));
 	}
 
-	printk(KERN_DEBUG "\n\nCR    x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 xA xB xC "
-	       "xD xE xF");
+	printk("\n"
+	       KERN_DEBUG "\n"
+	       KERN_DEBUG
+	       "CR    x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 xA xB xC xD xE xF");
 
 	for (i = 0; i < 0xB7; i++) {
 		if (!(i % 16))
-			printk(KERN_DEBUG "\nCR%xx ", i >> 4);
+			printk("\n" KERN_DEBUG "CR%xx ", i >> 4);
 		vga_out8(vgaCRIndex, i, par);
-		printk(KERN_DEBUG " %02x", vga_in8(vgaCRReg, par));
+		printk(" %02x", vga_in8(vgaCRReg, par));
 	}
 
-	printk(KERN_DEBUG "\n\n");
+	printk("\n"
+	       KERN_DEBUG "\n");
 }
 #endif
 
diff --git a/fs/dlm/dlm_internal.h b/fs/dlm/dlm_internal.h
index 74901e9..59f3cb4 100644
--- a/fs/dlm/dlm_internal.h
+++ b/fs/dlm/dlm_internal.h
@@ -81,10 +81,11 @@ do { \
 { \
   if (!(x)) \
   { \
-    printk(KERN_ERR "\nDLM:  Assertion failed on line %d of file %s\n" \
-               "DLM:  assertion:  \"%s\"\n" \
-               "DLM:  time = %lu\n", \
-               __LINE__, __FILE__, #x, jiffies); \
+    printk(KERN_ERR "\n" \
+	   KERN_ERR "DLM:  Assertion failed on line %d of file %s\n" \
+	   KERN_ERR "DLM:  assertion:  \"%s\"\n" \
+	   KERN_ERR "DLM:  time = %lu\n", \
+	   __LINE__, __FILE__, #x, jiffies); \
     {do} \
     printk("\n"); \
     BUG(); \
diff --git a/fs/freevxfs/vxfs_bmap.c b/fs/freevxfs/vxfs_bmap.c
index f86fd3c..c65b39a 100644
--- a/fs/freevxfs/vxfs_bmap.c
+++ b/fs/freevxfs/vxfs_bmap.c
@@ -166,7 +166,9 @@ vxfs_bmap_indir(struct inode *ip, long indir, int size, long block)
 			struct vxfs_typed_dev4	*typ4 =
 				(struct vxfs_typed_dev4 *)typ;
 
-			printk(KERN_INFO "\n\nTYPED_DEV4 detected!\n");
+			printk(KERN_INFO "\n"
+			       KERN_INFO "\n"
+			       KERN_INFO "TYPED_DEV4 detected!\n");
 			printk(KERN_INFO "block: %Lu\tsize: %Ld\tdev: %d\n",
 			       (unsigned long long) typ4->vd4_block,
 			       (unsigned long long) typ4->vd4_size,
@@ -229,7 +231,9 @@ vxfs_bmap_typed(struct inode *ip, long iblock)
 			struct vxfs_typed_dev4	*typ4 =
 				(struct vxfs_typed_dev4 *)typ;
 
-			printk(KERN_INFO "\n\nTYPED_DEV4 detected!\n");
+			printk(KERN_INFO "\n"
+			       KERN_INFO "\n"
+			       KERN_INFO "TYPED_DEV4 detected!\n");
 			printk(KERN_INFO "block: %Lu\tsize: %Ld\tdev: %d\n",
 			       (unsigned long long) typ4->vd4_block,
 			       (unsigned long long) typ4->vd4_size,
diff --git a/fs/jffs2/wbuf.c b/fs/jffs2/wbuf.c
index 91d1d0f..3c51cda 100644
--- a/fs/jffs2/wbuf.c
+++ b/fs/jffs2/wbuf.c
@@ -1094,7 +1094,8 @@ int jffs2_write_nand_badblock(struct jffs2_sb_info *c, struct jffs2_eraseblock *
 	if (!c->mtd->block_markbad)
 		return 1; // What else can we do?
 
-	printk(KERN_WARNING "JFFS2: marking eraseblock at %08x\n as bad", bad_offset);
+	printk(KERN_WARNING "JFFS2: marking eraseblock at %08x\n"
+	       KERN_WARNING " as bad", bad_offset);
 	ret = c->mtd->block_markbad(c->mtd, bad_offset);
 
 	if (ret) {
diff --git a/mm/slub.c b/mm/slub.c
index 04151da..2bbf0d9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2914,7 +2914,8 @@ static void resiliency_test(void)
 
 	p = kzalloc(16, GFP_KERNEL);
 	p[16] = 0x12;
-	printk(KERN_ERR "\n1. kmalloc-16: Clobber Redzone/next pointer"
+	printk(KERN_ERR "\n"
+	       KERN_ERR "1. kmalloc-16: Clobber Redzone/next pointer"
 			" 0x12->0x%p\n\n", p + 16);
 
 	validate_slab_cache(kmalloc_caches + 4);
@@ -2922,7 +2923,8 @@ static void resiliency_test(void)
 	/* Hmmm... The next two are dangerous */
 	p = kzalloc(32, GFP_KERNEL);
 	p[32 + sizeof(void *)] = 0x34;
-	printk(KERN_ERR "\n2. kmalloc-32: Clobber next pointer/next slab"
+	printk(KERN_ERR "\n"
+	       KERN_ERR "2. kmalloc-32: Clobber next pointer/next slab"
 		 	" 0x34 -> -0x%p\n", p);
 	printk(KERN_ERR "If allocated object is overwritten then not detectable\n\n");
 
@@ -2930,12 +2932,14 @@ static void resiliency_test(void)
 	p = kzalloc(64, GFP_KERNEL);
 	p += 64 + (get_cycles() & 0xff) * sizeof(void *);
 	*p = 0x56;
-	printk(KERN_ERR "\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
+	printk(KERN_ERR "\n"
+	       KERN_ERR "3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
 									p);
 	printk(KERN_ERR "If allocated object is overwritten then not detectable\n\n");
 	validate_slab_cache(kmalloc_caches + 6);
 
-	printk(KERN_ERR "\nB. Corruption after free\n");
+	printk(KERN_ERR "\n"
+	       KERN_ERR "B. Corruption after free\n");
 	p = kzalloc(128, GFP_KERNEL);
 	kfree(p);
 	*p = 0x78;
@@ -2945,13 +2949,15 @@ static void resiliency_test(void)
 	p = kzalloc(256, GFP_KERNEL);
 	kfree(p);
 	p[50] = 0x9a;
-	printk(KERN_ERR "\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n", p);
+	printk(KERN_ERR "\n"
+	       KERN_ERR "2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n", p);
 	validate_slab_cache(kmalloc_caches + 8);
 
 	p = kzalloc(512, GFP_KERNEL);
 	kfree(p);
 	p[512] = 0xab;
-	printk(KERN_ERR "\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
+	printk(KERN_ERR "\n"
+	       KERN_ERR "3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
 	validate_slab_cache(kmalloc_caches + 9);
 }
 #else


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
