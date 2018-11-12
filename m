Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E76186B028A
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 09:40:24 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 3-v6so7316818plc.18
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 06:40:24 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 19si15590256pgq.215.2018.11.12.06.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 06:40:23 -0800 (PST)
Date: Mon, 12 Nov 2018 15:40:20 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: skip zone who has no managed_pages in
 calculate_totalreserve_pages()
Message-ID: <20181112144020.GC14987@dhcp22.suse.cz>
References: <20181112071404.13620-1-richard.weiyang@gmail.com>
 <20181112080926.GA14987@dhcp22.suse.cz>
 <20181112142641.6oxn4fv4pocm7fmt@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181112142641.6oxn4fv4pocm7fmt@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Mon 12-11-18 14:26:41, Wei Yang wrote:
> On Mon, Nov 12, 2018 at 09:09:26AM +0100, Michal Hocko wrote:
> >On Mon 12-11-18 15:14:04, Wei Yang wrote:
> >> Zone with no managed_pages doesn't contribute totalreserv_pages. And the
> >> more nodes we have, the more empty zones there are.
> >> 
> >> This patch skip the zones to save some cycles.
> >
> >What is the motivation for the patch? Does it really cause any
> >measurable difference in performance?
> >
> 
> The motivation here is to reduce some unnecessary work.

I have guessed so even though the changelog was quite modest on the
motivation.

> Based on my understanding, almost every node has empty zones, since
> zones within a node are ordered in monotonic increasing memory address.

Yes, this is likely the case. Btw. a check for populated_zone or
for_each_populated_zone would suite much better.

> The worst case is all zones has managed_pages. For example, there is
> only one node, or configured to have only ZONE_NORMAL and
> ZONE_MOVABLE. Otherwise, the more node/zone we have, the more empty
> zones there are.
> 
> I didn't have detail tests on this patch, since I don't have machine
> with large numa nodes. While compared with the following ten lines of
> code, this check to skip them is worthwhile to me.

Well, the main question is whether the optimization is really worth it.
There is not much work done for each zone.

I haven't looked closer whether the patch is actually correct, it seems
to be though, but optimizations without measurable effect tend to be not
that attractive.

-- 
Michal Hocko
SUSE Labs
