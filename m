Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 39B3D6B0268
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 20:32:51 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 189so457953iow.14
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 17:32:51 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k78si59464iod.151.2017.11.06.17.32.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 17:32:50 -0800 (PST)
Subject: Re: [PATCH v2 8/9] memfd-test: move common code to a shared unit
References: <20171106143944.13821-1-marcandre.lureau@redhat.com>
 <20171106143944.13821-9-marcandre.lureau@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <2bc46777-4ab8-977f-44a7-160400abb881@oracle.com>
Date: Mon, 6 Nov 2017 17:32:41 -0800
MIME-Version: 1.0
In-Reply-To: <20171106143944.13821-9-marcandre.lureau@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

On 11/06/2017 06:39 AM, Marc-AndrA(C) Lureau wrote:
> The memfd & fuse tests will share more common code in the following
> commits to test hugetlb support.
> 
> Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

> ---
>  tools/testing/selftests/memfd/Makefile     |  5 ++++
>  tools/testing/selftests/memfd/common.c     | 45 ++++++++++++++++++++++++++++++
>  tools/testing/selftests/memfd/common.h     |  9 ++++++
>  tools/testing/selftests/memfd/fuse_test.c  |  8 ++----
>  tools/testing/selftests/memfd/memfd_test.c | 36 ++----------------------
>  5 files changed, 63 insertions(+), 40 deletions(-)
>  create mode 100644 tools/testing/selftests/memfd/common.c
>  create mode 100644 tools/testing/selftests/memfd/common.h
> 
> diff --git a/tools/testing/selftests/memfd/Makefile b/tools/testing/selftests/memfd/Makefile
> index 3926a0409dda..a5276a91dfbf 100644
> --- a/tools/testing/selftests/memfd/Makefile
> +++ b/tools/testing/selftests/memfd/Makefile
> @@ -12,3 +12,8 @@ fuse_mnt.o: CFLAGS += $(shell pkg-config fuse --cflags)
>  include ../lib.mk
>  
>  $(OUTPUT)/fuse_mnt: LDLIBS += $(shell pkg-config fuse --libs)
> +
> +$(OUTPUT)/memfd_test: memfd_test.c common.o
> +$(OUTPUT)/fuse_test: fuse_test.c common.o
> +
> +EXTRA_CLEAN = common.o
> diff --git a/tools/testing/selftests/memfd/common.c b/tools/testing/selftests/memfd/common.c
> new file mode 100644
> index 000000000000..7ed269cd3abb
> --- /dev/null
> +++ b/tools/testing/selftests/memfd/common.c
> @@ -0,0 +1,45 @@
> +// SPDX-License-Identifier: GPL-2.0
> +#define _GNU_SOURCE
> +#define __EXPORTED_HEADERS__
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <linux/fcntl.h>
> +#include <linux/memfd.h>
> +#include <sys/syscall.h>
> +
> +#include "common.h"
> +
> +int hugetlbfs_test = 0;
> +
> +/*
> + * Copied from mlock2-tests.c
> + */
> +unsigned long default_huge_page_size(void)
> +{
> +	unsigned long hps = 0;
> +	char *line = NULL;
> +	size_t linelen = 0;
> +	FILE *f = fopen("/proc/meminfo", "r");
> +
> +	if (!f)
> +		return 0;
> +	while (getline(&line, &linelen, f) > 0) {
> +		if (sscanf(line, "Hugepagesize:       %lu kB", &hps) == 1) {
> +			hps <<= 10;
> +			break;
> +		}
> +	}
> +
> +	free(line);
> +	fclose(f);
> +	return hps;
> +}
> +
> +int sys_memfd_create(const char *name, unsigned int flags)
> +{
> +	if (hugetlbfs_test)
> +		flags |= MFD_HUGETLB;
> +
> +	return syscall(__NR_memfd_create, name, flags);
> +}
> diff --git a/tools/testing/selftests/memfd/common.h b/tools/testing/selftests/memfd/common.h
> new file mode 100644
> index 000000000000..522d2c630bd8
> --- /dev/null
> +++ b/tools/testing/selftests/memfd/common.h
> @@ -0,0 +1,9 @@
> +#ifndef COMMON_H_
> +#define COMMON_H_
> +
> +extern int hugetlbfs_test;
> +
> +unsigned long default_huge_page_size(void);
> +int sys_memfd_create(const char *name, unsigned int flags);
> +
> +#endif
> diff --git a/tools/testing/selftests/memfd/fuse_test.c b/tools/testing/selftests/memfd/fuse_test.c
> index 1ccb7a3eb14b..795a25ba8521 100644
> --- a/tools/testing/selftests/memfd/fuse_test.c
> +++ b/tools/testing/selftests/memfd/fuse_test.c
> @@ -33,15 +33,11 @@
>  #include <sys/wait.h>
>  #include <unistd.h>
>  
> +#include "common.h"
> +
>  #define MFD_DEF_SIZE 8192
>  #define STACK_SIZE 65536
>  
> -static int sys_memfd_create(const char *name,
> -			    unsigned int flags)
> -{
> -	return syscall(__NR_memfd_create, name, flags);
> -}
> -
>  static int mfd_assert_new(const char *name, loff_t sz, unsigned int flags)
>  {
>  	int r, fd;
> diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
> index 955d09ee16ca..4c049b6b6985 100644
> --- a/tools/testing/selftests/memfd/memfd_test.c
> +++ b/tools/testing/selftests/memfd/memfd_test.c
> @@ -19,6 +19,8 @@
>  #include <sys/wait.h>
>  #include <unistd.h>
>  
> +#include "common.h"
> +
>  #define MEMFD_STR	"memfd:"
>  #define MEMFD_HUGE_STR	"memfd-hugetlb:"
>  #define SHARED_FT_STR	"(shared file-table)"
> @@ -29,43 +31,9 @@
>  /*
>   * Default is not to test hugetlbfs
>   */
> -static int hugetlbfs_test;
>  static size_t mfd_def_size = MFD_DEF_SIZE;
>  static const char *memfd_str = MEMFD_STR;
>  
> -/*
> - * Copied from mlock2-tests.c
> - */
> -static unsigned long default_huge_page_size(void)
> -{
> -	unsigned long hps = 0;
> -	char *line = NULL;
> -	size_t linelen = 0;
> -	FILE *f = fopen("/proc/meminfo", "r");
> -
> -	if (!f)
> -		return 0;
> -	while (getline(&line, &linelen, f) > 0) {
> -		if (sscanf(line, "Hugepagesize:       %lu kB", &hps) == 1) {
> -			hps <<= 10;
> -			break;
> -		}
> -	}
> -
> -	free(line);
> -	fclose(f);
> -	return hps;
> -}
> -
> -static int sys_memfd_create(const char *name,
> -			    unsigned int flags)
> -{
> -	if (hugetlbfs_test)
> -		flags |= MFD_HUGETLB;
> -
> -	return syscall(__NR_memfd_create, name, flags);
> -}
> -
>  static int mfd_assert_new(const char *name, loff_t sz, unsigned int flags)
>  {
>  	int r, fd;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
