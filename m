Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E6DE46B0005
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 04:08:01 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c3so2247465eda.3
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:08:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9-v6si780227ejf.91.2018.11.13.01.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 01:08:00 -0800 (PST)
Date: Tue, 13 Nov 2018 10:07:58 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: skip zone who has no managed_pages in
 calculate_totalreserve_pages()
Message-ID: <20181113090758.GL15120@dhcp22.suse.cz>
References: <20181112071404.13620-1-richard.weiyang@gmail.com>
 <20181112080926.GA14987@dhcp22.suse.cz>
 <20181112142641.6oxn4fv4pocm7fmt@master>
 <20181112144020.GC14987@dhcp22.suse.cz>
 <20181113013942.zgixlky4ojbzikbd@master>
 <20181113080834.GK15120@dhcp22.suse.cz>
 <20181113081644.giu5vxhsfqjqlexh@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113081644.giu5vxhsfqjqlexh@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Tue 13-11-18 08:16:44, Wei Yang wrote:
> On Tue, Nov 13, 2018 at 09:08:34AM +0100, Michal Hocko wrote:
> >On Tue 13-11-18 01:39:42, Wei Yang wrote:
> >> On Mon, Nov 12, 2018 at 03:40:20PM +0100, Michal Hocko wrote:
> >> >On Mon 12-11-18 14:26:41, Wei Yang wrote:
> >> >> On Mon, Nov 12, 2018 at 09:09:26AM +0100, Michal Hocko wrote:
> >> >> >On Mon 12-11-18 15:14:04, Wei Yang wrote:
> >> >> >> Zone with no managed_pages doesn't contribute totalreserv_pages. And the
> >> >> >> more nodes we have, the more empty zones there are.
> >> >> >> 
> >> >> >> This patch skip the zones to save some cycles.
> >> >> >
> >> >> >What is the motivation for the patch? Does it really cause any
> >> >> >measurable difference in performance?
> >> >> >
> >> >> 
> >> >> The motivation here is to reduce some unnecessary work.
> >> >
> >> >I have guessed so even though the changelog was quite modest on the
> >> >motivation.
> >> >
> >> >> Based on my understanding, almost every node has empty zones, since
> >> >> zones within a node are ordered in monotonic increasing memory address.
> >> >
> >> >Yes, this is likely the case. Btw. a check for populated_zone or
> >> >for_each_populated_zone would suite much better.
> >> >
> >> 
> >> Hmm... maybe not exact.
> >> 
> >>     populated_zone checks zone->present_pages
> >>     managed_zone checks zone->managed_pages
> >> 
> >> As the comment of managed_zone says, this one records the pages managed
> >> by buddy system. And when we look at the usage of totalreserve_pages, it
> >> is only used in page allocation. And finally, *max* is checked with
> >> managed_pages instead of present_pages.
> >> 
> >> Because of this, managed_zone is more accurate at this place. Is my
> >> understanding correct?
> >
> >OK, fair enough. There is a certain discrepancy here. You are right that
> >we do not care about pages out of the page allocator scope (e.g. early
> >bootmem allocations, struct pages) but this is likely what other callers
> >of populated_zone are looking for as well. It seems that managed pages
> >counter which only came in later was not considered in other places.
> >
> >That being said this asks for a cleanup of some sort. And I think such a
> >cleanup wold be appreciated much more than an optimization of an unknown
> >effect and wonder why this check is used here and not at other places.
> 
> You are right. There are three pages(spanned, managed, present) in a
> zone, which is a little confusing.
> 
> So you are willing to get rid of present_pages, if I am right?

No, I believe we want all three of them. But reviewing
for_each_populated_zone users and explicit checks for present/managed
pages and unify them would be a step forward both a more optimal code
and more maintainable code. I haven't checked but
for_each_populated_zone would seem like a proper user for managed page
counter. But that really requires to review all current users.

-- 
Michal Hocko
SUSE Labs
