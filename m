Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 707B26B0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 13:10:04 -0500 (EST)
Date: Wed, 13 Feb 2013 10:09:04 -0800
Message-Id: <201302131809.r1DI94tc015462@tazenda.hos.anvin.org>
From: "H. Peter Anvin" <hpa@zytor.com>
Subject: [GIT PULL] Final x86 fixes for 3.8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@suse.de>, Brad Spengler <spender@grsecurity.net>, Dan Rosenberg <dan.j.rosenberg@gmail.com>, David Woodhouse <dwmw2@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Frederic Weisbecker <fweisbec@gmail.com>, "H. Peter Anvin" <hpa@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.coM>, Stoney Wang <song-bo.wang@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, stable@kernel.org, stable@vger.kernel.org

Hi Linus,

One (hopefully) last batch of x86 fixes.  You asked for the patch by
patch justifications, so here they are:

      x86, MCE: Retract most UAPI exports

   This one unexports from userspace a bunch of definitions which
   should never have been exported.  We really want to create an
   accidental legacy here.

      x86, doc: Add a bootloader ID for OVMF

   This is a documentation-only patch, just recording the official
   assignment of a boot loader ID.

      x86: Do not leak kernel page mapping locations

   Security: avoid making it needlessly easy for user space to probe
   the kernel memory layout.

      x86/mm: Check if PUD is large when validating a kernel address

   Prevent failures using /proc/kcore when using 1G pages.

      x86/apic: Work around boot failure on HP ProLiant DL980 G7 Server systems

   Works around a BIOS problem causing boot failures on affected hardware.


----------------------------------------------------------------

The following changes since commit fe547d7714783ff77719f05a6712554cb4eeecc0:

  Merge branch 'fix-max-write' of git://git.kernel.org/pub/scm/linux/kernel/git/teigland/linux-dlm (2013-02-05 20:50:11 +1100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git x86-urgent-for-linus

The head of this tree is 0ee364eb316348ddf3e0dfcd986f5f13f528f821.

  x86/mm: Check if PUD is large when validating a kernel address (2013-02-13 10:02:55 +0100)

----------------------------------------------------------------

Borislav Petkov (1):
      x86, MCE: Retract most UAPI exports

H. Peter Anvin (2):
      Merge tag 'ras_for_3.8' into x86/urgent
      x86, doc: Add a bootloader ID for OVMF

Kees Cook (1):
      x86: Do not leak kernel page mapping locations

Mel Gorman (1):
      x86/mm: Check if PUD is large when validating a kernel address

Stoney Wang (1):
      x86/apic: Work around boot failure on HP ProLiant DL980 G7 Server systems

 Documentation/x86/boot.txt         |  1 +
 arch/x86/include/asm/mce.h         | 84 ++++++++++++++++++++++++++++++++++++
 arch/x86/include/asm/pgtable.h     |  5 +++
 arch/x86/include/uapi/asm/mce.h    | 87 --------------------------------------
 arch/x86/kernel/apic/x2apic_phys.c | 21 ++++-----
 arch/x86/mm/fault.c                |  8 ++--
 arch/x86/mm/init_64.c              |  3 ++
 7 files changed, 109 insertions(+), 100 deletions(-)

diff --git a/Documentation/x86/boot.txt b/Documentation/x86/boot.txt
index e540fd6..b443f1d 100644
--- a/Documentation/x86/boot.txt
+++ b/Documentation/x86/boot.txt
@@ -390,6 +390,7 @@ Protocol:	2.00+
 	F  Special		(0xFF = undefined)
        10  Reserved
        11  Minimal Linux Bootloader <http://sebastian-plotz.blogspot.de>
+       12  OVMF UEFI virtualization stack
 
   Please contact <hpa@zytor.com> if you need a bootloader ID
   value assigned.
diff --git a/arch/x86/include/asm/mce.h b/arch/x86/include/asm/mce.h
index ecdfee6..f4076af 100644
--- a/arch/x86/include/asm/mce.h
+++ b/arch/x86/include/asm/mce.h
@@ -3,6 +3,90 @@
 
 #include <uapi/asm/mce.h>
 
+/*
+ * Machine Check support for x86
+ */
+
+/* MCG_CAP register defines */
+#define MCG_BANKCNT_MASK	0xff         /* Number of Banks */
+#define MCG_CTL_P		(1ULL<<8)    /* MCG_CTL register available */
+#define MCG_EXT_P		(1ULL<<9)    /* Extended registers available */
+#define MCG_CMCI_P		(1ULL<<10)   /* CMCI supported */
+#define MCG_EXT_CNT_MASK	0xff0000     /* Number of Extended registers */
+#define MCG_EXT_CNT_SHIFT	16
+#define MCG_EXT_CNT(c)		(((c) & MCG_EXT_CNT_MASK) >> MCG_EXT_CNT_SHIFT)
+#define MCG_SER_P		(1ULL<<24)   /* MCA recovery/new status bits */
+
+/* MCG_STATUS register defines */
+#define MCG_STATUS_RIPV  (1ULL<<0)   /* restart ip valid */
+#define MCG_STATUS_EIPV  (1ULL<<1)   /* ip points to correct instruction */
+#define MCG_STATUS_MCIP  (1ULL<<2)   /* machine check in progress */
+
+/* MCi_STATUS register defines */
+#define MCI_STATUS_VAL   (1ULL<<63)  /* valid error */
+#define MCI_STATUS_OVER  (1ULL<<62)  /* previous errors lost */
+#define MCI_STATUS_UC    (1ULL<<61)  /* uncorrected error */
+#define MCI_STATUS_EN    (1ULL<<60)  /* error enabled */
+#define MCI_STATUS_MISCV (1ULL<<59)  /* misc error reg. valid */
+#define MCI_STATUS_ADDRV (1ULL<<58)  /* addr reg. valid */
+#define MCI_STATUS_PCC   (1ULL<<57)  /* processor context corrupt */
+#define MCI_STATUS_S	 (1ULL<<56)  /* Signaled machine check */
+#define MCI_STATUS_AR	 (1ULL<<55)  /* Action required */
+#define MCACOD		  0xffff     /* MCA Error Code */
+
+/* Architecturally defined codes from SDM Vol. 3B Chapter 15 */
+#define MCACOD_SCRUB	0x00C0	/* 0xC0-0xCF Memory Scrubbing */
+#define MCACOD_SCRUBMSK	0xfff0
+#define MCACOD_L3WB	0x017A	/* L3 Explicit Writeback */
+#define MCACOD_DATA	0x0134	/* Data Load */
+#define MCACOD_INSTR	0x0150	/* Instruction Fetch */
+
+/* MCi_MISC register defines */
+#define MCI_MISC_ADDR_LSB(m)	((m) & 0x3f)
+#define MCI_MISC_ADDR_MODE(m)	(((m) >> 6) & 7)
+#define  MCI_MISC_ADDR_SEGOFF	0	/* segment offset */
+#define  MCI_MISC_ADDR_LINEAR	1	/* linear address */
+#define  MCI_MISC_ADDR_PHYS	2	/* physical address */
+#define  MCI_MISC_ADDR_MEM	3	/* memory address */
+#define  MCI_MISC_ADDR_GENERIC	7	/* generic */
+
+/* CTL2 register defines */
+#define MCI_CTL2_CMCI_EN		(1ULL << 30)
+#define MCI_CTL2_CMCI_THRESHOLD_MASK	0x7fffULL
+
+#define MCJ_CTX_MASK		3
+#define MCJ_CTX(flags)		((flags) & MCJ_CTX_MASK)
+#define MCJ_CTX_RANDOM		0    /* inject context: random */
+#define MCJ_CTX_PROCESS		0x1  /* inject context: process */
+#define MCJ_CTX_IRQ		0x2  /* inject context: IRQ */
+#define MCJ_NMI_BROADCAST	0x4  /* do NMI broadcasting */
+#define MCJ_EXCEPTION		0x8  /* raise as exception */
+#define MCJ_IRQ_BRAODCAST	0x10 /* do IRQ broadcasting */
+
+#define MCE_OVERFLOW 0		/* bit 0 in flags means overflow */
+
+/* Software defined banks */
+#define MCE_EXTENDED_BANK	128
+#define MCE_THERMAL_BANK	(MCE_EXTENDED_BANK + 0)
+#define K8_MCE_THRESHOLD_BASE   (MCE_EXTENDED_BANK + 1)
+
+#define MCE_LOG_LEN 32
+#define MCE_LOG_SIGNATURE	"MACHINECHECK"
+
+/*
+ * This structure contains all data related to the MCE log.  Also
+ * carries a signature to make it easier to find from external
+ * debugging tools.  Each entry is only valid when its finished flag
+ * is set.
+ */
+struct mce_log {
+	char signature[12]; /* "MACHINECHECK" */
+	unsigned len;	    /* = MCE_LOG_LEN */
+	unsigned next;
+	unsigned flags;
+	unsigned recordlen;	/* length of struct mce */
+	struct mce entry[MCE_LOG_LEN];
+};
 
 struct mca_config {
 	bool dont_log_ce;
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5199db2..1c1a955 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -142,6 +142,11 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
 	return (pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT;
 }
 
+static inline unsigned long pud_pfn(pud_t pud)
+{
+	return (pud_val(pud) & PTE_PFN_MASK) >> PAGE_SHIFT;
+}
+
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
 
 static inline int pmd_large(pmd_t pte)
diff --git a/arch/x86/include/uapi/asm/mce.h b/arch/x86/include/uapi/asm/mce.h
index 58c8298..a0eab85 100644
--- a/arch/x86/include/uapi/asm/mce.h
+++ b/arch/x86/include/uapi/asm/mce.h
@@ -4,66 +4,6 @@
 #include <linux/types.h>
 #include <asm/ioctls.h>
 
-/*
- * Machine Check support for x86
- */
-
-/* MCG_CAP register defines */
-#define MCG_BANKCNT_MASK	0xff         /* Number of Banks */
-#define MCG_CTL_P		(1ULL<<8)    /* MCG_CTL register available */
-#define MCG_EXT_P		(1ULL<<9)    /* Extended registers available */
-#define MCG_CMCI_P		(1ULL<<10)   /* CMCI supported */
-#define MCG_EXT_CNT_MASK	0xff0000     /* Number of Extended registers */
-#define MCG_EXT_CNT_SHIFT	16
-#define MCG_EXT_CNT(c)		(((c) & MCG_EXT_CNT_MASK) >> MCG_EXT_CNT_SHIFT)
-#define MCG_SER_P	 	(1ULL<<24)   /* MCA recovery/new status bits */
-
-/* MCG_STATUS register defines */
-#define MCG_STATUS_RIPV  (1ULL<<0)   /* restart ip valid */
-#define MCG_STATUS_EIPV  (1ULL<<1)   /* ip points to correct instruction */
-#define MCG_STATUS_MCIP  (1ULL<<2)   /* machine check in progress */
-
-/* MCi_STATUS register defines */
-#define MCI_STATUS_VAL   (1ULL<<63)  /* valid error */
-#define MCI_STATUS_OVER  (1ULL<<62)  /* previous errors lost */
-#define MCI_STATUS_UC    (1ULL<<61)  /* uncorrected error */
-#define MCI_STATUS_EN    (1ULL<<60)  /* error enabled */
-#define MCI_STATUS_MISCV (1ULL<<59)  /* misc error reg. valid */
-#define MCI_STATUS_ADDRV (1ULL<<58)  /* addr reg. valid */
-#define MCI_STATUS_PCC   (1ULL<<57)  /* processor context corrupt */
-#define MCI_STATUS_S	 (1ULL<<56)  /* Signaled machine check */
-#define MCI_STATUS_AR	 (1ULL<<55)  /* Action required */
-#define MCACOD		  0xffff     /* MCA Error Code */
-
-/* Architecturally defined codes from SDM Vol. 3B Chapter 15 */
-#define MCACOD_SCRUB	0x00C0	/* 0xC0-0xCF Memory Scrubbing */
-#define MCACOD_SCRUBMSK	0xfff0
-#define MCACOD_L3WB	0x017A	/* L3 Explicit Writeback */
-#define MCACOD_DATA	0x0134	/* Data Load */
-#define MCACOD_INSTR	0x0150	/* Instruction Fetch */
-
-/* MCi_MISC register defines */
-#define MCI_MISC_ADDR_LSB(m)	((m) & 0x3f)
-#define MCI_MISC_ADDR_MODE(m)	(((m) >> 6) & 7)
-#define  MCI_MISC_ADDR_SEGOFF	0	/* segment offset */
-#define  MCI_MISC_ADDR_LINEAR	1	/* linear address */
-#define  MCI_MISC_ADDR_PHYS	2	/* physical address */
-#define  MCI_MISC_ADDR_MEM	3	/* memory address */
-#define  MCI_MISC_ADDR_GENERIC	7	/* generic */
-
-/* CTL2 register defines */
-#define MCI_CTL2_CMCI_EN		(1ULL << 30)
-#define MCI_CTL2_CMCI_THRESHOLD_MASK	0x7fffULL
-
-#define MCJ_CTX_MASK		3
-#define MCJ_CTX(flags)		((flags) & MCJ_CTX_MASK)
-#define MCJ_CTX_RANDOM		0    /* inject context: random */
-#define MCJ_CTX_PROCESS		0x1  /* inject context: process */
-#define MCJ_CTX_IRQ		0x2  /* inject context: IRQ */
-#define MCJ_NMI_BROADCAST	0x4  /* do NMI broadcasting */
-#define MCJ_EXCEPTION		0x8  /* raise as exception */
-#define MCJ_IRQ_BRAODCAST	0x10 /* do IRQ broadcasting */
-
 /* Fields are zero when not available */
 struct mce {
 	__u64 status;
@@ -87,35 +27,8 @@ struct mce {
 	__u64 mcgcap;	/* MCGCAP MSR: machine check capabilities of CPU */
 };
 
-/*
- * This structure contains all data related to the MCE log.  Also
- * carries a signature to make it easier to find from external
- * debugging tools.  Each entry is only valid when its finished flag
- * is set.
- */
-
-#define MCE_LOG_LEN 32
-
-struct mce_log {
-	char signature[12]; /* "MACHINECHECK" */
-	unsigned len;	    /* = MCE_LOG_LEN */
-	unsigned next;
-	unsigned flags;
-	unsigned recordlen;	/* length of struct mce */
-	struct mce entry[MCE_LOG_LEN];
-};
-
-#define MCE_OVERFLOW 0		/* bit 0 in flags means overflow */
-
-#define MCE_LOG_SIGNATURE	"MACHINECHECK"
-
 #define MCE_GET_RECORD_LEN   _IOR('M', 1, int)
 #define MCE_GET_LOG_LEN      _IOR('M', 2, int)
 #define MCE_GETCLEAR_FLAGS   _IOR('M', 3, int)
 
-/* Software defined banks */
-#define MCE_EXTENDED_BANK	128
-#define MCE_THERMAL_BANK	MCE_EXTENDED_BANK + 0
-#define K8_MCE_THRESHOLD_BASE      (MCE_EXTENDED_BANK + 1)
-
 #endif /* _UAPI_ASM_X86_MCE_H */
diff --git a/arch/x86/kernel/apic/x2apic_phys.c b/arch/x86/kernel/apic/x2apic_phys.c
index e03a1e1..562a76d 100644
--- a/arch/x86/kernel/apic/x2apic_phys.c
+++ b/arch/x86/kernel/apic/x2apic_phys.c
@@ -20,18 +20,19 @@ static int set_x2apic_phys_mode(char *arg)
 }
 early_param("x2apic_phys", set_x2apic_phys_mode);
 
-static int x2apic_acpi_madt_oem_check(char *oem_id, char *oem_table_id)
+static bool x2apic_fadt_phys(void)
 {
-	if (x2apic_phys)
-		return x2apic_enabled();
-	else if ((acpi_gbl_FADT.header.revision >= FADT2_REVISION_ID) &&
-		(acpi_gbl_FADT.flags & ACPI_FADT_APIC_PHYSICAL) &&
-		x2apic_enabled()) {
+	if ((acpi_gbl_FADT.header.revision >= FADT2_REVISION_ID) &&
+		(acpi_gbl_FADT.flags & ACPI_FADT_APIC_PHYSICAL)) {
 		printk(KERN_DEBUG "System requires x2apic physical mode\n");
-		return 1;
+		return true;
 	}
-	else
-		return 0;
+	return false;
+}
+
+static int x2apic_acpi_madt_oem_check(char *oem_id, char *oem_table_id)
+{
+	return x2apic_enabled() && (x2apic_phys || x2apic_fadt_phys());
 }
 
 static void
@@ -82,7 +83,7 @@ static void init_x2apic_ldr(void)
 
 static int x2apic_phys_probe(void)
 {
-	if (x2apic_mode && x2apic_phys)
+	if (x2apic_mode && (x2apic_phys || x2apic_fadt_phys()))
 		return 1;
 
 	return apic == &apic_x2apic_phys;
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 027088f..fb674fd 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -748,13 +748,15 @@ __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 				return;
 		}
 #endif
+		/* Kernel addresses are always protection faults: */
+		if (address >= TASK_SIZE)
+			error_code |= PF_PROT;
 
-		if (unlikely(show_unhandled_signals))
+		if (likely(show_unhandled_signals))
 			show_signal_msg(regs, error_code, address, tsk);
 
-		/* Kernel addresses are always protection faults: */
 		tsk->thread.cr2		= address;
-		tsk->thread.error_code	= error_code | (address >= TASK_SIZE);
+		tsk->thread.error_code	= error_code;
 		tsk->thread.trap_nr	= X86_TRAP_PF;
 
 		force_sig_info_fault(SIGSEGV, si_code, address, tsk, 0);
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 2ead3c8..75c9a6a 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -831,6 +831,9 @@ int kern_addr_valid(unsigned long addr)
 	if (pud_none(*pud))
 		return 0;
 
+	if (pud_large(*pud))
+		return pfn_valid(pud_pfn(*pud));
+
 	pmd = pmd_offset(pud, addr);
 	if (pmd_none(*pmd))
 		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
