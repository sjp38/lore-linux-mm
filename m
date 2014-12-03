Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 47D6F6B006C
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 10:23:49 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so15819676pac.25
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 07:23:49 -0800 (PST)
Received: from e28smtp02.in.ibm.com ([122.248.162.2])
        by mx.google.com with ESMTPS id dm1si38840805pbb.32.2014.12.03.07.23.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 07:23:47 -0800 (PST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 3 Dec 2014 20:53:42 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id CF3B1E0054
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 20:54:08 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sB3FOGI365405020
	for <linux-mm@kvack.org>; Wed, 3 Dec 2014 20:54:16 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sB3FNbn8029205
	for <linux-mm@kvack.org>; Wed, 3 Dec 2014 20:53:38 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 03/10] mm: Convert p[te|md]_numa users to p[te|md]_protnone_numa
In-Reply-To: <1417551115.27448.7.camel@kernel.crashing.org>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de> <1416578268-19597-4-git-send-email-mgorman@suse.de> <1417473762.7182.8.camel@kernel.crashing.org> <87k32ah5q3.fsf@linux.vnet.ibm.com> <1417551115.27448.7.camel@kernel.crashing.org>
Date: Wed, 03 Dec 2014 20:53:37 +0530
Message-ID: <87lhmobvuu.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>

Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:

> On Tue, 2014-12-02 at 12:57 +0530, Aneesh Kumar K.V wrote:
>> Now, hash_preload can possibly insert an hpte in hash page table even if
>> the access is not allowed by the pte permissions. But i guess even that
>> is ok. because we will fault again, end-up calling hash_page_mm where we
>> handle that part correctly.
>
> I think we need a test case...
>

I ran the subpageprot test that Paul had written. I modified it to ran
with selftest. 

commit 0cd3756bce6880a13de49406ce5c8537712c9bf8
Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date:   Wed Dec 3 20:40:06 2014 +0530

    selftest/ppc: Add subpage protection self test.
    
    Originally written by  Paul Mackerras <paulus@samba.org>
    
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

diff --git a/tools/testing/selftests/powerpc/mm/Makefile b/tools/testing/selftests/powerpc/mm/Makefile
index 357ccbd6bad9..fb00c6f7d675 100644
--- a/tools/testing/selftests/powerpc/mm/Makefile
+++ b/tools/testing/selftests/powerpc/mm/Makefile
@@ -1,7 +1,7 @@
 noarg:
 	$(MAKE) -C ../
 
-PROGS := hugetlb_vs_thp_test
+PROGS := hugetlb_vs_thp_test subpage_prot
 
 all: $(PROGS)
 
diff --git a/tools/testing/selftests/powerpc/mm/subpage_prot.c b/tools/testing/selftests/powerpc/mm/subpage_prot.c
new file mode 100644
index 000000000000..1efeafc2e175
--- /dev/null
+++ b/tools/testing/selftests/powerpc/mm/subpage_prot.c
@@ -0,0 +1,150 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <signal.h>
+#include <stdarg.h>
+#include <sys/ptrace.h>
+#include <sys/mman.h>
+#include <errno.h>
+#include <ucontext.h>
+#include <assert.h>
+
+#include "utils.h"
+
+void *mallocblock;
+unsigned long mallocsize;
+void *fileblock;
+off_t filesize;
+
+int in_test;
+volatile int faulted;
+volatile void *dar;
+int errors;
+
+static void segv(int signum, siginfo_t *info, void *ctxt_v)
+{
+	ucontext_t *ctxt = (ucontext_t *)ctxt_v;
+	struct pt_regs *regs = ctxt->uc_mcontext.regs;
+
+	if (!in_test) {
+		fprintf(stderr, "Segfault outside of test !\n");
+		exit(1);
+	}
+	faulted = 1;
+	dar = (void *)regs->dar;
+	regs->nip += 4;
+}
+
+static inline void do_read(const volatile void *addr)
+{
+	int ret;
+	asm volatile("lwz %0,0(%1); twi 0,%0,0; isync;\n"
+		     : "=r" (ret) : "r" (addr) : "memory");
+}
+
+static inline void do_write(const volatile void *addr)
+{
+	int val = 0x1234567;
+	asm volatile("stw %0,0(%1); sync; \n"
+		     : : "r" (val), "r" (addr) : "memory");
+}
+
+static inline void check_faulted(void *addr, long page, long subpage, int write)
+{
+	int want_fault = (subpage == ((page + 3) % 16));
+
+	if (write)
+		want_fault |= (subpage == ((page + 1) % 16));
+
+	if (faulted != want_fault) {
+		printf("Failed at 0x%p (p=%ld,sp=%ld,w=%d), want=%s, got=%s !\n",
+		       addr, page, subpage, write,
+		       want_fault ? "fault" : "pass",
+		       faulted ? "fault" : "pass");
+		++errors;
+	}
+	if (faulted) {
+		if (dar != addr) {
+			printf("Fault expected at 0x%p and happened at 0x%p !\n",
+			       addr, dar);
+		}
+		faulted = 0;
+		asm volatile("sync" : : : "memory");
+	}
+}
+
+static int run_test(void *addr, unsigned long size)
+{
+	unsigned int *map;
+	long i, j, pages, err;
+
+	pages = size / 0x10000;
+	map = malloc(pages * 4);
+	assert(map);
+
+	/* for each page, mark subpage i % 16 read only and subpage
+	 * (i + 3) % 16 inaccessible
+	 */
+	for (i = 0; i < pages; i++)
+		map[i] = (0x40000000 >> (((i + 1) * 2) % 32)) |
+			(0xc0000000 >> (((i + 3) * 2) % 32));
+	err = syscall(310, addr, size, map);
+	if (err) {
+		perror("subpage_perm");
+		return 1;
+	}
+	free(map);
+
+	in_test = 1;
+	errors = 0;
+	for (i = 0; i < pages; i++)
+		for (j = 0; j < 16; j++, addr += 0x1000) {
+			do_read(addr);
+			check_faulted(addr, i, j, 0);
+			do_write(addr);
+			check_faulted(addr, i, j, 1);
+		}
+	in_test = 0;
+	if (errors) {
+		printf("%d errors detected\n", errors);
+		return 1;
+	}
+	printf("OK\n");
+	return 0;
+}
+
+int test_main(void)
+{
+	unsigned long align;
+
+	if (getpagesize() != 0x10000) {
+		fprintf(stderr, "Kernel page size must be 64K!\n");
+		return 1;
+	}
+
+	struct sigaction act = {
+		.sa_sigaction = segv,
+		.sa_flags = SA_SIGINFO
+	};
+	sigaction(SIGSEGV, &act, NULL);
+
+	mallocsize = 4*16*1024*1024;
+	posix_memalign(&mallocblock, 64*1024, mallocsize);
+	assert(mallocblock);
+	align = (unsigned long)mallocblock;
+	if (align & 0xffff)
+		align = (align | 0xffff) + 1;
+	mallocblock = (void *)align;
+
+	printf("allocated malloc block of 0x%lx bytes at 0x%p\n",
+	       mallocsize, mallocblock);
+
+	printf("testing malloc block...\n");
+	return run_test(mallocblock, mallocsize);
+}
+
+int main(void)
+{
+	return test_harness(test_main, "subpage_prot");
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
