Date: Tue, 29 Jul 2008 14:11:25 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [PATCH] reserved-ram for pci-passthrough without VT-d capable
	hardware
Message-ID: <20080729121125.GK11494@duo.random>
References: <1214232737-21267-1-git-send-email-benami@il.ibm.com> <1214232737-21267-2-git-send-email-benami@il.ibm.com> <20080625005739.GM6938@duo.random> <20080625011808.GN6938@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080625011808.GN6938@duo.random>
Sender: owner-linux-mm@kvack.org
From: Andrea Arcangeli <andrea@qumranet.com>
Return-Path: <owner-linux-mm@kvack.org>
To: benami@il.ibm.com, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: amit.shah@qumranet.com, kvm@vger.kernel.org, aliguori@us.ibm.com, allen.m.kay@intel.com, muli@il.ibm.com, linux-mm@kvack.org, andi@firstfloor.org, tglx@linutronix.de, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

The "reserved RAM" can be mapped by virtualization software with
/dev/mem to create a 1:1 mapping between guest physical (bus) address
and host physical (bus) address. This will allow pci passthrough with
DMA for the guest using the ram with the 1:1 mapping. The only detail
to take care of is the ram marked "reserved RAM failed". The
virtualization software must create for the guest an e820 map that
only includes the "reserved RAM" regions but if the guest touches
memory with guest physical address in the "reserved RAM failed" ranges
(linux guest will do that even if the ram isn't present in the e820
map), it should provide that as ram and map it with a non linear
mapping. This should allow any linux kernel to run fine and hopefully
any other OS too.

svm ~ # cat /proc/iomem |head -n 20
00000000-00000fff : reserved RAM failed
00001000-00005fff : reserved RAM
00006000-00007fff : reserved RAM failed
00008000-0009efff : reserved RAM
0009f000-0009ffff : reserved
000cd600-000cffff : pnp 00:0d
000f0000-000fffff : reserved
00100000-0fffffff : reserved RAM
10000000-3dedffff : System RAM
  10000000-10329ab2 : Kernel code
  10329ab3-104933e7 : Kernel data
  104f5000-10558e67 : Kernel bss
3dee0000-3dee2fff : ACPI Non-volatile Storage
3dee3000-3deeffff : ACPI Tables
3def0000-3defffff : reserved
3dff0000-3ffeffff : pnp 00:0d
e0000000-efffffff : reserved
fa000000-fbffffff : PCI Bus #01
  fa000000-fbffffff : 0000:01:05.0
fda00000-fdbfffff : PCI Bus #01
svm ~ # hexdump /dev/mem | grep -C2 'cccc cccc cccc cccc'
00007e0 0000 0000 0000 0000 0000 0000 0000 0000
*
0001000 cccc cccc cccc cccc cccc cccc cccc cccc
*
0006000 a5a5 a5a5 8ec8 8ed8 8ec0 66d0 06c7 0000
--
*
0007ff0 0000 0000 0000 0000 3063 1000 0000 0000
0008000 cccc cccc cccc cccc cccc cccc cccc cccc
*
009f000 0002 0000 0000 0000 0000 0000 0000 0000
--
00fffe0 6000 3c03 45e7 0184 0500 0082 01c0 0223
00ffff0 5bea 00e0 31f0 2f32 3931 302f 0037 12fc
0100000 cccc cccc cccc cccc cccc cccc cccc cccc
*
10000000 8d48 f92d ffff 48ff ed81 0000 1000 8948
^C
svm ~ #

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
---

This is a port to current linux-2.6.git of the previous reserved-ram
patch. Let me know if there's a chance to get this acked and
included. Anything that isn't at compile time would require much
bigger changes just to parse the command line at 16bit realmode time
to know where to relocate the kernel dynamically. Because 1:1 is a
corner case feature required only by some users, this is the minimal
intrusive approach. This also has some limits as it can't reserve more
than 1g, and with a few more changes 2g but this is ok for a long time
as the virtualized 1:1 guest doesn't need to be huge, just a desktop.

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1276,8 +1276,36 @@ config CRASH_DUMP
 	  (CONFIG_RELOCATABLE=y).
 	  For more details see Documentation/kdump/kdump.txt
 
+config RESERVE_PHYSICAL_START
+	bool "Reserve all RAM below PHYSICAL_START (EXPERIMENTAL)"
+	depends on !RELOCATABLE && X86_64
+	help
+	  This makes the kernel use only RAM above __PHYSICAL_START.
+	  All memory below __PHYSICAL_START will be left unused and
+	  marked as "reserved RAM" in /proc/iomem. The few special
+	  pages that can't be relocated at addresses above
+	  __PHYSICAL_START and that can't be guaranteed to be unused
+	  by the running kernel will be marked "reserved RAM failed"
+	  in /proc/iomem. Those may or may be not used by the kernel
+	  (for example SMP trampoline pages would only be used if
+	  CPU hotplug is enabled).
+
+	  The "reserved RAM" can be mapped by virtualization software
+	  with /dev/mem to create a 1:1 mapping between guest physical
+	  (bus) address and host physical (bus) address. This will
+	  allow PCI passthrough with DMA for the guest using the RAM
+	  with the 1:1 mapping. The only detail to take care of is the
+	  RAM marked "reserved RAM failed". The virtualization
+	  software must create for the guest an e820 map that only
+	  includes the "reserved RAM" regions but if the guest touches
+	  memory with guest physical address in the "reserved RAM
+	  failed" ranges (Linux guest will do that even if the RAM
+	  isn't present in the e820 map), it should provide that as
+	  RAM and map it with a non-linear mapping. This should allow
+	  any Linux kernel to run fine and hopefully any other OS too.
+
 config PHYSICAL_START
-	hex "Physical address where the kernel is loaded" if (EMBEDDED || CRASH_DUMP)
+	hex "Physical address where the kernel is loaded" if (EMBEDDED || CRASH_DUMP || RESERVE_PHYSICAL_START)
 	default "0x1000000" if X86_NUMAQ
 	default "0x200000" if X86_64
 	default "0x100000"
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -148,6 +148,14 @@ void __init e820_print_map(char *who)
 		case E820_NVS:
 			printk(KERN_CONT "(ACPI NVS)\n");
 			break;
+#ifdef CONFIG_RESERVE_PHYSICAL_START
+		case E820_RESERVED_RAM:
+			printk(KERN_CONT "(reserved RAM)\n");
+			break;
+		case E820_RESERVED_RAM_FAILED:
+			printk(KERN_CONT "(reserved RAM failed)\n");
+			break;
+#endif
 		default:
 			printk(KERN_CONT "type %u\n", e820.map[i].type);
 			break;
@@ -384,10 +392,28 @@ static int __init __append_e820_map(stru
 		u64 end = start + size;
 		u32 type = biosmap->type;
 
+#ifdef CONFIG_RESERVE_PHYSICAL_START
+		/* make space for two more low-prio types */
+		type += 2;
+#endif
+
 		/* Overflow in 64 bits? Ignore the memory map. */
 		if (start > end)
 			return -1;
 
+#ifdef CONFIG_RESERVE_PHYSICAL_START
+		if (type == E820_RAM) {
+			if (end <= __PHYSICAL_START)
+				type = E820_RESERVED_RAM;
+			else if (start < __PHYSICAL_START) {
+				e820_add_region(start,
+						__PHYSICAL_START-start,
+						E820_RESERVED_RAM);
+				size -= __PHYSICAL_START-start;
+				start = __PHYSICAL_START;
+			}
+		}
+#endif
 		e820_add_region(start, size, type);
 
 		biosmap++;
@@ -893,7 +919,35 @@ void __init early_res_to_bootmem(u64 sta
 			final_start, final_end);
 		reserve_bootmem_generic(final_start, final_end - final_start,
 				BOOTMEM_DEFAULT);
+#ifdef CONFIG_RESERVE_PHYSICAL_START
+		if (r->start < __PHYSICAL_START)
+			e820_add_region(r->start, r->end - r->start,
+					E820_RESERVED_RAM_FAILED);
+#endif			
 	}
+#ifdef CONFIG_RESERVE_PHYSICAL_START
+	/* solve E820_RESERVED_RAM vs E820_RESERVED_RAM_FAILED conflicts */
+	update_e820();
+
+	/* now reserve E820_RESERVED_RAM */
+	for (i = 0; i < e820.nr_map; i++) {
+		struct e820entry *ei = &e820.map[i];
+
+		if (ei->type != E820_RESERVED_RAM)
+			continue;
+		final_start = max(start, (u64) ei->addr);
+		final_end = min(end, (u64) (ei->addr + ei->size));
+		if (final_start >= final_end)
+			continue;
+		if (reserve_bootmem_generic(final_start,
+					    final_end - final_start,
+					    BOOTMEM_DEFAULT))
+			printk(KERN_ERR "reserved physical start failure");
+		else
+			printk(KERN_INFO " bootmem reserved RAM: [%Lx-%Lx]\n",
+			       final_start, final_end - 1);
+	}
+#endif
 }
 
 /* Check for already reserved areas */
@@ -1095,6 +1149,17 @@ unsigned long __init e820_end_of_low_ram
 {
 	return e820_end_pfn(1UL<<(32 - PAGE_SHIFT), E820_RAM);
 }
+
+static int __init e820_is_not_ram(int type)
+{
+#ifdef CONFIG_RESERVE_PHYSICAL_START
+	return type != E820_RAM && type != E820_RESERVED_RAM &&
+		type != E820_RESERVED_RAM_FAILED;
+#else
+	return type != E820_RAM;
+#endif	
+}
+
 /*
  * Finds an active region in the address range from start_pfn to last_pfn and
  * returns its range in ei_startpfn and ei_endpfn for the e820 entry.
@@ -1115,8 +1180,8 @@ int __init e820_find_active_region(const
 		return 0;
 
 	/* Skip if map is outside the node */
-	if (ei->type != E820_RAM || *ei_endpfn <= start_pfn ||
-				    *ei_startpfn >= last_pfn)
+	if (e820_is_not_ram(ei->type) || *ei_endpfn <= start_pfn ||
+	    *ei_startpfn >= last_pfn)
 		return 0;
 
 	/* Check for overlaps */
@@ -1260,6 +1325,10 @@ static inline const char *e820_type_to_s
 	case E820_RAM:	return "System RAM";
 	case E820_ACPI:	return "ACPI Tables";
 	case E820_NVS:	return "ACPI Non-volatile Storage";
+#ifdef CONFIG_RESERVE_PHYSICAL_START
+	case E820_RESERVED_RAM_FAILED: return "reserved RAM failed";
+	case E820_RESERVED_RAM: return "reserved RAM";
+#endif
 	default:	return "reserved";
 	}
 }
@@ -1289,6 +1358,12 @@ void __init e820_reserve_resources(void)
 		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 		insert_resource(&iomem_resource, res);
 		res++;
+
+#ifdef CONFIG_RESERVE_PHYSICAL_START
+		if (i == E820_RESERVED_RAM)
+			memset(__va(e820.map[i].addr),
+			       POISON_FREE_INITMEM, e820.map[i].size);
+#endif
 	}
 
 	for (i = 0; i < e820_saved.nr_map; i++) {
diff --git a/include/asm-x86/e820.h b/include/asm-x86/e820.h
--- a/include/asm-x86/e820.h
+++ b/include/asm-x86/e820.h
@@ -39,10 +39,19 @@
 
 #define E820NR	0x1e8		/* # entries in E820MAP */
 
+#ifdef CONFIG_RESERVE_PHYSICAL_START
+#define E820_RESERVED_RAM 1
+#define E820_RESERVED_RAM_FAILED 2
+#define E820_RAM	3
+#define E820_RESERVED	4
+#define E820_ACPI	5
+#define E820_NVS	6
+#else
 #define E820_RAM	1
 #define E820_RESERVED	2
 #define E820_ACPI	3
 #define E820_NVS	4
+#endif
 
 /* reserved RAM used by kernel itself */
 #define E820_RESERVED_KERN        128
diff --git a/include/asm-x86/page_64.h b/include/asm-x86/page_64.h
--- a/include/asm-x86/page_64.h
+++ b/include/asm-x86/page_64.h
@@ -35,6 +35,7 @@
 #define __PAGE_OFFSET           _AC(0xffff880000000000, UL)
 
 #define __PHYSICAL_START	CONFIG_PHYSICAL_START
+#define __PHYSICAL_OFFSET	(__PHYSICAL_START-0x200000)
 #define __KERNEL_ALIGN		0x200000
 
 /*
@@ -57,7 +58,7 @@
  * Kernel image size is limited to 512 MB (see level2_kernel_pgt in
  * arch/x86/kernel/head_64.S), and it is mapped here:
  */
-#define KERNEL_IMAGE_SIZE	(512 * 1024 * 1024)
+#define KERNEL_IMAGE_SIZE	(512 * 1024 * 1024 + __PHYSICAL_OFFSET)
 #define KERNEL_IMAGE_START	_AC(0xffffffff80000000, UL)
 
 #ifndef __ASSEMBLY__
diff --git a/include/asm-x86/pgtable_64.h b/include/asm-x86/pgtable_64.h
--- a/include/asm-x86/pgtable_64.h
+++ b/include/asm-x86/pgtable_64.h
@@ -150,7 +150,7 @@ static inline void native_pgd_clear(pgd_
 #define VMALLOC_START    _AC(0xffffc20000000000, UL)
 #define VMALLOC_END      _AC(0xffffe1ffffffffff, UL)
 #define VMEMMAP_START	 _AC(0xffffe20000000000, UL)
-#define MODULES_VADDR    _AC(0xffffffffa0000000, UL)
+#define MODULES_VADDR    (0xffffffffa0000000UL+__PHYSICAL_OFFSET)
 #define MODULES_END      _AC(0xfffffffffff00000, UL)
 #define MODULES_LEN   (MODULES_END - MODULES_VADDR)
 
diff --git a/include/asm-x86/trampoline.h b/include/asm-x86/trampoline.h
--- a/include/asm-x86/trampoline.h
+++ b/include/asm-x86/trampoline.h
@@ -13,7 +13,11 @@ extern unsigned long init_rsp;
 extern unsigned long init_rsp;
 extern unsigned long initial_code;
 
+#ifndef CONFIG_RESERVE_PHYSICAL_START
 #define TRAMPOLINE_BASE 0x6000
+#else
+#define TRAMPOLINE_BASE 0x90000 /* move it next to 640k */
+#endif
 extern unsigned long setup_trampoline(void);
 
 #endif /* __ASSEMBLY__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
