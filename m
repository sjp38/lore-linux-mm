Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0348E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:05:07 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r25-v6so766760edc.7
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 05:05:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j13-v6si886493edp.51.2018.09.12.05.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 05:05:05 -0700 (PDT)
Date: Wed, 12 Sep 2018 14:05:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180912120504.GE10951@dhcp22.suse.cz>
References: <20180907130550.11885-1-mhocko@kernel.org>
 <alpine.DEB.2.21.1809101253080.177111@chino.kir.corp.google.com>
 <20180911115613.GR10951@dhcp22.suse.cz>
 <alpine.DEB.2.21.1809111319060.189563@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1809111319060.189563@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stefan Priebe <s.priebe@profihost.ag>

On Tue 11-09-18 13:30:20, David Rientjes wrote:
> On Tue, 11 Sep 2018, Michal Hocko wrote:
[...]
> > hugepage specific MPOL flags sounds like yet another step into even more
> > cluttered API and semantic, I am afraid. Why should this be any
> > different from regular page allocations? You are getting off-node memory
> > once your local node is full. You have to use an explicit binding to
> > disallow that. THP should be similar in that regards. Once you have said
> > that you _really_ want THP then you are closer to what we do for regular
> > pages IMHO.
> > 
> 
> Saying that we really want THP isn't an all-or-nothing decision.  We 
> certainly want to try hard to fault hugepages locally especially at task 
> startup when remapping our .text segment to thp, and MADV_HUGEPAGE works 
> very well for that.  Remote hugepages would be a regression that we now 
> have no way to avoid because the kernel doesn't provide for it, if we were 
> to remove __GFP_THISNODE that this patch introduces.

Why cannot you use mempolicy to bind to local nodes if you really care
about the locality?

> On Broadwell, for example, we find 7% slower access to remote hugepages 
> than local native pages.  On Naples, that becomes worse: 14% slower access 
> latency for intrasocket hugepages compared to local native pages and 39% 
> slower for intersocket.

So, again, how does this compare to regular 4k pages? You are going to
pay for the same remote access as well.

>From what you have said so far it sounds like you would like to have
something like the zone/node reclaim mode fine grained for a specific
mapping. If we really want to support something like that then it should
be a generic policy rather than THP specific thing IMHO.

As I've said it is hard to come up with a solution that would satisfy
everybody but considering that the existing reports are seeing this a
regression and cosindering their NUMA requirements are not so strict as
yours I would tend to think that stronger NUMA requirements should be
expressed explicitly rather than implicit effect of a madvise flag. We
do have APIs for that.
-- 
Michal Hocko
SUSE Labs
