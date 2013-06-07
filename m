Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 5BEF36B0032
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 21:27:24 -0400 (EDT)
Message-ID: <51B136E2.4010606@huawei.com>
Date: Fri, 7 Jun 2013 09:26:58 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: Transparent Hugepage impact on memcpy
References: <51ADAC15.1050103@huawei.com> <51AEAFD8.305@huawei.com> <CAMO-S2ixv55bGEFGR6Eh=UZgVBz=nv81EckuzWoVi0t4KdB+VA@mail.gmail.com>
In-Reply-To: <CAMO-S2ixv55bGEFGR6Eh=UZgVBz=nv81EckuzWoVi0t4KdB+VA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, qiuxishi <qiuxishi@huawei.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hush Bensen <hush.bensen@gmail.com>, mitake.hitoshi@gmail.com

Hi Hitoshi,

Thanks for your reply! please see below.

On 2013/6/6 21:54, Hitoshi Mitake wrote:

> Hi Jianguo,
> 
> On Wed, Jun 5, 2013 at 12:26 PM, Jianguo Wu <wujianguo@huawei.com> wrote:
>> Hi,
>> One more question, I wrote a memcpy test program, mostly the same as with perf bench memcpy.
>> But test result isn't consistent with perf bench when THP is off.
>>
>>         my program                              perf bench
>> THP:    3.628368 GB/Sec (with prefault)         3.672879 GB/Sec (with prefault)
>> NO-THP: 3.612743 GB/Sec (with prefault)         6.190187 GB/Sec (with prefault)
>>
>> Below is my code:
>>         src = calloc(1, len);
>>         dst = calloc(1, len);
>>
>>         if (prefault)
>>                 memcpy(dst, src, len);
>>         gettimeofday(&tv_start, NULL);
>>         memcpy(dst, src, len);
>>         gettimeofday(&tv_end, NULL);
>>
>>         timersub(&tv_end, &tv_start, &tv_diff);
>>         free(src);
>>         free(dst);
>>
>>         speed = (double)((double)len / timeval2double(&tv_diff));
>>         print_bps(speed);
>>
>> This is weird, is it possible that perf bench do some build optimize?
>>
>> Thansk,
>> Jianguo Wu.
> 
> perf bench mem memcpy is build with -O6. This is the compile command
> line (you can get this with make V=1):
> gcc -o bench/mem-memcpy-x86-64-asm.o -c -fno-omit-frame-pointer -ggdb3
> -funwind-tables -Wall -Wextra -std=gnu99 -Werror -O6 .... # ommited
> 
> Can I see your compile option for your test program and the actual
> command line executing perf bench mem memcpy?
> 

I just compiled my test program with gcc -o memcpy-test memcpy-test.c.
I tried to use the same compile option with perf bench mem memcpy, and
the test result showed no difference.

My execute command line for perf bench mem memcpy:
#./perf bench mem memcpy -l 1gb -o

Thanks,
Jianguo Wu

> Thanks,
> Hitoshi
> 
>>
>> On 2013/6/4 16:57, Jianguo Wu wrote:
>>
>>> Hi all,
>>>
>>> I tested memcpy with perf bench, and found that in prefault case, When Transparent Hugepage is on,
>>> memcpy has worse performance.
>>>
>>> When THP on is 3.672879 GB/Sec (with prefault), while THP off is 6.190187 GB/Sec (with prefault).
>>>
>>> I think THP will improve performance, but the test result obviously not the case.
>>> Andrea mentioned THP cause "clear_page/copy_page less cache friendly" in
>>> http://events.linuxfoundation.org/slides/2011/lfcs/lfcs2011_hpc_arcangeli.pdf.
>>>
>>> I am not quite understand this, could you please give me some comments, Thanks!
>>>
>>> I test in Linux-3.4-stable, and my machine info is:
>>> Intel(R) Xeon(R) CPU           E5520  @ 2.27GHz
>>>
>>> available: 2 nodes (0-1)
>>> node 0 cpus: 0 1 2 3 8 9 10 11
>>> node 0 size: 24567 MB
>>> node 0 free: 23550 MB
>>> node 1 cpus: 4 5 6 7 12 13 14 15
>>> node 1 size: 24576 MB
>>> node 1 free: 23767 MB
>>> node distances:
>>> node   0   1
>>>   0:  10  20
>>>   1:  20  10
>>>
>>> Below is test result:
>>> ---with THP---
>>> #cat /sys/kernel/mm/transparent_hugepage/enabled
>>> [always] madvise never
>>> #./perf bench mem memcpy -l 1gb -o
>>> # Running mem/memcpy benchmark...
>>> # Copying 1gb Bytes ...
>>>
>>>        3.672879 GB/Sec (with prefault)
>>>
>>> #./perf stat ...
>>> Performance counter stats for './perf bench mem memcpy -l 1gb -o':
>>>
>>>           35455940 cache-misses              #   53.504 % of all cache refs     [49.45%]
>>>           66267785 cache-references                                             [49.78%]
>>>               2409 page-faults
>>>          450768651 dTLB-loads
>>>                                                   [50.78%]
>>>              24580 dTLB-misses
>>>               #    0.01% of all dTLB cache hits  [51.01%]
>>>         1338974202 dTLB-stores
>>>                                                  [50.63%]
>>>              77943 dTLB-misses
>>>                                                  [50.24%]
>>>          697404997 iTLB-loads
>>>                                                   [49.77%]
>>>                274 iTLB-misses
>>>               #    0.00% of all iTLB cache hits  [49.30%]
>>>
>>>        0.855041819 seconds time elapsed
>>>
>>> ---no THP---
>>> #cat /sys/kernel/mm/transparent_hugepage/enabled
>>> always madvise [never]
>>>
>>> #./perf bench mem memcpy -l 1gb -o
>>> # Running mem/memcpy benchmark...
>>> # Copying 1gb Bytes ...
>>>
>>>        6.190187 GB/Sec (with prefault)
>>>
>>> #./perf stat ...
>>> Performance counter stats for './perf bench mem memcpy -l 1gb -o':
>>>
>>>           16920763 cache-misses              #   98.377 % of all cache refs     [50.01%]
>>>           17200000 cache-references                                             [50.04%]
>>>             524652 page-faults
>>>          734365659 dTLB-loads
>>>                                                   [50.04%]
>>>            4986387 dTLB-misses
>>>               #    0.68% of all dTLB cache hits  [50.04%]
>>>         1013408298 dTLB-stores
>>>                                                  [50.04%]
>>>            8180817 dTLB-misses
>>>                                                  [49.97%]
>>>         1526642351 iTLB-loads
>>>                                                   [50.41%]
>>>                 56 iTLB-misses
>>>               #    0.00% of all iTLB cache hits  [50.21%]
>>>
>>>        1.025425847 seconds time elapsed
>>>
>>> Thanks,
>>> Jianguo Wu.
>>
>>
>>
>>
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
