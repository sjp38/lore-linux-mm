Date: Fri, 02 Apr 2004 14:26:37 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH] Basic nonlinear for x86
Message-ID: <92680000.1080937597@[10.1.1.4]>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1896969384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, Linux Hotplug Memory <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

--==========1896969384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Attached is a snapshot of a basic nonlinear implementation.  It's similar
to the one Daniel Phillips did a couple of years ago.  So far it works on
base x86 machines.  Still to be done is to port to other architectures and
roll support for discontigmem into it.

My apologies for not moving this forward to the latest -mm.  It's just
getting too hard to keep up with akpm :)

Dave McCracken

--==========1896969384==========
Content-Type: text/plain; charset=iso-8859-1;
 name="nonlinear-2.6.5-rc2-mm1-1.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="nonlinear-2.6.5-rc2-mm1-1.diff";
 size=24237

--- 2.6.5-rc2-mm1/./arch/i386/kernel/doublefault.c	2004-03-23 =
12:38:19.000000000 -0600
+++ 2.6.5-rc2-mm1-nonlinear/./arch/i386/kernel/doublefault.c	2004-03-23 =
12:38:58.000000000 -0600
@@ -61,5 +61,5 @@ struct tss_struct doublefault_tss __cach
 	.ss		=3D __KERNEL_DS,
 	.ds		=3D __USER_DS,
=20
-	.__cr3		=3D __pa(swapper_pg_dir)
+	.__cr3		=3D __boot_pa(swapper_pg_dir)
 };
--- 2.6.5-rc2-mm1/./arch/i386/kernel/acpi/boot.c	2004-03-23 =
12:38:19.000000000 -0600
+++ 2.6.5-rc2-mm1-nonlinear/./arch/i386/kernel/acpi/boot.c	2004-03-23 =
12:38:58.000000000 -0600
@@ -482,9 +482,9 @@ acpi_find_rsdp (void)
=20
 	if (efi_enabled) {
 		if (efi.acpi20)
-			return __pa(efi.acpi20);
+			return __boot_pa(efi.acpi20);
 		else if (efi.acpi)
-			return __pa(efi.acpi);
+			return __boot_pa(efi.acpi);
 	}
 	/*
 	 * Scan memory looking for the RSDP signature. First search EBDA (low
--- 2.6.5-rc2-mm1/./arch/i386/kernel/setup.c	2004-03-23 12:38:19.000000000 =
-0600
+++ 2.6.5-rc2-mm1-nonlinear/./arch/i386/kernel/setup.c	2004-03-23 =
13:02:18.000000000 -0600
@@ -118,6 +118,7 @@ unsigned char aux_device_present;
 extern void early_cpu_init(void);
 extern void dmi_scan_machine(void);
 extern void generic_apic_probe(char *);
+extern void zone_sizes_init(void);
 extern int root_mountflags;
=20
 unsigned long saved_videomode;
@@ -810,6 +811,11 @@ static unsigned long __init setup_memory
=20
 	find_max_pfn();
=20
+#ifdef CONFIG_NONLINEAR
+	setup_memsections();
+	alloc_memsections(0, 0, max_pfn);
+#endif
+
 	max_low_pfn =3D find_max_low_pfn();
=20
 #ifdef CONFIG_HIGHMEM
@@ -1075,6 +1081,9 @@ __setup("noreplacement", noreplacement_s
 void __init setup_arch(char **cmdline_p)
 {
 	unsigned long max_low_pfn;
+#ifdef CONFIG_NONLINEAR
+	struct page *lmem_map;
+#endif
=20
 	memcpy(&boot_cpu_data, &new_cpu_data, sizeof(new_cpu_data));
 	pre_setup_arch_hook();
@@ -1127,10 +1136,10 @@ void __init setup_arch(char **cmdline_p)
 	init_mm.end_data =3D (unsigned long) _edata;
 	init_mm.brk =3D init_pg_tables_end + PAGE_OFFSET;
=20
-	code_resource.start =3D virt_to_phys(_text);
-	code_resource.end =3D virt_to_phys(_etext)-1;
-	data_resource.start =3D virt_to_phys(_etext);
-	data_resource.end =3D virt_to_phys(_edata)-1;
+	code_resource.start =3D __boot_pa(_text);
+	code_resource.end =3D __boot_pa(_etext)-1;
+	data_resource.start =3D __boot_pa(_etext);
+	data_resource.end =3D __boot_pa(_edata)-1;
=20
 	parse_cmdline_early(cmdline_p);
=20
@@ -1146,6 +1155,13 @@ void __init setup_arch(char **cmdline_p)
 #endif
 	paging_init();
=20
+#ifdef CONFIG_NONLINEAR
+	lmem_map =3D alloc_bootmem(max_pfn * sizeof(struct page));
+	alloc_memmap(lmem_map, 0, max_pfn);
+#endif
+
+	zone_sizes_init();
+
 #ifdef CONFIG_EARLY_PRINTK
 	{
 		char *s =3D strstr(*cmdline_p, "earlyprintk=3D");
--- 2.6.5-rc2-mm1/./arch/i386/kernel/smpboot.c	2004-03-23 =
12:38:19.000000000 -0600
+++ 2.6.5-rc2-mm1-nonlinear/./arch/i386/kernel/smpboot.c	2004-03-23 =
12:38:58.000000000 -0600
@@ -107,7 +107,7 @@ void __init smp_alloc_memory(void)
 	 * Has to be in very low memory so we can execute
 	 * real-mode AP code.
 	 */
-	if (__pa(trampoline_base) >=3D 0x9F000)
+	if (__boot_pa(trampoline_base) >=3D 0x9F000)
 		BUG();
 }
=20
--- 2.6.5-rc2-mm1/./arch/i386/kernel/efi.c	2004-03-19 18:11:33.000000000 =
-0600
+++ 2.6.5-rc2-mm1-nonlinear/./arch/i386/kernel/efi.c	2004-03-23 =
12:38:58.000000000 -0600
@@ -114,9 +114,9 @@ static void efi_call_phys_prelog(void)
 	 */
 	local_flush_tlb();
=20
-	cpu_gdt_descr[0].address =3D __pa(cpu_gdt_descr[0].address);
+	cpu_gdt_descr[0].address =3D __boot_pa(cpu_gdt_descr[0].address);
 	__asm__ __volatile__("lgdt %0":"=3Dm"
-			    (*(struct Xgt_desc_struct *) __pa(&cpu_gdt_descr[0])));
+			    (*(struct Xgt_desc_struct *) __boot_pa(&cpu_gdt_descr[0])));
 }
=20
 static void efi_call_phys_epilog(void)
--- 2.6.5-rc2-mm1/./arch/i386/kernel/apic.c	2004-03-19 18:12:09.000000000 =
-0600
+++ 2.6.5-rc2-mm1-nonlinear/./arch/i386/kernel/apic.c	2004-03-23 =
12:38:58.000000000 -0600
@@ -710,7 +710,7 @@ void __init init_apic_mappings(void)
 	 */
 	if (!smp_found_config && detect_init_APIC()) {
 		apic_phys =3D (unsigned long) alloc_bootmem_pages(PAGE_SIZE);
-		apic_phys =3D __pa(apic_phys);
+		apic_phys =3D __boot_pa(apic_phys);
 	} else
 		apic_phys =3D mp_lapic_addr;
=20
@@ -742,7 +742,7 @@ void __init init_apic_mappings(void)
 			} else {
 fake_ioapic_page:
 				ioapic_phys =3D (unsigned long) alloc_bootmem_pages(PAGE_SIZE);
-				ioapic_phys =3D __pa(ioapic_phys);
+				ioapic_phys =3D __boot_pa(ioapic_phys);
 			}
 			set_fixmap_nocache(idx, ioapic_phys);
 			Dprintk("mapped IOAPIC to %08lx (%08lx)\n",
--- 2.6.5-rc2-mm1/./arch/i386/kernel/entry_trampoline.c	2004-03-23 =
12:38:19.000000000 -0600
+++ =
2.6.5-rc2-mm1-nonlinear/./arch/i386/kernel/entry_trampoline.c	2004-03-23 =
12:38:58.000000000 -0600
@@ -30,8 +30,8 @@ void __init init_entry_mappings(void)
 	 */
 	trap_init_virtual_IDT();
=20
-	__set_fixmap(FIX_ENTRY_TRAMPOLINE_0, __pa((unsigned =
long)&__entry_tramp_start), PAGE_KERNEL);
-	__set_fixmap(FIX_ENTRY_TRAMPOLINE_1, __pa((unsigned =
long)&__entry_tramp_start) + PAGE_SIZE, PAGE_KERNEL);
+	__set_fixmap(FIX_ENTRY_TRAMPOLINE_0, __boot_pa((unsigned =
long)&__entry_tramp_start), PAGE_KERNEL);
+	__set_fixmap(FIX_ENTRY_TRAMPOLINE_1, __boot_pa((unsigned =
long)&__entry_tramp_start) + PAGE_SIZE, PAGE_KERNEL);
 	tramp =3D (void *)fix_to_virt(FIX_ENTRY_TRAMPOLINE_0);
=20
 	printk("mapped 4G/4G trampoline to %p.\n", tramp);
--- 2.6.5-rc2-mm1/./arch/i386/mm/init.c	2004-03-23 12:38:19.000000000 -0600
+++ 2.6.5-rc2-mm1-nonlinear/./arch/i386/mm/init.c	2004-03-23 =
13:01:08.000000000 -0600
@@ -350,8 +350,6 @@ void __init zone_sizes_init(void)
 	}
 	free_area_init(zones_size);	
 }
-#else
-extern void zone_sizes_init(void);
 #endif /* !CONFIG_DISCONTIGMEM */
=20
 /*
@@ -386,7 +384,6 @@ void __init paging_init(void)
 	zap_low_mappings();
 #endif
 	kmap_init();
-	zone_sizes_init();
 }
=20
 /*
@@ -440,10 +437,12 @@ void __init mem_init(void)
 	int tmp;
 	int bad_ppro;
=20
+#ifndef CONFIG_NONLINEAR
 #ifndef CONFIG_DISCONTIGMEM
 	if (!mem_map)
 		BUG();
 #endif
+#endif
 	
 	bad_ppro =3D ppro_with_ram_bug();
=20
--- 2.6.5-rc2-mm1/./arch/i386/mm/pgtable.c	2004-03-23 12:38:19.000000000 =
-0600
+++ 2.6.5-rc2-mm1-nonlinear/./arch/i386/mm/pgtable.c	2004-03-23 =
12:38:58.000000000 -0600
@@ -23,6 +23,9 @@
 #include <asm/tlbflush.h>
 #include <asm/atomic_kmap.h>
=20
+#ifdef CONFIG_NONLINEAR
+void show_mem(void){}
+#else
 void show_mem(void)
 {
 	int total =3D 0, reserved =3D 0;
@@ -55,6 +58,7 @@ void show_mem(void)
 	printk("%d pages shared\n",shared);
 	printk("%d pages swap cached\n",cached);
 }
+#endif
=20
 /*
  * Associate a virtual page frame with a given physical page frame=20
--- 2.6.5-rc2-mm1/./arch/i386/Kconfig	2004-03-23 12:38:19.000000000 -0600
+++ 2.6.5-rc2-mm1-nonlinear/./arch/i386/Kconfig	2004-03-23 =
12:38:58.000000000 -0600
@@ -785,6 +785,9 @@ config HAVE_ARCH_BOOTMEM_NODE
 	depends on NUMA
 	default y
=20
+config NONLINEAR
+	bool "Allow nonlinear physical memory"
+
 config HIGHPTE
 	bool "Allocate 3rd-level pagetables from highmem"
 	depends on HIGHMEM4G || HIGHMEM64G
--- 2.6.5-rc2-mm1/./include/linux/mm.h	2004-03-23 12:38:19.000000000 -0600
+++ 2.6.5-rc2-mm1-nonlinear/./include/linux/mm.h	2004-03-23 =
12:38:58.000000000 -0600
@@ -202,6 +202,9 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
+#ifdef CONFIG_NONLINEAR
+	unsigned short section;		/* memory section id */
+#endif
 };
=20
 /*
@@ -364,14 +367,16 @@ static inline void set_page_zone(struct=20
 	page->flags |=3D nodezone_num << NODEZONE_SHIFT;
 }
=20
+#ifndef	CONFIG_NONLINEAR
 #ifndef CONFIG_DISCONTIGMEM
 /* The array of struct pages - for discontigmem use pgdat->lmem_map */
 extern struct page *mem_map;
 #endif
+#endif
=20
 static inline void *lowmem_page_address(struct page *page)
 {
-	return __va(page_to_pfn(page) << PAGE_SHIFT);
+	return (void *)__va(page_to_pfn(page) << PAGE_SHIFT);
 }
=20
 #if defined(CONFIG_HIGHMEM) && !defined(WANT_PAGE_VIRTUAL)
@@ -526,10 +531,10 @@ static inline pmd_t *pmd_alloc(struct mm
 }
=20
 extern void free_area_init(unsigned long * zones_size);
-extern void free_area_init_node(int nid, pg_data_t *pgdat, struct page =
*pmap,
+extern void free_area_init_node(int nid, pg_data_t *pgdat,=20
 	unsigned long * zones_size, unsigned long zone_start_pfn,=20
 	unsigned long *zholes_size);
-extern void memmap_init_zone(struct page *, unsigned long, int,
+extern void memmap_init_zone(unsigned long, int,
 	unsigned long, unsigned long);
 extern void mem_init(void);
 extern void show_mem(void);
--- 2.6.5-rc2-mm1/./include/linux/mmzone.h	2004-03-23 12:38:19.000000000 =
-0600
+++ 2.6.5-rc2-mm1-nonlinear/./include/linux/mmzone.h	2004-03-23 =
12:38:58.000000000 -0600
@@ -167,7 +167,6 @@ struct zone {
 	 * Discontig memory support fields.
 	 */
 	struct pglist_data	*zone_pgdat;
-	struct page		*zone_mem_map;
 	/* zone_start_pfn =3D=3D zone_start_paddr >> PAGE_SHIFT */
 	unsigned long		zone_start_pfn;
=20
@@ -219,7 +218,9 @@ typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
 	struct zonelist node_zonelists[MAX_NR_ZONES];
 	int nr_zones;
+#ifndef CONFIG_NONLINEAR
 	struct page *node_mem_map;
+#endif
 	struct bootmem_data *bdata;
 	unsigned long node_start_pfn;
 	unsigned long node_present_pages; /* total number of physical pages */
@@ -330,7 +331,6 @@ int lower_zone_protection_sysctl_handler
=20
 extern struct pglist_data contig_page_data;
 #define NODE_DATA(nid)		(&contig_page_data)
-#define NODE_MEM_MAP(nid)	mem_map
 #define MAX_NODES_SHIFT		1
 #define pfn_to_nid(pfn)		(0)
=20
--- 2.6.5-rc2-mm1/./include/linux/nonlinear.h	1969-12-31 18:00:00.000000000 =
-0600
+++ 2.6.5-rc2-mm1-nonlinear/./include/linux/nonlinear.h	2004-03-23 =
12:38:58.000000000 -0600
@@ -0,0 +1,104 @@
+#ifndef __LINUX_NONLINEAR_H_
+#define __LINUX_NONLINEAR_H_
+
+#include <asm/nonlinear.h>
+
+#define	__HAVE_ARCH_MEMMAP_INIT	1
+
+#define SECTION_SIZE		(1<<SECTION_SHIFT)
+#define SECTION_MASK		(~(SECTION_SIZE-1))
+#define PAGES_PER_SECTION	(1<<(SECTION_SHIFT-PAGE_SHIFT))
+#define PAGE_SECTION_MASK	(~(PAGES_PER_SECTION-1))
+#define	NR_SECTIONS		(1<<(MAX_MEM_SHIFT-SECTION_SHIFT))
+#define	NR_PHYS_SECTIONS	(1<<(MAX_PHYS_SHIFT-SECTION_SHIFT))
+
+#define	INVALID_PHYS_SECTION	((unsigned short)0xffff)
+#define	INVALID_SECTION		((unsigned int)0xffffffff)
+
+struct page;
+
+struct mem_section {
+	unsigned int	phys_section;
+	struct page	*mem_map;
+};
+
+extern struct mem_section mem_section[];
+extern unsigned short phys_section[];
+
+static inline unsigned long
+section_to_addr(unsigned short nr)
+{
+	return nr << SECTION_SHIFT;
+}
+
+static inline unsigned int
+addr_to_section(unsigned long addr)
+{
+	return addr >> SECTION_SHIFT;
+}
+
+static inline unsigned long
+section_to_pfn(unsigned short nr)
+{
+	return nr << (SECTION_SHIFT - PAGE_SHIFT);
+}
+
+static inline unsigned int
+pfn_to_section(unsigned long addr)
+{
+	return addr >> (SECTION_SHIFT - PAGE_SHIFT);
+}
+
+static inline unsigned int
+pfn_to_section_roundup(unsigned long addr)
+{
+	return (addr+(PAGES_PER_SECTION-1)) >> (SECTION_SHIFT - PAGE_SHIFT);
+}
+
+static inline unsigned long
+section_offset(unsigned long addr)
+{
+	return addr & ~SECTION_MASK;
+}
+
+static inline unsigned long
+section_offset_pfn(unsigned long pfn)
+{
+	return pfn & ~PAGE_SECTION_MASK;
+}
+
+static inline unsigned long
+__pa(unsigned long addr)
+{
+	return =
section_to_addr(mem_section[addr_to_section(addr-PAGE_OFFSET)].phys_section)=
 |
+		section_offset(addr);
+}
+
+static inline unsigned long
+__va(unsigned long addr)
+{
+	return (section_to_addr(phys_section[addr_to_section(addr)]) |
+		section_offset(addr)) + PAGE_OFFSET;
+}
+
+extern struct page *pfn_to_page(unsigned long pfn);
+unsigned long page_to_pfn(struct page *page);
+
+static inline int
+pfn_valid(unsigned long pfn)
+{
+	if (phys_section[pfn_to_section(pfn)] =3D=3D INVALID_PHYS_SECTION)
+		return 0;
+	else
+		return 1;
+}
+
+extern void setup_memsections(void);
+extern void alloc_memsections(unsigned long start_pfn, unsigned long =
start_phys_pfn, unsigned long size);
+extern void alloc_memmap(struct page *page, unsigned long start_pfn, =
unsigned long size);
+extern void memmap_init(unsigned long size, int nid, unsigned long zone, =
unsigned long start_pfn);
+
+extern struct page *pfn_to_page(unsigned long pfn);
+extern unsigned long page_to_pfn(struct page *page);
+
+#endif /* __LINUX_NONLINEAR_H_ */
--- 2.6.5-rc2-mm1/./include/asm-i386/processor.h	2004-03-23 =
12:38:19.000000000 -0600
+++ 2.6.5-rc2-mm1-nonlinear/./include/asm-i386/processor.h	2004-03-23 =
12:38:58.000000000 -0600
@@ -179,7 +179,7 @@ static inline unsigned int cpuid_edx(uns
 }
=20
 #define load_cr3(pgdir) \
-	asm volatile("movl %0,%%cr3": :"r" (__pa(pgdir)))
+	asm volatile("movl %0,%%cr3": :"r" (__boot_pa(pgdir)))
=20
=20
 /*
--- 2.6.5-rc2-mm1/./include/asm-i386/page.h	2004-03-23 12:38:19.000000000 =
-0600
+++ 2.6.5-rc2-mm1-nonlinear/./include/asm-i386/page.h	2004-03-23 =
12:38:58.000000000 -0600
@@ -130,14 +130,21 @@ static __inline__ int get_order(unsigned
 #define VMALLOC_RESERVE		((unsigned long)__VMALLOC_RESERVE)
 #define __MAXMEM		(-__PAGE_OFFSET-__VMALLOC_RESERVE)
 #define MAXMEM			((unsigned long)(-PAGE_OFFSET-VMALLOC_RESERVE))
+#ifdef CONFIG_NONLINEAR
+#define __boot_pa(x)		((unsigned long)(x)-PAGE_OFFSET)
+#define __boot_va(x)		((void *)((unsigned long)(x)+PAGE_OFFSET))
+#else
 #define __pa(x)			((unsigned long)(x)-PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
-#define pfn_to_kaddr(pfn)      __va((pfn) << PAGE_SHIFT)
+#define	__boot_pa(x)		__pa(x)
+#define	__boot_va(x)		__va(x)
 #ifndef CONFIG_DISCONTIGMEM
 #define pfn_to_page(pfn)	(mem_map + (pfn))
 #define page_to_pfn(page)	((unsigned long)((page) - mem_map))
 #define pfn_valid(pfn)		((pfn) < max_mapnr)
 #endif /* !CONFIG_DISCONTIGMEM */
+#endif
+#define pfn_to_kaddr(pfn)      __va((pfn) << PAGE_SHIFT)
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
=20
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
@@ -145,6 +152,12 @@ static __inline__ int get_order(unsigned
 #define VM_DATA_DEFAULT_FLAGS	(VM_READ | VM_WRITE | VM_EXEC | \
 				 VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
=20
+#ifdef CONFIG_NONLINEAR
+#ifndef __ASSEMBLY__
+#include <linux/nonlinear.h>
+#endif
+#endif
+
 #endif /* __KERNEL__ */
=20
 #endif /* _I386_PAGE_H */
--- 2.6.5-rc2-mm1/./include/asm-i386/io.h	2004-03-19 18:12:00.000000000 =
-0600
+++ 2.6.5-rc2-mm1-nonlinear/./include/asm-i386/io.h	2004-03-23 =
12:38:58.000000000 -0600
@@ -60,7 +60,7 @@
 =20
 static inline unsigned long virt_to_phys(volatile void * address)
 {
-	return __pa(address);
+	return __pa((unsigned long)address);
 }
=20
 /**
@@ -78,7 +78,7 @@ static inline unsigned long virt_to_phys
=20
 static inline void * phys_to_virt(unsigned long address)
 {
-	return __va(address);
+	return (void *)__va((unsigned long)address);
 }
=20
 /*
--- 2.6.5-rc2-mm1/./include/asm-i386/nonlinear.h	1969-12-31 =
18:00:00.000000000 -0600
+++ 2.6.5-rc2-mm1-nonlinear/./include/asm-i386/nonlinear.h	2004-03-23 =
12:38:58.000000000 -0600
@@ -0,0 +1,14 @@
+#ifndef __I386_NONLINEAR_H_
+#define __I386_NONLINEAR_H_
+
+#define SECTION_SHIFT		27	/* Size of section - 128 Mbytes */
+#ifdef CONFIG_X86_PAE
+#define	MAX_MEM_SHIFT		36	/* Number of sections to allocate */
+#define	MAX_PHYS_SHIFT		36	/* Max phys memory in sections */
+#else
+#define	MAX_MEM_SHIFT		32
+#define	MAX_PHYS_SHIFT		32
+#endif
+
+
+#endif /* __I386_NONLINEAR_H_ */
--- 2.6.5-rc2-mm1/./mm/page_alloc.c	2004-03-23 12:38:19.000000000 -0600
+++ 2.6.5-rc2-mm1-nonlinear/./mm/page_alloc.c	2004-03-23 12:49:07.000000000 =
-0600
@@ -168,7 +168,7 @@ static void destroy_compound_page(struct
  * -- wli
  */
=20
-static inline void __free_pages_bulk (struct page *page, struct page =
*base,
+static inline void __free_pages_bulk (struct page *page, unsigned long =
base,
 		struct zone *zone, struct free_area *area, unsigned long mask,
 		unsigned int order)
 {
@@ -176,7 +176,7 @@ static inline void __free_pages_bulk (st
=20
 	if (order)
 		destroy_compound_page(page, order);
-	page_idx =3D page - base;
+	page_idx =3D page_to_pfn(page) - base;
 	if (page_idx & ~mask)
 		BUG();
 	index =3D page_idx >> (1 + order);
@@ -196,8 +196,8 @@ static inline void __free_pages_bulk (st
 		 * This code is taking advantage of the identity:
 		 * 	-mask =3D 1+~mask
 		 */
-		buddy1 =3D base + (page_idx ^ -mask);
-		buddy2 =3D base + page_idx;
+		buddy1 =3D pfn_to_page(base + (page_idx ^ -mask));
+		buddy2 =3D pfn_to_page(base + page_idx);
 		BUG_ON(bad_range(zone, buddy1));
 		BUG_ON(bad_range(zone, buddy2));
 		list_del(&buddy1->lru);
@@ -206,7 +206,7 @@ static inline void __free_pages_bulk (st
 		index >>=3D 1;
 		page_idx &=3D mask;
 	}
-	list_add(&(base + page_idx)->lru, &area->free_list);
+	list_add(&(pfn_to_page(base + page_idx))->lru, &area->free_list);
 }
=20
 static inline void free_pages_check(const char *function, struct page =
*page)
@@ -242,13 +242,13 @@ static int
 free_pages_bulk(struct zone *zone, int count,
 		struct list_head *list, unsigned int order)
 {
-	unsigned long mask, flags;
+	unsigned long mask, flags, base;
 	struct free_area *area;
-	struct page *base, *page =3D NULL;
+	struct page *page =3D NULL;
 	int ret =3D 0;
=20
 	mask =3D (~0UL) << order;
-	base =3D zone->zone_mem_map;
+	base =3D zone->zone_start_pfn;
 	area =3D zone->free_area + order;
 	spin_lock_irqsave(&zone->lock, flags);
 	zone->all_unreclaimable =3D 0;
@@ -356,7 +356,7 @@ static struct page *__rmqueue(struct zon
=20
 		page =3D list_entry(area->free_list.next, struct page, lru);
 		list_del(&page->lru);
-		index =3D page - zone->zone_mem_map;
+		index =3D page_to_pfn(page) - zone->zone_start_pfn;
 		if (current_order !=3D MAX_ORDER-1)
 			MARK_USED(index, current_order, area);
 		zone->free_pages -=3D 1UL << order;
@@ -1355,11 +1355,12 @@ static void __init calculate_zone_totalp
  * up by free_all_bootmem() once the early boot process is
  * done. Non-atomic initialization, single-pass.
  */
-void __init memmap_init_zone(struct page *start, unsigned long size, int =
nid,
-		unsigned long zone, unsigned long start_pfn)
+void memmap_init_zone(unsigned long size, int nid,
+		      unsigned long zone, unsigned long start_pfn)
 {
-	struct page *page;
+	struct page *page, *start;
=20
+	start =3D pfn_to_page(start_pfn);
 	for (page =3D start; page < (start + size); page++) {
 		set_page_zone(page, NODEZONE(nid, zone));
 		set_page_count(page, 0);
@@ -1375,8 +1376,8 @@ void __init memmap_init_zone(struct page
 }
=20
 #ifndef __HAVE_ARCH_MEMMAP_INIT
-#define memmap_init(start, size, nid, zone, start_pfn) \
-	memmap_init_zone((start), (size), (nid), (zone), (start_pfn))
+#define memmap_init(size, nid, zone, start_pfn) \
+	memmap_init_zone((size), (nid), (zone), (start_pfn))
 #endif
=20
 /*
@@ -1391,7 +1392,6 @@ static void __init free_area_init_core(s
 	unsigned long i, j;
 	const unsigned long zone_required_alignment =3D 1UL << (MAX_ORDER-1);
 	int cpu, nid =3D pgdat->node_id;
-	struct page *lmem_map =3D pgdat->node_mem_map;
 	unsigned long zone_start_pfn =3D pgdat->node_start_pfn;
=20
 	pgdat->nr_zones =3D 0;
@@ -1475,16 +1475,14 @@ static void __init free_area_init_core(s
=20
 		pgdat->nr_zones =3D j+1;
=20
-		zone->zone_mem_map =3D lmem_map;
 		zone->zone_start_pfn =3D zone_start_pfn;
=20
 		if ((zone_start_pfn) & (zone_required_alignment-1))
 			printk("BUG: wrong zone alignment, it will crash\n");
=20
-		memmap_init(lmem_map, size, nid, j, zone_start_pfn);
+		memmap_init(size, nid, j, zone_start_pfn);
=20
 		zone_start_pfn +=3D size;
-		lmem_map +=3D size;
=20
 		for (i =3D 0; ; i++) {
 			unsigned long bitmap_size;
@@ -1527,19 +1525,12 @@ static void __init free_area_init_core(s
 }
=20
 void __init free_area_init_node(int nid, struct pglist_data *pgdat,
-		struct page *node_mem_map, unsigned long *zones_size,
+		unsigned long *zones_size,
 		unsigned long node_start_pfn, unsigned long *zholes_size)
 {
-	unsigned long size;
-
 	pgdat->node_id =3D nid;
 	pgdat->node_start_pfn =3D node_start_pfn;
 	calculate_zone_totalpages(pgdat, zones_size, zholes_size);
-	if (!node_mem_map) {
-		size =3D (pgdat->node_spanned_pages + 1) * sizeof(struct page);
-		node_mem_map =3D alloc_bootmem_node(pgdat, size);
-	}
-	pgdat->node_mem_map =3D node_mem_map;
=20
 	free_area_init_core(pgdat, zones_size, zholes_size);
 }
@@ -1552,9 +1543,9 @@ EXPORT_SYMBOL(contig_page_data);
=20
 void __init free_area_init(unsigned long *zones_size)
 {
-	free_area_init_node(0, &contig_page_data, NULL, zones_size,
+	free_area_init_node(0, &contig_page_data, zones_size,
 			__pa(PAGE_OFFSET) >> PAGE_SHIFT, NULL);
-	mem_map =3D contig_page_data.node_mem_map;
+
 }
 #endif
=20
--- 2.6.5-rc2-mm1/./mm/Makefile	2004-03-23 12:38:19.000000000 -0600
+++ 2.6.5-rc2-mm1-nonlinear/./mm/Makefile	2004-03-23 12:50:19.000000000 =
-0600
@@ -13,3 +13,4 @@ obj-y			:=3D bootmem.o filemap.o mempool.o
=20
 obj-$(CONFIG_SWAP)	+=3D page_io.o swap_state.o swapfile.o
 obj-$(CONFIG_X86_4G)	+=3D usercopy.o
+obj-$(CONFIG_NONLINEAR) +=3D nonlinear.o
--- 2.6.5-rc2-mm1/./mm/nonlinear.c	1969-12-31 18:00:00.000000000 -0600
+++ 2.6.5-rc2-mm1-nonlinear/./mm/nonlinear.c	2004-03-23 12:38:58.000000000 =
-0600
@@ -0,0 +1,122 @@
+/*
+ * Written by: Dave McCracken <dmccr@us.ibm.com>, IBM Corporation
+ *
+ * Copyright (C) 2004, IBM Corp.
+ *
+ * All rights reserved.         =20
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ * NON INFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/mm.h>
+
+struct mem_section mem_section[NR_SECTIONS];
+unsigned short phys_section[NR_PHYS_SECTIONS];
+
+void
+setup_memsections(void)
+{
+	int	index;
+	struct mem_section *ms;
+	unsigned short *ps;
+
+	for (index =3D 0, ms =3D mem_section; index < NR_SECTIONS; index++, ms++) =
{
+		ms->phys_section =3D INVALID_SECTION;
+		ms->mem_map =3D NULL;
+	}
+	for (index =3D 0, ps =3D phys_section; index < NR_PHYS_SECTIONS; index++, =
ps++) {
+		*ps =3D INVALID_PHYS_SECTION;
+	}
+}
+
+void
+alloc_memsections(unsigned long start_pfn,
+		  unsigned long start_phys_pfn,
+		  unsigned long pfn_count)
+{
+	unsigned int index, limit;
+	unsigned int physid;
+	unsigned int sect_count;
+	unsigned short sect_index;
+	struct mem_section *ms;
+	unsigned short *ps;
+	
+	sect_count =3D pfn_to_section_roundup(pfn_count);
+	sect_index =3D index =3D pfn_to_section(start_pfn);
+	limit =3D index + sect_count;
+	ms =3D &mem_section[index];
+	physid =3D pfn_to_section(start_phys_pfn);
+	for (; index < limit; index++, ms++, physid++) {
+		ms->phys_section =3D physid;
+	}
+
+	index =3D pfn_to_section(start_phys_pfn);
+	limit =3D index + sect_count;
+	for (ps =3D &phys_section[index]; index < limit; index++, ps++, =
sect_index++) {
+		*ps =3D sect_index;
+	}
+}
+
+void
+alloc_memmap(struct page *page, unsigned long start_pfn, unsigned long =
size)
+{
+	unsigned int index, limit;
+	struct mem_section *ms;
+
+	size =3D pfn_to_section_roundup(size);
+	index =3D pfn_to_section(start_pfn);
+	limit =3D index + size;
+	ms =3D &mem_section[index];
+	for (; index < limit; index++, ms++, page +=3D PAGES_PER_SECTION) {
+		ms->mem_map =3D page;
+	}
+}
+
+void
+memmap_init(unsigned long num_pages, int nid,
+	    unsigned long zone, unsigned long start_pfn)
+{
+	unsigned long offset;
+
+	offset =3D section_offset_pfn(start_pfn);
+	while (num_pages) {
+		unsigned long npages;
+
+		npages =3D num_pages - offset;
+		if (npages > PAGES_PER_SECTION)
+		    npages =3D PAGES_PER_SECTION;
+		memmap_init_zone(npages, nid, zone, start_pfn);
+		start_pfn +=3D npages;
+		num_pages -=3D npages;
+		offset =3D 0;
+	}
+}
+
+struct page *
+pfn_to_page(unsigned long pfn)
+{
+	return =
&mem_section[phys_section[pfn_to_section(pfn)]].mem_map[section_offset_pfn(p=
fn)];
+}
+
+unsigned long
+page_to_pfn(struct page *page)
+{
+	return section_to_pfn(mem_section[page->section].phys_section) +
+		(page - mem_section[page->section].mem_map);
+}
+

--==========1896969384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
