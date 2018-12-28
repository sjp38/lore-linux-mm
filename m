Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70CCB8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 04:42:14 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s22so19547648pgv.8
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 01:42:14 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x13si40788770pgx.266.2018.12.28.01.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 01:42:12 -0800 (PST)
Date: Fri, 28 Dec 2018 17:42:08 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181228084105.GQ16738@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, Dec 28, 2018 at 09:41:05AM +0100, Michal Hocko wrote:
>On Fri 28-12-18 13:08:06, Wu Fengguang wrote:
>[...]
>> Optimization: do hot/cold page tracking and migration
>> =====================================================
>>
>> Since PMEM is slower than DRAM, we need to make sure hot pages go to
>> DRAM and cold pages stay in PMEM, to get the best out of PMEM and DRAM.
>>
>> - DRAM=>PMEM cold page migration
>>
>> It can be done in kernel page reclaim path, near the anonymous page
>> swap out point. Instead of swapping out, we now have the option to
>> migrate cold pages to PMEM NUMA nodes.
>
>OK, this makes sense to me except I am not sure this is something that
>should be pmem specific. Is there any reason why we shouldn't migrate
>pages on memory pressure to other nodes in general? In other words
>rather than paging out we whould migrate over to the next node that is
>not under memory pressure. Swapout would be the next level when the
>memory is (almost_) fully utilized. That wouldn't be pmem specific.

In future there could be multi memory levels with different
performance/size/cost metric. There are ongoing HMAT works to describe
that. When ready, we can switch to the HMAT based general infrastructure.
Then the code will no longer be PMEM specific, but do general
promotion/demotion migrations between high/low memory levels.
Swapout could be from the lowest level memory.

Migration between peer nodes is the obvious simple way and a good
choice for the initial implementation. But yeah, it's possible to
migrate to other nodes. For example, it can be combined with NUMA
balancing: if we know the page is mostly accessed by the other socket,
then it'd best to migrate hot/cold pages directly to that socket.

>> User space may also do it, however cannot act on-demand, when there
>> are memory pressure in DRAM nodes.
>>
>> - PMEM=>DRAM hot page migration
>>
>> While LRU can be good enough for identifying cold pages, frequency
>> based accounting can be more suitable for identifying hot pages.
>>
>> Our design choice is to create a flexible user space daemon to drive
>> the accounting and migration, with necessary kernel supports by this
>> patchset.
>
>We do have numa balancing, why cannot we rely on it? This along with the
>above would allow to have pmem numa nodes (cpuless nodes in fact)
>without any special casing and a natural part of the MM. It would be
>only the matter of the configuration to set the appropriate distance to
>allow reasonable allocation fallback strategy.

Good question. We actually tried reusing NUMA balancing mechanism to
do page-fault triggered migration. move_pages() only calls
change_prot_numa(). It turns out the 2 migration types have different
purposes (one for hotness, another for home node) and hence implement
details. We end up modifying some few NUMA balancing logic -- removing
rate limiting, changing target node logics, etc.

Those look unnecessary complexities for this post. This v2 patchset
mainly fulfills our first milestone goal: a minimal viable solution
that's relatively clean to backport. Even when preparing for new
upstreamable versions, it may be good to keep it simple for the
initial upstream inclusion.

>I haven't looked at the implementation yet but if you are proposing a
>special cased zone lists then this is something CDM (Coherent Device
>Memory) was trying to do two years ago and there was quite some
>skepticism in the approach.

It looks we are pretty different than CDM. :)
We creating new NUMA nodes rather than CDM's new ZONE.
The zonelists modification is just to make PMEM nodes more separated.

Thanks,
Fengguang
