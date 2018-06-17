Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB356B027C
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 07:49:26 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 31-v6so8291163plf.19
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 04:49:26 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a76-v6si13510926pfk.35.2018.06.17.04.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jun 2018 04:49:25 -0700 (PDT)
Subject: Patch "x86/pkeys/selftests: Adjust the self-test to fresh distros that export the pkeys ABI" has been added to the 4.16-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 17 Jun 2018 13:23:53 +0200
Message-ID: <15292346334991@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180514085623.GB7094@gmail.com, akpm@linux-foundation.org, alexander.levin@microsoft.com, dave.hansen@intel.com, dave.hansen@linux.intel.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linuxram@us.ibm.com, mingo@kernel.org, mpe@ellerman.id.au, peterz@infradead.org, shakeelb@google.com, shuah@kernel.org, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/pkeys/selftests: Adjust the self-test to fresh distros that export the pkeys ABI

to the 4.16-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-pkeys-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-pkeys-abi.patch
and it can be found in the queue-4.16 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Sun Jun 17 12:07:34 CEST 2018
From: Ingo Molnar <mingo@kernel.org>
Date: Mon, 14 May 2018 10:56:23 +0200
Subject: x86/pkeys/selftests: Adjust the self-test to fresh distros that export the pkeys ABI

From: Ingo Molnar <mingo@kernel.org>

[ Upstream commit 0fb96620dce351608aa82eed5942e2f58b07beda ]

Ubuntu 18.04 started exporting pkeys details in header files, resulting
in build failures and warnings in the pkeys self-tests:

  protection_keys.c:232:0: warning: "SEGV_BNDERR" redefined
  protection_keys.c:387:5: error: conflicting types for a??pkey_geta??
  protection_keys.c:409:5: error: conflicting types for a??pkey_seta??
  ...

Fix these namespace conflicts and double definitions, plus also
clean up the ABI definitions to make it all a bit more readable ...

Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: akpm@linux-foundation.org
Cc: dave.hansen@intel.com
Cc: linux-mm@kvack.org
Cc: linuxram@us.ibm.com
Cc: mpe@ellerman.id.au
Cc: shakeelb@google.com
Cc: shuah@kernel.org
Link: http://lkml.kernel.org/r/20180514085623.GB7094@gmail.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/protection_keys.c |   67 +++++++++++++++-----------
 1 file changed, 41 insertions(+), 26 deletions(-)

--- a/tools/testing/selftests/x86/protection_keys.c
+++ b/tools/testing/selftests/x86/protection_keys.c
@@ -191,26 +191,30 @@ void lots_o_noops_around_write(int *writ
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
 
@@ -225,8 +229,14 @@ void dump_mem(void *dumpme, int len_byte
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
@@ -418,7 +433,7 @@ u32 pkey_get(int pkey, unsigned long fla
 	return masked_pkru;
 }
 
-int pkey_set(int pkey, unsigned long rights, unsigned long flags)
+static int hw_pkey_set(int pkey, unsigned long rights, unsigned long flags)
 {
 	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
 	u32 old_pkru = __rdpkru();
@@ -452,15 +467,15 @@ void pkey_disable_set(int pkey, int flag
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
@@ -468,8 +483,8 @@ void pkey_disable_set(int pkey, int flag
 
 	pkey_assert(ret >= 0);
 
-	pkey_rights = pkey_get(pkey, syscall_flags);
-	dprintf1("%s(%d) pkey_get(%d): %x\n", __func__,
+	pkey_rights = hw_pkey_get(pkey, syscall_flags);
+	dprintf1("%s(%d) hw_pkey_get(%d): %x\n", __func__,
 			pkey, pkey, pkey_rights);
 
 	dprintf1("%s(%d) pkru: 0x%x\n", __func__, pkey, rdpkru());
@@ -483,24 +498,24 @@ void pkey_disable_clear(int pkey, int fl
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


Patches currently in stable-queue which might be from mingo@kernel.org are

queue-4.16/locking-rwsem-add-a-new-rwsem_anonymously_owned-flag.patch
queue-4.16/x86-pkeys-selftests-factor-out-instruction-page.patch
queue-4.16/kthread-sched-wait-fix-kthread_parkme-wait-loop.patch
queue-4.16/proc-kcore-don-t-bounds-check-against-address-0.patch
queue-4.16/stop_machine-sched-fix-migrate_swap-vs.-active_balance-deadlock.patch
queue-4.16/kthread-sched-wait-fix-kthread_parkme-completion-issue.patch
queue-4.16/init-fix-false-positives-in-w-x-checking.patch
queue-4.16/x86-pkeys-selftests-fix-pointer-math.patch
queue-4.16/x86-pkeys-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-pkeys-abi.patch
queue-4.16/locking-percpu-rwsem-annotate-rwsem-ownership-transfer-by-setting-rwsem_owner_unknown.patch
queue-4.16/x86-pkeys-selftests-add-a-test-for-pkey-0.patch
queue-4.16/x86-pkeys-selftests-stop-using-assert.patch
queue-4.16/sched-core-introduce-set_special_state.patch
queue-4.16/x86-pkeys-selftests-save-off-prot-for-allocations.patch
queue-4.16/x86-pkeys-selftests-remove-dead-debugging-code-fix-dprint_in_signal.patch
queue-4.16/x86-selftests-add-mov_to_ss-test.patch
queue-4.16/sched-debug-move-the-print_rt_rq-and-print_dl_rq-declarations-to-kernel-sched-sched.h.patch
queue-4.16/x86-mpx-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-mpx-abi.patch
queue-4.16/x86-pkeys-selftests-add-prot_exec-test.patch
queue-4.16/sched-deadline-make-the-grub_reclaim-function-static.patch
queue-4.16/objtool-kprobes-x86-sync-the-latest-asm-insn.h-header-with-tools-objtool-arch-x86-include-asm-insn.h.patch
queue-4.16/x86-pkeys-selftests-allow-faults-on-unknown-keys.patch
queue-4.16/x86-pkeys-selftests-give-better-unexpected-fault-error-messages.patch
queue-4.16/x86-pkeys-selftests-avoid-printf-in-signal-deadlocks.patch
queue-4.16/efi-libstub-arm64-handle-randomized-text_offset.patch
queue-4.16/x86-pkeys-selftests-fix-pkey-exhaustion-test-off-by-one.patch
