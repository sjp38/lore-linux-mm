Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D999D6B0268
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 05:14:26 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p65so2352647wma.1
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 02:14:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d12sor10191745edh.37.2017.11.23.02.14.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 02:14:25 -0800 (PST)
Date: Thu, 23 Nov 2017 13:14:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V2] selftest/vm: Add test case for mmap across 128TB
 boundary.
Message-ID: <20171123101422.6fu7ehvjuw2v5jjh@node.shutemov.name>
References: <20171123030313.6418-1-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123030313.6418-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 23, 2017 at 08:33:13AM +0530, Aneesh Kumar K.V wrote:
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

Patch with my selftest is already in -tip tree. I think this selftest
should replace it, not add another one.

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

LGPL? Why?

> + *
> + * This program is distributed in the hope that it would be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
> + *
> + */
> +
> +static int run_test(struct testcase *test, int count)
> +{
> +	void *p;
> +	int i, ret = 0;
> +
> +	for (i = 0; i < count; i++) {
> +		struct testcase *t = test + i;
> +
> +		p = mmap(t->addr, t->size, PROT_READ | PROT_WRITE, t->flags, -1, 0);
> +
> +		printf("%s: %p - ", t->msg, p);
> +
> +		if (p == MAP_FAILED) {
> +			printf("FAILED\n");
> +			ret = 1;
> +			continue;
> +		}
> +
> +		if (t->low_addr_required && p >= (void *)(1UL << 47)) {
> +			printf("FAILED\n");
> +			ret = 1;
> +		} else {
> +			/*
> +			 * Do a dereference of the address returned so that we catch
> +			 * bugs in page fault handling
> +			 */
> +			*(int *)p = 10;

If we are going to touch memory, maybe not just first page, but whole
range? memset()?

> +			printf("OK\n");
> +		}
> +		if (!t->keep_mapped)
> +			munmap(p, t->size);
> +	}
> +
> +	return ret;
> +}

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
