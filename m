Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3C116B0038
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 06:36:40 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w95so9942797wrc.20
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 03:36:40 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d18si7795113edj.346.2017.11.22.03.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 03:36:38 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAMBY1bM114560
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 06:36:37 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ed88ygucy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 06:36:36 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 22 Nov 2017 11:36:34 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv3 2/2] x86/selftests: Add test for mapping placement for 5-level paging
In-Reply-To: <20171122081147.5gjushlstmnnmlev@node.shutemov.name>
References: <20171115143607.81541-1-kirill.shutemov@linux.intel.com> <20171115143607.81541-2-kirill.shutemov@linux.intel.com> <87y3myzx7z.fsf@linux.vnet.ibm.com> <20171122081147.5gjushlstmnnmlev@node.shutemov.name>
Date: Wed, 22 Nov 2017 17:06:27 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87vai2zgsk.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Wed, Nov 22, 2017 at 11:11:36AM +0530, Aneesh Kumar K.V wrote:
>> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
>> 
>> > With 5-level paging, we have 56-bit virtual address space available for
>> > userspace. But we don't want to expose userspace to addresses above
>> > 47-bits, unless it asked specifically for it.
>> >
>> > We use mmap(2) hint address as a way for kernel to know if it's okay to
>> > allocate virtual memory above 47-bit.
>> >
>> > Let's add a self-test that covers few corner cases of the interface.
>> >
>> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> 
>> Can we move this to selftest/vm/ ? I had a variant which i was using to
>> test issues on ppc64. One change we did recently was to use >=128TB as
>> the hint addr value to select larger address space. I also would like to
>> check for exact mmap return addr in some case. Attaching below the test
>> i was using. I will check whether this patch can be updated to test what
>> is converted in my selftest. I also want to do the boundary check twice.
>> The hash trasnslation mode in POWER require us to track addr limit and
>> we had bugs around address space slection before and after updating the
>> addr limit.
>
> Feel free to move it to selftest/vm. I don't have time to test setup and
> test it on Power myself, but this would be great.
>

How about the below? Do you want me to send this as a patch to the list? 

#include <stdio.h>
#include <sys/mman.h>
#include <string.h>

#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))

#ifdef __powerpc64__
#define PAGE_SIZE	64*1024
/*
 * This will work with 16M and 2M hugepage size
 */
#define HUGETLB_SIZE	16*1024*1024
#else
#define PAGE_SIZE	4096
#define HUGETLB_SIZE	2*1024*1024
#endif

/*
 * >= 128TB is the hint addr value we used to select
 * large address space.
 */
#define ADDR_SWITCH_HINT (1UL << 47)
#define LOW_ADDR	((void *) (1UL << 30))
#define HIGH_ADDR	((void *) (1UL << 48))

struct testcase {
	void *addr;
	unsigned long size;
	unsigned long flags;
	const char *msg;
	unsigned int addr_check_cond;
	unsigned int low_addr_required:1;
	unsigned int keep_mapped:1;
};

static struct testcase testcases[] = {
	{
		/*
		 * If stack is moved, we could possibly allocate
		 * this at the requested address.
		 */
		.addr = ((void *)(ADDR_SWITCH_HINT - PAGE_SIZE)),
		.size = PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, PAGE_SIZE)",
		.low_addr_required = 1,
	},
	{
		/*
		 * We should never allocate at the requested address or above it
		 * The len cross the 128TB boundary. Without MAP_FIXED
		 * we will always search in the lower address space.
		 */
		.addr = ((void *)(ADDR_SWITCH_HINT - PAGE_SIZE)),
		.size = 2 * PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, (2 * PAGE_SIZE))",
		.low_addr_required = 1,
	},
	{
		/*
		 * Exact mapping at 128TB, the area is free we should get that
		 * even without MAP_FIXED.
		 */
		.addr = ((void *)(ADDR_SWITCH_HINT)),
		.size = PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(ADDR_SWITCH_HINT, PAGE_SIZE)",
		.keep_mapped = 1,
	},
	{
		.addr = (void *)(ADDR_SWITCH_HINT),
		.size = 2 * PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
		.msg = "mmap(ADDR_SWITCH_HINT, 2 * PAGE_SIZE, MAP_FIXED)",
	},
	{
		.addr = NULL,
		.size = 2 * PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(NULL)",
		.low_addr_required = 1,
	},
	{
		.addr = LOW_ADDR,
		.size = 2 * PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(LOW_ADDR)",
		.low_addr_required = 1,
	},
	{
		.addr = HIGH_ADDR,
		.size = 2 * PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(HIGH_ADDR)",
		.keep_mapped = 1,
	},
	{
		.addr = HIGH_ADDR,
		.size = 2 * PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(HIGH_ADDR) again",
		.keep_mapped = 1,
	},
	{
		.addr = HIGH_ADDR,
		.size = 2 * PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
		.msg = "mmap(HIGH_ADDR, MAP_FIXED)",
	},
	{
		.addr = (void*) -1,
		.size = 2 * PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(-1)",
		.keep_mapped = 1,
	},
	{
		.addr = (void*) -1,
		.size = 2 * PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(-1) again",
	},
	{
		.addr = ((void *)(ADDR_SWITCH_HINT - PAGE_SIZE)),
		.size = PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, PAGE_SIZE)",
		.low_addr_required = 1,
	},
	{
		.addr = (void *)(ADDR_SWITCH_HINT - PAGE_SIZE),
		.size = 2 * PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, 2 * PAGE_SIZE)",
		.low_addr_required = 1,
		.keep_mapped = 1,
	},
	{
		.addr = (void *)(ADDR_SWITCH_HINT - PAGE_SIZE / 2),
		.size = 2 * PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE/2 , 2 * PAGE_SIZE)",
		.low_addr_required = 1,
		.keep_mapped = 1,
	},
	{
		.addr = ((void *)(ADDR_SWITCH_HINT)),
		.size = PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(ADDR_SWITCH_HINT, PAGE_SIZE)",
	},
	{
		.addr = (void *)(ADDR_SWITCH_HINT),
		.size = 2 * PAGE_SIZE,
		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
		.msg = "mmap(ADDR_SWITCH_HINT, 2 * PAGE_SIZE, MAP_FIXED)",
	},
};

static struct testcase hugetlb_testcases[] = {
	{
		.addr = NULL,
		.size = HUGETLB_SIZE,
		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(NULL, MAP_HUGETLB)",
		.low_addr_required = 1,
	},
	{
		.addr = LOW_ADDR,
		.size = HUGETLB_SIZE,
		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(LOW_ADDR, MAP_HUGETLB)",
		.low_addr_required = 1,
	},
	{
		.addr = HIGH_ADDR,
		.size = HUGETLB_SIZE,
		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(HIGH_ADDR, MAP_HUGETLB)",
		.keep_mapped = 1,
	},
	{
		.addr = HIGH_ADDR,
		.size = HUGETLB_SIZE,
		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(HIGH_ADDR, MAP_HUGETLB) again",
		.keep_mapped = 1,
	},
	{
		.addr = HIGH_ADDR,
		.size = HUGETLB_SIZE,
		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
		.msg = "mmap(HIGH_ADDR, MAP_FIXED | MAP_HUGETLB)",
	},
	{
		.addr = (void*) -1,
		.size = HUGETLB_SIZE,
		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(-1, MAP_HUGETLB)",
		.keep_mapped = 1,
	},
	{
		.addr = (void*) -1,
		.size = HUGETLB_SIZE,
		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap(-1, MAP_HUGETLB) again",
	},
	{
		.addr = (void *)(ADDR_SWITCH_HINT - PAGE_SIZE),
		.size = 2 * HUGETLB_SIZE,
		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
		.msg = "mmap((1UL << 47), 4UL << 20, MAP_HUGETLB)",
		.low_addr_required = 1,
		.keep_mapped = 1,
	},
	{
		.addr = (void *)(ADDR_SWITCH_HINT),
		.size = 2 * HUGETLB_SIZE,
		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
		.msg = "mmap(ADDR_SWITCH_HINT , 2 * HUGETLB_SIZE, MAP_FIXED | MAP_HUGETLB)",
	},
};

static void run_test(struct testcase *test, int count)
{
	int i;
	void *p;

	for (i = 0; i < count; i++) {
		struct testcase *t = test + i;

		p = mmap(t->addr, t->size, PROT_READ | PROT_WRITE, t->flags, -1, 0);

		printf("%s: %p - ", t->msg, p);

		if (p == MAP_FAILED) {
			printf("FAILED\n");
			continue;
		}

		if (t->low_addr_required && p >= (void *)(1UL << 47))
			printf("FAILED\n");
		else {
			/*
			 * Do a dereference of the address returned so that we catch
			 * bugs in page fault handling
			 */
			*(int *)p = 10;
			printf("OK\n");
		}
		if (!t->keep_mapped)
			munmap(p, t->size);
	}
}

static int supported_arch(void)
{
#if defined(__powerpc64__)
	return 1;
#elif defined(__x86_64__)
	return 1;
#else
	return 0;
#endif
}

int main(int argc, char **argv)
{
	if (!supported_arch())
		return 0;

	run_test(testcases, ARRAY_SIZE(testcases));
	if (argc == 2 && !strcmp(argv[1], "--run_hugetlb"))
		run_test(hugetlb_testcases, ARRAY_SIZE(hugetlb_testcases));
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
