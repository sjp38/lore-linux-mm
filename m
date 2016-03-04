Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f175.google.com (mail-yw0-f175.google.com [209.85.161.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0078F6B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 00:21:21 -0500 (EST)
Received: by mail-yw0-f175.google.com with SMTP id i131so23395396ywc.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 21:21:20 -0800 (PST)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id 6si648237ybs.17.2016.03.03.21.21.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 21:21:19 -0800 (PST)
Received: by mail-yw0-x244.google.com with SMTP id s188so2387859ywe.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 21:21:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D806B4.9040203@linux.vnet.ibm.com>
References: <1456988501-29046-1-git-send-email-zhlcindy@gmail.com>
	<1456988501-29046-2-git-send-email-zhlcindy@gmail.com>
	<56D806B4.9040203@linux.vnet.ibm.com>
Date: Fri, 4 Mar 2016 13:21:19 +0800
Message-ID: <CAD8of+rT_vPma9YjTFu9XTe5cTLpcnUxsP4Fb_gFFuotidB4bg@mail.gmail.com>
Subject: Re: [PATCH RFC 1/2] mm: meminit: initialise more memory for
 inode/dentry hash tables in early boot
From: Li Zhang <zhlcindy@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: mpe@ellerman.id.au, aneesh.kumar@linux.vnet.ibm.com, mgorman@techsingularity.net, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

On Thu, Mar 3, 2016 at 5:41 PM, Anshuman Khandual
<khandual@linux.vnet.ibm.com> wrote:
> On 03/03/2016 12:31 PM, Li Zhang wrote:
>> From: Li Zhang <zhlcindy@linux.vnet.ibm.com>
>>
>> This patch is based on Mel Gorman's old patch in the mailing list,
>> https://lkml.org/lkml/2015/5/5/280 which is dicussed but it is
>
> Typo here ....................................^^^^^^^^
>

Sorry, I will correct it.

>
>> fixed with a completion to wait for all memory initialised in
>> page_alloc_init_late(). It is to fix the oom problem on X86
>
> You can just write *out of memory* instead of *oom* or put them in
> capitals.
>
OK

>> with 24TB memory which allocates memory in late initialisation.
>> But for Power platform with 32TB memory, it causes a call trace
>> in vfs_caches_init->inode_init() and inode hash table needs more
>> memory.
>> So this patch allocates 1GB for 0.25TB/node for large system
>> as it is mentioned in https://lkml.org/lkml/2015/5/1/627
>
> I am wondering how its going to impact other architectures.

I just saw some discussion for X86 in https://lkml.org/lkml/2015/5/1/627.
And some tests are done for X86 with huge memory.
>From code view, this allocate more memory in early initialisation, it may
cause boot time a little bit.

>>
>> This call trace is found on Power with 32TB memory, 1024CPUs, 16nodes.
>> The log from dmesg as the following:
>>
>> [    0.091780] Dentry cache hash table entries: 2147483648 (order: 18,
>> 17179869184 bytes)
>> [    2.891012] vmalloc: allocation failure, allocated 16021913600 of
>> 17179934720 bytes
>> [    2.891034] swapper/0: page allocation failure: order:0,
>> mode:0x2080020
>> [    2.891038] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.4.0-0-ppc64
>> [    2.891041] Call Trace:
>> [    2.891046] [c0000000012bfa00] [c0000000007c4a50]
>>                 .dump_stack+0xb4/0xb664 (unreliable)
>> [    2.891051] [c0000000012bfa80] [c0000000001f93d4]
>>                 .warn_alloc_failed+0x114/0x160
>> [    2.891054] [c0000000012bfb30] [c00000000023c204]
>>                 .__vmalloc_area_node+0x1a4/0x2b0
>> [    2.891058] [c0000000012bfbf0] [c00000000023c3f4]
>>                 .__vmalloc_node_range+0xe4/0x110
>> [    2.891061] [c0000000012bfc90] [c00000000023c460]
>>                 .__vmalloc_node+0x40/0x50
>> [    2.891065] [c0000000012bfd10] [c000000000b67d60]
>>                 .alloc_large_system_hash+0x134/0x2a4
>> [    2.891068] [c0000000012bfdd0] [c000000000b70924]
>>                 .inode_init+0xa4/0xf0
>> [    2.891071] [c0000000012bfe60] [c000000000b706a0]
>>                 .vfs_caches_init+0x80/0x144
>> [    2.891074] [c0000000012bfef0] [c000000000b35208]
>>                 .start_kernel+0x40c/0x4e0
>> [    2.891078] [c0000000012bff90] [c000000000008cfc]
>>                 start_here_common+0x20/0x4a4
>> [    2.891080] Mem-Info:
>
> The dmesg output here needs some formatting.
>
>>
>> Signed-off-by: Li Zhang <zhlcindy@linux.vnet.ibm.com>
>> ---
>>  mm/page_alloc.c | 11 +++++++++--
>>  1 file changed, 9 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 838ca8bb..4847f25 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -293,13 +293,20 @@ static inline bool update_defer_init(pg_data_t *pgdat,
>>                               unsigned long pfn, unsigned long zone_end,
>>                               unsigned long *nr_initialised)
>>  {
>> +     unsigned long max_initialise;
>> +
>>       /* Always populate low zones for address-contrained allocations */
>>       if (zone_end < pgdat_end_pfn(pgdat))
>>               return true;
>> +     /*
>> +     * Initialise at least 2G of a node but also take into account that
>> +     * two large system hashes that can take up 1GB for 0.25TB/node.
>> +     */
>> +     max_initialise = max(2UL << (30 - PAGE_SHIFT),
>> +             (pgdat->node_spanned_pages >> 8));
>>
>> -     /* Initialise at least 2G of the highest zone */
>>       (*nr_initialised)++;
>> -     if (*nr_initialised > (2UL << (30 - PAGE_SHIFT)) &&
>> +     if ((*nr_initialised > max_initialise) &&
>
> Does this change need to be tested on all architectures ?

Currently, this feature is only supported for X86 in upstream.
It can be tested more in the future if some architectures need to enable it.

-- 

Best Regards
-Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
