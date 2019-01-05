Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEFC38E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 18:27:46 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so36429208edz.15
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:27:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z15-v6sor16173828eju.2.2019.01.05.15.27.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 15:27:45 -0800 (PST)
Date: Sat, 5 Jan 2019 23:27:43 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v3] mm: remove extra drain pages on pcp list
Message-ID: <20190105232743.zyjb5um3gqjcfsjw@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181218204656.4297-1-richard.weiyang@gmail.com>
 <20181221170228.10686-1-richard.weiyang@gmail.com>
 <20190103135609.GP31793@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190103135609.GP31793@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de, david@redhat.com

On Thu, Jan 03, 2019 at 02:56:09PM +0100, Michal Hocko wrote:
>On Sat 22-12-18 01:02:28, Wei Yang wrote:
>> In current implementation, there are two places to isolate a range of
>> page: __offline_pages() and alloc_contig_range(). During this procedure,
>> it will drain pages on pcp list.
>> 
>> Below is a brief call flow:
>> 
>>   __offline_pages()/alloc_contig_range()
>>       start_isolate_page_range()
>>           set_migratetype_isolate()
>>               drain_all_pages()
>>       drain_all_pages()                 <--- A
>> 
>> >From this snippet we can see current logic is isolate and drain pcp list
>> for each pageblock and drain pcp list again for the whole range.
>> 
>> While the drain at A is not necessary. The reason is
>> start_isolate_page_range() will set the migrate type of a range to
>> MIGRATE_ISOLATE. After doing so, this range will never be allocated from
>> Buddy, neither to a real user nor to pcp list. This means the procedure
>> to drain pages on pcp list after start_isolate_page_range() will not
>> drain any page in the target range.
>
>I am still not happy with the changelog. I would suggest the following
>instead
>
>"
>start_isolate_page_range is responsible for isolating the given pfn
>range. One part of that job is to make sure that also pages that are on
>the allocator pcp lists are properly isolated. Otherwise they could be
>reused and the range wouldn't be completely isolated until the memory is
>freed back.  While there is no strict guarantee here because pages might
>get allocated at any time before drain_all_pages is called there doesn't
>seem to be any strong demand for such a guarantee.
>
>In any case, draining is already done at the isolation level and there
>is no need to do it again later by start_isolate_page_range callers
>(memory hotplug and CMA allocator currently). Therefore remove pointless
>draining in existing callers to make the code more clear and
>functionally correct.
>"
> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>
>With something like that, you can add
>Acked-by: Michal Hocko <mhocko@suse.com>
>

Thanks, would adjust it accordingly.

-- 
Wei Yang
Help you, Help me
