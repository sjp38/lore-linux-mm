Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2675F8E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 15:18:11 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id w28so8802005qkj.22
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 12:18:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 23sor49551890qvf.66.2019.01.04.12.18.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 12:18:10 -0800 (PST)
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
References: <20190103165927.GU31793@dhcp22.suse.cz>
 <5d8f3a98-a954-c8ab-83d9-2f94c614f268@lca.pw>
 <20190103190715.GZ31793@dhcp22.suse.cz>
 <62e96e34-7ea9-491a-b5b6-4828da980d48@lca.pw>
 <20190103202235.GE31793@dhcp22.suse.cz>
 <a5666d82-b7ad-4b90-5f4e-fd22afc3e1dc@lca.pw>
 <20190104130906.GO31793@dhcp22.suse.cz>
 <e4ad9d12-387d-1cc6-f404-cae6d43ccf80@lca.pw>
 <20190104151737.GT31793@dhcp22.suse.cz>
 <c8faf7eb-d23f-4ef7-3432-0acc7165f883@lca.pw>
 <20190104153245.GV31793@dhcp22.suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <fa135cd8-32e5-86f7-14ee-30685bca91b5@lca.pw>
Date: Fri, 4 Jan 2019 15:18:08 -0500
MIME-Version: 1.0
In-Reply-To: <20190104153245.GV31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, Pavel.Tatashin@microsoft.com, mingo@kernel.org, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 1/4/19 10:32 AM, Michal Hocko wrote:
> On Fri 04-01-19 10:25:12, Qian Cai wrote:
>> On 1/4/19 10:17 AM, Michal Hocko wrote:
>>> On Fri 04-01-19 10:01:40, Qian Cai wrote:
>>>> On 1/4/19 8:09 AM, Michal Hocko wrote:
>>>>>> Here is the number without DEFERRED_STRUCT_PAGE_INIT.
>>>>>>
>>>>>> == page_ext_init() after page_alloc_init_late() ==
>>>>>> Node 0, zone DMA: page owner found early allocated 0 pages
>>>>>> Node 0, zone DMA32: page owner found early allocated 7009 pages
>>>>>> Node 0, zone Normal: page owner found early allocated 85827 pages
>>>>>> Node 4, zone Normal: page owner found early allocated 75063 pages
>>>>>>
>>>>>> == page_ext_init() before kmemleak_init() ==
>>>>>> Node 0, zone DMA: page owner found early allocated 0 pages
>>>>>> Node 0, zone DMA32: page owner found early allocated 6654 pages
>>>>>> Node 0, zone Normal: page owner found early allocated 41907 pages
>>>>>> Node 4, zone Normal: page owner found early allocated 41356 pages
>>>>>>
>>>>>> So, it told us that it will miss tens of thousands of early page allocation call
>>>>>> sites.
>>>>>
>>>>> This is an answer for the first part of the question (how much). The
>>>>> second is _do_we_care_?
>>>>
>>>> Well, the purpose of this simple "ugly" ifdef is to avoid a regression for the
>>>> existing page_owner users with DEFERRED_STRUCT_PAGE_INIT deselected that would
>>>> start to miss tens of thousands early page allocation call sites.
>>>
>>> I am pretty sure we will hear about that when that happens. And act
>>> accordingly.
>>>
>>>> The other option I can think of to not hurt your eyes is to rewrite the whole
>>>> page_ext_init(), init_page_owner(), init_debug_guardpage() to use all early
>>>> functions, so it can work in both with DEFERRED_STRUCT_PAGE_INIT=y and without.
>>>> However, I have a hard-time to convince myself it is a sensible thing to do.
>>>
>>> Or simply make the page_owner initialization only touch the already
>>> initialized memory. Have you explored that option as well?
>>
>> Yes, a proof-of-concept version is v1 where ends up with more ifdefs due to
>> dealing with all the low-level details,
>>
>> https://lore.kernel.org/lkml/20181220060303.38686-1-cai@lca.pw/
> 
> That is obviously not what I've had in mind. We have __init_single_page
> which initializes a single struct page. Is there any way to hook
> page_ext initialization there?

Well, the current design is,

(1) allocate page_ext physical-contiguous pages for all
    nodes.
(2) page owner gathers all early allocation pages.
(3) page owner is fully operational.

It may be possible to move (1) as early as possible just after vmalloc_init() in
start_kernel() because it depends on vmalloc(), but it still needs to call (2)
as there have had many early allocation pages already.

Node 0, zone DMA: page owner found early allocated 0 pages
Node 0, zone DMA32: page owner found early allocated 6654 pages
Node 0, zone Normal: page owner found early allocated 40972 pages
Node 4, zone Normal: page owner found early allocated 40968 pages

But, (2) still depends on DEFERRED_STRUCT_PAGE_INIT. To get ride of this
dependency, it may be possible to add some checking in __init_single_page():

- if not done (1), save those pages to an array and defer
  page_owner early_handle initialization until done (1).

Though, I can't see any really benefit of this approach apart from "beautify"
the code.
