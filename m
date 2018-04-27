Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 106336B0010
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 13:50:03 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l85so411745pfb.18
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 10:50:03 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id v13-v6si1524657pgr.676.2018.04.27.10.50.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 10:50:01 -0700 (PDT)
Subject: [PATCH 9/9] x86, pkeys, selftests: add PROT_EXEC test
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 27 Apr 2018 10:45:42 -0700
References: <20180427174527.0031016C@viggo.jf.intel.com>
In-Reply-To: <20180427174527.0031016C@viggo.jf.intel.com>
Message-Id: <20180427174542.29114E42@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

Under the covers, implement executable-only memory with
protection keys when userspace calls mprotect(PROT_EXEC).

But, we did not have a selftest for that.  Now we do.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Shuah Khan <shuah@kernel.org>
---

 b/tools/testing/selftests/x86/protection_keys.c |   51 ++++++++++++++++++++++--
 1 file changed, 47 insertions(+), 4 deletions(-)

diff -puN tools/testing/selftests/x86/protection_keys.c~pkeys-selftests-prot_exec tools/testing/selftests/x86/protection_keys.c
--- a/tools/testing/selftests/x86/protection_keys.c~pkeys-selftests-prot_exec	2018-04-26 11:24:12.572481103 -0700
+++ b/tools/testing/selftests/x86/protection_keys.c	2018-04-26 11:24:12.575481103 -0700
@@ -930,10 +930,10 @@ void expected_pk_fault(int pkey)
 	dprintf2("%s(%d): last_si_pkey: %d\n", __func__, pkey, last_si_pkey);
 	pkey_assert(last_pkru_faults + 1 == pkru_faults);
 
-       /*
-	* For exec-only memory, we do not know the pkey in
-	* advance, so skip this check.
-	*/
+	/*
+	 * For exec-only memory, we do not know the pkey in
+	 * advance, so skip this check.
+	 */
 	if (pkey != UNKNOWN_PKEY)
 		pkey_assert(last_si_pkey == pkey);
 
@@ -1335,6 +1335,49 @@ void test_executing_on_unreadable_memory
 	expected_pk_fault(pkey);
 }
 
+void test_implicit_mprotect_exec_only_memory(int *ptr, u16 pkey)
+{
+	void *p1;
+	int scratch;
+	int ptr_contents;
+	int ret;
+
+	dprintf1("%s() start\n", __func__);
+
+	p1 = get_pointer_to_instructions();
+	lots_o_noops_around_write(&scratch);
+	ptr_contents = read_ptr(p1);
+	dprintf2("ptr (%p) contents@%d: %x\n", p1, __LINE__, ptr_contents);
+
+	/* Use a *normal* mprotect(), not mprotect_pkey(): */
+	ret = mprotect(p1, PAGE_SIZE, PROT_EXEC);
+	pkey_assert(!ret);
+
+	dprintf2("pkru: %x\n", rdpkru());
+
+	/* Make sure this is an *instruction* fault */
+	madvise(p1, PAGE_SIZE, MADV_DONTNEED);
+	lots_o_noops_around_write(&scratch);
+	do_not_expect_pk_fault();
+	ptr_contents = read_ptr(p1);
+	dprintf2("ptr (%p) contents@%d: %x\n", p1, __LINE__, ptr_contents);
+	expected_pk_fault(UNKNOWN_PKEY);
+
+	/*
+	 * Put the memory back to non-PROT_EXEC.  Should clear the
+	 * exec-only pkey off the VMA and allow it to be readable
+	 * again.  Go to PROT_NONE first to check for a kernel bug
+	 * that did not clear the pkey when doing PROT_NONE.
+	 */
+	ret = mprotect(p1, PAGE_SIZE, PROT_NONE);
+	pkey_assert(!ret);
+
+	ret = mprotect(p1, PAGE_SIZE, PROT_READ|PROT_EXEC);
+	pkey_assert(!ret);
+	ptr_contents = read_ptr(p1);
+	do_not_expect_pk_fault();
+}
+
 void test_mprotect_pkey_on_unsupported_cpu(int *ptr, u16 pkey)
 {
 	int size = PAGE_SIZE;
_
