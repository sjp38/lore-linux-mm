Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 70C7D6B006E
	for <linux-mm@kvack.org>; Wed,  6 May 2015 03:10:18 -0400 (EDT)
Received: by oign205 with SMTP id n205so805632oig.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 00:10:18 -0700 (PDT)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id s204si11548884oia.32.2015.05.06.00.10.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 00:10:17 -0700 (PDT)
Received: by obcux3 with SMTP id ux3so770465obc.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 00:10:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150506062801.GA12737@js1304-P5Q-DELUXE>
References: <1430732477-16977-1-git-send-email-zhuhui@xiaomi.com>
 <1430796179-1795-1-git-send-email-zhuhui@xiaomi.com> <20150506062801.GA12737@js1304-P5Q-DELUXE>
From: Hui Zhu <teawater@gmail.com>
Date: Wed, 6 May 2015 15:09:37 +0800
Message-ID: <CANFwon19RF+yGbstD4C=MfXYnktu19DxW-cxoxEoDf1mhr=1zA@mail.gmail.com>
Subject: Re: [PATCH v2] CMA: page_isolation: check buddy before access it
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Hui Zhu <zhuhui@xiaomi.com>, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, lauraa@codeaurora.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, May 6, 2015 at 2:28 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Tue, May 05, 2015 at 11:22:59AM +0800, Hui Zhu wrote:
>> Change pfn_present to pfn_valid_within according to the review of Laura.
>>
>> I got a issue:
>> [  214.294917] Unable to handle kernel NULL pointer dereference at virtual address 0000082a
>> [  214.303013] pgd = cc970000
>> [  214.305721] [0000082a] *pgd=00000000
>> [  214.309316] Internal error: Oops: 5 [#1] PREEMPT SMP ARM
>> [  214.335704] PC is at get_pageblock_flags_group+0x5c/0xb0
>> [  214.341030] LR is at unset_migratetype_isolate+0x148/0x1b0
>> [  214.346523] pc : [<c00cc9a0>]    lr : [<c0109874>]    psr: 80000093
>> [  214.346523] sp : c7029d00  ip : 00000105  fp : c7029d1c
>> [  214.358005] r10: 00000001  r9 : 0000000a  r8 : 00000004
>> [  214.363231] r7 : 60000013  r6 : 000000a4  r5 : c0a357e4  r4 : 00000000
>> [  214.369761] r3 : 00000826  r2 : 00000002  r1 : 00000000  r0 : 0000003f
>> [  214.376291] Flags: Nzcv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment user
>> [  214.383516] Control: 10c5387d  Table: 2cb7006a  DAC: 00000015
>> [  214.949720] Backtrace:
>> [  214.952192] [<c00cc944>] (get_pageblock_flags_group+0x0/0xb0) from [<c0109874>] (unset_migratetype_isolate+0x148/0x1b0)
>> [  214.962978]  r7:60000013 r6:c0a357c0 r5:c0a357e4 r4:c1555000
>> [  214.968693] [<c010972c>] (unset_migratetype_isolate+0x0/0x1b0) from [<c0109adc>] (undo_isolate_page_range+0xd0/0xdc)
>> [  214.979222] [<c0109a0c>] (undo_isolate_page_range+0x0/0xdc) from [<c00d097c>] (__alloc_contig_range+0x254/0x34c)
>> [  214.989398]  r9:000abc00 r8:c7028000 r7:000b1f53 r6:000b3e00 r5:00000005
>> r4:c7029db4
>> [  214.997308] [<c00d0728>] (__alloc_contig_range+0x0/0x34c) from [<c00d0a88>] (alloc_contig_range+0x14/0x18)
>> [  215.006973] [<c00d0a74>] (alloc_contig_range+0x0/0x18) from [<c0398148>] (dma_alloc_from_contiguous_addr+0x1ac/0x304)
>>
>> This issue is because when call unset_migratetype_isolate to unset a part
>> of CMA memory, it try to access the buddy page to get its status:
>>               if (order >= pageblock_order) {
>>                       page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
>>                       buddy_idx = __find_buddy_index(page_idx, order);
>>                       buddy = page + (buddy_idx - page_idx);
>>
>>                       if (!is_migrate_isolate_page(buddy)) {
>> But the begin addr of this part of CMA memory is very close to a part of
>> memory that is reserved in the boot time (not in buddy system).
>> So add a check before access it.
>>
>> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
>> ---
>>  mm/page_isolation.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index 755a42c..eb22d1f 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -101,7 +101,8 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>>                       buddy_idx = __find_buddy_index(page_idx, order);
>>                       buddy = page + (buddy_idx - page_idx);
>>
>> -                     if (!is_migrate_isolate_page(buddy)) {
>> +                     if (!pfn_valid_within(page_to_pfn(buddy))
>> +                         || !is_migrate_isolate_page(buddy)) {
>>                               __isolate_free_page(page, order);
>>                               kernel_map_pages(page, (1 << order), 1);
>>                               set_page_refcounted(page);
>
> Hello,
>
> This isolation is for merging buddy pages. If buddy is not valid, we
> don't need to isolate page, because we can't merge them.
> I think that correct code would be:
>
> pfn_valid_within(page_to_pfn(buddy)) &&
>         !is_migrate_isolate_page(buddy)
>
> But, isolation and free here is safe operation so your code will work
> fine.
>

Oops!  I posted a new version for the patch.

Thanks,
Hui

> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
