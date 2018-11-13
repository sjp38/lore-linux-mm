Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 76A416B0006
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 20:39:46 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so1809375eda.3
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 17:39:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z2-v6sor9439769edp.6.2018.11.12.17.39.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 17:39:44 -0800 (PST)
Date: Tue, 13 Nov 2018 01:39:42 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: skip zone who has no managed_pages in
 calculate_totalreserve_pages()
Message-ID: <20181113013942.zgixlky4ojbzikbd@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181112071404.13620-1-richard.weiyang@gmail.com>
 <20181112080926.GA14987@dhcp22.suse.cz>
 <20181112142641.6oxn4fv4pocm7fmt@master>
 <20181112144020.GC14987@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181112144020.GC14987@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Mon, Nov 12, 2018 at 03:40:20PM +0100, Michal Hocko wrote:
>On Mon 12-11-18 14:26:41, Wei Yang wrote:
>> On Mon, Nov 12, 2018 at 09:09:26AM +0100, Michal Hocko wrote:
>> >On Mon 12-11-18 15:14:04, Wei Yang wrote:
>> >> Zone with no managed_pages doesn't contribute totalreserv_pages. And the
>> >> more nodes we have, the more empty zones there are.
>> >> 
>> >> This patch skip the zones to save some cycles.
>> >
>> >What is the motivation for the patch? Does it really cause any
>> >measurable difference in performance?
>> >
>> 
>> The motivation here is to reduce some unnecessary work.
>
>I have guessed so even though the changelog was quite modest on the
>motivation.
>
>> Based on my understanding, almost every node has empty zones, since
>> zones within a node are ordered in monotonic increasing memory address.
>
>Yes, this is likely the case. Btw. a check for populated_zone or
>for_each_populated_zone would suite much better.
>

Hmm... maybe not exact.

    populated_zone checks zone->present_pages
    managed_zone checks zone->managed_pages

As the comment of managed_zone says, this one records the pages managed
by buddy system. And when we look at the usage of totalreserve_pages, it
is only used in page allocation. And finally, *max* is checked with
managed_pages instead of present_pages.

Because of this, managed_zone is more accurate at this place. Is my
understanding correct?

>> The worst case is all zones has managed_pages. For example, there is
>> only one node, or configured to have only ZONE_NORMAL and
>> ZONE_MOVABLE. Otherwise, the more node/zone we have, the more empty
>> zones there are.
>> 
>> I didn't have detail tests on this patch, since I don't have machine
>> with large numa nodes. While compared with the following ten lines of
>> code, this check to skip them is worthwhile to me.
>
>Well, the main question is whether the optimization is really worth it.
>There is not much work done for each zone.
>
>I haven't looked closer whether the patch is actually correct, it seems
>to be though, but optimizations without measurable effect tend to be not
>that attractive.
>

I believe you are right to some extend, this tiny invisible change is
far away from attractive. While I have another opinion about
optimization.

That would be great to have a strong optimizatioin which improve the
system more than 10%. And there are another kind of optimization that
improves the system a little. We may call it polish.

One polish may not obvious, while cumulative polish make a system
outstanding.

Why German products are famous all around the world? Why people is
willing to pay much more to get a ZWILLING knife than others? Because we
trust German manufactures will polish their product day after day, year
after year with any efforts they can.

So as I am to linux kernel.

BTW, I am also thinking about to reduce some unnecessary work of
lowmem_reserve[] calculation. Because those empty zone's lowmem_reserve
is never used. Even cumulative effect of these two optimization is
trivial, I still think it is worth.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
