Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 08DCB8E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 09:18:29 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id t83so975505oie.16
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 06:18:29 -0800 (PST)
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id x7si802064otk.273.2018.12.13.06.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 06:18:27 -0800 (PST)
Subject: Re: [bug?] poor migrate_pages() performance on arm64
References: <1125108393.85764095.1544629302243.JavaMail.zimbra@redhat.com>
 <9291e284-7b9b-3d93-1e79-f01c174d9979@huawei.com>
 <837880744.86933950.1544696810428.JavaMail.zimbra@redhat.com>
From: John Garry <john.garry@huawei.com>
Message-ID: <1dd3d68b-23dc-80d0-2a4f-04d0200ef61f@huawei.com>
Date: Thu, 13 Dec 2018 14:18:11 +0000
MIME-Version: 1.0
In-Reply-To: <837880744.86933950.1544696810428.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, Tan Xiaojun <tanxiaojun@huawei.com>, ltp@lists.linux.it, linux-arm-kernel@lists.infradead.org, Linuxarm <linuxarm@huawei.com>

On 13/12/2018 10:26, Jan Stancek wrote:
>
>
> ----- Original Message -----
>> + cc'ing linuxarm@huawei.com
>>
>> It seems that we're spending much time in cache invalidate.
>>
>> When you say 4 nodes, does that mean memory on all 4 nodes?
>
> Correct:
>
> # numactl -H
> available: 4 nodes (0-3)
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
> node 0 size: 65304 MB
> node 0 free: 59939 MB
> node 1 cpus: 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
> node 1 size: 65404 MB
> node 1 free: 64419 MB
> node 2 cpus: 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47
> node 2 size: 65404 MB
> node 2 free: 64832 MB
> node 3 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63
> node 3 size: 65403 MB
> node 3 free: 64805 MB
> node distances:
> node   0   1   2   3
>   0:  10  15  20  20
>   1:  15  10  20  20
>   2:  20  20  10  15
>   3:  20  20  15  10
>

Thanks. I assume that you're using 64K pages, but I would not say that 
would make a difference.

Have you tested other arm64 systems and found similar?

We will check this test ourselves.

Cheers,
John

>>
>> Thanks,
>> John
>>
>> On 12/12/2018 15:41, Jan Stancek wrote:
>>> Hi,
>>>
>>> I'm observing migrate_pages() taking quite long time on arm64
>>> system (Huawei TaiShan 2280, 4 nodes, 64 CPUs). I'm using 4.20.0-rc6,
>>> but it's reproducible with older kernels (4.14) as well.
>>>
>>> The test (see [1] below), is a trivial C application, that migrates
>>> current process from one node to another. More complicated example
>>> is also LTP's migrate_pages03, where this has been originally reported.
>>>
>>> It takes 2+ seconds to migrate process from one node to another:
>>>   # strace -f -t -T ./a.out
>>>   ...
>>>   [pid 13754] 10:17:13 migrate_pages(0, 8, [0x0000000000000002],
>>>   [0x0000000000000001]) = 1 <0.058115>
>>>   [pid 13754] 10:17:13 migrate_pages(0, 8, [0x0000000000000001],
>>>   [0x0000000000000002]) = 12 <2.348186>
>>>   [pid 13754] 10:17:16 migrate_pages(0, 8, [0x0000000000000002],
>>>   [0x0000000000000001]) = 1 <0.057889>
>>>   [pid 13754] 10:17:16 migrate_pages(0, 8, [0x0000000000000001],
>>>   [0x0000000000000002]) = 10 <2.194890>
>>>   ...
>>>
>>> This scales with number of children. For example with MAXCHILD 1000,
>>> it takes ~33 seconds:
>>>   # strace -f -t -T ./a.out
>>>   ...
>>>   [pid 13773] 10:17:55 migrate_pages(0, 8, [0x0000000000000001],
>>>   [0x0000000000000002]) = 11 <33.615550>
>>>   [pid 13773] 10:18:29 migrate_pages(0, 8, [0x0000000000000002],
>>>   [0x0000000000000001]) = 2 <5.460270>
>>>   ...
>>>
>>> It appears to be related to migration of shared pages, presumably
>>> executable code of glibc.
>>>
>>> If I run [1] without CAP_SYS_NICE, it completes very quickly:
>>>   # sudo -u nobody strace -f -t -T ./a.out
>>>   ...
>>>   [pid 14847] 10:24:57 migrate_pages(0, 8, [0x0000000000000001],
>>>   [0x0000000000000002]) = 0 <0.000172>
>>>   [pid 14847] 10:24:57 migrate_pages(0, 8, [0x0000000000000002],
>>>   [0x0000000000000001]) = 0 <0.000091>
>>>   [pid 14847] 10:24:57 migrate_pages(0, 8, [0x0000000000000001],
>>>   [0x0000000000000002]) = 0 <0.000074>
>>>   [pid 14847] 10:24:57 migrate_pages(0, 8, [0x0000000000000002],
>>>   [0x0000000000000001]) = 0 <0.000069>
>>>   ...
>>>
>>>
>>> Looking at perf, most of time is spent invalidating icache.
>>>
>>> -  100.00%     0.00%  a.out    [kernel.kallsyms]  [k] __sys_trace_return
>>>    - __sys_trace_return
>>>       - 100.00% __se_sys_migrate_pages
>>>            do_migrate_pages.part.9
>>>          - migrate_pages
>>>             - 99.92% rmap_walk
>>>                - 99.92% rmap_walk_file
>>>                   - 99.90% remove_migration_pte
>>>                      - 99.85% __sync_icache_dcache
>>>                           __flush_cache_user_range
>>>
>>> Percent│      nop
>>>        │      ubfx   x3, x3, #16, #4
>>>        │      mov    x2, #0x4                        // #4
>>>        │      lsl    x2, x2, x3
>>>        │      sub    x3, x2, #0x1
>>>        │      bic    x4, x0, x3
>>>   1.82 │      dc     cvau, x4
>>>        │      add    x4, x4, x2
>>>        │      cmp    x4, x1
>>>        │    → b.cc   0xffff00000809efc8  // b.lo, b.ul, fffff7f61067
>>>        │      dsb    ish
>>>        │      nop
>>>   0.07 │      nop
>>>        │      mrs    x3, ctr_el0
>>>        │      nop
>>>        │      and    x3, x3, #0xf
>>>        │      mov    x2, #0x4                        // #4
>>>        │      lsl    x2, x2, x3
>>>        │      sub    x3, x2, #0x1
>>>        │      bic    x3, x0, x3
>>>  96.17 │      ic     ivau, x3
>>>        │      add    x3, x3, x2
>>>        │      cmp    x3, x1
>>>        │    → b.cc   0xffff00000809f000  // b.lo, b.ul, fffff7f61067
>>>   0.10 │      dsb    ish
>>>        │      isb
>>>   1.85 │      mov    x0, #0x0                        // #0
>>>        │78: ← ret
>>>        │      mov    x0, #0xfffffffffffffff2         // #-14
>>>        │    ↑ b      78
>>>
>>> Regards,
>>> Jan
>>>
>>> [1]
>>> ----- 8< -----
>>> #include <signal.h>
>>> #include <stdio.h>
>>> #include <stdlib.h>
>>> #include <unistd.h>
>>> #include <sys/syscall.h>
>>>
>>> #define MAXCHILD 10
>>>
>>> int main(void)
>>> {
>>> 	long node1 = 1, node2 = 2;
>>> 	int i, child;
>>> 	int pids[MAXCHILD];
>>>
>>> 	for (i = 0; i < MAXCHILD; i++) {
>>> 		child = fork();
>>> 		if (child == 0) {
>>> 			sleep(600);
>>> 			exit(0);
>>> 		}
>>> 		pids[i] = child;
>>> 	}
>>>
>>> 	for (i = 0; i < 5; i++) {
>>> 		syscall(__NR_migrate_pages, 0, 8, &node1, &node2);
>>> 		syscall(__NR_migrate_pages, 0, 8, &node2, &node1);
>>> 	}
>>>
>>> 	for (i = 0; i < MAXCHILD; i++) {
>>> 		kill(pids[i], SIGKILL);
>>> 	}
>>>
>>> 	return 0;
>>> }
>>> ----- >8 -----
>>>
>>> _______________________________________________
>>> linux-arm-kernel mailing list
>>> linux-arm-kernel@lists.infradead.org
>>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>>>
>>
>>
>>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>
