Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D5D876B0260
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 09:47:34 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a12so1983645qka.7
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 06:47:34 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id x10si432983qkl.37.2017.11.03.06.47.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 06:47:33 -0700 (PDT)
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id vA3DlWFM012802
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 3 Nov 2017 13:47:32 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id vA3DlVm0012755
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 3 Nov 2017 13:47:32 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id vA3DlVc1010186
	for <linux-mm@kvack.org>; Fri, 3 Nov 2017 13:47:31 GMT
Received: by mail-oi0-f49.google.com with SMTP id c77so2112880oig.0
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 06:47:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171103092703.63qyafmg7rnpoqab@dhcp22.suse.cz>
References: <20171102170221.7401-1-pasha.tatashin@oracle.com>
 <20171102170221.7401-2-pasha.tatashin@oracle.com> <20171103092703.63qyafmg7rnpoqab@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 3 Nov 2017 09:47:30 -0400
Message-ID: <CAOAebxvXz2+N36QLo5xdJzbCfCPeC5E3a1p0PBTtN5ZXNNYG8Q@mail.gmail.com>
Subject: Re: [PATCH v2 1/1] mm: buddy page accessed before initialized
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Hi Michal,

There is a small regression, on the largest x86 machine I have access to:
Before:
node 1 initialised, 32471632 pages in 901ms
After:
node 1 initialised, 32471632 pages in 1128ms

One node contains 128G of memory (overal 1T in 8 nodes). This
regression is going to be solved by this work:
https://patchwork.kernel.org/patch/9920953/, other than that I do not
know a better solution. The overall performance is still much better
compared to before this project.

Also, thinking about this problem some more, it is safer to split the
initialization, and freeing parts into two functions:

In deferred_init_memmap()
1574         for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
1575                 spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
1576                 epfn = min_t(unsigned long, zone_end_pfn(zone),
PFN_DOWN(epa));
1577                 nr_pages += deferred_init_range(nid, zid, spfn, epfn);
1578         }

Replace with two loops:
First loop, calls a function that initializes the given range, the 2nd
loop calls a function that frees it. This way we won't get a potential
problem where buddy page is computed from the next range that has not
yet been initialized. And it is also going to be easier to multithread
later: multi-thread the first loop, wait for it to finish,
multi-thread the 2nd loop wait for it to finish.

Pasha


On Fri, Nov 3, 2017 at 5:27 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 02-11-17 13:02:21, Pavel Tatashin wrote:
>> This problem is seen when machine is rebooted after kexec:
>> A message like this is printed:
>> ==========================================================================
>> WARNING: CPU: 21 PID: 249 at linux/lib/list_debug.c:53__listd+0x83/0xa0
>> Modules linked in:
>> CPU: 21 PID: 249 Comm: pgdatinit0 Not tainted 4.14.0-rc6_pt_deferred #90
>> Hardware name: Oracle Corporation ORACLE SERVER X6-2/ASM,MOTHERBOARD,1U,
>> BIOS 3016
>> node 1 initialised, 32444607 pages in 1679ms
>> task: ffff880180e75a00 task.stack: ffffc9000cdb0000
>> RIP: 0010:__list_del_entry_valid+0x83/0xa0
>> RSP: 0000:ffffc9000cdb3d18 EFLAGS: 00010046
>> RAX: 0000000000000054 RBX: 0000000000000009 RCX: ffffffff81c5f3e8
>> RDX: 0000000000000000 RSI: 0000000000000086 RDI: 0000000000000046
>> RBP: ffffc9000cdb3d18 R08: 00000000fffffffe R09: 0000000000000154
>> R10: 0000000000000005 R11: 0000000000000153 R12: 0000000001fcdc00
>> R13: 0000000001fcde00 R14: ffff88207ffded00 R15: ffffea007f370000
>> FS:  0000000000000000(0000) GS:ffff881fffac0000(0000) knlGS:0
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 0000000000000000 CR3: 000000407ec09001 CR4: 00000000003606e0
>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>> Call Trace:
>>  free_one_page+0x103/0x390
>>  __free_pages_ok+0x1cf/0x2d0
>>  __free_pages+0x19/0x30
>>  __free_pages_boot_core+0xae/0xba
>>  deferred_free_range+0x60/0x94
>>  deferred_init_memmap+0x324/0x372
>>  kthread+0x109/0x140
>>  ? __free_pages_bootmem+0x2e/0x2e
>>  ? kthread_park+0x60/0x60
>>  ret_from_fork+0x25/0x30
>>
>> list_del corruption. next->prev should be ffffea007f428020, but was
>> ffffea007f1d8020
>> ==========================================================================
>>
>> The problem happens in this path:
>>
>> page_alloc_init_late
>>   deferred_init_memmap
>>     deferred_init_range
>>       __def_free
>>         deferred_free_range
>>           __free_pages_boot_core(page, order)
>>             __free_pages()
>>               __free_pages_ok()
>>                 free_one_page()
>>                   __free_one_page(page, pfn, zone, order, migratetype);
>>
>> deferred_init_range() initializes one page at a time by calling
>> __init_single_page(), once it initializes pageblock_nr_pages pages, it
>> calls deferred_free_range() to free the initialized pages to the buddy
>> allocator. Eventually, we reach __free_one_page(), where we compute buddy
>> page:
>>       buddy_pfn = __find_buddy_pfn(pfn, order);
>>       buddy = page + (buddy_pfn - pfn);
>>
>> buddy_pfn is computed as pfn ^ (1 << order), or pfn + pageblock_nr_pages.
>> Thefore, buddy page becomes a page one after the range that currently was
>> initialized, and we access this page in this function. Also, later when we
>> return back to deferred_init_range(), the buddy page is initialized again.
>>
>> So, in order to avoid this issue, we must initialize the buddy page prior
>> to calling deferred_free_range().
>
> Have you measured any negative performance impact with this change?
>
>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>
> The patch looks good to me otherwise. So if this doesn't introduce a
> noticeable overhead, which I whope it doesn't then feel free to add
> Acked-by: Michal Hocko <mhocko@suse.com>
> --
> Michal Hocko
> SUSE Labs
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
