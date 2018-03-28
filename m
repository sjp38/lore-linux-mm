Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 799936B0031
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:17:27 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g22so1270974pgv.16
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:17:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p3sor957485pga.31.2018.03.28.06.17.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 06:17:26 -0700 (PDT)
Date: Wed, 28 Mar 2018 21:17:14 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: break on the first hit of mem range
Message-ID: <20180328131714.GA543@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180327035707.84113-1-richard.weiyang@gmail.com>
 <20180327105821.GF5652@dhcp22.suse.cz>
 <20180328003936.GB91956@WeideMacBook-Pro.local>
 <20180328070200.GC9275@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180328070200.GC9275@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org

On Wed, Mar 28, 2018 at 09:02:00AM +0200, Michal Hocko wrote:
>On Wed 28-03-18 08:39:36, Wei Yang wrote:
>> On Tue, Mar 27, 2018 at 12:58:21PM +0200, Michal Hocko wrote:
>> >On Tue 27-03-18 11:57:07, Wei Yang wrote:
>> >> find_min_pfn_for_node() iterate on pfn range to find the minimum pfn for a
>> >> node. The memblock_region in memblock_type are already ordered, which means
>> >> the first hit in iteration is the minimum pfn.
>> >
>> >I haven't looked at the code yet but the changelog should contain the
>> >motivation why it exists. It seems like this is an optimization. If so,
>> >what is the impact?
>> >
>> 
>> Yep, this is a trivial optimization on searching the minimal pfn on a special
>> node. It would be better for audience to understand if I put some words in
>> change log.
>> 
>> The impact of this patch is it would accelerate the searching process when
>> there are many memory ranges in memblock.
>> 
>> For example, in the case https://lkml.org/lkml/2018/3/25/291, there are around
>> 30 memory ranges on node 0. The original code need to iterate all those ranges
>> to find the minimal pfn, while after optimization it just need once.
>
>Then show us some numbers to justify the change.

Oops, I don't have any data to prove this.

My test machine just has 7 memory regions and only one node. So it reduce
iteration from 7 to 1, which I don't think will have some visible effect.

While we can do some calculation to estimate the effect.

Assume there are N memory regions and M nodes and each node has equal number
of memory regions.

So before the change, there are

	N * M    iterations

After this optimization, there are

        (N / 2) * M   iterations

So the expected improvement of this change is half the iterations for finding
the minimal pfn.

Last but not the least, as I know, usually there are less than 100 memory
regions on a machine. This improvement is really limited on current systems.
The more memory regions and node a system has, the more improvement it will
has.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
