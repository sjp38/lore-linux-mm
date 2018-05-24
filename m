Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id C751C6B000D
	for <linux-mm@kvack.org>; Thu, 24 May 2018 16:55:10 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id q4-v6so1664955ote.6
        for <linux-mm@kvack.org>; Thu, 24 May 2018 13:55:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b48-v6sor10630005otj.310.2018.05.24.13.55.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 May 2018 13:55:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180523041954.GA16285@hori1.linux.bs1.fc.nec.co.jp>
References: <152699997165.24093.12194490924829406111.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152700000922.24093.14813242965473482705.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180523041954.GA16285@hori1.linux.bs1.fc.nec.co.jp>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 24 May 2018 13:55:04 -0700
Message-ID: <CAPcyv4hL5+ZfHjnYYtoioB5AK5Ukpg99d6eYWTKSeJc6uHxkyg@mail.gmail.com>
Subject: Re: [PATCH 07/11] mm, madvise_inject_error: fix page count leak
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Andi Kleen <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, "hch@lst.de" <hch@lst.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>

On Tue, May 22, 2018 at 9:19 PM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> On Tue, May 22, 2018 at 07:40:09AM -0700, Dan Williams wrote:
>> The madvise_inject_error() routine uses get_user_pages() to lookup the
>> pfn and other information for injected error, but it fails to release
>> that pin.
>>
>> The dax-dma-vs-truncate warning catches this failure with the following
>> signature:
>>
>>  Injecting memory failure for pfn 0x208900 at process virtual address 0x7f3908d00000
>>  Memory failure: 0x208900: reserved kernel page still referenced by 1 users
>>  Memory failure: 0x208900: recovery action for reserved kernel page: Failed
>>  WARNING: CPU: 37 PID: 9566 at fs/dax.c:348 dax_disassociate_entry+0x4e/0x90
>>  CPU: 37 PID: 9566 Comm: umount Tainted: G        W  OE     4.17.0-rc6+ #1900
>>  [..]
>>  RIP: 0010:dax_disassociate_entry+0x4e/0x90
>>  RSP: 0018:ffffc9000a9b3b30 EFLAGS: 00010002
>>  RAX: ffffea0008224000 RBX: 0000000000208a00 RCX: 0000000000208900
>>  RDX: 0000000000000001 RSI: ffff8804058c6160 RDI: 0000000000000008
>>  RBP: 000000000822000a R08: 0000000000000002 R09: 0000000000208800
>>  R10: 0000000000000000 R11: 0000000000208801 R12: ffff8804058c6168
>>  R13: 0000000000000000 R14: 0000000000000002 R15: 0000000000000001
>>  FS:  00007f4548027fc0(0000) GS:ffff880431d40000(0000) knlGS:0000000000000000
>>  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>  CR2: 000056316d5f8988 CR3: 00000004298cc000 CR4: 00000000000406e0
>>  Call Trace:
>>   __dax_invalidate_mapping_entry+0xab/0xe0
>>   dax_delete_mapping_entry+0xf/0x20
>>   truncate_exceptional_pvec_entries.part.14+0x1d4/0x210
>>   truncate_inode_pages_range+0x291/0x920
>>   ? kmem_cache_free+0x1f8/0x300
>>   ? lock_acquire+0x9f/0x200
>>   ? truncate_inode_pages_final+0x31/0x50
>>   ext4_evict_inode+0x69/0x740
>>
>> Cc: <stable@vger.kernel.org>
>> Fixes: bd1ce5f91f54 ("HWPOISON: avoid grabbing the page count...")
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Andi Kleen <ak@linux.intel.com>
>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  mm/madvise.c |   11 ++++++++---
>>  1 file changed, 8 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index 4d3c922ea1a1..246fa4d4eee2 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -631,11 +631,13 @@ static int madvise_inject_error(int behavior,
>>
>>
>>       for (; start < end; start += PAGE_SIZE << order) {
>> +             unsigned long pfn;
>>               int ret;
>>
>>               ret = get_user_pages_fast(start, 1, 0, &page);
>>               if (ret != 1)
>>                       return ret;
>> +             pfn = page_to_pfn(page);
>>
>>               /*
>>                * When soft offlining hugepages, after migrating the page
>> @@ -651,17 +653,20 @@ static int madvise_inject_error(int behavior,
>>
>>               if (behavior == MADV_SOFT_OFFLINE) {
>>                       pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
>> -                                             page_to_pfn(page), start);
>> +                                     pfn, start);
>>
>>                       ret = soft_offline_page(page, MF_COUNT_INCREASED);
>> +                     put_page(page);
>>                       if (ret)
>>                               return ret;
>>                       continue;
>>               }
>> +             put_page(page);
>
> We keep the page count pinned after the isolation of the error page
> in order to make sure that the error page is disabled and never reused.
> This seems not explicit enough, so some comment should be helpful.

As far as I can see this extra reference count to keep the page from
being should be taken internal to memory_failure(), not assumed from
the inject error path. I might be overlooking something, but I do not
see who is responsible for taking this extra reference in the case
where memory_failure() is called by the machine check code rather than
madvise_inject_error()?

>
> BTW, looking at the kernel message like "Memory failure: 0x208900:
> reserved kernel page still referenced by 1 users", memory_failure()
> considers dav_pagemap pages as "reserved kernel pages" (MF_MSG_KERNEL).
> If memory error handler recovers a dav_pagemap page in its special way,
> we can define a new action_page_types entry like MF_MSG_DAX.
> Reporting like "Memory failure: 0xXXXXX: recovery action for dax page:
> Failed" might be helpful for end user's perspective.

Sounds good, I'll take a look at this.
