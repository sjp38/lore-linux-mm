Received: from bix (build.pdx.osdl.net [172.20.1.2])
	by mail.osdl.org (8.11.6/8.11.6) with SMTP id i4N9sSr05610
	for <linux-mm@kvack.org>; Sun, 23 May 2004 02:54:28 -0700
Date: Sun, 23 May 2004 02:53:58 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Fw: Re: current -linus tree dies on x86_64
Message-Id: <20040523025358.72c9f8a9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hm, linux-mm seems to have dropped this.

Begin forwarded message:

Date: Sun, 23 May 2004 01:21:49 -0700
From: Andrew Morton <akpm@osdl.org>
To: ak@muc.de, linux-mm@kvack.org
Subject: Re: current -linus tree dies on x86_64


Andrew Morton <akpm@osdl.org> wrote:
>
> Andrew Morton <akpm@osdl.org> wrote:
>  >
>  > As soon as I put in enough memory pressure to start swapping it oopses in
>  >  release_pages().
> 
>  I'm doing the bsearch on this.

The crash is caused by the below changeset.  I was using my own .config so
the defconfig update is not the cause.  I guess either the pageattr.c
changes or the instruction replacements.  The lesson here is to split dem
patches up a bit!

Anyway.  Over to you, Andi.




# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/05/15 10:40:53-07:00 ak@muc.de 
#   [PATCH] x86-64 updates
#   
#   Various accumulated x86-64 patches and bug fixes.
#   
#   It fixes one nasty bug that has been there since NX is used by 
#   default in the kernel. With heavy AGP memory allocation it would
#   set NX on parts of the kernel mapping in some corner cases, which gave
#   endless crash loops. Thanks goes to some wizards in AMD debug labs
#   for getting a trace out of this.
#   
#   Also various other fixes. This patches only changes x86-64 specific
#   files, i have some changes outside too that I am sending separately.
#   
#    - Fix help test for CONFIG_NUMA
#    - Don't enable SMT nice on CMP
#    - Move HT and MWAIT checks up to generic code
#    - Update defconfig
#    - Remove duplicated includes (Arthur Othieno)
#    - Set up GSI entry for ACPI SCI correctly (from i386)
#    - Fix some comments
#    - Fix threadinfo printing in oopses
#    - Set task alignment to 16 bytes
#    - Handle NX bit for code pages correctly in change_page_attr()
#    - Use generic nops for non amd specific kernel
#    - Add __KERNEL__ checks in unistd.h (David Lee)
# 
# include/asm-x86_64/unistd.h
#   2004/05/15 06:32:28-07:00 ak@muc.de +1 -1
#   x86-64 updates
# 
# include/asm-x86_64/processor.h
#   2004/05/15 06:32:28-07:00 ak@muc.de +24 -4
#   x86-64 updates
# 
# arch/x86_64/mm/pageattr.c
#   2004/05/15 06:41:06-07:00 ak@muc.de +22 -15
#   x86-64 updates
# 
# arch/x86_64/kernel/traps.c
#   2004/05/15 06:32:27-07:00 ak@muc.de +2 -2
#   x86-64 updates
# 
# arch/x86_64/kernel/setup.c
#   2004/05/15 06:32:27-07:00 ak@muc.de +7 -5
#   x86-64 updates
# 
# arch/x86_64/kernel/reboot.c
#   2004/05/15 06:32:27-07:00 ak@muc.de +2 -2
#   x86-64 updates
# 
# arch/x86_64/kernel/pci-gart.c
#   2004/05/15 06:32:27-07:00 ak@muc.de +0 -1
#   x86-64 updates
# 
# arch/x86_64/kernel/mpparse.c
#   2004/05/15 06:32:27-07:00 ak@muc.de +4 -1
#   x86-64 updates
# 
# arch/x86_64/kernel/domain.c
#   2004/05/15 06:40:13-07:00 ak@muc.de +4 -0
#   x86-64 updates
# 
# arch/x86_64/ia32/ptrace32.c
#   2004/05/15 06:32:26-07:00 ak@muc.de +1 -2
#   x86-64 updates
# 
# arch/x86_64/defconfig
#   2004/05/15 06:33:33-07:00 ak@muc.de +137 -40
#   x86-64 updates
# 
# arch/x86_64/Kconfig
#   2004/05/15 06:32:23-07:00 ak@muc.de +3 -4
#   x86-64 updates
# 
diff -Nru a/arch/x86_64/Kconfig b/arch/x86_64/Kconfig
--- a/arch/x86_64/Kconfig	2004-05-23 01:15:37 -07:00
+++ b/arch/x86_64/Kconfig	2004-05-23 01:15:37 -07:00
@@ -249,7 +249,6 @@
 	  cost of slightly increased overhead in some places. If unsure say
 	  N here.
 
-# someone write a better help text please.
 config K8_NUMA
        bool "K8 NUMA support"
        depends on SMP
@@ -257,9 +256,9 @@
 	  Enable NUMA (Non Unified Memory Architecture) support for
 	  AMD Opteron Multiprocessor systems. The kernel will try to allocate
 	  memory used by a CPU on the local memory controller of the CPU
-	  and in the future do more optimizations. This may improve performance 
-	  or it may not. Code is still experimental.
-	  Say N if unsure.
+	  and add some more NUMA awareness to the kernel.
+	  This code is recommended on all multiprocessor Opteron systems
+	  and normally doesn't hurt on others.
 
 config DISCONTIGMEM
        bool
diff -Nru a/arch/x86_64/defconfig b/arch/x86_64/defconfig
--- a/arch/x86_64/defconfig	2004-05-23 01:15:37 -07:00
+++ b/arch/x86_64/defconfig	2004-05-23 01:15:37 -07:00
@@ -72,6 +72,7 @@
 CONFIG_MTRR=y
 CONFIG_SMP=y
 # CONFIG_PREEMPT is not set
+CONFIG_SCHED_SMT=y
 CONFIG_K8_NUMA=y
 CONFIG_DISCONTIGMEM=y
 CONFIG_NUMA=y
@@ -282,6 +283,7 @@
 # CONFIG_SCSI_SATA_SVW is not set
 CONFIG_SCSI_ATA_PIIX=y
 # CONFIG_SCSI_SATA_PROMISE is not set
+# CONFIG_SCSI_SATA_SX4 is not set
 # CONFIG_SCSI_SATA_SIL is not set
 # CONFIG_SCSI_SATA_SIS is not set
 CONFIG_SCSI_SATA_VIA=y
@@ -296,6 +298,7 @@
 # CONFIG_SCSI_IPS is not set
 # CONFIG_SCSI_INIA100 is not set
 # CONFIG_SCSI_SYM53C8XX_2 is not set
+# CONFIG_SCSI_IPR is not set
 # CONFIG_SCSI_QLOGIC_ISP is not set
 # CONFIG_SCSI_QLOGIC_FC is not set
 # CONFIG_SCSI_QLOGIC_1280 is not set
@@ -331,6 +334,7 @@
 #
 # I2O device support
 #
+# CONFIG_I2O is not set
 
 #
 # Networking support
@@ -363,8 +367,6 @@
 # CONFIG_INET6_ESP is not set
 # CONFIG_INET6_IPCOMP is not set
 # CONFIG_IPV6_TUNNEL is not set
-# CONFIG_DECNET is not set
-# CONFIG_BRIDGE is not set
 # CONFIG_NETFILTER is not set
 
 #
@@ -372,7 +374,9 @@
 #
 # CONFIG_IP_SCTP is not set
 # CONFIG_ATM is not set
+# CONFIG_BRIDGE is not set
 # CONFIG_VLAN_8021Q is not set
+# CONFIG_DECNET is not set
 # CONFIG_LLC2 is not set
 # CONFIG_IPX is not set
 # CONFIG_ATALK is not set
@@ -393,16 +397,23 @@
 # Network testing
 #
 # CONFIG_NET_PKTGEN is not set
+CONFIG_NETPOLL=y
+# CONFIG_NETPOLL_RX is not set
+# CONFIG_NETPOLL_TRAP is not set
+CONFIG_NET_POLL_CONTROLLER=y
+# CONFIG_HAMRADIO is not set
+# CONFIG_IRDA is not set
+# CONFIG_BT is not set
 CONFIG_NETDEVICES=y
+# CONFIG_DUMMY is not set
+# CONFIG_BONDING is not set
+# CONFIG_EQUALIZER is not set
+# CONFIG_TUN is not set
 
 #
 # ARCnet devices
 #
 # CONFIG_ARCNET is not set
-# CONFIG_DUMMY is not set
-# CONFIG_BONDING is not set
-# CONFIG_EQUALIZER is not set
-# CONFIG_TUN is not set
 
 #
 # Ethernet (10 or 100Mbit)
@@ -421,6 +432,7 @@
 CONFIG_NET_PCI=y
 # CONFIG_PCNET32 is not set
 CONFIG_AMD8111_ETH=y
+# CONFIG_AMD8111E_NAPI is not set
 # CONFIG_ADAPTEC_STARFIRE is not set
 # CONFIG_B44 is not set
 CONFIG_FORCEDETH=y
@@ -436,7 +448,6 @@
 # CONFIG_8139TOO_TUNE_TWISTER is not set
 # CONFIG_8139TOO_8129 is not set
 # CONFIG_8139_OLD_RX_RESET is not set
-CONFIG_8139_RXBUF_IDX=2
 # CONFIG_SIS900 is not set
 # CONFIG_EPIC100 is not set
 # CONFIG_SUNDANCE is not set
@@ -453,7 +464,6 @@
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
 # CONFIG_R8169 is not set
-# CONFIG_SIS190 is not set
 # CONFIG_SK98LIN is not set
 CONFIG_TIGON3=y
 
@@ -461,47 +471,29 @@
 # Ethernet (10000 Mbit)
 #
 # CONFIG_IXGB is not set
-# CONFIG_FDDI is not set
-# CONFIG_HIPPI is not set
-# CONFIG_PPP is not set
-# CONFIG_SLIP is not set
-
-#
-# Wireless LAN (non-hamradio)
-#
-# CONFIG_NET_RADIO is not set
+# CONFIG_S2IO is not set
 
 #
 # Token Ring devices
 #
 # CONFIG_TR is not set
-# CONFIG_NET_FC is not set
-# CONFIG_SHAPER is not set
-CONFIG_NETCONSOLE=y
-
-#
-# Wan interfaces
-#
-# CONFIG_WAN is not set
-
-#
-# Amateur Radio support
-#
-# CONFIG_HAMRADIO is not set
 
 #
-# IrDA (infrared) support
+# Wireless LAN (non-hamradio)
 #
-# CONFIG_IRDA is not set
+# CONFIG_NET_RADIO is not set
 
 #
-# Bluetooth support
+# Wan interfaces
 #
-# CONFIG_BT is not set
-CONFIG_NETPOLL=y
-# CONFIG_NETPOLL_RX is not set
-# CONFIG_NETPOLL_TRAP is not set
-CONFIG_NET_POLL_CONTROLLER=y
+# CONFIG_WAN is not set
+# CONFIG_FDDI is not set
+# CONFIG_HIPPI is not set
+# CONFIG_PPP is not set
+# CONFIG_SLIP is not set
+# CONFIG_NET_FC is not set
+# CONFIG_SHAPER is not set
+CONFIG_NETCONSOLE=y
 
 #
 # ISDN subsystem
@@ -685,7 +677,108 @@
 #
 # USB support
 #
-# CONFIG_USB is not set
+CONFIG_USB=y
+# CONFIG_USB_DEBUG is not set
+
+#
+# Miscellaneous USB options
+#
+CONFIG_USB_DEVICEFS=y
+# CONFIG_USB_BANDWIDTH is not set
+# CONFIG_USB_DYNAMIC_MINORS is not set
+
+#
+# USB Host Controller Drivers
+#
+CONFIG_USB_EHCI_HCD=y
+# CONFIG_USB_EHCI_SPLIT_ISO is not set
+# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
+CONFIG_USB_OHCI_HCD=y
+# CONFIG_USB_UHCI_HCD is not set
+
+#
+# USB Device Class drivers
+#
+# CONFIG_USB_AUDIO is not set
+# CONFIG_USB_BLUETOOTH_TTY is not set
+# CONFIG_USB_MIDI is not set
+# CONFIG_USB_ACM is not set
+CONFIG_USB_PRINTER=y
+CONFIG_USB_STORAGE=y
+# CONFIG_USB_STORAGE_DEBUG is not set
+# CONFIG_USB_STORAGE_DATAFAB is not set
+# CONFIG_USB_STORAGE_FREECOM is not set
+# CONFIG_USB_STORAGE_ISD200 is not set
+# CONFIG_USB_STORAGE_DPCM is not set
+# CONFIG_USB_STORAGE_HP8200e is not set
+# CONFIG_USB_STORAGE_SDDR09 is not set
+# CONFIG_USB_STORAGE_SDDR55 is not set
+# CONFIG_USB_STORAGE_JUMPSHOT is not set
+
+#
+# USB Human Interface Devices (HID)
+#
+CONFIG_USB_HID=y
+CONFIG_USB_HIDINPUT=y
+# CONFIG_HID_FF is not set
+# CONFIG_USB_HIDDEV is not set
+# CONFIG_USB_AIPTEK is not set
+# CONFIG_USB_WACOM is not set
+# CONFIG_USB_KBTAB is not set
+# CONFIG_USB_POWERMATE is not set
+# CONFIG_USB_MTOUCH is not set
+# CONFIG_USB_EGALAX is not set
+# CONFIG_USB_XPAD is not set
+# CONFIG_USB_ATI_REMOTE is not set
+
+#
+# USB Imaging devices
+#
+# CONFIG_USB_MDC800 is not set
+# CONFIG_USB_MICROTEK is not set
+# CONFIG_USB_HPUSBSCSI is not set
+
+#
+# USB Multimedia devices
+#
+# CONFIG_USB_DABUSB is not set
+
+#
+# Video4Linux support is needed for USB Multimedia device support
+#
+
+#
+# USB Network adaptors
+#
+# CONFIG_USB_CATC is not set
+# CONFIG_USB_KAWETH is not set
+# CONFIG_USB_PEGASUS is not set
+# CONFIG_USB_RTL8150 is not set
+# CONFIG_USB_USBNET is not set
+
+#
+# USB port drivers
+#
+
+#
+# USB Serial Converter support
+#
+# CONFIG_USB_SERIAL is not set
+
+#
+# USB Miscellaneous drivers
+#
+# CONFIG_USB_EMI62 is not set
+# CONFIG_USB_EMI26 is not set
+# CONFIG_USB_TIGL is not set
+# CONFIG_USB_AUERSWALD is not set
+# CONFIG_USB_RIO500 is not set
+# CONFIG_USB_LEGOTOWER is not set
+# CONFIG_USB_LCD is not set
+# CONFIG_USB_LED is not set
+# CONFIG_USB_CYTHERM is not set
+# CONFIG_USB_PHIDGETSERVO is not set
+# CONFIG_USB_TEST is not set
 
 #
 # USB Gadget Support
@@ -696,6 +789,7 @@
 # Firmware Drivers
 #
 # CONFIG_EDD is not set
+# CONFIG_SMBIOS is not set
 
 #
 # File systems
@@ -714,6 +808,9 @@
 CONFIG_REISERFS_FS=y
 # CONFIG_REISERFS_CHECK is not set
 # CONFIG_REISERFS_PROC_INFO is not set
+CONFIG_REISERFS_FS_XATTR=y
+CONFIG_REISERFS_FS_POSIX_ACL=y
+# CONFIG_REISERFS_FS_SECURITY is not set
 # CONFIG_JFS_FS is not set
 CONFIG_FS_POSIX_ACL=y
 # CONFIG_XFS_FS is not set
@@ -787,7 +884,6 @@
 # CONFIG_CIFS is not set
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
-# CONFIG_INTERMEZZO_FS is not set
 # CONFIG_AFS_FS is not set
 
 #
@@ -833,3 +929,4 @@
 # Library routines
 #
 CONFIG_CRC32=y
+# CONFIG_LIBCRC32C is not set
diff -Nru a/arch/x86_64/ia32/ptrace32.c b/arch/x86_64/ia32/ptrace32.c
--- a/arch/x86_64/ia32/ptrace32.c	2004-05-23 01:15:37 -07:00
+++ b/arch/x86_64/ia32/ptrace32.c	2004-05-23 01:15:37 -07:00
@@ -17,6 +17,7 @@
 #include <linux/syscalls.h>
 #include <linux/unistd.h>
 #include <linux/mm.h>
+#include <linux/ptrace.h>
 #include <asm/ptrace.h>
 #include <asm/uaccess.h>
 #include <asm/user32.h>
@@ -25,8 +26,6 @@
 #include <asm/debugreg.h>
 #include <asm/i387.h>
 #include <asm/fpu32.h>
-#include <linux/ptrace.h>
-#include <linux/mm.h>
 
 /* determines which flags the user has access to. */
 /* 1 = access 0 = no access */
diff -Nru a/arch/x86_64/kernel/domain.c b/arch/x86_64/kernel/domain.c
--- a/arch/x86_64/kernel/domain.c	2004-05-23 01:15:37 -07:00
+++ b/arch/x86_64/kernel/domain.c	2004-05-23 01:15:37 -07:00
@@ -21,6 +21,10 @@
 		struct sched_domain *phys_domain = &per_cpu(phys_domains, i);
 
 		*cpu_domain = SD_SIBLING_INIT;
+		/* Disable SMT NICE for CMP */
+		/* RED-PEN use a generic flag */ 
+		if (cpu_data[i].x86_vendor == X86_VENDOR_AMD) 
+			cpu_domain->flags &= ~SD_SHARE_CPUPOWER; 
 		cpu_domain->span = cpu_sibling_map[i];
 		cpu_domain->parent = phys_domain;
 		cpu_domain->groups = &sched_group_cpus[i];
diff -Nru a/arch/x86_64/kernel/mpparse.c b/arch/x86_64/kernel/mpparse.c
--- a/arch/x86_64/kernel/mpparse.c	2004-05-23 01:15:37 -07:00
+++ b/arch/x86_64/kernel/mpparse.c	2004-05-23 01:15:37 -07:00
@@ -920,8 +920,11 @@
 		}
 
 		/* Don't set up the ACPI SCI because it's already set up */
-		if (acpi_fadt.sci_int == gsi)
+		if (acpi_fadt.sci_int == gsi) {
+			/* we still need to set up the entry's irq */
+			acpi_gsi_to_irq(gsi, &entry->irq);
 			continue;
+		}
 
 		ioapic = mp_find_ioapic(gsi);
 		if (ioapic < 0)
diff -Nru a/arch/x86_64/kernel/pci-gart.c b/arch/x86_64/kernel/pci-gart.c
--- a/arch/x86_64/kernel/pci-gart.c	2004-05-23 01:15:37 -07:00
+++ b/arch/x86_64/kernel/pci-gart.c	2004-05-23 01:15:37 -07:00
@@ -30,7 +30,6 @@
 #include <asm/proto.h>
 #include <asm/cacheflush.h>
 #include <asm/kdebug.h>
-#include <asm/proto.h>
 
 #ifdef CONFIG_PREEMPT
 #define preempt_atomic() in_atomic()
diff -Nru a/arch/x86_64/kernel/reboot.c b/arch/x86_64/kernel/reboot.c
--- a/arch/x86_64/kernel/reboot.c	2004-05-23 01:15:37 -07:00
+++ b/arch/x86_64/kernel/reboot.c	2004-05-23 01:15:37 -07:00
@@ -29,9 +29,9 @@
 static int reboot_mode = 0;
 
 /* reboot=b[ios] | t[riple] | k[bd] [, [w]arm | [c]old]
-   bios	  Use the CPU reboto vector for warm reset
+   bios	  Use the CPU reboot vector for warm reset
    warm   Don't set the cold reboot flag
-   cold   Set the cold reboto flag
+   cold   Set the cold reboot flag
    triple Force a triple fault (init)
    kbd    Use the keyboard controller. cold reset (default)
  */ 
diff -Nru a/arch/x86_64/kernel/setup.c b/arch/x86_64/kernel/setup.c
--- a/arch/x86_64/kernel/setup.c	2004-05-23 01:15:37 -07:00
+++ b/arch/x86_64/kernel/setup.c	2004-05-23 01:15:37 -07:00
@@ -663,7 +663,7 @@
 	return r;
 }
 
-static void __init detect_ht(void)
+static void __init detect_ht(struct cpuinfo_x86 *c)
 {
 #ifdef CONFIG_SMP
 	u32 	eax, ebx, ecx, edx;
@@ -671,6 +671,9 @@
 	int	initial_apic_id;
 	int 	cpu = smp_processor_id();
 	
+	if (!cpu_has(c, X86_FEATURE_HT))
+		return;
+
 	cpuid(1, &eax, &ebx, &ecx, &edx);
 	smp_num_siblings = (ebx & 0xff0000) >> 16;
 	
@@ -768,7 +771,6 @@
 	unsigned int trace = 0, l1i = 0, l1d = 0, l2 = 0, l3 = 0; 
 	unsigned n;
 
-	select_idle_routine(c);
 	if (c->cpuid_level > 1) {
 		/* supports eax=2  call */
 		int i, j, n;
@@ -837,9 +839,6 @@
 		c->x86_cache_size = l2 ? l2 : (l1i+l1d);
 	}
 
-	if (cpu_has(c, X86_FEATURE_HT))
-		detect_ht(); 
-
 	n = cpuid_eax(0x80000000);
 	if (n >= 0x80000008) {
 		unsigned eax = cpuid_eax(0x80000008);
@@ -969,6 +968,9 @@
 			break;
 	}
 	
+	select_idle_routine(c);
+	detect_ht(c); 
+		
 	/*
 	 * On SMP, boot_cpu_data holds the common feature set between
 	 * all CPUs; so make sure that we indicate which features are
diff -Nru a/arch/x86_64/kernel/traps.c b/arch/x86_64/kernel/traps.c
--- a/arch/x86_64/kernel/traps.c	2004-05-23 01:15:37 -07:00
+++ b/arch/x86_64/kernel/traps.c	2004-05-23 01:15:37 -07:00
@@ -256,8 +256,8 @@
 
 	printk("CPU %d ", cpu);
 	__show_regs(regs);
-	printk("Process %s (pid: %d, stackpage=%08lx)\n",
-		cur->comm, cur->pid, 4096+(unsigned long)cur);
+	printk("Process %s (pid: %d, threadinfo %p, task %p)\n",
+		cur->comm, cur->pid, cur->thread_info, cur);
 
 	/*
 	 * When in-kernel, we also print out the stack and code at the
diff -Nru a/arch/x86_64/mm/pageattr.c b/arch/x86_64/mm/pageattr.c
--- a/arch/x86_64/mm/pageattr.c	2004-05-23 01:15:37 -07:00
+++ b/arch/x86_64/mm/pageattr.c	2004-05-23 01:15:37 -07:00
@@ -32,7 +32,8 @@
 	return pte;
 } 
 
-static struct page *split_large_page(unsigned long address, pgprot_t prot)
+static struct page *split_large_page(unsigned long address, pgprot_t prot,
+				     pgprot_t ref_prot)
 { 
 	int i; 
 	unsigned long addr;
@@ -45,7 +46,7 @@
 	pbase = (pte_t *)page_address(base);
 	for (i = 0; i < PTRS_PER_PTE; i++, addr += PAGE_SIZE) {
 		pbase[i] = pfn_pte(addr >> PAGE_SHIFT, 
-				   addr == address ? prot : PAGE_KERNEL);
+				   addr == address ? prot : ref_prot);
 	}
 	return base;
 } 
@@ -95,7 +96,8 @@
  * No more special protections in this 2/4MB area - revert to a
  * large page again. 
  */
-static void revert_page(struct page *kpte_page, unsigned long address)
+static void revert_page(struct page *kpte_page, unsigned long address, 
+			pgprot_t ref_prot)
 {
        pgd_t *pgd;
        pmd_t *pmd; 
@@ -104,12 +106,14 @@
        pgd = pgd_offset_k(address); 
        pmd = pmd_offset(pgd, address);
        BUG_ON(pmd_val(*pmd) & _PAGE_PSE); 
-       large_pte = mk_pte_phys(__pa(address) & LARGE_PAGE_MASK, PAGE_KERNEL_LARGE);
+       pgprot_val(ref_prot) |= _PAGE_PSE;
+       large_pte = mk_pte_phys(__pa(address) & LARGE_PAGE_MASK, ref_prot);
        set_pte((pte_t *)pmd, large_pte);
 }      
 
 static int
-__change_page_attr(unsigned long address, struct page *page, pgprot_t prot)
+__change_page_attr(unsigned long address, struct page *page, pgprot_t prot, 
+		   pgprot_t ref_prot)
 { 
 	pte_t *kpte; 
 	struct page *kpte_page;
@@ -119,29 +123,29 @@
 	if (!kpte) return 0;
 	kpte_page = virt_to_page(((unsigned long)kpte) & PAGE_MASK);
 	kpte_flags = pte_val(*kpte); 
-	if (pgprot_val(prot) != pgprot_val(PAGE_KERNEL)) { 
+	if (pgprot_val(prot) != pgprot_val(ref_prot)) { 
 		if ((kpte_flags & _PAGE_PSE) == 0) { 
 			pte_t old = *kpte;
-			pte_t standard = mk_pte(page, PAGE_KERNEL); 
+			pte_t standard = mk_pte(page, ref_prot); 
 
 			set_pte(kpte, mk_pte(page, prot)); 
 			if (pte_same(old,standard))
 				get_page(kpte_page);
 		} else {
-			struct page *split = split_large_page(address, prot); 
+			struct page *split = split_large_page(address, prot, ref_prot); 
 			if (!split)
 				return -ENOMEM;
 			get_page(kpte_page);
-			set_pte(kpte,mk_pte(split, PAGE_KERNEL));
+			set_pte(kpte,mk_pte(split, ref_prot));
 		}	
 	} else if ((kpte_flags & _PAGE_PSE) == 0) { 
-		set_pte(kpte, mk_pte(page, PAGE_KERNEL));
+		set_pte(kpte, mk_pte(page, ref_prot));
 		__put_page(kpte_page);
 	}
 
 	if (page_count(kpte_page) == 1) {
 		save_page(address, kpte_page); 		     
-		revert_page(kpte_page, address);
+		revert_page(kpte_page, address, ref_prot);
 	} 
 	return 0;
 } 
@@ -167,13 +171,16 @@
 	down_write(&init_mm.mmap_sem);
 	for (i = 0; i < numpages; !err && i++, page++) { 
 		unsigned long address = (unsigned long)page_address(page); 
-		err = __change_page_attr(address, page, prot); 
+		err = __change_page_attr(address, page, prot, PAGE_KERNEL); 
 		if (err) 
 			break; 
-		/* Handle kernel mapping too which aliases part of the lowmem */
+		/* Handle kernel mapping too which aliases part of the
+		 * lowmem */
 		if (page_to_phys(page) < KERNEL_TEXT_SIZE) {		
-			unsigned long addr2 = __START_KERNEL_map + page_to_phys(page);
-			err = __change_page_attr(addr2, page, prot);
+			unsigned long addr2;
+			addr2 = __START_KERNEL_map + page_to_phys(page);
+			err = __change_page_attr(addr2, page, prot, 
+						 PAGE_KERNEL_EXECUTABLE);
 		} 
 	} 	
 	up_write(&init_mm.mmap_sem); 
diff -Nru a/include/asm-x86_64/processor.h b/include/asm-x86_64/processor.h
--- a/include/asm-x86_64/processor.h	2004-05-23 01:15:37 -07:00
+++ b/include/asm-x86_64/processor.h	2004-05-23 01:15:37 -07:00
@@ -44,8 +44,6 @@
 
 /*
  *  CPU type and hardware bug flags. Kept separately for each CPU.
- *  Members of this structure are referenced in head.S, so think twice
- *  before touching them. [mj]
  */
 
 struct cpuinfo_x86 {
@@ -229,6 +227,8 @@
 	unsigned long io_bitmap[IO_BITMAP_LONGS + 1];
 } __attribute__((packed)) ____cacheline_aligned;
 
+#define ARCH_MIN_TASKALIGN	16
+
 struct thread_struct {
 	unsigned long	rsp0;
 	unsigned long	rsp;
@@ -246,14 +246,14 @@
 /* fault info */
 	unsigned long	cr2, trap_no, error_code;
 /* floating point info */
-	union i387_union	i387;
+	union i387_union	i387  __attribute__((aligned(16)));
 /* IO permissions. the bitmap could be moved into the GDT, that would make
    switch faster for a limited number of ioperm using tasks. -AK */
 	int		ioperm;
 	unsigned long	*io_bitmap_ptr;
 /* cached TLS descriptors. */
 	u64 tls_array[GDT_ENTRY_TLS_ENTRIES];
-};
+} __attribute__((aligned(16)));
 
 #define INIT_THREAD  {}
 
@@ -345,7 +345,17 @@
 /* '6' because it used to be for P6 only (but now covers Pentium 4 as well) */
 #define MICROCODE_IOCFREE	_IO('6',0)
 
+/* generic versions from gas */
+#define GENERIC_NOP1	".byte 0x90\n"
+#define GENERIC_NOP2    	".byte 0x89,0xf6\n"
+#define GENERIC_NOP3        ".byte 0x8d,0x76,0x00\n"
+#define GENERIC_NOP4        ".byte 0x8d,0x74,0x26,0x00\n"
+#define GENERIC_NOP5        GENERIC_NOP1 GENERIC_NOP4
+#define GENERIC_NOP6	".byte 0x8d,0xb6,0x00,0x00,0x00,0x00\n"
+#define GENERIC_NOP7	".byte 0x8d,0xb4,0x26,0x00,0x00,0x00,0x00\n"
+#define GENERIC_NOP8	GENERIC_NOP1 GENERIC_NOP7
 
+#ifdef CONFIG_MK8
 #define ASM_NOP1 K8_NOP1
 #define ASM_NOP2 K8_NOP2
 #define ASM_NOP3 K8_NOP3
@@ -354,6 +364,16 @@
 #define ASM_NOP6 K8_NOP6
 #define ASM_NOP7 K8_NOP7
 #define ASM_NOP8 K8_NOP8
+#else
+#define ASM_NOP1 GENERIC_NOP1
+#define ASM_NOP2 GENERIC_NOP2
+#define ASM_NOP3 GENERIC_NOP3
+#define ASM_NOP4 GENERIC_NOP4
+#define ASM_NOP5 GENERIC_NOP5
+#define ASM_NOP6 GENERIC_NOP6
+#define ASM_NOP7 GENERIC_NOP7
+#define ASM_NOP8 GENERIC_NOP8
+#endif
 
 /* Opteron nops */
 #define K8_NOP1 ".byte 0x90\n"
diff -Nru a/include/asm-x86_64/unistd.h b/include/asm-x86_64/unistd.h
--- a/include/asm-x86_64/unistd.h	2004-05-23 01:15:37 -07:00
+++ b/include/asm-x86_64/unistd.h	2004-05-23 01:15:37 -07:00
@@ -731,7 +731,7 @@
 
 #endif /* __KERNEL_SYSCALLS__ */
 
-#ifndef __ASSEMBLY__
+#if !defined(__ASSEMBLY__) && defined(__KERNEL__)
 
 #include <linux/linkage.h>
 #include <linux/compiler.h>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
