Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id B89DC6B0032
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 10:12:15 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md4so297611pbc.7
        for <linux-mm@kvack.org>; Tue, 04 Jun 2013 07:12:15 -0700 (PDT)
Message-ID: <51ADF56B.2060407@gmail.com>
Date: Tue, 04 Jun 2013 22:10:51 +0800
From: Hush Bensen <hush.bensen@gmail.com>
MIME-Version: 1.0
Subject: Re: Transparent Hugepage impact on memcpy
References: <51ADAC15.1050103@huawei.com>
In-Reply-To: <51ADAC15.1050103@huawei.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Andi Kleen <ak@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, qiuxishi <qiuxishi@huawei.com>

Cc thp guys.

ao? 2013/6/4 16:57, Jianguo Wu a??e??:
> Hi all,
>
> I tested memcpy with perf bench, and found that in prefault case, When Transparent Hugepage is on,
> memcpy has worse performance.
>
> When THP on is 3.672879 GB/Sec (with prefault), while THP off is 6.190187 GB/Sec (with prefault).
>
> I think THP will improve performance, but the test result obviously not the case.
> Andrea mentioned THP cause "clear_page/copy_page less cache friendly" in
> http://events.linuxfoundation.org/slides/2011/lfcs/lfcs2011_hpc_arcangeli.pdf.
>
> I am not quite understand this, could you please give me some comments, Thanks!
>
> I test in Linux-3.4-stable, and my machine info is:
> Intel(R) Xeon(R) CPU           E5520  @ 2.27GHz
>
> available: 2 nodes (0-1)
> node 0 cpus: 0 1 2 3 8 9 10 11
> node 0 size: 24567 MB
> node 0 free: 23550 MB
> node 1 cpus: 4 5 6 7 12 13 14 15
> node 1 size: 24576 MB
> node 1 free: 23767 MB
> node distances:
> node   0   1
>    0:  10  20
>    1:  20  10
>
> Below is test result:
> ---with THP---
> #cat /sys/kernel/mm/transparent_hugepage/enabled
> [always] madvise never
> #./perf bench mem memcpy -l 1gb -o
> # Running mem/memcpy benchmark...
> # Copying 1gb Bytes ...
>
>         3.672879 GB/Sec (with prefault)
>
> #./perf stat ...
> Performance counter stats for './perf bench mem memcpy -l 1gb -o':
>
>            35455940 cache-misses              #   53.504 % of all cache refs     [49.45%]
>            66267785 cache-references                                             [49.78%]
>                2409 page-faults
>           450768651 dTLB-loads
>                                                    [50.78%]
>               24580 dTLB-misses
>                #    0.01% of all dTLB cache hits  [51.01%]
>          1338974202 dTLB-stores
>                                                   [50.63%]
>               77943 dTLB-misses
>                                                   [50.24%]
>           697404997 iTLB-loads
>                                                    [49.77%]
>                 274 iTLB-misses
>                #    0.00% of all iTLB cache hits  [49.30%]
>
>         0.855041819 seconds time elapsed
>
> ---no THP---
> #cat /sys/kernel/mm/transparent_hugepage/enabled
> always madvise [never]
>
> #./perf bench mem memcpy -l 1gb -o
> # Running mem/memcpy benchmark...
> # Copying 1gb Bytes ...
>
>         6.190187 GB/Sec (with prefault)
>
> #./perf stat ...
> Performance counter stats for './perf bench mem memcpy -l 1gb -o':
>
>            16920763 cache-misses              #   98.377 % of all cache refs     [50.01%]
>            17200000 cache-references                                             [50.04%]
>              524652 page-faults
>           734365659 dTLB-loads
>                                                    [50.04%]
>             4986387 dTLB-misses
>                #    0.68% of all dTLB cache hits  [50.04%]
>          1013408298 dTLB-stores
>                                                   [50.04%]
>             8180817 dTLB-misses
>                                                   [49.97%]
>          1526642351 iTLB-loads
>                                                    [50.41%]
>                  56 iTLB-misses
>                #    0.00% of all iTLB cache hits  [50.21%]
>
>         1.025425847 seconds time elapsed
>
> Thanks,
> Jianguo Wu.
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
