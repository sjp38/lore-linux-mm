Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kB1E9B7K257988
	for <linux-mm@kvack.org>; Fri, 1 Dec 2006 14:09:11 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB1E9Ble2420976
	for <linux-mm@kvack.org>; Fri, 1 Dec 2006 14:09:11 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB1E9Bph008465
	for <linux-mm@kvack.org>; Fri, 1 Dec 2006 14:09:11 GMT
Date: Fri, 1 Dec 2006 15:07:33 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [patch/rfc 1/2] Memory detection fixes.
Message-ID: <20061201140733.GB8788@osiris.boeblingen.de.ibm.com>
References: <20061201140542.GA8788@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061201140542.GA8788@osiris.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Carsten Otte <cotte@de.ibm.com>
List-ID: <linux-mm.kvack.org>

[S390] Memory detection fixes.

VMALLOC_END on 31bit should be 0x8000000UL instead of 0x7fffffffL.
The page mask which is used to make sure memory_end is on 4MB/2MB
boundary is wrong and not needed. Therefore remove it.
Make sure a vmalloc area does also exist and work on (future)
machines with 4TB and more memory.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 arch/s390/kernel/head31.S  |    3 --
 arch/s390/kernel/head64.S  |    4 ---
 arch/s390/kernel/setup.c   |   49 +++++++++++++++++++++++++++++----------------
 include/asm-s390/pgtable.h |   15 +++++++++++--
 4 files changed, 44 insertions(+), 27 deletions(-)

Index: linux-2.6.19-rc6-mm2/arch/s390/kernel/head31.S
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/kernel/head31.S
+++ linux-2.6.19-rc6-mm2/arch/s390/kernel/head31.S
@@ -177,8 +177,6 @@ startup_continue:
 	st	%r0,4(%r3)		# store size of chunk
 	st	%r6,8(%r3)		# store type of chunk
 	la	%r3,12(%r3)
-	l	%r4,.Lmemsize-.LPG1(%r13)	 # address of variable memory_size
-	st	%r5,0(%r4)		# store last end to memory size
 	ahi	%r10,-1			# update chunk number
 .Lchkloop:
 	lr	%r6,%r7			# set access code to last cc
@@ -293,7 +291,6 @@ startup_continue:
 .Lpcmvpg:.long	0x00080000,0x80000000 + .Lchkmvpg
 .Lpcidte:.long	0x00080000,0x80000000 + .Lchkidte
 .Lpcdiag9c:.long 0x00080000,0x80000000 + .Lchkdiag9c
-.Lmemsize:.long memory_size
 .Lmchunk:.long	memory_chunk
 .Lmflags:.long	machine_flags
 .Lbss_bgn:  .long __bss_start
Index: linux-2.6.19-rc6-mm2/arch/s390/kernel/head64.S
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/kernel/head64.S
+++ linux-2.6.19-rc6-mm2/arch/s390/kernel/head64.S
@@ -81,8 +81,6 @@ startup_continue:
 	aghi	%r1,1			# size is one more than end
 	larl	%r2,memory_chunk
 	stg	%r1,8(%r2)		# store size of chunk
-	larl	%r2,memory_size
-	stg	%r1,0(%r2)		# set memory size
 	j	.Ldonemem
 
 .Lslowmemdetect:
@@ -188,8 +186,6 @@ startup_continue:
 	stg	%r0,8(%r3)		# store size of chunk
 	st	%r6,20(%r3)		# store type of chunk
 	la	%r3,24(%r3)
-	larl	%r8,memory_size
-	stg	%r5,0(%r8)		# store memory size
 	ahi	%r10,-1			# update chunk number
 .Lchkloop:
 	lr	%r6,%r7			# set access code to last cc
Index: linux-2.6.19-rc6-mm2/arch/s390/kernel/setup.c
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/kernel/setup.c
+++ linux-2.6.19-rc6-mm2/arch/s390/kernel/setup.c
@@ -62,7 +62,6 @@ EXPORT_SYMBOL_GPL(uaccess);
 unsigned int console_mode = 0;
 unsigned int console_devno = -1;
 unsigned int console_irq = -1;
-unsigned long memory_size = 0;
 unsigned long machine_flags = 0;
 
 struct mem_chunk memory_chunk[MEMORY_CHUNKS];
@@ -486,6 +485,37 @@ setup_resources(void)
 	}
 }
 
+static void __init setup_memory_end(void)
+{
+	unsigned long real_size, memory_size;
+	unsigned long max_mem, max_phys;
+	int i;
+
+	memory_size = real_size = 0;
+	max_phys = VMALLOC_END - VMALLOC_MIN_SIZE;
+	memory_end &= PAGE_MASK;
+
+	max_mem = memory_end ? min(max_phys, memory_end) : max_phys;
+
+	for (i = 0; i < MEMORY_CHUNKS; i++) {
+		struct mem_chunk *chunk = &memory_chunk[i];
+
+		real_size = max(real_size, chunk->addr + chunk->size);
+		if (chunk->addr >= max_mem) {
+			memset(chunk, 0, sizeof(*chunk));
+			continue;
+		}
+		if (chunk->addr + chunk->size > max_mem)
+			chunk->size = max_mem - chunk->addr;
+		memory_size = max(memory_size, chunk->addr + chunk->size);
+	}
+	if (!memory_end)
+		memory_end = memory_size;
+	if (real_size > memory_end)
+		printk("More memory detected than supported. Unused: %luk\n",
+		       (real_size - memory_end) >> 10);
+}
+
 static void __init
 setup_memory(void)
 {
@@ -642,8 +672,6 @@ setup_arch(char **cmdline_p)
 	init_mm.end_data = (unsigned long) &_edata;
 	init_mm.brk = (unsigned long) &_end;
 
-	memory_end = memory_size;
-
 	if (MACHINE_HAS_MVCOS)
 		memcpy(&uaccess, &uaccess_mvcos, sizeof(uaccess));
 	else
@@ -651,20 +679,7 @@ setup_arch(char **cmdline_p)
 
 	parse_early_param();
 
-#ifndef CONFIG_64BIT
-	memory_end &= ~0x400000UL;
-
-        /*
-         * We need some free virtual space to be able to do vmalloc.
-         * On a machine with 2GB memory we make sure that we have at
-         * least 128 MB free space for vmalloc.
-         */
-        if (memory_end > 1920*1024*1024)
-                memory_end = 1920*1024*1024;
-#else /* CONFIG_64BIT */
-	memory_end &= ~0x200000UL;
-#endif /* CONFIG_64BIT */
-
+	setup_memory_end();
 	setup_memory();
 	setup_resources();
 	setup_lowcore();
Index: linux-2.6.19-rc6-mm2/include/asm-s390/pgtable.h
===================================================================
--- linux-2.6.19-rc6-mm2.orig/include/asm-s390/pgtable.h
+++ linux-2.6.19-rc6-mm2/include/asm-s390/pgtable.h
@@ -110,13 +110,22 @@ extern char empty_zero_page[PAGE_SIZE];
 #define VMALLOC_OFFSET  (8*1024*1024)
 #define VMALLOC_START   (((unsigned long) high_memory + VMALLOC_OFFSET) \
 			 & ~(VMALLOC_OFFSET-1))
+
+/*
+ * We need some free virtual space to be able to do vmalloc.
+ * VMALLOC_MIN_SIZE defines the minimum size of the vmalloc
+ * area. On a machine with 2GB memory we make sure that we
+ * have at least 128MB free space for vmalloc. On a machine
+ * with 4TB we make sure we have at least 1GB.
+ */
 #ifndef __s390x__
-# define VMALLOC_END     (0x7fffffffL)
+#define VMALLOC_MIN_SIZE	0x8000000UL
+#define VMALLOC_END		0x80000000UL
 #else /* __s390x__ */
-# define VMALLOC_END     (0x40000000000L)
+#define VMALLOC_MIN_SIZE	0x40000000UL
+#define VMALLOC_END		0x40000000000UL
 #endif /* __s390x__ */
 
-
 /*
  * A 31 bit pagetable entry of S390 has following format:
  *  |   PFRA          |    |  OS  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
