Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2F58E0008
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 12:58:49 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y83so19604310qka.7
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 09:58:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c47sor101004435qvh.6.2019.01.21.09.58.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 09:58:48 -0800 (PST)
Subject: Re: [PATCH] mm/hotplug: invalid PFNs from pfn_to_online_page()
From: Qian Cai <cai@lca.pw>
References: <51e79597-21ef-3073-9036-cfc33291f395@lca.pw>
 <20190118021650.93222-1-cai@lca.pw> <20190121095352.GM4087@dhcp22.suse.cz>
 <1295f347-5a14-5b3b-23ef-2f001c25d980@lca.pw>
Message-ID: <3c4aa744-4a8a-08a6-bc41-ac3a722a0d17@lca.pw>
Date: Mon, 21 Jan 2019 12:58:46 -0500
MIME-Version: 1.0
In-Reply-To: <1295f347-5a14-5b3b-23ef-2f001c25d980@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: akpm@linux-foundation.org, osalvador@suse.de, catalin.marinas@arm.com, vbabka@suse.cz, linux-mm@kvack.org



On 1/21/19 11:38 AM, Qian Cai wrote:
> 
> 
> On 1/21/19 4:53 AM, Michal Hocko wrote:
>> On Thu 17-01-19 21:16:50, Qian Cai wrote:
>>> On an arm64 ThunderX2 server, the first kmemleak scan would crash [1]
>>> with CONFIG_DEBUG_VM_PGFLAGS=y due to page_to_nid() found a pfn that is
>>> not directly mapped (MEMBLOCK_NOMAP). Hence, the page->flags is
>>> uninitialized.
>>>
>>> This is due to the commit 9f1eb38e0e11 ("mm, kmemleak: little
>>> optimization while scanning") starts to use pfn_to_online_page() instead
>>> of pfn_valid(). However, in the CONFIG_MEMORY_HOTPLUG=y case,
>>> pfn_to_online_page() does not call memblock_is_map_memory() while
>>> pfn_valid() does.
>>
>> How come there is an online section which has an pfn_valid==F? We do
>> allocate the full section worth of struct pages so there is a valid
>> struct page. Is there any hole inside this section?
> 
> It has CONFIG_HOLES_IN_ZONE=y.

Actually, this does not seem have anything to do with holes.

68709f45385a arm64: only consider memblocks with NOMAP cleared for linear mapping

This causes pages marked as nomap being no long reassigned to the new zone in
memmap_init_zone() by calling __init_single_page().

There is an old discussion for this topic.
https://lkml.org/lkml/2016/11/30/566
