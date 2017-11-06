Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB84C280257
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:59:12 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id b15so6731279qkg.23
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:59:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v54sor8308645qtc.160.2017.11.06.00.59.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:59:12 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 19/51] powerpc: Handle exceptions caused by pkey violation
Date: Mon,  6 Nov 2017 00:57:11 -0800
Message-Id: <1509958663-18737-20-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

Handle Data and  Instruction exceptions caused by memory
protection-key.

The CPU will detect the key fault if the HPTE is already
programmed with the key.

However if the HPTE is not  hashed, a key fault will not
be detected by the hardware. The software will detect
pkey violation in such a case.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/mm/fault.c |   32 +++++++++++++++++++++++++++-----
 1 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 4797d08..dfcd0e4 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -145,6 +145,24 @@ static noinline int bad_area(struct pt_regs *regs, unsigned long address)
 	return __bad_area(regs, address, SEGV_MAPERR);
 }
 
+static int bad_page_fault_exception(struct pt_regs *regs, unsigned long address,
+				    int si_code)
+{
+	int sig = SIGBUS;
+	int code = BUS_OBJERR;
+
+#ifdef CONFIG_PPC_MEM_KEYS
+	if (si_code & DSISR_KEYFAULT) {
+		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
+		sig = SIGSEGV;
+		code = SEGV_PKUERR;
+	}
+#endif /* CONFIG_PPC_MEM_KEYS */
+
+	_exception(sig, regs, code, address);
+	return 0;
+}
+
 static int do_sigbus(struct pt_regs *regs, unsigned long address,
 		     unsigned int fault)
 {
@@ -391,11 +409,9 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 		return 0;
 
 	if (unlikely(page_fault_is_bad(error_code))) {
-		if (is_user) {
-			_exception(SIGBUS, regs, BUS_OBJERR, address);
-			return 0;
-		}
-		return SIGBUS;
+		if (!is_user)
+			return SIGBUS;
+		return bad_page_fault_exception(regs, address, error_code);
 	}
 
 	/* Additional sanity check(s) */
@@ -498,6 +514,12 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * the fault.
 	 */
 	fault = handle_mm_fault(vma, address, flags);
+
+#ifdef CONFIG_PPC_MEM_KEYS
+	if (unlikely(fault & VM_FAULT_SIGSEGV))
+		return __bad_area(regs, address, SEGV_PKUERR);
+#endif /* CONFIG_PPC_MEM_KEYS */
+
 	major |= fault & VM_FAULT_MAJOR;
 
 	/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
