Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26D2B6B000A
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:56:28 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l6-v6so8930264wrn.17
        for <linux-mm@kvack.org>; Mon, 14 May 2018 01:56:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i15-v6sor1288974wmg.49.2018.05.14.01.56.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 01:56:26 -0700 (PDT)
Date: Mon, 14 May 2018 10:56:23 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH] x86/pkeys/selftests: Adjust the self-test to fresh distros
 that export the pkeys ABI
Message-ID: <20180514085623.GB7094@gmail.com>
References: <20180509171336.76636D88@viggo.jf.intel.com>
 <20180514082918.GA21574@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180514082918.GA21574@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, akpm@linux-foundation.org, shuah@kernel.org, shakeelb@google.com

Ubuntu 18.04 started exporting pkeys details in header files, resulting
in build failures and warnings in the pkeys self-tests:

  protection_keys.c:232:0: warning: "SEGV_BNDERR" redefined
  protection_keys.c:387:5: error: conflicting types for a??pkey_geta??
  protection_keys.c:409:5: error: conflicting types for a??pkey_seta??
  ...

Fix these namespace conflicts and double definitions, plus also
clean up the ABI definitions to make it all a bit more readable ...

Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 tools/testing/selftests/x86/protection_keys.c | 67 ++++++++++++++++-----------
 1 file changed, 41 insertions(+), 26 deletions(-)

diff --git a/tools/testing/selftests/x86/protection_keys.c b/tools/testing/selftests/x86/protection_keys.c
index f15aa5a76fe3..bbe80a5c31c7 100644
--- a/tools/testing/selftests/x86/protection_keys.c
+++ b/tools/testing/selftests/x86/protection_keys.c
@@ -191,26 +191,30 @@ void lots_o_noops_around_write(int *write_to_me)
 #ifdef __i386__
 
 #ifndef SYS_mprotect_key
-# define SYS_mprotect_key 380
+# define SYS_mprotect_key	380
 #endif
+
 #ifndef SYS_pkey_alloc
-# define SYS_pkey_alloc	 381
-# define SYS_pkey_free	 382
+# define SYS_pkey_alloc		381
+# define SYS_pkey_free		382
 #endif
-#define REG_IP_IDX REG_EIP
-#define si_pkey_offset 0x14
+
+#define REG_IP_IDX		REG_EIP
+#define si_pkey_offset		0x14
 
 #else
 
 #ifndef SYS_mprotect_key
-# define SYS_mprotect_key 329
+# define SYS_mprotect_key	329
 #endif
+
 #ifndef SYS_pkey_alloc
-# define SYS_pkey_alloc	 330
-# define SYS_pkey_free	 331
+# define SYS_pkey_alloc		330
+# define SYS_pkey_free		331
 #endif
-#define REG_IP_IDX REG_RIP
-#define si_pkey_offset 0x20
+
+#define REG_IP_IDX		REG_RIP
+#define si_pkey_offset		0x20
 
 #endif
 
@@ -225,8 +229,14 @@ void dump_mem(void *dumpme, int len_bytes)
 	}
 }
 
-#define SEGV_BNDERR     3  /* failed address bound checks */
-#define SEGV_PKUERR     4
+/* Failed address bound checks: */
+#ifndef SEGV_BNDERR
+# define SEGV_BNDERR		3
+#endif
+
+#ifndef SEGV_PKUERR
+# define SEGV_PKUERR		4
+#endif
 
 static char *si_code_str(int si_code)
 {
@@ -393,10 +403,15 @@ pid_t fork_lazy_child(void)
 	return forkret;
 }
 
-#define PKEY_DISABLE_ACCESS    0x1
-#define PKEY_DISABLE_WRITE     0x2
+#ifndef PKEY_DISABLE_ACCESS
+# define PKEY_DISABLE_ACCESS	0x1
+#endif
+
+#ifndef PKEY_DISABLE_WRITE
+# define PKEY_DISABLE_WRITE	0x2
+#endif
 
-u32 pkey_get(int pkey, unsigned long flags)
+static u32 hw_pkey_get(int pkey, unsigned long flags)
 {
 	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
 	u32 pkru = __rdpkru();
@@ -418,7 +433,7 @@ u32 pkey_get(int pkey, unsigned long flags)
 	return masked_pkru;
 }
 
-int pkey_set(int pkey, unsigned long rights, unsigned long flags)
+static int hw_pkey_set(int pkey, unsigned long rights, unsigned long flags)
 {
 	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
 	u32 old_pkru = __rdpkru();
@@ -452,15 +467,15 @@ void pkey_disable_set(int pkey, int flags)
 		pkey, flags);
 	pkey_assert(flags & (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
 
-	pkey_rights = pkey_get(pkey, syscall_flags);
+	pkey_rights = hw_pkey_get(pkey, syscall_flags);
 
-	dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
+	dprintf1("%s(%d) hw_pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
 	pkey_assert(pkey_rights >= 0);
 
 	pkey_rights |= flags;
 
-	ret = pkey_set(pkey, pkey_rights, syscall_flags);
+	ret = hw_pkey_set(pkey, pkey_rights, syscall_flags);
 	assert(!ret);
 	/*pkru and flags have the same format */
 	shadow_pkru |= flags << (pkey * 2);
@@ -468,8 +483,8 @@ void pkey_disable_set(int pkey, int flags)
 
 	pkey_assert(ret >= 0);
 
-	pkey_rights = pkey_get(pkey, syscall_flags);
-	dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
+	pkey_rights = hw_pkey_get(pkey, syscall_flags);
+	dprintf1("%s(%d) hw_pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
 
 	dprintf1("%s(%d) pkru: 0x%x\n", __func__, pkey, rdpkru());
@@ -483,24 +498,24 @@ void pkey_disable_clear(int pkey, int flags)
 {
 	unsigned long syscall_flags = 0;
 	int ret;
-	int pkey_rights = pkey_get(pkey, syscall_flags);
+	int pkey_rights = hw_pkey_get(pkey, syscall_flags);
 	u32 orig_pkru = rdpkru();
 
 	pkey_assert(flags & (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
 
-	dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
+	dprintf1("%s(%d) hw_pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
 	pkey_assert(pkey_rights >= 0);
 
 	pkey_rights |= flags;
 
-	ret = pkey_set(pkey, pkey_rights, 0);
+	ret = hw_pkey_set(pkey, pkey_rights, 0);
 	/* pkru and flags have the same format */
 	shadow_pkru &= ~(flags << (pkey * 2));
 	pkey_assert(ret >= 0);
 
-	pkey_rights = pkey_get(pkey, syscall_flags);
-	dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
+	pkey_rights = hw_pkey_get(pkey, syscall_flags);
+	dprintf1("%s(%d) hw_pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
 
 	dprintf1("%s(%d) pkru: 0x%x\n", __func__, pkey, rdpkru());
