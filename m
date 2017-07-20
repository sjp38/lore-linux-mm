Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 373456B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:55:45 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w63so11842094wrc.5
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 23:55:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s11si1647010wra.513.2017.07.19.23.55.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 23:55:44 -0700 (PDT)
Subject: Re: [PATCH 6/9] mm, page_alloc: simplify zonelist initialization
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-7-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d23a3570-e39c-d708-c9d1-80258d45a97f@suse.cz>
Date: Thu, 20 Jul 2017 08:55:42 +0200
MIME-Version: 1.0
In-Reply-To: <20170714080006.7250-7-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 07/14/2017 10:00 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> build_zonelists gradually builds zonelists from the nearest to the most
> distant node. As we do not know how many populated zones we will have in
> each node we rely on the _zoneref to terminate initialized part of the
> zonelist by a NULL zone. While this is functionally correct it is quite
> suboptimal because we cannot allow updaters to race with zonelists
> users because they could see an empty zonelist and fail the allocation
> or hit the OOM killer in the worst case.
> 
> We can do much better, though. We can store the node ordering into an
> already existing node_order array and then give this array to
> build_zonelists_in_node_order and do the whole initialization at once.
> zonelists consumers still might see halfway initialized state but that
> should be much more tolerateable because the list will not be empty and
> they would either see some zone twice or skip over some zone(s) in the
> worst case which shouldn't lead to immediate failures.
> 
> This patch alone doesn't introduce any functional change yet, though, it
> is merely a preparatory work for later changes.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

I've collected the fold-ups from this thread and looked at the result as
single patch. Sems OK, just two things:
- please rename variable "i" in build_zonelists() to e.g. "nr_nodes"
- the !CONFIG_NUMA variant of build_zonelists() won't build, because it
doesn't declare nr_zones variable

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
