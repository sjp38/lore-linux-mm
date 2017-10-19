Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4086B0260
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:24:53 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w134so9743913qkb.13
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:24:53 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v24si1897164qtc.170.2017.10.19.16.24.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 16:24:52 -0700 (PDT)
Subject: Re: [PATCH V3] selftests/vm: Add tests validating mremap mirror
 functionality
References: <20171018055502.31752-1-khandual@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <472ed67c-7c14-29d3-ac22-e9340a05bc06@oracle.com>
Date: Thu, 19 Oct 2017 16:24:46 -0700
MIME-Version: 1.0
In-Reply-To: <20171018055502.31752-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mhocko@kernel.org, shuahkh@osg.samsung.com

On 10/17/2017 10:55 PM, Anshuman Khandual wrote:
> This adds two tests to validate mirror functionality with mremap()
> system call on shared and private anon mappings. After the commit
> dba58d3b8c5 ("mm/mremap: fail map duplication attempts for private
> mappings"), any attempt to mirror private anon mapping will fail.
> 
> Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

The tests themselves look fine.  However, they are pretty simple and
could very easily be combined into one 'mremap_mirror.c' file.  I
would prefer that they be combined, but it is not a deal breaker.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

> ---
> 
> Changes in V3:
> 
> - Fail any attempts to mirror an existing anon private mapping
> - Updated run_vmtests to include these new mremap tests
> - Updated the commit message
> 
> Changes in V2: (https://patchwork.kernel.org/patch/9861259/)
> 
> - Added a test for private anon mappings
> - Used sysconf(_SC_PAGESIZE) instead of hard coding page size
> - Used MREMAP_MAYMOVE instead of hard coding the flag value 1
> 
> Original V1: (https://patchwork.kernel.org/patch/9854415/)
> 
>  tools/testing/selftests/vm/Makefile                |  2 +
>  .../selftests/vm/mremap_mirror_private_anon.c      | 41 +++++++++++++++
>  .../selftests/vm/mremap_mirror_shared_anon.c       | 58 ++++++++++++++++++++++
>  tools/testing/selftests/vm/run_vmtests             | 22 ++++++++
>  4 files changed, 123 insertions(+)
>  create mode 100644 tools/testing/selftests/vm/mremap_mirror_private_anon.c
>  create mode 100644 tools/testing/selftests/vm/mremap_mirror_shared_anon.c
> 
> diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
> index cbb29e4..6401f91 100644
> --- a/tools/testing/selftests/vm/Makefile
> +++ b/tools/testing/selftests/vm/Makefile
> @@ -17,6 +17,8 @@ TEST_GEN_FILES += transhuge-stress
>  TEST_GEN_FILES += userfaultfd
>  TEST_GEN_FILES += mlock-random-test
>  TEST_GEN_FILES += virtual_address_range
> +TEST_GEN_FILES += mremap_mirror_shared_anon
> +TEST_GEN_FILES += mremap_mirror_private_anon
>  
>  TEST_PROGS := run_vmtests
>  
> diff --git a/tools/testing/selftests/vm/mremap_mirror_private_anon.c b/tools/testing/selftests/vm/mremap_mirror_private_anon.c
> new file mode 100644
> index 0000000..e4fa85b
> --- /dev/null
> +++ b/tools/testing/selftests/vm/mremap_mirror_private_anon.c
> @@ -0,0 +1,41 @@
> +/*
> + * Test to verify mirror functionality with mremap() system
> + * call for private anon mappings. Any attempt to create a
> + * mirror mapping for an anon private one should fail.
> + *
> + * Copyright (C) 2017 Anshuman Khandual, IBM Corporation
> + *
> + * Licensed under GPL V2
> + */
> +#define _GNU_SOURCE
> +#include <stdio.h>
> +#include <string.h>
> +#include <unistd.h>
> +#include <errno.h>
> +#include <sys/mman.h>
> +#include <sys/time.h>
> +
> +#define PATTERN		0xbe
> +#define NR_PAGES	10
> +
> +int main(int argc, char *argv[])
> +{
> +	unsigned long alloc_size;
> +	char *ptr, *mirror_ptr;
> +
> +	alloc_size = sysconf(_SC_PAGESIZE) * NR_PAGES;
> +	ptr = mmap(NULL, alloc_size, PROT_READ | PROT_WRITE,
> +			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
> +	if (ptr == MAP_FAILED) {
> +		perror("map() failed");
> +		return -1;
> +	}
> +	memset(ptr, PATTERN, alloc_size);
> +
> +	mirror_ptr =  (char *) mremap(ptr, 0, alloc_size, MREMAP_MAYMOVE);
> +	if (mirror_ptr == MAP_FAILED)
> +		return 0;
> +
> +	printf("Mirror attempt on private anon mapping should have failed\n");
> +	return 1;
> +}
> diff --git a/tools/testing/selftests/vm/mremap_mirror_shared_anon.c b/tools/testing/selftests/vm/mremap_mirror_shared_anon.c
> new file mode 100644
> index 0000000..1d5c838
> --- /dev/null
> +++ b/tools/testing/selftests/vm/mremap_mirror_shared_anon.c
> @@ -0,0 +1,58 @@
> +/*
> + * Test to verify mirror functionality with mremap() system
> + * call for shared anon mappings. The 'mirrored' buffer will
> + * match element to element with that of the original one.
> + *
> + * Copyright (C) 2017 Anshuman Khandual, IBM Corporation
> + *
> + * Licensed under GPL V2
> + */
> +#define _GNU_SOURCE
> +#include <stdio.h>
> +#include <string.h>
> +#include <unistd.h>
> +#include <errno.h>
> +#include <sys/mman.h>
> +#include <sys/time.h>
> +
> +#define PATTERN		0xbe
> +#define NR_PAGES	10
> +
> +int test_mirror(char *old, char *new, unsigned long size)
> +{
> +	unsigned long i;
> +
> +	for (i = 0; i < size; i++) {
> +		if (new[i] != old[i]) {
> +			printf("Mismatch at new[%lu] expected \
> +				%d received %d\n", i, old[i], new[i]);
> +			return 1;
> +		}
> +	}
> +	return 0;
> +}
> +
> +int main(int argc, char *argv[])
> +{
> +	unsigned long alloc_size;
> +	char *ptr, *mirror_ptr;
> +
> +	alloc_size = sysconf(_SC_PAGESIZE) * NR_PAGES;
> +	ptr = mmap(NULL, alloc_size, PROT_READ | PROT_WRITE,
> +			MAP_SHARED | MAP_ANONYMOUS, -1, 0);
> +	if (ptr == MAP_FAILED) {
> +		perror("map() failed");
> +		return -1;
> +	}
> +	memset(ptr, PATTERN, alloc_size);
> +
> +	mirror_ptr =  (char *) mremap(ptr, 0, alloc_size, MREMAP_MAYMOVE);
> +	if (mirror_ptr == MAP_FAILED) {
> +		perror("mremap() failed");
> +		return -1;
> +	}
> +
> +	if (test_mirror(ptr, mirror_ptr, alloc_size))
> +		return 1;
> +	return 0;
> +}
> diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
> index 07548a1..4c8d111 100755
> --- a/tools/testing/selftests/vm/run_vmtests
> +++ b/tools/testing/selftests/vm/run_vmtests
> @@ -176,4 +176,26 @@ else
>  	echo "[PASS]"
>  fi
>  
> +echo "-----------------------------"
> +echo "mremap_mirror_private_anon"
> +echo "-----------------------------"
> +./mremap_mirror_private_anon
> +if [ $? -ne 0 ]; then
> +	echo "[FAIL]"
> +	exitcode=1
> +else
> +	echo "[PASS]"
> +fi
> +
> +echo "-----------------------------"
> +echo "mremap_mirror_shared_anon"
> +echo "-----------------------------"
> +./mremap_mirror_shared_anon
> +if [ $? -ne 0 ]; then
> +	echo "[FAIL]"
> +	exitcode=1
> +else
> +	echo "[PASS]"
> +fi
> +
>  exit $exitcode
> 


-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
