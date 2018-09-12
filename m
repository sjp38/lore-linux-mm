Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26B2F8E0003
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:40:34 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 90-v6so1505474pla.18
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:40:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v9-v6sor317171pgh.329.2018.09.12.13.40.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 13:40:32 -0700 (PDT)
Date: Wed, 12 Sep 2018 13:40:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
In-Reply-To: <20180912120504.GE10951@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1809121336310.47609@chino.kir.corp.google.com>
References: <20180907130550.11885-1-mhocko@kernel.org> <alpine.DEB.2.21.1809101253080.177111@chino.kir.corp.google.com> <20180911115613.GR10951@dhcp22.suse.cz> <alpine.DEB.2.21.1809111319060.189563@chino.kir.corp.google.com>
 <20180912120504.GE10951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stefan Priebe <s.priebe@profihost.ag>

On Wed, 12 Sep 2018, Michal Hocko wrote:

> > Saying that we really want THP isn't an all-or-nothing decision.  We 
> > certainly want to try hard to fault hugepages locally especially at task 
> > startup when remapping our .text segment to thp, and MADV_HUGEPAGE works 
> > very well for that.  Remote hugepages would be a regression that we now 
> > have no way to avoid because the kernel doesn't provide for it, if we were 
> > to remove __GFP_THISNODE that this patch introduces.
> 
> Why cannot you use mempolicy to bind to local nodes if you really care
> about the locality?
> 

Because we do not want to oom kill, we want to fallback first to local 
native pages and then to remote native pages.  That's the order of least 
to greatest latency, we do not want to work hard to allocate a remote 
hugepage when a local native page is faster.  This seems pretty straight 
forward.

> From what you have said so far it sounds like you would like to have
> something like the zone/node reclaim mode fine grained for a specific
> mapping. If we really want to support something like that then it should
> be a generic policy rather than THP specific thing IMHO.
> 
> As I've said it is hard to come up with a solution that would satisfy
> everybody but considering that the existing reports are seeing this a
> regression and cosindering their NUMA requirements are not so strict as
> yours I would tend to think that stronger NUMA requirements should be
> expressed explicitly rather than implicit effect of a madvise flag. We
> do have APIs for that.

Every process on every platform we have would need to define this explicit 
mempolicy for users of libraries that remap text segments because changing 
the allocation behavior of thp out from under them would cause very 
noticeable performance regressions.  I don't know of any platform where 
remote hugepages is preferred over local native pages.  If they exist, it 
sounds resaonable to introduce a stronger variant of MADV_HUGEPAGE that 
defines exactly what you want rather than causing it to become a dumping 
ground and userspace regressions.
