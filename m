Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85906800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 13:52:57 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id d15so16145829qtg.2
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 10:52:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i93sor6114624qtd.1.2018.01.22.10.52.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 10:52:56 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 03/24] selftests/vm: move generic definitions to header file
Date: Mon, 22 Jan 2018 10:51:56 -0800
Message-Id: <1516647137-11174-4-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516647137-11174-1-git-send-email-linuxram@us.ibm.com>
References: <1516647137-11174-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, arnd@arndb.de

Moved all the generic definition and helper functions to the
header file

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |   62 ++++++++++++++++++++++--
 tools/testing/selftests/vm/protection_keys.c |   66 --------------------------
 2 files changed, 57 insertions(+), 71 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index a568166..c1bc761 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -13,8 +13,31 @@
 #include <ucontext.h>
 #include <sys/mman.h>
 
+/* Define some kernel-like types */
+#define  u8 uint8_t
+#define u16 uint16_t
+#define u32 uint32_t
+#define u64 uint64_t
+
+#ifdef __i386__
+#define SYS_mprotect_key 380
+#define SYS_pkey_alloc	 381
+#define SYS_pkey_free	 382
+#define REG_IP_IDX REG_EIP
+#define si_pkey_offset 0x14
+#else
+#define SYS_mprotect_key 329
+#define SYS_pkey_alloc	 330
+#define SYS_pkey_free	 331
+#define REG_IP_IDX REG_RIP
+#define si_pkey_offset 0x20
+#endif
+
 #define NR_PKEYS 16
 #define PKEY_BITS_PER_PKEY 2
+#define PKEY_DISABLE_ACCESS    0x1
+#define PKEY_DISABLE_WRITE     0x2
+#define HPAGE_SIZE	(1UL<<21)
 
 #ifndef DEBUG_LEVEL
 #define DEBUG_LEVEL 0
@@ -141,11 +164,6 @@ static inline void __pkey_write_allow(int pkey, int do_allow_write)
 	dprintf4("pkey_reg now: %08x\n", rdpkey_reg());
 }
 
-#define PROT_PKEY0     0x10            /* protection key value (bit 0) */
-#define PROT_PKEY1     0x20            /* protection key value (bit 1) */
-#define PROT_PKEY2     0x40            /* protection key value (bit 2) */
-#define PROT_PKEY3     0x80            /* protection key value (bit 3) */
-
 #define PAGE_SIZE 4096
 #define MB	(1<<20)
 
@@ -223,4 +241,38 @@ int pkey_reg_xstate_offset(void)
 	return xstate_offset;
 }
 
+static inline void __page_o_noops(void)
+{
+	/* 8-bytes of instruction * 512 bytes = 1 page */
+	asm(".rept 512 ; nopl 0x7eeeeeee(%eax) ; .endr");
+}
+
 #endif /* _PKEYS_HELPER_H */
+
+#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
+#define ALIGN_UP(x, align_to)	(((x) + ((align_to)-1)) & ~((align_to)-1))
+#define ALIGN_DOWN(x, align_to) ((x) & ~((align_to)-1))
+#define ALIGN_PTR_UP(p, ptr_align_to)	\
+		((typeof(p))ALIGN_UP((unsigned long)(p), ptr_align_to))
+#define ALIGN_PTR_DOWN(p, ptr_align_to) \
+	((typeof(p))ALIGN_DOWN((unsigned long)(p), ptr_align_to))
+#define __stringify_1(x...)     #x
+#define __stringify(x...)       __stringify_1(x)
+
+#define PTR_ERR_ENOTSUP ((void *)-ENOTSUP)
+
+int dprint_in_signal;
+char dprint_in_signal_buffer[DPRINT_IN_SIGNAL_BUF_SIZE];
+
+extern void abort_hooks(void);
+#define pkey_assert(condition) do {		\
+	if (!(condition)) {			\
+		dprintf0("assert() at %s::%d test_nr: %d iteration: %d\n", \
+				__FILE__, __LINE__,	\
+				test_nr, iteration_nr);	\
+		dprintf0("errno at assert: %d", errno);	\
+		abort_hooks();			\
+		assert(condition);		\
+	}					\
+} while (0)
+#define raw_assert(cond) assert(cond)
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index 4aebf12..91bade4 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -49,34 +49,9 @@
 int test_nr;
 
 unsigned int shadow_pkey_reg;
-
-#define HPAGE_SIZE	(1UL<<21)
-#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
-#define ALIGN_UP(x, align_to)	(((x) + ((align_to)-1)) & ~((align_to)-1))
-#define ALIGN_DOWN(x, align_to) ((x) & ~((align_to)-1))
-#define ALIGN_PTR_UP(p, ptr_align_to)	((typeof(p))ALIGN_UP((unsigned long)(p),	ptr_align_to))
-#define ALIGN_PTR_DOWN(p, ptr_align_to)	((typeof(p))ALIGN_DOWN((unsigned long)(p),	ptr_align_to))
-#define __stringify_1(x...)     #x
-#define __stringify(x...)       __stringify_1(x)
-
-#define PTR_ERR_ENOTSUP ((void *)-ENOTSUP)
-
 int dprint_in_signal;
 char dprint_in_signal_buffer[DPRINT_IN_SIGNAL_BUF_SIZE];
 
-extern void abort_hooks(void);
-#define pkey_assert(condition) do {		\
-	if (!(condition)) {			\
-		dprintf0("assert() at %s::%d test_nr: %d iteration: %d\n", \
-				__FILE__, __LINE__,	\
-				test_nr, iteration_nr);	\
-		dprintf0("errno at assert: %d", errno);	\
-		abort_hooks();			\
-		assert(condition);		\
-	}					\
-} while (0)
-#define raw_assert(cond) assert(cond)
-
 void cat_into_file(char *str, char *file)
 {
 	int fd = open(file, O_RDWR);
@@ -154,12 +129,6 @@ void abort_hooks(void)
 #endif
 }
 
-static inline void __page_o_noops(void)
-{
-	/* 8-bytes of instruction * 512 bytes = 1 page */
-	asm(".rept 512 ; nopl 0x7eeeeeee(%eax) ; .endr");
-}
-
 /*
  * This attempts to have roughly a page of instructions followed by a few
  * instructions that do a write, and another page of instructions.  That
@@ -182,38 +151,6 @@ void lots_o_noops_around_write(int *write_to_me)
 	dprintf3("%s() done\n", __func__);
 }
 
-/* Define some kernel-like types */
-#define  u8 uint8_t
-#define u16 uint16_t
-#define u32 uint32_t
-#define u64 uint64_t
-
-#ifdef __i386__
-
-#ifndef SYS_mprotect_key
-# define SYS_mprotect_key 380
-#endif
-#ifndef SYS_pkey_alloc
-# define SYS_pkey_alloc	 381
-# define SYS_pkey_free	 382
-#endif
-#define REG_IP_IDX REG_EIP
-#define si_pkey_offset 0x14
-
-#else
-
-#ifndef SYS_mprotect_key
-# define SYS_mprotect_key 329
-#endif
-#ifndef SYS_pkey_alloc
-# define SYS_pkey_alloc	 330
-# define SYS_pkey_free	 331
-#endif
-#define REG_IP_IDX REG_RIP
-#define si_pkey_offset 0x20
-
-#endif
-
 void dump_mem(void *dumpme, int len_bytes)
 {
 	char *c = (void *)dumpme;
@@ -424,9 +361,6 @@ void dumpit(char *f)
 	close(fd);
 }
 
-#define PKEY_DISABLE_ACCESS    0x1
-#define PKEY_DISABLE_WRITE     0x2
-
 u32 pkey_get(int pkey, unsigned long flags)
 {
 	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
