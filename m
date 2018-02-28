Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 027156B0003
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 03:08:15 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id h21so1378853qtm.22
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 00:08:14 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m84si447739qkh.179.2018.02.28.00.08.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 00:08:14 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1S7xgGK027615
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 03:08:13 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gdq1sbd58-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 03:08:13 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 28 Feb 2018 08:08:11 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] selftests/vm: Update max va test to check for high address return.
In-Reply-To: <20180228035830.10089-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20180228035830.10089-1-aneesh.kumar@linux.vnet.ibm.com>
Date: Wed, 28 Feb 2018 13:38:05 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87vaeha656.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> mmap(-1,..) is expected to search from max supported VA top down. It should find
> an address above ADDR_SWITCH_HINT. Explicitly check for this.
>
> Also derefer the address even if we failed the addr check.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

One issue I noticed is how to make this conditional so that we can still
run the test on x86 with 4 level page table?

> ---
>  tools/testing/selftests/vm/va_128TBswitch.c | 27 ++++++++++++++++++++-------
>  1 file changed, 20 insertions(+), 7 deletions(-)
>
> diff --git a/tools/testing/selftests/vm/va_128TBswitch.c b/tools/testing/selftests/vm/va_128TBswitch.c
> index e7fe734c374f..f68fa4bd8179 100644
> --- a/tools/testing/selftests/vm/va_128TBswitch.c
> +++ b/tools/testing/selftests/vm/va_128TBswitch.c
> @@ -44,6 +44,7 @@ struct testcase {
>  	unsigned long flags;
>  	const char *msg;
>  	unsigned int low_addr_required:1;
> +	unsigned int high_addr_required:1;
>  	unsigned int keep_mapped:1;
>  };
>  
> @@ -108,6 +109,7 @@ static struct testcase testcases[] = {
>  		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
>  		.msg = "mmap(HIGH_ADDR)",
>  		.keep_mapped = 1,
> +		.high_addr_required = 1,
>  	},
>  	{
>  		.addr = HIGH_ADDR,
> @@ -115,12 +117,14 @@ static struct testcase testcases[] = {
>  		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
>  		.msg = "mmap(HIGH_ADDR) again",
>  		.keep_mapped = 1,
> +		.high_addr_required = 1,
>  	},
>  	{
>  		.addr = HIGH_ADDR,
>  		.size = 2 * PAGE_SIZE,
>  		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
>  		.msg = "mmap(HIGH_ADDR, MAP_FIXED)",
> +		.high_addr_required = 1,
>  	},
>  	{
>  		.addr = (void *) -1,
> @@ -128,12 +132,14 @@ static struct testcase testcases[] = {
>  		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
>  		.msg = "mmap(-1)",
>  		.keep_mapped = 1,
> +		.high_addr_required = 1,
>  	},
>  	{
>  		.addr = (void *) -1,
>  		.size = 2 * PAGE_SIZE,
>  		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
>  		.msg = "mmap(-1) again",
> +		.high_addr_required = 1,
>  	},
>  	{
>  		.addr = ((void *)(ADDR_SWITCH_HINT - PAGE_SIZE)),
> @@ -193,6 +199,7 @@ static struct testcase hugetlb_testcases[] = {
>  		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
>  		.msg = "mmap(HIGH_ADDR, MAP_HUGETLB)",
>  		.keep_mapped = 1,
> +		.high_addr_required = 1,
>  	},
>  	{
>  		.addr = HIGH_ADDR,
> @@ -200,12 +207,14 @@ static struct testcase hugetlb_testcases[] = {
>  		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
>  		.msg = "mmap(HIGH_ADDR, MAP_HUGETLB) again",
>  		.keep_mapped = 1,
> +		.high_addr_required = 1,
>  	},
>  	{
>  		.addr = HIGH_ADDR,
>  		.size = HUGETLB_SIZE,
>  		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
>  		.msg = "mmap(HIGH_ADDR, MAP_FIXED | MAP_HUGETLB)",
> +		.high_addr_required = 1,
>  	},
>  	{
>  		.addr = (void *) -1,
> @@ -213,12 +222,14 @@ static struct testcase hugetlb_testcases[] = {
>  		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
>  		.msg = "mmap(-1, MAP_HUGETLB)",
>  		.keep_mapped = 1,
> +		.high_addr_required = 1,
>  	},
>  	{
>  		.addr = (void *) -1,
>  		.size = HUGETLB_SIZE,
>  		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
>  		.msg = "mmap(-1, MAP_HUGETLB) again",
> +		.high_addr_required = 1,
>  	},
>  	{
>  		.addr = (void *)(ADDR_SWITCH_HINT - PAGE_SIZE),
> @@ -257,14 +268,16 @@ static int run_test(struct testcase *test, int count)
>  		if (t->low_addr_required && p >= (void *)(ADDR_SWITCH_HINT)) {
>  			printf("FAILED\n");
>  			ret = 1;
> -		} else {
> -			/*
> -			 * Do a dereference of the address returned so that we catch
> -			 * bugs in page fault handling
> -			 */
> -			memset(p, 0, t->size);
> +		} else if (t->high_addr_required && p < (void *)(ADDR_SWITCH_HINT)) {
> +			printf("FAILED\n");
> +			ret = 1;
> +		} else
>  			printf("OK\n");
> -		}
> +		/*
> +		 * Do a dereference of the address returned so that we catch
> +		 * bugs in page fault handling
> +		 */
> +		memset(p, 0, t->size);
>  		if (!t->keep_mapped)
>  			munmap(p, t->size);
>  	}
> -- 
> 2.14.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
