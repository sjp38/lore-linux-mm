Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D10C06B000A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 01:44:26 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j189-v6so1206842oih.11
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 22:44:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y11-v6sor1752338oix.10.2018.08.07.22.44.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 22:44:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5543a32a-20f9-18ff-dc13-73737257ed99@suse.cz>
References: <20180806065224.31383-1-rashmica.g@gmail.com> <5543a32a-20f9-18ff-dc13-73737257ed99@suse.cz>
From: Rashmica Gupta <rashmica.g@gmail.com>
Date: Wed, 8 Aug 2018 15:44:24 +1000
Message-ID: <CAC6rBs=SySU9Amq2tr0AA6YMJVBmVhNyVCUfi+2b5MaSA=iLiw@mail.gmail.com>
Subject: Re: [PATCH v2] resource: Merge resources on a node when hot-adding memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: toshi.kani@hpe.com, tglx@linutronix.de, akpm@linux-foundation.org, bp@suse.de, brijesh.singh@amd.com, thomas.lendacky@amd.com, jglisse@redhat.com, gregkh@linuxfoundation.org, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, malat@debian.org, pasha.tatashin@oracle.com, Bjorn Helgaas <bhelgaas@google.com>, osalvador@techadventures.net, yasu.isimatu@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Aug 7, 2018 at 9:52 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 08/06/2018 08:52 AM, Rashmica Gupta wrote:
>> When hot-removing memory release_mem_region_adjustable() splits
>> iomem resources if they are not the exact size of the memory being
>> hot-deleted. Adding this memory back to the kernel adds a new
>> resource.
>>
>> Eg a node has memory 0x0 - 0xfffffffff. Offlining and hot-removing
>> 1GB from 0xf40000000 results in the single resource 0x0-0xfffffffff being
>> split into two resources: 0x0-0xf3fffffff and 0xf80000000-0xfffffffff.
>>
>> When we hot-add the memory back we now have three resources:
>> 0x0-0xf3fffffff, 0xf40000000-0xf7fffffff, and 0xf80000000-0xfffffffff.
>>
>> Now if we try to remove a section of memory that overlaps these resources,
>> like 2GB from 0xf40000000, release_mem_region_adjustable() fails as it
>> expects the chunk of memory to be within the boundaries of a single
>> resource.
>
> Hi,
>
> it's the first time I see the resource code, so I might be easily wrong.
> How can it happen that the second remove is section aligned but the
> first one not?
>

I probably shouldn't have used that word... When I said "a section of memory"
I really meant "a chunk of memory" or "some memory".


>> This patch adds a function request_resource_and_merge(). This is called
>> instead of request_resource_conflict() when registering a resource in
>> add_memory(). It calls request_resource_conflict() and if hot-removing is
>> enabled (if it isn't we won't get resource fragmentation) we attempt to
>> merge contiguous resources on the node.
>>
>> Signed-off-by: Rashmica Gupta <rashmica.g@gmail.com>
> ...
>> --- a/kernel/resource.c
>> +++ b/kernel/resource.c
> ...
>> +/*
>> + * Attempt to merge resources on the node
>> + */
>> +static void merge_node_resources(int nid, struct resource *parent)
>> +{
>> +     struct resource *res;
>> +     uint64_t start_addr;
>> +     uint64_t end_addr;
>> +     int ret;
>> +
>> +     start_addr = node_start_pfn(nid) << PAGE_SHIFT;
>> +     end_addr = node_end_pfn(nid) << PAGE_SHIFT;
>> +
>> +     write_lock(&resource_lock);
>> +
>> +     /* Get the first resource */
>> +     res = parent->child;
>> +
>> +     while (res) {
>> +             /* Check that the resource is within the node */
>> +             if (res->start < start_addr) {
>> +                     res = res->sibling;
>> +                     continue;
>> +             }
>> +             /* Exit if resource is past end of node */
>> +             if (res->sibling->end > end_addr)
>> +                     break;
>
> IIUC, resource end is closed, so adjacent resources's start is end+1.
> But node_end_pfn is open, so the comparison above should use '>='
> instead of '>'?

You are right. Thanks for spotting that.

>
>> +
>> +             ret = merge_resources(res);
>> +             if (!ret)
>> +                     continue;
>> +             res = res->sibling;
>
> Should this rather use next_resource() to merge at all levels of the
> hierarchy? Although memory seems to be flat under &iomem_resource so it
> would be just future-proofing.

I don't know enough about the hierarchy and layout of resources to comment on
this.

>
> Thanks,
> Vlastimil
