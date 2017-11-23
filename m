Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 30F9B6B0033
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 22:42:21 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l4so8912472wre.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:42:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y18si6576943edm.29.2017.11.22.19.42.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 19:42:19 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAN3cvim010975
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 22:42:18 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2edp0xt9w6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 22:42:17 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 23 Nov 2017 03:42:15 -0000
Subject: Re: [PATCH V2] selftest/vm: Add test case for mmap across 128TB
 boundary.
References: <20171123030313.6418-1-aneesh.kumar@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 23 Nov 2017 09:12:09 +0530
MIME-Version: 1.0
In-Reply-To: <20171123030313.6418-1-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <9b911930-ca95-b325-e032-918b21984727@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/23/2017 08:33 AM, Aneesh Kumar K.V wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> This patch add a self-test that covers a few corner cases of the interface.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
> 
> Changes from V1:
> * Add the test to run_vmtests script
> 
>  tools/testing/selftests/vm/Makefile         |   1 +
>  tools/testing/selftests/vm/run_vmtests      |  11 ++
>  tools/testing/selftests/vm/va_128TBswitch.c | 297 ++++++++++++++++++++++++++++
>  3 files changed, 309 insertions(+)
>  create mode 100644 tools/testing/selftests/vm/va_128TBswitch.c
> 
> diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
> index cbb29e41ef2b..b1fb3cd7cf52 100644
> --- a/tools/testing/selftests/vm/Makefile
> +++ b/tools/testing/selftests/vm/Makefile
> @@ -17,6 +17,7 @@ TEST_GEN_FILES += transhuge-stress
>  TEST_GEN_FILES += userfaultfd
>  TEST_GEN_FILES += mlock-random-test
>  TEST_GEN_FILES += virtual_address_range
> +TEST_GEN_FILES += va_128TBswitch

This will conflict with a test case for mremap clone functionality
which might have been queued in Shuah's tree.

https://patchwork.kernel.org/patch/10031943/

>  
>  TEST_PROGS := run_vmtests
>  
> diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
> index 07548a1fa901..d8305fb83125 100755
> --- a/tools/testing/selftests/vm/run_vmtests
> +++ b/tools/testing/selftests/vm/run_vmtests
> @@ -176,4 +176,15 @@ else
>  	echo "[PASS]"
>  fi
>  
> +echo "-----------------------------"
> +echo "running virtual address 128TB switch test"
> +echo "-----------------------------"
> +./va_128TBswitch
> +if [ $? -ne 0 ]; then
> +    echo "[FAIL]"
> +    exitcode=1
> +else
> +    echo "[PASS]"
> +fi
> +
>  exit $exitcode
> diff --git a/tools/testing/selftests/vm/va_128TBswitch.c b/tools/testing/selftests/vm/va_128TBswitch.c
> new file mode 100644
> index 000000000000..2fdb84ab94b1
> --- /dev/null
> +++ b/tools/testing/selftests/vm/va_128TBswitch.c
> @@ -0,0 +1,297 @@
> +/*
> + *
> + * Authors: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> + * Authors: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of version 2.1 of the GNU Lesser General Public License
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it would be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
> + *
> + */
> +
> +#include <stdio.h>
> +#include <sys/mman.h>
> +#include <string.h>
> +
> +#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
> +
> +#ifdef __powerpc64__
> +#define PAGE_SIZE	(64 << 10)
> +/*
> + * This will work with 16M and 2M hugepage size
> + */
> +#define HUGETLB_SIZE	(16 << 20)
> +#else
> +#define PAGE_SIZE	(4 << 10)
> +#define HUGETLB_SIZE	(2 << 20)
> +#endif
> +
> +/*
> + * >= 128TB is the hint addr value we used to select
> + * large address space.
> + */
> +#define ADDR_SWITCH_HINT (1UL << 47)
> +#define LOW_ADDR	((void *) (1UL << 30))
> +#define HIGH_ADDR	((void *) (1UL << 48))

Is there any particular reason for choosing 1GB as low and 256TB
as high address ?

> +
> +struct testcase {
> +	void *addr;
> +	unsigned long size;
> +	unsigned long flags;
> +	const char *msg;
> +	unsigned int low_addr_required:1;
> +	unsigned int keep_mapped:1;
> +};
> +
> +static struct testcase testcases[] = {
> +	{
> +		/*
> +		 * If stack is moved, we could possibly allocate
> +		 * this at the requested address.
> +		 */
> +		.addr = ((void *)(ADDR_SWITCH_HINT - PAGE_SIZE)),
> +		.size = PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, PAGE_SIZE)",
> +		.low_addr_required = 1,
> +	},
> +	{
> +		/*
> +		 * We should never allocate at the requested address or above it
> +		 * The len cross the 128TB boundary. Without MAP_FIXED
> +		 * we will always search in the lower address space.
> +		 */
> +		.addr = ((void *)(ADDR_SWITCH_HINT - PAGE_SIZE)),
> +		.size = 2 * PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, (2 * PAGE_SIZE))",
> +		.low_addr_required = 1,
> +	},
> +	{
> +		/*
> +		 * Exact mapping at 128TB, the area is free we should get that
> +		 * even without MAP_FIXED.
> +		 */
> +		.addr = ((void *)(ADDR_SWITCH_HINT)),
> +		.size = PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(ADDR_SWITCH_HINT, PAGE_SIZE)",
> +		.keep_mapped = 1,
> +	},
> +	{
> +		.addr = (void *)(ADDR_SWITCH_HINT),
> +		.size = 2 * PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
> +		.msg = "mmap(ADDR_SWITCH_HINT, 2 * PAGE_SIZE, MAP_FIXED)",
> +	},
> +	{
> +		.addr = NULL,
> +		.size = 2 * PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(NULL)",
> +		.low_addr_required = 1,
> +	},
> +	{
> +		.addr = LOW_ADDR,
> +		.size = 2 * PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(LOW_ADDR)",
> +		.low_addr_required = 1,
> +	},
> +	{
> +		.addr = HIGH_ADDR,
> +		.size = 2 * PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(HIGH_ADDR)",
> +		.keep_mapped = 1,
> +	},
> +	{
> +		.addr = HIGH_ADDR,
> +		.size = 2 * PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(HIGH_ADDR) again",
> +		.keep_mapped = 1,
> +	},
> +	{
> +		.addr = HIGH_ADDR,
> +		.size = 2 * PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
> +		.msg = "mmap(HIGH_ADDR, MAP_FIXED)",
> +	},
> +	{
> +		.addr = (void *) -1,
> +		.size = 2 * PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(-1)",
> +		.keep_mapped = 1,
> +	},
> +	{
> +		.addr = (void *) -1,
> +		.size = 2 * PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(-1) again",
> +	},
> +	{
> +		.addr = ((void *)(ADDR_SWITCH_HINT - PAGE_SIZE)),
> +		.size = PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, PAGE_SIZE)",
> +		.low_addr_required = 1,
> +	},
> +	{
> +		.addr = (void *)(ADDR_SWITCH_HINT - PAGE_SIZE),
> +		.size = 2 * PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, 2 * PAGE_SIZE)",
> +		.low_addr_required = 1,
> +		.keep_mapped = 1,
> +	},
> +	{
> +		.addr = (void *)(ADDR_SWITCH_HINT - PAGE_SIZE / 2),
> +		.size = 2 * PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE/2 , 2 * PAGE_SIZE)",
> +		.low_addr_required = 1,
> +		.keep_mapped = 1,
> +	},
> +	{
> +		.addr = ((void *)(ADDR_SWITCH_HINT)),
> +		.size = PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(ADDR_SWITCH_HINT, PAGE_SIZE)",
> +	},
> +	{
> +		.addr = (void *)(ADDR_SWITCH_HINT),
> +		.size = 2 * PAGE_SIZE,
> +		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
> +		.msg = "mmap(ADDR_SWITCH_HINT, 2 * PAGE_SIZE, MAP_FIXED)",
> +	},
> +};
> +
> +static struct testcase hugetlb_testcases[] = {
> +	{
> +		.addr = NULL,
> +		.size = HUGETLB_SIZE,
> +		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(NULL, MAP_HUGETLB)",
> +		.low_addr_required = 1,
> +	},
> +	{
> +		.addr = LOW_ADDR,
> +		.size = HUGETLB_SIZE,
> +		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(LOW_ADDR, MAP_HUGETLB)",
> +		.low_addr_required = 1,
> +	},
> +	{
> +		.addr = HIGH_ADDR,
> +		.size = HUGETLB_SIZE,
> +		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(HIGH_ADDR, MAP_HUGETLB)",
> +		.keep_mapped = 1,
> +	},
> +	{
> +		.addr = HIGH_ADDR,
> +		.size = HUGETLB_SIZE,
> +		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(HIGH_ADDR, MAP_HUGETLB) again",
> +		.keep_mapped = 1,
> +	},
> +	{
> +		.addr = HIGH_ADDR,
> +		.size = HUGETLB_SIZE,
> +		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
> +		.msg = "mmap(HIGH_ADDR, MAP_FIXED | MAP_HUGETLB)",
> +	},
> +	{
> +		.addr = (void *) -1,
> +		.size = HUGETLB_SIZE,
> +		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(-1, MAP_HUGETLB)",
> +		.keep_mapped = 1,
> +	},
> +	{
> +		.addr = (void *) -1,
> +		.size = HUGETLB_SIZE,
> +		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(-1, MAP_HUGETLB) again",
> +	},
> +	{
> +		.addr = (void *)(ADDR_SWITCH_HINT - PAGE_SIZE),
> +		.size = 2 * HUGETLB_SIZE,
> +		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
> +		.msg = "mmap(ADDR_SWITCH_HINT - PAGE_SIZE, 2*HUGETLB_SIZE, MAP_HUGETLB)",
> +		.low_addr_required = 1,
> +		.keep_mapped = 1,
> +	},
> +	{
> +		.addr = (void *)(ADDR_SWITCH_HINT),
> +		.size = 2 * HUGETLB_SIZE,
> +		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
> +		.msg = "mmap(ADDR_SWITCH_HINT , 2*HUGETLB_SIZE, MAP_FIXED | MAP_HUGETLB)",
> +	},
> +};

Does the test permutations with 'keep_mapped' form some sort of corner
case for later test cases ? If yes, could you please describe it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
