Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id B333E6B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:40:26 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id f10so313863oth.14
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:40:26 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h197si1650968oic.366.2018.02.15.10.40.25
        for <linux-mm@kvack.org>;
        Thu, 15 Feb 2018 10:40:25 -0800 (PST)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [bug?] mallocstress poor performance with THP on arm64 system
References: <1847959563.1954032.1518649501357.JavaMail.zimbra@redhat.com>
Date: Thu, 15 Feb 2018 18:40:22 +0000
In-Reply-To: <1847959563.1954032.1518649501357.JavaMail.zimbra@redhat.com>
	(Jan Stancek's message of "Wed, 14 Feb 2018 18:05:01 -0500 (EST)")
Message-ID: <87sha23xm1.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, lwoodman <lwoodman@redhat.com>, Rafael Aquini <aquini@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

Jan Stancek <jstancek@redhat.com> writes:

> Hi,
>
> mallocstress[1] LTP testcase takes ~5+ minutes to complete
> on some arm64 systems (e.g. 4 node, 64 CPU, 256GB RAM):
>  real    7m58.089s
>  user    0m0.513s
>  sys     24m27.041s
>
> But if I turn off THP ("transparent_hugepage=3Dnever") it's a lot faster:
>  real    0m4.185s
>  user    0m0.298s
>  sys     0m13.954s
>

>From the config fragment below the kernel is using 64k pages which
matches up with the 512MB default hugepage at PMD level.

With transparent hugepage enabled, the kernel tries to allocate
hugepages on page faults. Each fault taken by 'mallocstress' test this
ends up allocating in 512MB chunks but only uses the first few bytes.

You can change the default transparent hugepage option to madvise (by
setting CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=3Dy or by "echo madvise >
/sys/kernel/mm/transparent_hugepage/enabled").

The other option is to ignore 'mallocstress' runtime as it is not
representative and for certain workloads (e.g., VMs) it can be useful to
boot with transparent_hugepage=3Dalways.

Thanks,
Punit

> Perf suggests, that most time is spent in clear_page().
>
> -   94.25%    94.24%  mallocstress  [kernel.kallsyms]   [k] clear_page
>      94.24% thread_start
>         start_thread
>         alloc_mem
>         allocate_free
>       - malloc
>          - 94.24% _int_malloc
>             - 94.24% sysmalloc
>                  el0_da
>                  do_mem_abort
>                  do_translation_fault
>                  do_page_fault
>                  handle_mm_fault
>                - __handle_mm_fault
>                   - 94.22% do_huge_pmd_anonymous_page
>                      - __do_huge_pmd_anonymous_page
>                         - 94.21% clear_huge_page
>                              clear_page
>
> Percent=E2=94=82
>        =E2=94=82
>        =E2=94=82
>        =E2=94=82    Disassembly of section load0:
>        =E2=94=82
>        =E2=94=82    ffff0000087f0540 <load0>:
>   0.00 =E2=94=82      mrs    x1, dczid_el0
>   0.00 =E2=94=82      and    w1, w1, #0xf
>        =E2=94=82      mov    x2, #0x4                        // #4
>        =E2=94=82      lsl    x1, x2, x1
> 100.00 =E2=94=8210:   dc     zva, x0
>        =E2=94=82      add    x0, x0, x1
>        =E2=94=82      tst    x0, #0xffff
>        =E2=94=82    =E2=86=91 b.ne   10
>        =E2=94=82    =E2=86=90 ret
>
> # uname -r
> 4.15.3
>
> # grep HUGE -r .config
> CONFIG_CGROUP_HUGETLB=3Dy
> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=3Dy
> CONFIG_HAVE_ARCH_HUGE_VMAP=3Dy
> CONFIG_SYS_SUPPORTS_HUGETLBFS=3Dy
> CONFIG_TRANSPARENT_HUGEPAGE=3Dy
> CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=3Dy
> # CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
> CONFIG_TRANSPARENT_HUGE_PAGECACHE=3Dy
> CONFIG_HUGETLBFS=3Dy
> CONFIG_HUGETLB_PAGE=3Dy
>
> # grep _PAGE -r .config
> CONFIG_ARM64_PAGE_SHIFT=3D16
> CONFIG_PAGE_COUNTER=3Dy
> CONFIG_HAVE_ALIGNED_STRUCT_PAGE=3Dy
> # CONFIG_ARM64_4K_PAGES is not set
> # CONFIG_ARM64_16K_PAGES is not set
> CONFIG_ARM64_64K_PAGES=3Dy
> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=3Dy
> CONFIG_TRANSPARENT_HUGE_PAGECACHE=3Dy
> CONFIG_IDLE_PAGE_TRACKING=3Dy
> CONFIG_PROC_PAGE_MONITOR=3Dy
> CONFIG_HUGETLB_PAGE=3Dy
> CONFIG_ARCH_HAS_GIGANTIC_PAGE=3Dy
> # CONFIG_PAGE_OWNER is not set
> # CONFIG_PAGE_EXTENSION is not set
> # CONFIG_DEBUG_PAGEALLOC is not set
> # CONFIG_PAGE_POISONING is not set
> # CONFIG_DEBUG_PAGE_REF is not set
>
> # cat /proc/meminfo  | grep Huge
> Hugepagesize:     524288 kB

I noticed 512MB - that's a _huge_ hugepage.

The config suggests that the kernel is running with 64k pages.
>
> # numactl -H
> available: 4 nodes (0-3)
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
> node 0 size: 65308 MB
> node 0 free: 64892 MB
> node 1 cpus: 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
> node 1 size: 65404 MB
> node 1 free: 62804 MB
> node 2 cpus: 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47
> node 2 size: 65404 MB
> node 2 free: 62847 MB
> node 3 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63
> node 3 size: 65402 MB
> node 3 free: 64671 MB
> node distances:
> node   0   1   2   3=20
>   0:  10  15  20  20=20
>   1:  15  10  20  20=20
>   2:  20  20  10  15=20
>   3:  20  20  15  10
>
> Regards,
> Jan
>
> [1] https://github.com/linux-test-project/ltp/blob/master/testcases/kerne=
l/mem/mtest07/mallocstress.c
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
