Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id DAB2282F99
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 18:36:46 -0500 (EST)
Received: by mail-io0-f171.google.com with SMTP id o67so229127504iof.3
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 15:36:46 -0800 (PST)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id l12si3013557igf.97.2015.12.23.15.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 15:36:45 -0800 (PST)
From: Robert Elliott <elliott@hpe.com>
Subject: [PATCH] Documentation/kernel-parameters: update KMG units
Date: Wed, 23 Dec 2015 18:38:16 -0600
Message-Id: <1450917496-4023-1-git-send-email-elliott@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net, akpm@linux-foundation.org, mgorman@techsingularity.net, matt@codeblueprint.co.uk
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Robert Elliott <elliott@hpe.com>

Since commit e004f3c7780d ("lib/cmdline.c: add size unit t/p/e to
memparse") expanded memparse() to support T, P, and E units in addition
to K, M, and G, all the kernel parameters that use that function became
capable of more than [KMG] mentioned in kernel-parameters.txt.

Expand the introduction to the units and change all existing [KMG]
descriptions to [KMGTPE].  cma only had [MG]; reservelow only had [K].

Add [KMGTPE] for hugepagesz and memory_corruption_check_size, which also
use memparse().

Update two source code files with comments mentioning [KMG].

Signed-off-by: Robert Elliott <elliott@hpe.com>
---
 Documentation/kernel-parameters.txt | 101 +++++++++++++++++++-----------------
 kernel/crash_dump.c                 |   2 +-
 mm/page_alloc.c                     |   2 +-
 3 files changed, 56 insertions(+), 49 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 742f69d..3f77290 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -159,10 +159,16 @@ a fixed number of characters. This limit depends on the architecture
 and is between 256 and 4096 characters. It is defined in the file
 ./include/asm/setup.h as COMMAND_LINE_SIZE.
 
-Finally, the [KMG] suffix is commonly described after a number of kernel
-parameter values. These 'K', 'M', and 'G' letters represent the _binary_
-multipliers 'Kilo', 'Mega', and 'Giga', equalling 2^10, 2^20, and 2^30
-bytes respectively. Such letter suffixes can also be entirely omitted.
+Finally, the [KMGTPE] suffix is commonly described after a number
+of kernel parameter values. These letters represent the _binary_
+multipliers:
+	'K' = Ki (2^10)
+	'M' = Mi (2^20)
+	'G' = Gi (2^30)
+	'T' = Ti (2^40)
+	'P' = Pi (2^50)
+	'E' = Ei (2^60)
+Such letter suffixes can also be entirely omitted.
 
 
 	acpi=		[HW,ACPI,X86,ARM64]
@@ -663,8 +669,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			Also note the kernel might malfunction if you disable
 			some critical bits.
 
-	cma=nn[MG]@[start[MG][-end[MG]]]
-			[ARM,X86,KNL]
+	cma=nn[KMGTPE]@[start[KMGTPE][-end[KMGTPE]]] [ARM,X86,KNL]
 			Sets the size of kernel global memory area for
 			contiguous memory allocations and optionally the
 			placement constraint by the physical address range of
@@ -679,7 +684,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			a hypervisor.
 			Default: yes
 
-	coherent_pool=nn[KMG]	[ARM,KNL]
+	coherent_pool=nn[KMGTPE]	[ARM,KNL]
 			Sets the size of memory pool for coherent, atomic dma
 			allocations, by default set to 256K.
 
@@ -763,7 +768,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			Format:
 			<first_slot>,<last_slot>,<port>,<enum_bit>[,<debug>]
 
-	crashkernel=size[KMG][@offset[KMG]]
+	crashkernel=size[KMGTPE][@offset[KMGTPE]]
 			[KNL] Using kexec, Linux can switch to a 'crash kernel'
 			upon panic. This parameter reserves the physical
 			memory region [offset, offset + size] for that kernel
@@ -775,18 +780,18 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			[KNL] Same as above, but depends on the memory
 			in the running system. The syntax of range is
 			start-[end] where start and end are both
-			a memory unit (amount[KMG]). See also
+			a memory unit (amount[KMGTPE]). See also
 			Documentation/kdump/kdump.txt for an example.
 
-	crashkernel=size[KMG],high
-			[KNL, x86_64] range could be above 4G. Allow kernel
+	crashkernel=size[KMGTPE],high [KNL, x86_64]
+			range could be above 4G. Allow kernel
 			to allocate physical memory region from top, so could
 			be above 4G if system have more than 4G ram installed.
 			Otherwise memory region will be allocated below 4G, if
 			available.
 			It will be ignored if crashkernel=X is specified.
-	crashkernel=size[KMG],low
-			[KNL, x86_64] range under 4G. When crashkernel=X,high
+	crashkernel=size[KMGTPE],low [KNL, x86_64]
+			range under 4G. When crashkernel=X,high
 			is passed, kernel could allocate physical memory region
 			above 4G, that cause second kernel crash on system
 			that require some amount of low memory, e.g. swiotlb
@@ -1111,7 +1116,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			you are really sure that your UEFI does sane gc and
 			fulfills the spec otherwise your board may brick.
 
-	efi_fake_mem=	nn[KMG]@ss[KMG]:aa[,nn[KMG]@ss[KMG]:aa,..] [EFI; X86]
+	efi_fake_mem=	[EFI; X86]
+			Format:
+			  nn[KMGTPE]@ss[KMGTPE]:aa[,nn[KMGTPE]@ss[KMGTPE]:aa,..]
 			Add arbitrary attribute to specific memory range by
 			updating original EFI memory map.
 			Region of memory which aa attribute is added to is
@@ -1138,7 +1145,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			See Documentation/block/cfq-iosched.txt and
 			Documentation/block/deadline-iosched.txt for details.
 
-	elfcorehdr=[size[KMG]@]offset[KMG] [IA64,PPC,SH,X86,S390]
+	elfcorehdr=[size[KMGTPE]@]offset[KMGTPE] [IA64,PPC,SH,X86,S390]
 			Specifies physical address of start of kernel core
 			image elf header and optionally the size. Generally
 			kexec loader will pass this option to capture kernel.
@@ -1298,9 +1305,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			corresponding firmware-first mode error processing
 			logic will be disabled.
 
-	highmem=nn[KMG]	[KNL,BOOT] forces the highmem zone to have an exact
-			size of <nn>. This works even on boxes that have no
-			highmem otherwise. This also works to reduce highmem
+	highmem=nn[KMGTPE]	[KNL,BOOT] forces the highmem zone to have an
+			exact size of <nn>. This works even on boxes that have
+			no highmem otherwise. This also works to reduce highmem
 			size on bigger boxes.
 
 	highres=	[KNL] Enable/disable high resolution timer mode.
@@ -1324,7 +1331,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			registers.  Default set by CONFIG_HPET_MMAP_DEFAULT.
 
 	hugepages=	[HW,X86-32,IA-64] HugeTLB pages to allocate at boot.
-	hugepagesz=	[HW,IA-64,PPC,X86-64] The size of the HugeTLB pages.
+	hugepagesz=nn[KMGTPE]	[HW,IA-64,PPC,X86-64,ARM64] The size of the
+			HugeTLB pages.
 			On x86-64 and powerpc, this option can be specified
 			multiple times interleaved with hugepages= to reserve
 			huge pages of different sizes. Valid pages sizes on
@@ -1692,7 +1700,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 
 	keepinitrd	[HW,ARM]
 
-	kernelcore=nn[KMG]	[KNL,X86,IA-64,PPC] This parameter
+	kernelcore=nn[KMGTPE]	[KNL,X86,IA-64,PPC] This parameter
 			specifies the amount of memory usable by the kernel
 			for non-movable allocations.  The requested amount is
 			spread evenly throughout all nodes in the system. The
@@ -1947,7 +1955,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			6 (KERN_INFO)		informational
 			7 (KERN_DEBUG)		debug-level messages
 
-	log_buf_len=n[KMG]	Sets the size of the printk ring buffer,
+	log_buf_len=nn[KMGTPE]	Sets the size of the printk ring buffer,
 			in bytes.  n must be a power of two and greater
 			than the minimal size. The minimal size is defined
 			by LOG_BUF_SHIFT kernel config parameter. There is
@@ -2002,7 +2010,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			 yeeloong laptop.
 			Example: machtype=lemote-yeeloong-2f-7inch
 
-	max_addr=nn[KMG]	[KNL,BOOT,ia64] All physical memory greater
+	max_addr=nn[KMGTPE]	[KNL,BOOT,ia64] All physical memory greater
 			than or equal to this physical address is ignored.
 
 	maxcpus=	[SMP] Maximum number of processors that	an SMP kernel
@@ -2029,7 +2037,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			Format: <first>,<last>
 			Specifies range of consoles to be captured by the MDA.
 
-	mem=nn[KMG]	[KNL,BOOT] Force usage of a specific amount of memory
+	mem=nn[KMGTPE]	[KNL,BOOT] Force usage of a specific amount of memory
 			Amount of memory to be used when the kernel is not able
 			to see the whole system memory or for test.
 			[X86] Work as limiting max address. Use together
@@ -2040,7 +2048,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	mem=nopentium	[BUGS=X86-32] Disable usage of 4MB pages for kernel
 			memory.
 
-	memchunk=nn[KMG]
+	memchunk=nn[KMGTPE]
 			[KNL,SH] Allow user to override the default size for
 			per-device physically contiguous DMA buffers.
 
@@ -2050,15 +2058,15 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			BIOS output or other requirements. See the memmap=nn@ss
 			option description.
 
-	memmap=nn[KMG]@ss[KMG]
+	memmap=nn[KMGTPE]@ss[KMGTPE]
 			[KNL] Force usage of a specific region of memory.
 			Region of memory to be used is from ss to ss+nn.
 
-	memmap=nn[KMG]#ss[KMG]
+	memmap=nn[KMGTPE]#ss[KMGTPE]
 			[KNL,ACPI] Mark specific memory as ACPI data.
 			Region of memory to be marked is from ss to ss+nn.
 
-	memmap=nn[KMG]$ss[KMG]
+	memmap=nn[KMGTPE]$ss[KMGTPE]
 			[KNL,ACPI] Mark specific memory as reserved.
 			Region of memory to be reserved is from ss to ss+nn.
 			Example: Exclude memory from 0x18690000-0x1869ffff
@@ -2066,7 +2074,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			         or
 			         memmap=0x10000$0x18690000
 
-	memmap=nn[KMG]!ss[KMG]
+	memmap=nn[KMGTPE]!ss[KMGTPE]
 			[KNL,X86] Mark specific memory as protected.
 			Region of memory to be used, from ss to ss+nn.
 			The memory region may be marked as e820 type 12 (0xc)
@@ -2084,7 +2092,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			affects the same memory, you can use memmap=
 			to prevent the kernel from using that memory.
 
-	memory_corruption_check_size=size [X86]
+	memory_corruption_check_size=nn[KMGTPE] [X86]
 			By default it checks for corruption in the low
 			64k, making this memory unavailable for normal
 			use.  Use this parameter to scan for
@@ -2119,7 +2127,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 
 	mga=		[HW,DRM]
 
-	min_addr=nn[KMG]	[KNL,BOOT,ia64] All physical memory below this
+	min_addr=nn[KMGTPE]	[KNL,BOOT,ia64] All physical memory below this
 			physical address is ignored.
 
 	mini2440=	[ARM,HW,KNL]
@@ -2168,7 +2176,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	mousedev.yres=	[MOUSE] Vertical screen resolution, used for devices
 			reporting absolute coordinates, such as tablets
 
-	movablecore=nn[KMG]	[KNL,X86,IA-64,PPC] This parameter
+	movablecore=nn[KMGTPE]	[KNL,X86,IA-64,PPC] This parameter
 			is similar to kernelcore except it specifies the
 			amount of memory used for migratable allocations.
 			If both kernelcore and movablecore is specified,
@@ -2213,11 +2221,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			[HW] Make the MicroTouch USB driver use raw coordinates
 			('y', default) or cooked coordinates ('n')
 
-	mtrr_chunk_size=nn[KMG] [X86]
+	mtrr_chunk_size=nn[KMGTPE] [X86]
 			used for mtrr cleanup. It is largest continuous chunk
 			that could hold holes aka. UC entries.
 
-	mtrr_gran_size=nn[KMG] [X86]
+	mtrr_gran_size=nn[KMGTPE] [X86]
 			Used for mtrr cleanup. It is granularity of mtrr block.
 			Default is 1.
 			Large value could prevent small alignment from
@@ -2842,10 +2850,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 				any pair of devices, possibly at the cost of
 				reduced performance.  This also guarantees
 				that hot-added devices will work.
-		cbiosize=nn[KMG]	The fixed amount of bus space which is
+		cbiosize=nn[KMGTPE]	The fixed amount of bus space which is
 				reserved for the CardBus bridge's IO window.
 				The default value is 256 bytes.
-		cbmemsize=nn[KMG]	The fixed amount of bus space which is
+		cbmemsize=nn[KMGTPE]	The fixed amount of bus space which is
 				reserved for the CardBus bridge's memory
 				window. The default value is 64 megabytes.
 		resource_alignment=
@@ -2863,10 +2871,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 				the default.
 				off: Turn ECRC off
 				on: Turn ECRC on.
-		hpiosize=nn[KMG]	The fixed amount of bus space which is
+		hpiosize=nn[KMGTPE]	The fixed amount of bus space which is
 				reserved for hotplug bridge's IO window.
 				Default size is 256 bytes.
-		hpmemsize=nn[KMG]	The fixed amount of bus space which is
+		hpmemsize=nn[KMGTPE]	The fixed amount of bus space which is
 				reserved for hotplug bridge's memory window.
 				Default size is 2 megabytes.
 		realloc=	Enable/disable reallocating PCI bridge resources
@@ -3354,12 +3362,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	reserve=	[KNL,BUGS] Force the kernel to ignore some iomem area
 
 	reservetop=	[X86-32]
-			Format: nn[KMG]
+			Format: nn[KMGTPE]
 			Reserves a hole at the top of the kernel virtual
 			address space.
 
 	reservelow=	[X86]
-			Format: nn[K]
+			Format: nn[KMGTPE]
 			Set the amount of memory to reserve for BIOS at
 			the bottom of the address space.
 
@@ -3423,7 +3431,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			Useful for devices that are detected asynchronously
 			(e.g. USB and MMC devices).
 
-	rproc_mem=nn[KMG][@address]
+	rproc_mem=nn[KMGTPE][@address]
 			[KNL,ARM,CMA] Remoteproc physical memory block.
 			Memory area to be used by remote processor image,
 			managed by CMA.
@@ -3760,7 +3768,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			This will guarantee that all the other pcrs
 			are saved.
 
-	trace_buf_size=nn[KMG]
+	trace_buf_size=nn[KMGTPE]
 			[FTRACE] will set tracing buffer size on each cpu.
 
 	trace_event=[event-list]
@@ -4004,10 +4012,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	virtio_mmio.device=
 			[VMMIO] Memory mapped virtio (platform) device.
 
-				<size>@<baseaddr>:<irq>[:<id>]
+				<size>[KMGTPE]@<baseaddr>:<irq>[:<id>]
 			where:
-				<size>     := size (can use standard suffixes
-						like K, M and G)
+				<size>     := size
 				<baseaddr> := physical base address
 				<irq>      := interrupt number (as passed to
 						request_irq())
@@ -4024,9 +4031,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			This is actually a boot loader parameter; the value is
 			passed to the kernel using a special protocol.
 
-	vmalloc=nn[KMG]	[KNL,BOOT] Forces the vmalloc area to have an exact
-			size of <nn>. This can be used to increase the
-			minimum size (128MB on x86). It can also be used to
+	vmalloc=nn[KMGTPE]	[KNL,BOOT] Forces the vmalloc area to have an
+			exact size of <nn>. This can be used to increase the
+			minimum size (128 MiB on x86). It can also be used to
 			decrease the size and leave more room for directly
 			mapped kernel RAM.
 
diff --git a/kernel/crash_dump.c b/kernel/crash_dump.c
index b64e238..b7984cf 100644
--- a/kernel/crash_dump.c
+++ b/kernel/crash_dump.c
@@ -29,7 +29,7 @@ unsigned long long elfcorehdr_size;
  * elfcorehdr= specifies the location of elf core header stored by the crashed
  * kernel. This option will be passed by kexec loader to the capture kernel.
  *
- * Syntax: elfcorehdr=[size[KMG]@]offset[KMG]
+ * Syntax: elfcorehdr=[size[KMGTPE]@]offset[KMGTPE]
  */
 static int __init setup_elfcorehdr(char *arg)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d666df..13cf824 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5500,7 +5500,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	}
 
 	/*
-	 * If movablecore=nn[KMG] was specified, calculate what size of
+	 * If movablecore=nn[KMGTPE] was specified, calculate what size of
 	 * kernelcore that corresponds so that memory usable for
 	 * any allocation type is evenly spread. If both kernelcore
 	 * and movablecore are specified, then the value of kernelcore
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
