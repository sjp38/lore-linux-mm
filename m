Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9AC36B026C
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 03:16:47 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e12so5569243edd.16
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 00:16:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e28sor3220993edb.24.2018.11.13.00.16.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 00:16:46 -0800 (PST)
Date: Tue, 13 Nov 2018 08:16:44 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: skip zone who has no managed_pages in
 calculate_totalreserve_pages()
Message-ID: <20181113081644.giu5vxhsfqjqlexh@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181112071404.13620-1-richard.weiyang@gmail.com>
 <20181112080926.GA14987@dhcp22.suse.cz>
 <20181112142641.6oxn4fv4pocm7fmt@master>
 <20181112144020.GC14987@dhcp22.suse.cz>
 <20181113013942.zgixlky4ojbzikbd@master>
 <20181113080834.GK15120@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113080834.GK15120@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Tue, Nov 13, 2018 at 09:08:34AM +0100, Michal Hocko wrote:
>On Tue 13-11-18 01:39:42, Wei Yang wrote:
>> On Mon, Nov 12, 2018 at 03:40:20PM +0100, Michal Hocko wrote:
>> >On Mon 12-11-18 14:26:41, Wei Yang wrote:
>> >> On Mon, Nov 12, 2018 at 09:09:26AM +0100, Michal Hocko wrote:
>> >> >On Mon 12-11-18 15:14:04, Wei Yang wrote:
>> >> >> Zone with no managed_pages doesn't contribute totalreserv_pages. And the
>> >> >> more nodes we have, the more empty zones there are.
>> >> >> 
>> >> >> This patch skip the zones to save some cycles.
>> >> >
>> >> >What is the motivation for the patch? Does it really cause any
>> >> >measurable difference in performance?
>> >> >
>> >> 
>> >> The motivation here is to reduce some unnecessary work.
>> >
>> >I have guessed so even though the changelog was quite modest on the
>> >motivation.
>> >
>> >> Based on my understanding, almost every node has empty zones, since
>> >> zones within a node are ordered in monotonic increasing memory address.
>> >
>> >Yes, this is likely the case. Btw. a check for populated_zone or
>> >for_each_populated_zone would suite much better.
>> >
>> 
>> Hmm... maybe not exact.
>> 
>>     populated_zone checks zone->present_pages
>>     managed_zone checks zone->managed_pages
>> 
>> As the comment of managed_zone says, this one records the pages managed
>> by buddy system. And when we look at the usage of totalreserve_pages, it
>> is only used in page allocation. And finally, *max* is checked with
>> managed_pages instead of present_pages.
>> 
>> Because of this, managed_zone is more accurate at this place. Is my
>> understanding correct?
>
>OK, fair enough. There is a certain discrepancy here. You are right that
>we do not care about pages out of the page allocator scope (e.g. early
>bootmem allocations, struct pages) but this is likely what other callers
>of populated_zone are looking for as well. It seems that managed pages
>counter which only came in later was not considered in other places.
>
>That being said this asks for a cleanup of some sort. And I think such a
>cleanup wold be appreciated much more than an optimization of an unknown
>effect and wonder why this check is used here and not at other places.

You are right. There are three pages(spanned, managed, present) in a
zone, which is a little confusing.

So you are willing to get rid of present_pages, if I am right?

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
