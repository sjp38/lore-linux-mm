Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DAD286B0266
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 04:28:08 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 31-v6so9783333plf.19
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 01:28:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u191-v6si11623866pgd.667.2018.06.18.01.28.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 01:28:07 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.16 246/279] x86/pkeys/selftests: Save off prot for allocations
Date: Mon, 18 Jun 2018 10:13:51 +0200
Message-Id: <20180618080618.947257586@linuxfoundation.org>
In-Reply-To: <20180618080608.851973560@linuxfoundation.org>
References: <20180618080608.851973560@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellermen <mpe@ellerman.id.au>, Peter Zijlstra <peterz@infradead.org>, Ram Pai <linuxram@us.ibm.com>, Shuah Khan <shuah@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Sasha Levin <alexander.levin@microsoft.com>

4.16-stable review patch.  If anyone has any objections, please let me know.

------------------

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
