Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC8D28E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 17:22:32 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id p24so43524207qtl.2
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 14:22:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 76sor25373221qkb.139.2019.01.03.14.22.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 14:22:31 -0800 (PST)
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
References: <20181220185031.43146-1-cai@lca.pw>
 <20181220203156.43441-1-cai@lca.pw> <20190103115114.GL31793@dhcp22.suse.cz>
 <e3ff1455-06cc-063e-24f0-3b525c345b84@lca.pw>
 <20190103165927.GU31793@dhcp22.suse.cz>
 <5d8f3a98-a954-c8ab-83d9-2f94c614f268@lca.pw>
 <20190103190715.GZ31793@dhcp22.suse.cz>
 <62e96e34-7ea9-491a-b5b6-4828da980d48@lca.pw>
 <20190103202235.GE31793@dhcp22.suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <a5666d82-b7ad-4b90-5f4e-fd22afc3e1dc@lca.pw>
Date: Thu, 3 Jan 2019 17:22:29 -0500
MIME-Version: 1.0
In-Reply-To: <20190103202235.GE31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, Pavel.Tatashin@microsoft.com, mingo@kernel.org, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 1/3/19 3:22 PM, Michal Hocko wrote:
> On Thu 03-01-19 14:53:47, Qian Cai wrote:
>> On 1/3/19 2:07 PM, Michal Hocko wrote> So can we make the revert with an
>> explanation that the patch was wrong?
>>> If we want to make hacks to catch more objects to be tracked then it
>>> would be great to have some numbers in hands.
>>
>> Well, those numbers are subject to change depends on future start_kernel()
>> order. Right now, there are many functions could be caught earlier by page owner.
>>
>> 	kmemleak_init();
> [...]
>> 	sched_init_smp();
> 
> The kernel source dump will not tell us much of course. A ball park
> number whether we are talking about dozen, hundreds or thousands of
> allocations would tell us something at least, doesn't it.
> 
> Handwaving that it might help us some is not particurarly useful. We are
> already losing some allocations already. Does it matter? Well, that
> depends, sometimes we do want to catch an owner of particular page and
> it is sad to find nothing. But how many times have you or somebody else
> encountered that in practice. That is exactly a useful information to
> judge an ugly ifdefery in the code. See my point?

Here is the number without DEFERRED_STRUCT_PAGE_INIT.

== page_ext_init() after page_alloc_init_late() ==
Node 0, zone DMA: page owner found early allocated 0 pages
Node 0, zone DMA32: page owner found early allocated 7009 pages
Node 0, zone Normal: page owner found early allocated 85827 pages
Node 4, zone Normal: page owner found early allocated 75063 pages

== page_ext_init() before kmemleak_init() ==
Node 0, zone DMA: page owner found early allocated 0 pages
Node 0, zone DMA32: page owner found early allocated 6654 pages
Node 0, zone Normal: page owner found early allocated 41907 pages
Node 4, zone Normal: page owner found early allocated 41356 pages

So, it told us that it will miss tens of thousands of early page allocation call
sites.
