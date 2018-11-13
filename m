Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 639BA6B026B
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 08:34:49 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b88-v6so10378025pfj.4
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 05:34:49 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 92-v6si22107570pli.133.2018.11.13.05.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 05:34:48 -0800 (PST)
Date: Tue, 13 Nov 2018 14:34:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/slub: skip node in case there is no slab to acquire
Message-ID: <20181113133443.GQ15120@dhcp22.suse.cz>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
 <20181113131751.GC16182@dhcp22.suse.cz>
 <20181113132624.xjnvxhrt4jk7mt3m@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113132624.xjnvxhrt4jk7mt3m@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue 13-11-18 13:26:24, Wei Yang wrote:
> On Tue, Nov 13, 2018 at 02:17:51PM +0100, Michal Hocko wrote:
> >On Thu 08-11-18 09:12:04, Wei Yang wrote:
> >> for_each_zone_zonelist() iterates the zonelist one by one, which means
> >> it will iterate on zones on the same node. While get_partial_node()
> >> checks available slab on node base instead of zone.
> >> 
> >> This patch skip a node in case get_partial_node() fails to acquire slab
> >> on that node.
> >
> >If this is an optimization then it should be accompanied by some
> >numbers.
> 
> Let me try to get some test result.
> 
> Do you have some suggestion on the test suite? Is kernel build a proper
> test?

Make sure that the workload is hitting hard on this particular code path
that it matters. I am not aware of any such workload but others might
know better.

In any case, if you are up to optimize something then you should
evaluate what kind of workload might benefit from it. If there is no
workload then it is likely not worth bothering. Some changes might look
like obvious improvements but then they might add a maintenance burden
or they might be even wrong for other reasons. Recent patches you have
posted show both issues.

I would encourage you to look at a practical issues instead. Throwing
random patches by reading the code without having a larger picture is
usually not the best way to go.

[...]

> In get_page_from_freelist(), we use last_pgdat_dirty_limit to track the
> last node out of dirty limit. I am willing to borrow this idea in
> get_any_partial() to skip a node.
> 
> Well, let me do some tests to see whether this is visible.

See the above. Each and every change has its cost and patches make sense
only when both the future maintenance cost and the review cost are payed
off.
-- 
Michal Hocko
SUSE Labs
