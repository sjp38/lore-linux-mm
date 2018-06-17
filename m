Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6EA6B0007
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 07:36:12 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b65-v6so7185822plb.5
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 04:36:12 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m8-v6si10424254pga.530.2018.06.17.04.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jun 2018 04:36:10 -0700 (PDT)
Subject: Patch "x86/pkeys/selftests: Save off 'prot' for allocations" has been added to the 4.14-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 17 Jun 2018 13:23:31 +0200
Message-ID: <152923461140152@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180509171354.AA23E228@viggo.jf.intel.com, akpm@linux-foundation.org, alexander.levin@microsoft.com, dave.hansen@intel.com, dave.hansen@linux.intel.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linuxram@us.ibm.com, mingo@kernel.org, mpe@ellerman.id.au, peterz@infradead.org, shuah@kernel.org, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/pkeys/selftests: Save off 'prot' for allocations

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-pkeys-selftests-save-off-prot-for-allocations.patch
and it can be found in the queue-4.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Sun Jun 17 12:13:49 CEST 2018
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 9 May 2018 10:13:54 -0700
Subject: x86/pkeys/selftests: Save off 'prot' for allocations

From: Dave Hansen <dave.hansen@linux.intel.com>

[ Upstream commit acb25d761d6f2f64e785ccefc71e54f244f1eda4 ]

This makes it possible to to tell what 'prot' a given allocation
is supposed to have.  That way, if we want to change just the
pkey, we know what 'prot' to pass to mprotect_pkey().

Also, keep a record of the most recent allocation so the tests
can easily find it.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Shuah Khan <shuah@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20180509171354.AA23E228@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/protection_keys.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

--- a/tools/testing/selftests/x86/protection_keys.c
+++ b/tools/testing/selftests/x86/protection_keys.c
@@ -677,10 +677,12 @@ int mprotect_pkey(void *ptr, size_t size
 struct pkey_malloc_record {
 	void *ptr;
 	long size;
+	int prot;
 };
 struct pkey_malloc_record *pkey_malloc_records;
+struct pkey_malloc_record *pkey_last_malloc_record;
 long nr_pkey_malloc_records;
-void record_pkey_malloc(void *ptr, long size)
+void record_pkey_malloc(void *ptr, long size, int prot)
 {
 	long i;
 	struct pkey_malloc_record *rec = NULL;
@@ -712,6 +714,8 @@ void record_pkey_malloc(void *ptr, long
 		(int)(rec - pkey_malloc_records), rec, ptr, size);
 	rec->ptr = ptr;
 	rec->size = size;
+	rec->prot = prot;
+	pkey_last_malloc_record = rec;
 	nr_pkey_malloc_records++;
 }
 
@@ -756,7 +760,7 @@ void *malloc_pkey_with_mprotect(long siz
 	pkey_assert(ptr != (void *)-1);
 	ret = mprotect_pkey((void *)ptr, PAGE_SIZE, prot, pkey);
 	pkey_assert(!ret);
-	record_pkey_malloc(ptr, size);
+	record_pkey_malloc(ptr, size, prot);
 	rdpkru();
 
 	dprintf1("%s() for pkey %d @ %p\n", __func__, pkey, ptr);
@@ -777,7 +781,7 @@ void *malloc_pkey_anon_huge(long size, i
 	size = ALIGN_UP(size, HPAGE_SIZE * 2);
 	ptr = mmap(NULL, size, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
 	pkey_assert(ptr != (void *)-1);
-	record_pkey_malloc(ptr, size);
+	record_pkey_malloc(ptr, size, prot);
 	mprotect_pkey(ptr, size, prot, pkey);
 
 	dprintf1("unaligned ptr: %p\n", ptr);
@@ -850,7 +854,7 @@ void *malloc_pkey_hugetlb(long size, int
 	pkey_assert(ptr != (void *)-1);
 	mprotect_pkey(ptr, size, prot, pkey);
 
-	record_pkey_malloc(ptr, size);
+	record_pkey_malloc(ptr, size, prot);
 
 	dprintf1("mmap()'d hugetlbfs for pkey %d @ %p\n", pkey, ptr);
 	return ptr;
@@ -872,7 +876,7 @@ void *malloc_pkey_mmap_dax(long size, in
 
 	mprotect_pkey(ptr, size, prot, pkey);
 
-	record_pkey_malloc(ptr, size);
+	record_pkey_malloc(ptr, size, prot);
 
 	dprintf1("mmap()'d for pkey %d @ %p\n", pkey, ptr);
 	close(fd);


Patches currently in stable-queue which might be from dave.hansen@linux.intel.com are

queue-4.14/x86-pkeys-selftests-factor-out-instruction-page.patch
queue-4.14/x86-pkeys-selftests-fix-pointer-math.patch
queue-4.14/x86-pkeys-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-pkeys-abi.patch
queue-4.14/x86-pkeys-selftests-add-a-test-for-pkey-0.patch
queue-4.14/x86-pkeys-selftests-stop-using-assert.patch
queue-4.14/x86-pkeys-selftests-save-off-prot-for-allocations.patch
queue-4.14/x86-pkeys-selftests-remove-dead-debugging-code-fix-dprint_in_signal.patch
queue-4.14/x86-mpx-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-mpx-abi.patch
queue-4.14/x86-pkeys-selftests-add-prot_exec-test.patch
queue-4.14/x86-pkeys-selftests-allow-faults-on-unknown-keys.patch
queue-4.14/x86-pkeys-selftests-give-better-unexpected-fault-error-messages.patch
queue-4.14/x86-pkeys-selftests-fix-pkey-exhaustion-test-off-by-one.patch
