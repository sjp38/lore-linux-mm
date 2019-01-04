Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB1FB8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 10:01:43 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id s70so42989837qks.4
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 07:01:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 43sor48528941qve.56.2019.01.04.07.01.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 07:01:42 -0800 (PST)
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
References: <20181220185031.43146-1-cai@lca.pw>
 <20181220203156.43441-1-cai@lca.pw> <20190103115114.GL31793@dhcp22.suse.cz>
 <e3ff1455-06cc-063e-24f0-3b525c345b84@lca.pw>
 <20190103165927.GU31793@dhcp22.suse.cz>
 <5d8f3a98-a954-c8ab-83d9-2f94c614f268@lca.pw>
 <20190103190715.GZ31793@dhcp22.suse.cz>
 <62e96e34-7ea9-491a-b5b6-4828da980d48@lca.pw>
 <20190103202235.GE31793@dhcp22.suse.cz>
 <a5666d82-b7ad-4b90-5f4e-fd22afc3e1dc@lca.pw>
 <20190104130906.GO31793@dhcp22.suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <e4ad9d12-387d-1cc6-f404-cae6d43ccf80@lca.pw>
Date: Fri, 4 Jan 2019 10:01:40 -0500
MIME-Version: 1.0
In-Reply-To: <20190104130906.GO31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, Pavel.Tatashin@microsoft.com, mingo@kernel.org, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 1/4/19 8:09 AM, Michal Hocko wrote:
>> Here is the number without DEFERRED_STRUCT_PAGE_INIT.
>>
>> == page_ext_init() after page_alloc_init_late() ==
>> Node 0, zone DMA: page owner found early allocated 0 pages
>> Node 0, zone DMA32: page owner found early allocated 7009 pages
>> Node 0, zone Normal: page owner found early allocated 85827 pages
>> Node 4, zone Normal: page owner found early allocated 75063 pages
>>
>> == page_ext_init() before kmemleak_init() ==
>> Node 0, zone DMA: page owner found early allocated 0 pages
>> Node 0, zone DMA32: page owner found early allocated 6654 pages
>> Node 0, zone Normal: page owner found early allocated 41907 pages
>> Node 4, zone Normal: page owner found early allocated 41356 pages
>>
>> So, it told us that it will miss tens of thousands of early page allocation call
>> sites.
> 
> This is an answer for the first part of the question (how much). The
> second is _do_we_care_?

Well, the purpose of this simple "ugly" ifdef is to avoid a regression for the
existing page_owner users with DEFERRED_STRUCT_PAGE_INIT deselected that would
start to miss tens of thousands early page allocation call sites.

The other option I can think of to not hurt your eyes is to rewrite the whole
page_ext_init(), init_page_owner(), init_debug_guardpage() to use all early
functions, so it can work in both with DEFERRED_STRUCT_PAGE_INIT=y and without.
However, I have a hard-time to convince myself it is a sensible thing to do.
