Date: Wed, 25 Jun 2008 03:18:08 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [PATCH] reserved-ram for pci-passthrough without VT-d capable
	hardware
Message-ID: <20080625011808.GN6938@duo.random>
References: <1214232737-21267-1-git-send-email-benami@il.ibm.com> <1214232737-21267-2-git-send-email-benami@il.ibm.com> <20080625005739.GM6938@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080625005739.GM6938@duo.random>
Sender: owner-linux-mm@kvack.org
From: Andrea Arcangeli <andrea@qumranet.com>
Return-Path: <owner-linux-mm@kvack.org>
To: benami@il.ibm.com, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: amit.shah@qumranet.com, kvm@vger.kernel.org, aliguori@us.ibm.com, allen.m.kay@intel.com, muli@il.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This has to be applied to the host kernel and for example specifying a
relocation address of 0x20000000 it will allow to start kvm guests
capable of pci-passthrough up to "-m 512" by passing the
"-reserved-ram" parameter in the command line. There's no risk of
errors from the user thanks to the reserved ranges being provided to
the virtualization software through /proc/iomem. Only you shouldn't
run more than one -reserved-ram kvm quest per system at once.

This works by reserving the ram early in the e820 map so the initial
pagetables are allocated above the kernel .text relocation and then I
make the sparse code think the reserved-ram is actually available (so
struct pages are allocated) and finally I've to reserve those pages in
the bootmem allocator immediately after the bootmem allocator has been
initialized, so they remain PageReserved not used by linux, but with
'struct page' backing so they can still be exported to qemu via device
driver vma->fault (as they can still be the target of any emulated
dma, not all devices will passthrough).

The virtualization software must create for the guest an e820 map that
only includes the "reserved RAM" regions but if the guest touches
memory with guest physical address in the "reserved RAM failed" ranges
it should provide that as ram and map it with a non linear
mapping (in practice the only problem is for the first page at address
0 physical which is usually the bios and no sane OS is doing DMA to
it).

vmx ~ # cat /proc/iomem |head -n 20
00000000-00000fff : reserved RAM failed
00001000-0008ffff : reserved RAM
00090000-00091fff : reserved RAM failed
00092000-0009cfff : reserved RAM
0009d000-0009ffff : reserved
000a0000-000ec16f : reserved RAM failed
000ec170-000fffff : reserved
00100000-1fffffff : reserved RAM
20000000-bff9ffff : System RAM
  20000000-20315f65 : Kernel code
  20315f66-204c3767 : Kernel data
  20557000-205c9eff : Kernel bss
bffa0000-bffaffff : ACPI Tables
bffb0000-bffdffff : ACPI Non-volatile Storage
bffe0000-bffedfff : reserved
bfff0000-bfffffff : reserved
d0000000-dfffffff : PCI Bus 0000:02
  d0000000-dfffffff : 0000:02:00.0
e0000000-efffffff : PCI MMCONFIG 0
  e0000000-efffffff : pnp 00:0c

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
---

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1198,8 +1198,36 @@ config CRASH_DUMP
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
diff --git a/arch/x86/kernel/e820_64.c b/arch/x86/kernel/e820_64.c
--- a/arch/x86/kernel/e820_64.c
+++ b/arch/x86/kernel/e820_64.c
@@ -119,7 +119,31 @@ void __init early_res_to_bootmem(unsigne
 		printk(KERN_INFO "  early res: %d [%lx-%lx] %s\n", i,
 			final_start, final_end - 1, r->name);
 		reserve_bootmem_generic(final_start, final_end - final_start);
+#ifdef CONFIG_RESERVE_PHYSICAL_START
+		if (r->start < __PHYSICAL_START)
+			add_memory_region(r->start, r->end - r->start,
+					  E820_RESERVED_RAM_FAILED);
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
+		final_start = max(start, (unsigned long) ei->addr);
+		final_end = min(end, (unsigned long) (ei->addr + ei->size));
+		if (final_start >= final_end)
+			continue;
+		reserve_bootmem_generic(final_start, final_end - final_start);
+		printk(KERN_INFO " bootmem reserved RAM: [%lx-%lx]\n",
+		       final_start, final_end - 1);
+	}
+#endif
 }
 
 /* Check for already reserved areas */
@@ -336,6 +360,16 @@ void __init e820_reserve_resources(void)
 		case E820_RAM:	res->name = "System RAM"; break;
 		case E820_ACPI:	res->name = "ACPI Tables"; break;
 		case E820_NVS:	res->name = "ACPI Non-volatile Storage"; break;
+#ifdef CONFIG_RESERVE_PHYSICAL_START
+		case E820_RESERVED_RAM_FAILED:
+			res->name = "reserved RAM failed";
+			break;
+		case E820_RESERVED_RAM:
+			memset(__va(e820.map[i].addr),
+			       POISON_FREE_INITMEM, e820.map[i].size);
+			res->name = "reserved RAM";
+			break;
+#endif
 		default:	res->name = "reserved";
 		}
 		res->start = e820.map[i].addr;
@@ -377,6 +411,16 @@ void __init e820_mark_nosave_regions(voi
 	}
 }
 
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
  * Finds an active region in the address range from start_pfn to end_pfn and
  * returns its range in ei_startpfn and ei_endpfn for the e820 entry.
@@ -395,11 +439,11 @@ static int __init e820_find_active_regio
 		return 0;
 
 	/* Check if max_pfn_mapped should be updated */
-	if (ei->type != E820_RAM && *ei_endpfn > max_pfn_mapped)
+	if (e820_is_not_ram(ei->type) && *ei_endpfn > max_pfn_mapped)
 		max_pfn_mapped = *ei_endpfn;
 
 	/* Skip if map is outside the node */
-	if (ei->type != E820_RAM || *ei_endpfn <= start_pfn ||
+	if (e820_is_not_ram(ei->type) || *ei_endpfn <= start_pfn ||
 				    *ei_startpfn >= end_pfn)
 		return 0;
 
@@ -495,6 +539,14 @@ static void __init e820_print_map(char *
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
@@ -724,9 +776,31 @@ static int __init copy_e820_map(struct e
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
+
+#ifdef CONFIG_RESERVE_PHYSICAL_START
+		if (type == E820_RAM) {
+			if (end <= __PHYSICAL_START) {
+				add_memory_region(start, size,
+						  E820_RESERVED_RAM);
+				continue;
+			}
+			if (start < __PHYSICAL_START) {
+				add_memory_region(start,
+						  __PHYSICAL_START-start,
+						  E820_RESERVED_RAM);
+				size -= __PHYSICAL_START-start;
+				start = __PHYSICAL_START;
+			}
+		}
+#endif
 
 		add_memory_region(start, size, type);
 	} while (biosmap++, --nr_map);
diff --git a/include/asm-x86/e820.h b/include/asm-x86/e820.h
--- a/include/asm-x86/e820.h
+++ b/include/asm-x86/e820.h
@@ -4,10 +4,19 @@
 #define E820MAX	128		/* number of entries in E820MAP */
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
 
 #ifndef __ASSEMBLY__
 struct e820entry {
diff --git a/include/asm-x86/page_64.h b/include/asm-x86/page_64.h
--- a/include/asm-x86/page_64.h
+++ b/include/asm-x86/page_64.h
@@ -29,6 +29,7 @@
 #define __PAGE_OFFSET           _AC(0xffff810000000000, UL)
 
 #define __PHYSICAL_START	CONFIG_PHYSICAL_START
+#define __PHYSICAL_OFFSET	(__PHYSICAL_START-0x200000)
 #define __KERNEL_ALIGN		0x200000
 
 /*
@@ -51,7 +52,7 @@
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
@@ -145,7 +145,7 @@ static inline void native_pgd_clear(pgd_
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
