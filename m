Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3F56B0005
	for <linux-mm@kvack.org>; Sat, 13 Oct 2018 21:16:51 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id d23-v6so10224897ywd.8
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 18:16:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g37-v6sor670758ywk.197.2018.10.13.18.16.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 13 Oct 2018 18:16:50 -0700 (PDT)
Received: from mail-yw1-f42.google.com (mail-yw1-f42.google.com. [209.85.161.42])
        by smtp.gmail.com with ESMTPSA id y206-v6sm1651606ywg.57.2018.10.13.18.16.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Oct 2018 18:16:46 -0700 (PDT)
Received: by mail-yw1-f42.google.com with SMTP id v1-v6so6348030ywv.6
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 18:16:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181013133929.28653-1-mpe@ellerman.id.au>
References: <20181013133929.28653-1-mpe@ellerman.id.au>
From: Kees Cook <keescook@chromium.org>
Date: Sat, 13 Oct 2018 18:16:44 -0700
Message-ID: <CAGXu5jJ9_viWyBo8zzOjF7enAqz7e=xYS38Jq3gn6=6bEz8auw@mail.gmail.com>
Subject: Re: [PATCH] selftests/vm: Add a test for MAP_FIXED_NOREPLACE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Jann Horn <jannh@google.com>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrea Arcangeli <aarcange@redhat.com>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Jason Evans <jasone@google.com>, David Goldblatt <davidtgoldblatt@gmail.com>, =?UTF-8?Q?Edward_Tomasz_Napiera=C5=82a?= <trasz@freebsd.org>, Daniel Micay <danielmicay@gmail.com>

On Sat, Oct 13, 2018 at 6:39 AM, Michael Ellerman <mpe@ellerman.id.au> wrote:
> Add a test for MAP_FIXED_NOREPLACE, based on some code originally by
> Jann Horn. This would have caught the overlap bug reported by Daniel Micay.
>
> I originally suggested to Michal that we create MAP_FIXED_NOREPLACE, but
> instead of writing a selftest I spent my time bike-shedding whether it
> should be called MAP_FIXED_SAFE/NOCLOBBER/WEAK/NEW .. mea culpa.

LOL. :)

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

>
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> ---
>  tools/testing/selftests/vm/.gitignore         |   1 +
>  tools/testing/selftests/vm/Makefile           |   1 +
>  .../selftests/vm/map_fixed_noreplace.c        | 206 ++++++++++++++++++
>  3 files changed, 208 insertions(+)
>  create mode 100644 tools/testing/selftests/vm/map_fixed_noreplace.c
>
> diff --git a/tools/testing/selftests/vm/.gitignore b/tools/testing/selftests/vm/.gitignore
> index af5ff83f6d7f..31b3c98b6d34 100644
> --- a/tools/testing/selftests/vm/.gitignore
> +++ b/tools/testing/selftests/vm/.gitignore
> @@ -13,3 +13,4 @@ mlock-random-test
>  virtual_address_range
>  gup_benchmark
>  va_128TBswitch
> +map_fixed_noreplace
> diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
> index e94b7b14bcb2..6e67e726e5a5 100644
> --- a/tools/testing/selftests/vm/Makefile
> +++ b/tools/testing/selftests/vm/Makefile
> @@ -12,6 +12,7 @@ TEST_GEN_FILES += gup_benchmark
>  TEST_GEN_FILES += hugepage-mmap
>  TEST_GEN_FILES += hugepage-shm
>  TEST_GEN_FILES += map_hugetlb
> +TEST_GEN_FILES += map_fixed_noreplace
>  TEST_GEN_FILES += map_populate
>  TEST_GEN_FILES += mlock-random-test
>  TEST_GEN_FILES += mlock2-tests
> diff --git a/tools/testing/selftests/vm/map_fixed_noreplace.c b/tools/testing/selftests/vm/map_fixed_noreplace.c
> new file mode 100644
> index 000000000000..d91bde511268
> --- /dev/null
> +++ b/tools/testing/selftests/vm/map_fixed_noreplace.c
> @@ -0,0 +1,206 @@
> +// SPDX-License-Identifier: GPL-2.0
> +
> +/*
> + * Test that MAP_FIXED_NOREPLACE works.
> + *
> + * Copyright 2018, Jann Horn <jannh@google.com>
> + * Copyright 2018, Michael Ellerman, IBM Corporation.
> + */
> +
> +#include <sys/mman.h>
> +#include <errno.h>
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <unistd.h>
> +
> +#ifndef MAP_FIXED_NOREPLACE
> +#define MAP_FIXED_NOREPLACE 0x100000
> +#endif
> +
> +#define BASE_ADDRESS   (256ul * 1024 * 1024)
> +
> +
> +static void dump_maps(void)
> +{
> +       char cmd[32];
> +
> +       snprintf(cmd, sizeof(cmd), "cat /proc/%d/maps", getpid());
> +       system(cmd);
> +}
> +
> +int main(void)
> +{
> +       unsigned long flags, addr, size, page_size;
> +       char *p;
> +
> +       page_size = sysconf(_SC_PAGE_SIZE);
> +
> +       flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED_NOREPLACE;
> +
> +       // Check we can map all the areas we need below
> +       errno = 0;
> +       addr = BASE_ADDRESS;
> +       size = 5 * page_size;
> +       p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
> +
> +       printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
> +
> +       if (p == MAP_FAILED) {
> +               dump_maps();
> +               printf("Error: couldn't map the space we need for the test\n");
> +               return 1;
> +       }
> +
> +       errno = 0;
> +       if (munmap((void *)addr, 5 * page_size) != 0) {
> +               dump_maps();
> +               printf("Error: munmap failed!?\n");
> +               return 1;
> +       }
> +       printf("unmap() successful\n");
> +
> +       errno = 0;
> +       addr = BASE_ADDRESS + page_size;
> +       size = 3 * page_size;
> +       p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
> +       printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
> +
> +       if (p == MAP_FAILED) {
> +               dump_maps();
> +               printf("Error: first mmap() failed unexpectedly\n");
> +               return 1;
> +       }
> +
> +       /*
> +        * Exact same mapping again:
> +        *   base |  free  | new
> +        *     +1 | mapped | new
> +        *     +2 | mapped | new
> +        *     +3 | mapped | new
> +        *     +4 |  free  | new
> +        */
> +       errno = 0;
> +       addr = BASE_ADDRESS;
> +       size = 5 * page_size;
> +       p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
> +       printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
> +
> +       if (p != MAP_FAILED) {
> +               dump_maps();
> +               printf("Error:1: mmap() succeeded when it shouldn't have\n");
> +               return 1;
> +       }
> +
> +       /*
> +        * Second mapping contained within first:
> +        *
> +        *   base |  free  |
> +        *     +1 | mapped |
> +        *     +2 | mapped | new
> +        *     +3 | mapped |
> +        *     +4 |  free  |
> +        */
> +       errno = 0;
> +       addr = BASE_ADDRESS + (2 * page_size);
> +       size = page_size;
> +       p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
> +       printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
> +
> +       if (p != MAP_FAILED) {
> +               dump_maps();
> +               printf("Error:2: mmap() succeeded when it shouldn't have\n");
> +               return 1;
> +       }
> +
> +       /*
> +        * Overlap end of existing mapping:
> +        *   base |  free  |
> +        *     +1 | mapped |
> +        *     +2 | mapped |
> +        *     +3 | mapped | new
> +        *     +4 |  free  | new
> +        */
> +       errno = 0;
> +       addr = BASE_ADDRESS + (3 * page_size);
> +       size = 2 * page_size;
> +       p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
> +       printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
> +
> +       if (p != MAP_FAILED) {
> +               dump_maps();
> +               printf("Error:3: mmap() succeeded when it shouldn't have\n");
> +               return 1;
> +       }
> +
> +       /*
> +        * Overlap start of existing mapping:
> +        *   base |  free  | new
> +        *     +1 | mapped | new
> +        *     +2 | mapped |
> +        *     +3 | mapped |
> +        *     +4 |  free  |
> +        */
> +       errno = 0;
> +       addr = BASE_ADDRESS;
> +       size = 2 * page_size;
> +       p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
> +       printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
> +
> +       if (p != MAP_FAILED) {
> +               dump_maps();
> +               printf("Error:4: mmap() succeeded when it shouldn't have\n");
> +               return 1;
> +       }
> +
> +       /*
> +        * Adjacent to start of existing mapping:
> +        *   base |  free  | new
> +        *     +1 | mapped |
> +        *     +2 | mapped |
> +        *     +3 | mapped |
> +        *     +4 |  free  |
> +        */
> +       errno = 0;
> +       addr = BASE_ADDRESS;
> +       size = page_size;
> +       p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
> +       printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
> +
> +       if (p == MAP_FAILED) {
> +               dump_maps();
> +               printf("Error:5: mmap() failed when it shouldn't have\n");
> +               return 1;
> +       }
> +
> +       /*
> +        * Adjacent to end of existing mapping:
> +        *   base |  free  |
> +        *     +1 | mapped |
> +        *     +2 | mapped |
> +        *     +3 | mapped |
> +        *     +4 |  free  |  new
> +        */
> +       errno = 0;
> +       addr = BASE_ADDRESS + (4 * page_size);
> +       size = page_size;
> +       p = mmap((void *)addr, size, PROT_NONE, flags, -1, 0);
> +       printf("mmap() @ 0x%lx-0x%lx p=%p result=%m\n", addr, addr + size, p);
> +
> +       if (p == MAP_FAILED) {
> +               dump_maps();
> +               printf("Error:6: mmap() failed when it shouldn't have\n");
> +               return 1;
> +       }
> +
> +       addr = BASE_ADDRESS;
> +       size = 5 * page_size;
> +       if (munmap((void *)addr, size) != 0) {
> +               dump_maps();
> +               printf("Error: munmap failed!?\n");
> +               return 1;
> +       }
> +       printf("unmap() successful\n");
> +
> +       printf("OK\n");
> +       return 0;
> +}
> --
> 2.17.1
>



-- 
Kees Cook
Pixel Security
