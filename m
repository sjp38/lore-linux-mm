Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC7B9C49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 03:09:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A0C3206A1
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 03:09:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A0C3206A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11AED6B0003; Mon, 16 Sep 2019 23:09:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CD1A6B0005; Mon, 16 Sep 2019 23:09:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFCCF6B0006; Mon, 16 Sep 2019 23:09:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0069.hostedemail.com [216.40.44.69])
	by kanga.kvack.org (Postfix) with ESMTP id D134C6B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 23:09:55 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5894B180AD802
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 03:09:55 +0000 (UTC)
X-FDA: 75942933150.14.drink17_7367016a2d356
X-HE-Tag: drink17_7367016a2d356
X-Filterd-Recvd-Size: 4795
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 03:09:52 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 02989337;
	Mon, 16 Sep 2019 20:09:52 -0700 (PDT)
Received: from [10.162.40.131] (p8cg001049571a15.blr.arm.com [10.162.40.131])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8E5E53F575;
	Mon, 16 Sep 2019 20:09:49 -0700 (PDT)
Subject: Re: [PATCH] mm/hotplug: Reorder memblock_[free|remove]() calls in
 try_remove_memory()
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org,
 linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>,
 Michal Hocko <mhocko@suse.com>, David Hildenbrand <david@redhat.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Dan Williams <dan.j.williams@intel.com>
References: <1568612857-10395-1-git-send-email-anshuman.khandual@arm.com>
 <20190916063612.GA1502@linux.ibm.com>
 <987dfde7-53f9-b013-5841-2c27c03d62d6@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <cc4193ec-a760-539b-099e-4aa1816dcea6@arm.com>
Date: Tue, 17 Sep 2019 08:40:03 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <987dfde7-53f9-b013-5841-2c27c03d62d6@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 09/16/2019 02:20 PM, Anshuman Khandual wrote:
> 
> 
> On 09/16/2019 12:06 PM, Mike Rapoport wrote:
>> On Mon, Sep 16, 2019 at 11:17:37AM +0530, Anshuman Khandual wrote:
>>> In add_memory_resource() the memory range to be hot added first gets into
>>> the memblock via memblock_add() before arch_add_memory() is called on it.
>>> Reverse sequence should be followed during memory hot removal which already
>>> is being followed in add_memory_resource() error path. This now ensures
>>> required re-order between memblock_[free|remove]() and arch_remove_memory()
>>> during memory hot-remove.
>>>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Oscar Salvador <osalvador@suse.de>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: David Hildenbrand <david@redhat.com>
>>> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>>> Cc: Dan Williams <dan.j.williams@intel.com>
>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>> ---
>>> Original patch https://lkml.org/lkml/2019/9/3/327
>>>
>>> Memory hot remove now works on arm64 without this because a recent commit
>>> 60bb462fc7ad ("drivers/base/node.c: simplify unregister_memory_block_under_nodes()").
>>>
>>> David mentioned that re-ordering should still make sense for consistency
>>> purpose (removing stuff in the reverse order they were added). This patch
>>> is now detached from arm64 hot-remove series.
>>>
>>> https://lkml.org/lkml/2019/9/3/326
>>>
>>>  mm/memory_hotplug.c | 4 ++--
>>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>> index c73f09913165..355c466e0621 100644
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -1770,13 +1770,13 @@ static int __ref try_remove_memory(int nid, u64 start, u64 size)
>>>
>>>  	/* remove memmap entry */
>>>  	firmware_map_remove(start, start + size, "System RAM");
>>> -	memblock_free(start, size);
>>> -	memblock_remove(start, size);
>>>
>>>  	/* remove memory block devices before removing memory */
>>>  	remove_memory_block_devices(start, size);
>>>
>>>  	arch_remove_memory(nid, start, size, NULL);
>>> +	memblock_free(start, size);
>>
>> I don't see memblock_reserve() anywhere in memory_hotplug.c, so the
>> memblock_free() call here seems superfluous. I think it can be simply
>> dropped.
> 
> I had observed that previously but was not sure whether or not there are
> still scenarios where it might be true. Error path in add_memory_resource()
> even just calls memblock_remove() not memblock_free(). Unless there is any
> objection, can just drop it.

Hello Mike,

Looks like we might need memblock_free() here as well. As you mentioned
before there might not be any memblock_reserve() in mm/memory_hotplug.c
but that does not guarantee that there could not have been a previous
memblock_reserve() or memblock_alloc_XXX() allocation which came from
the current hot remove range.

memblock_free() followed by memblock_remove() on the entire hot-remove
range ensures that memblock.memory and memblock.reserve are in sync and
the entire range is guaranteed to be removed from both the memory types.
Or am I missing something here.

- Anshuman

