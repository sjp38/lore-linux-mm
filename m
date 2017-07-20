Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9861C6B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 19:19:50 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n43so24888111qtc.13
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 16:19:50 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id z60si2684430qtc.86.2017.07.20.16.19.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 16:19:49 -0700 (PDT)
Subject: Re: [PATCH] selftests/vm: Add test to validate mirror functionality
 with mremap
References: <20170720093651.22106-1-khandual@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <965cf169-572c-537b-6784-766edcb4eb19@oracle.com>
Date: Thu, 20 Jul 2017 16:19:31 -0700
MIME-Version: 1.0
In-Reply-To: <20170720093651.22106-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org

On 07/20/2017 02:36 AM, Anshuman Khandual wrote:
> This adds a test to validate mirror functionality with mremap()
> system call on shared anon mappings.
> 
> Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  tools/testing/selftests/vm/Makefile                |  1 +
>  .../selftests/vm/mremap_mirror_shared_anon.c       | 54 ++++++++++++++++++++++

This may be a better fit in LTP where there are already several other
mremap tests.  I honestly do not know the best place for such a test.

>  2 files changed, 55 insertions(+)
>  create mode 100644 tools/testing/selftests/vm/mremap_mirror_shared_anon.c
> 
> diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
> index cbb29e4..11657ff5 100644
> --- a/tools/testing/selftests/vm/Makefile
> +++ b/tools/testing/selftests/vm/Makefile
> @@ -17,6 +17,7 @@ TEST_GEN_FILES += transhuge-stress
>  TEST_GEN_FILES += userfaultfd
>  TEST_GEN_FILES += mlock-random-test
>  TEST_GEN_FILES += virtual_address_range
> +TEST_GEN_FILES += mremap_mirror_shared_anon
>  
>  TEST_PROGS := run_vmtests
>  
> diff --git a/tools/testing/selftests/vm/mremap_mirror_shared_anon.c b/tools/testing/selftests/vm/mremap_mirror_shared_anon.c
> new file mode 100644
> index 0000000..b0adbb2
> --- /dev/null
> +++ b/tools/testing/selftests/vm/mremap_mirror_shared_anon.c
> @@ -0,0 +1,54 @@
> +/*
> + * Test to verify mirror functionality with mremap() system
> + * call for shared anon mappings.
> + *
> + * Copyright (C) 2017 Anshuman Khandual, IBM Corporation
> + *
> + * Licensed under GPL V2
> + */
> +#include <stdio.h>
> +#include <string.h>
> +#include <unistd.h>
> +#include <errno.h>
> +#include <sys/mman.h>
> +#include <sys/time.h>
> +
> +#define PATTERN		0xbe
> +#define ALLOC_SIZE	0x10000UL /* Works for 64K and 4K pages */

Why hardcode?  You could use sysconf to get page size and use some
multiple of that.

> +
> +int test_mirror(char *old, char *new, unsigned long size)
> +{
> +	unsigned long i;
> +
> +	for (i = 0; i < size; i++) {
> +		if (new[i] != old[i]) {
> +			printf("Mismatch at new[%lu] expected "
> +				"%d received %d\n", i, old[i], new[i]);
> +			return 1;
> +		}
> +	}
> +	return 0;
> +}
> +
> +int main(int argc, char *argv[])
> +{
> +	char *ptr, *mirror_ptr;
> +
> +	ptr = mmap(NULL, ALLOC_SIZE, PROT_READ | PROT_WRITE,
> +			MAP_SHARED | MAP_ANONYMOUS, -1, 0);
> +	if (ptr == MAP_FAILED) {
> +		perror("map() failed");
> +		return -1;
> +	}
> +	memset(ptr, PATTERN, ALLOC_SIZE);
> +
> +	mirror_ptr =  (char *) mremap(ptr, 0, ALLOC_SIZE, 1);

Why hardcode 1?  You really want the MREMAP_MAYMOVE flag.  Right?

> +	if (mirror_ptr == MAP_FAILED) {
> +		perror("mremap() failed");
> +		return -1;
> +	}
> +
> +	if (test_mirror(ptr, mirror_ptr, ALLOC_SIZE))
> +		return 1;
> +	return 0;
> +}

You may want to expand the test to make sure mremap(old_size == 0)
fails for private mappings.  Of course, this assumes my proposed
patch gets in.  Until then, it will succeed and create a new unrelated
mapping.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
