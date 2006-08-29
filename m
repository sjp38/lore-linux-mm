Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TKJcns005556
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:38 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TKJc0Z268072
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 14:19:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TKJcp7028679
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 14:19:38 -0600
Subject: [RFC][PATCH 04/10] replace _ALIGN()
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 29 Aug 2006 13:19:37 -0700
References: <20060829201934.47E63D1F@localhost.localdomain>
In-Reply-To: <20060829201934.47E63D1F@localhost.localdomain>
Message-Id: <20060829201937.FD4B319C@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Use ALIGN() in place of _ALIGN(), mostly on ppc.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 threadalloc-dave/include/asm-ppc/bootinfo.h                   |    2 -
 threadalloc-dave/arch/powerpc/kernel/prom.c                   |   20 +++++-----
 threadalloc-dave/arch/powerpc/kernel/prom_init.c              |    8 ++--
 threadalloc-dave/arch/powerpc/mm/44x_mmu.c                    |    2 -
 threadalloc-dave/arch/powerpc/platforms/powermac/bootx_init.c |    4 +-
 threadalloc-dave/arch/ppc/boot/simple/misc-embedded.c         |    4 +-
 threadalloc-dave/arch/ppc/boot/simple/misc.c                  |    2 -
 threadalloc-dave/arch/ppc/kernel/setup.c                      |    4 +-
 threadalloc-dave/arch/ppc/mm/44x_mmu.c                        |    2 -
 9 files changed, 24 insertions(+), 24 deletions(-)

diff -puN include/asm-ppc/bootinfo.h~replace-_ALIGN include/asm-ppc/bootinfo.h
--- threadalloc/include/asm-ppc/bootinfo.h~replace-_ALIGN	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/include/asm-ppc/bootinfo.h	2006-08-29 13:14:52.000000000 -0700
@@ -41,7 +41,7 @@ static inline struct bi_record *
 bootinfo_addr(unsigned long offset)
 {
 
-	return (struct bi_record *)_ALIGN((offset) + (1 << 20) - 1,
+	return (struct bi_record *)ALIGN((offset) + (1 << 20) - 1,
 					  (1 << 20));
 }
 #endif /* CONFIG_APUS */
diff -puN arch/powerpc/kernel/prom.c~replace-_ALIGN arch/powerpc/kernel/prom.c
--- threadalloc/arch/powerpc/kernel/prom.c~replace-_ALIGN	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/arch/powerpc/kernel/prom.c	2006-08-29 13:14:52.000000000 -0700
@@ -125,9 +125,9 @@ int __init of_scan_flat_dt(int (*it)(uns
 			u32 sz = *((u32 *)p);
 			p += 8;
 			if (initial_boot_params->version < 0x10)
-				p = _ALIGN(p, sz >= 8 ? 8 : 4);
+				p = ALIGN(p, sz >= 8 ? 8 : 4);
 			p += sz;
-			p = _ALIGN(p, 4);
+			p = ALIGN(p, 4);
 			continue;
 		}
 		if (tag != OF_DT_BEGIN_NODE) {
@@ -137,7 +137,7 @@ int __init of_scan_flat_dt(int (*it)(uns
 		}
 		depth++;
 		pathp = (char *)p;
-		p = _ALIGN(p + strlen(pathp) + 1, 4);
+		p = ALIGN(p + strlen(pathp) + 1, 4);
 		if ((*pathp) == '/') {
 			char *lp, *np;
 			for (lp = NULL, np = pathp; *np; np++)
@@ -163,7 +163,7 @@ unsigned long __init of_get_flat_dt_root
 		p += 4;
 	BUG_ON (*((u32 *)p) != OF_DT_BEGIN_NODE);
 	p += 4;
-	return _ALIGN(p + strlen((char *)p) + 1, 4);
+	return ALIGN(p + strlen((char *)p) + 1, 4);
 }
 
 /**
@@ -190,7 +190,7 @@ void* __init of_get_flat_dt_prop(unsigne
 		noff = *((u32 *)(p + 4));
 		p += 8;
 		if (initial_boot_params->version < 0x10)
-			p = _ALIGN(p, sz >= 8 ? 8 : 4);
+			p = ALIGN(p, sz >= 8 ? 8 : 4);
 
 		nstr = find_flat_dt_string(noff);
 		if (nstr == NULL) {
@@ -204,7 +204,7 @@ void* __init of_get_flat_dt_prop(unsigne
 			return (void *)p;
 		}
 		p += sz;
-		p = _ALIGN(p, 4);
+		p = ALIGN(p, 4);
 	} while(1);
 }
 
@@ -232,7 +232,7 @@ static void *__init unflatten_dt_alloc(u
 {
 	void *res;
 
-	*mem = _ALIGN(*mem, align);
+	*mem = ALIGN(*mem, align);
 	res = (void *)*mem;
 	*mem += size;
 
@@ -261,7 +261,7 @@ static unsigned long __init unflatten_dt
 	*p += 4;
 	pathp = (char *)*p;
 	l = allocl = strlen(pathp) + 1;
-	*p = _ALIGN(*p + l, 4);
+	*p = ALIGN(*p + l, 4);
 
 	/* version 0x10 has a more compact unit name here instead of the full
 	 * path. we accumulate the full path size using "fpsize", we'll rebuild
@@ -340,7 +340,7 @@ static unsigned long __init unflatten_dt
 		noff = *((u32 *)((*p) + 4));
 		*p += 8;
 		if (initial_boot_params->version < 0x10)
-			*p = _ALIGN(*p, sz >= 8 ? 8 : 4);
+			*p = ALIGN(*p, sz >= 8 ? 8 : 4);
 
 		pname = find_flat_dt_string(noff);
 		if (pname == NULL) {
@@ -366,7 +366,7 @@ static unsigned long __init unflatten_dt
 			*prev_pp = pp;
 			prev_pp = &pp->next;
 		}
-		*p = _ALIGN((*p) + sz, 4);
+		*p = ALIGN((*p) + sz, 4);
 	}
 	/* with version 0x10 we may not have the name property, recreate
 	 * it here from the unit name if absent
diff -puN arch/powerpc/kernel/prom_init.c~replace-_ALIGN arch/powerpc/kernel/prom_init.c
--- threadalloc/arch/powerpc/kernel/prom_init.c~replace-_ALIGN	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/arch/powerpc/kernel/prom_init.c	2006-08-29 13:14:52.000000000 -0700
@@ -1679,7 +1679,7 @@ static void __init *make_room(unsigned l
 {
 	void *ret;
 
-	*mem_start = _ALIGN(*mem_start, align);
+	*mem_start = ALIGN(*mem_start, align);
 	while ((*mem_start + needed) > *mem_end) {
 		unsigned long room, chunk;
 
@@ -1811,7 +1811,7 @@ static void __init scan_dt_build_struct(
 				*lp++ = *p;
 		}
 		*lp = 0;
-		*mem_start = _ALIGN((unsigned long)lp + 1, 4);
+		*mem_start = ALIGN((unsigned long)lp + 1, 4);
 	}
 
 	/* get it again for debugging */
@@ -1864,7 +1864,7 @@ static void __init scan_dt_build_struct(
 		/* push property content */
 		valp = make_room(mem_start, mem_end, l, 4);
 		call_prom("getprop", 4, 1, node, RELOC(pname), valp, l);
-		*mem_start = _ALIGN(*mem_start, 4);
+		*mem_start = ALIGN(*mem_start, 4);
 	}
 
 	/* Add a "linux,phandle" property. */
@@ -1920,7 +1920,7 @@ static void __init flatten_device_tree(v
 		prom_panic ("couldn't get device tree root\n");
 
 	/* Build header and make room for mem rsv map */ 
-	mem_start = _ALIGN(mem_start, 4);
+	mem_start = ALIGN(mem_start, 4);
 	hdr = make_room(&mem_start, &mem_end,
 			sizeof(struct boot_param_header), 4);
 	RELOC(dt_header_start) = (unsigned long)hdr;
diff -puN arch/powerpc/mm/44x_mmu.c~replace-_ALIGN arch/powerpc/mm/44x_mmu.c
--- threadalloc/arch/powerpc/mm/44x_mmu.c~replace-_ALIGN	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/arch/powerpc/mm/44x_mmu.c	2006-08-29 13:14:52.000000000 -0700
@@ -103,7 +103,7 @@ unsigned long __init mmu_mapin_ram(void)
 
 	/* Determine number of entries necessary to cover lowmem */
 	pinned_tlbs = (unsigned int)
-		(_ALIGN(total_lowmem, PPC44x_PIN_SIZE) >> PPC44x_PIN_SHIFT);
+		(ALIGN(total_lowmem, PPC44x_PIN_SIZE) >> PPC44x_PIN_SHIFT);
 
 	/* Write upper watermark to save location */
 	tlb_44x_hwater = PPC44x_LOW_SLOT - pinned_tlbs;
diff -puN arch/powerpc/platforms/powermac/bootx_init.c~replace-_ALIGN arch/powerpc/platforms/powermac/bootx_init.c
--- threadalloc/arch/powerpc/platforms/powermac/bootx_init.c~replace-_ALIGN	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/arch/powerpc/platforms/powermac/bootx_init.c	2006-08-29 13:14:52.000000000 -0700
@@ -389,7 +389,7 @@ static unsigned long __init bootx_flatte
 	hdr->dt_strings_size = bootx_dt_strend - bootx_dt_strbase;
 
 	/* Build structure */
-	mem_end = _ALIGN(mem_end, 16);
+	mem_end = ALIGN(mem_end, 16);
 	DBG("Building device tree structure at: %x\n", mem_end);
 	hdr->off_dt_struct = mem_end - mem_start;
 	bootx_scan_dt_build_struct(base, 4, &mem_end);
@@ -407,7 +407,7 @@ static unsigned long __init bootx_flatte
 	 * also bump mem_reserve_cnt to cause further reservations to
 	 * fail since it's too late.
 	 */
-	mem_end = _ALIGN(mem_end, PAGE_SIZE);
+	mem_end = ALIGN(mem_end, PAGE_SIZE);
 	DBG("End of boot params: %x\n", mem_end);
 	rsvmap[0] = mem_start;
 	rsvmap[1] = mem_end;
diff -puN arch/ppc/boot/simple/misc-embedded.c~replace-_ALIGN arch/ppc/boot/simple/misc-embedded.c
--- threadalloc/arch/ppc/boot/simple/misc-embedded.c~replace-_ALIGN	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/arch/ppc/boot/simple/misc-embedded.c	2006-08-29 13:14:52.000000000 -0700
@@ -218,7 +218,7 @@ load_kernel(unsigned long load_addr, int
 	{
 		struct bi_record *rec;
 		unsigned long initrd_loc = 0;
-		unsigned long rec_loc = _ALIGN((unsigned long)(zimage_size) +
+		unsigned long rec_loc = ALIGN((unsigned long)(zimage_size) +
 				(1 << 20) - 1, (1 << 20));
 		rec = (struct bi_record *)rec_loc;
 
@@ -232,7 +232,7 @@ load_kernel(unsigned long load_addr, int
 			if ((rec_loc > initrd_loc) &&
 					((initrd_loc + initrd_size)
 					 > rec_loc)) {
-				initrd_loc = _ALIGN((unsigned long)(zimage_size)
+				initrd_loc = ALIGN((unsigned long)(zimage_size)
 						+ (2 << 20) - 1, (2 << 20));
 			 	memmove((void *)initrd_loc, &__ramdisk_begin,
 					 initrd_size);
diff -puN arch/ppc/boot/simple/misc.c~replace-_ALIGN arch/ppc/boot/simple/misc.c
--- threadalloc/arch/ppc/boot/simple/misc.c~replace-_ALIGN	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/arch/ppc/boot/simple/misc.c	2006-08-29 13:14:52.000000000 -0700
@@ -245,7 +245,7 @@ decompress_kernel(unsigned long load_add
 		 * boundary. */
 		if ((rec_loc > initrd_loc) &&
 				((initrd_loc + initrd_size) > rec_loc)) {
-			initrd_loc = _ALIGN((unsigned long)(zimage_size)
+			initrd_loc = ALIGN((unsigned long)(zimage_size)
 					+ (2 << 20) - 1, (2 << 20));
 		 	memmove((void *)initrd_loc, &__ramdisk_begin,
 				 initrd_size);
diff -puN arch/ppc/kernel/setup.c~replace-_ALIGN arch/ppc/kernel/setup.c
--- threadalloc/arch/ppc/kernel/setup.c~replace-_ALIGN	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/arch/ppc/kernel/setup.c	2006-08-29 13:14:52.000000000 -0700
@@ -341,14 +341,14 @@ struct bi_record *find_bootinfo(void)
 {
 	struct bi_record *rec;
 
-	rec = (struct bi_record *)_ALIGN((ulong)__bss_start+(1<<20)-1,(1<<20));
+	rec = (struct bi_record *)ALIGN((ulong)__bss_start+(1<<20)-1,(1<<20));
 	if ( rec->tag != BI_FIRST ) {
 		/*
 		 * This 0x10000 offset is a terrible hack but it will go away when
 		 * we have the bootloader handle all the relocation and
 		 * prom calls -- Cort
 		 */
-		rec = (struct bi_record *)_ALIGN((ulong)__bss_start+0x10000+(1<<20)-1,(1<<20));
+		rec = (struct bi_record *)ALIGN((ulong)__bss_start+0x10000+(1<<20)-1,(1<<20));
 		if ( rec->tag != BI_FIRST )
 			return NULL;
 	}
diff -puN arch/ppc/mm/44x_mmu.c~replace-_ALIGN arch/ppc/mm/44x_mmu.c
--- threadalloc/arch/ppc/mm/44x_mmu.c~replace-_ALIGN	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/arch/ppc/mm/44x_mmu.c	2006-08-29 13:14:52.000000000 -0700
@@ -103,7 +103,7 @@ unsigned long __init mmu_mapin_ram(void)
 
 	/* Determine number of entries necessary to cover lowmem */
 	pinned_tlbs = (unsigned int)
-		(_ALIGN(total_lowmem, PPC_PIN_SIZE) >> PPC44x_PIN_SHIFT);
+		(ALIGN(total_lowmem, PPC_PIN_SIZE) >> PPC44x_PIN_SHIFT);
 
 	/* Write upper watermark to save location */
 	tlb_44x_hwater = PPC44x_LOW_SLOT - pinned_tlbs;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
