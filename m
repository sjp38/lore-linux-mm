Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE2A38E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:21:32 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x85-v6so1188798pfe.13
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 07:21:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e22-v6si1110323pfb.185.2018.09.12.07.21.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 07:21:31 -0700 (PDT)
Date: Wed, 12 Sep 2018 16:21:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180912142126.GM10951@dhcp22.suse.cz>
References: <20180907130550.11885-1-mhocko@kernel.org>
 <alpine.DEB.2.21.1809101253080.177111@chino.kir.corp.google.com>
 <20180911115613.GR10951@dhcp22.suse.cz>
 <20180912135417.GA15194@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912135417.GA15194@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stefan Priebe <s.priebe@profihost.ag>

On Wed 12-09-18 09:54:17, Andrea Arcangeli wrote:
> Hello,
> 
> On Tue, Sep 11, 2018 at 01:56:13PM +0200, Michal Hocko wrote:
> > Well, it seems that expectations differ for users. It seems that kvm
> > users do not really agree with your interpretation.
> 
> Like David also mentioned here:
> 
> lkml.kernel.org/r/alpine.DEB.2.21.1808211021110.258924@chino.kir.corp.google.com
> 
> depends on the hardware what is a win, so there's no one size fits
> all.
> 
> For two sockets providing remote THP to KVM is likely a win, but
> changing the defaults depending on boot-time NUMA topology makes
> things less deterministic and it's also impossible to define an exact
> break even point.
> 
> > I do realize that this is a gray zone because nobody bothered to define
> > the semantic since the MADV_HUGEPAGE has been introduced (a826e422420b4
> > is exceptionaly short of information). So we are left with more or less
> > undefined behavior and define it properly now. As we can see this might
> > regress in some workloads but I strongly suspect that an explicit
> > binding sounds more logical approach than a thp specific mpol mode. If
> > anything this should be a more generic memory policy basically saying
> > that a zone/node reclaim mode should be enabled for the particular
> > allocation.
> 
> MADV_HUGEPAGE means the allocation is long lived, so the cost of
> compaction is worth it in direct reclaim. Not much else. That is not
> the problem.

It seems there is no general agreement here. My understanding is that
this means that the user really prefers THP for whatever reasons.

> The problem is that even if you ignore the breakage and regression to
> real life workloads, what is happening right now obviously would
> require root privilege but MADV_HUEGPAGE requires no root privilege.

I do not follow.

> Swapping heavy because MADV_HUGEPAGE when there are gigabytes free on
> other nodes and not even 4k would be swapped-out with THP turned off
> in sysfs, is simply not possibly what MADV_HUGEPAGE could have been
> about, and it's a kernel regression that never existed until that
> commit that added __GFP_THISNODE to the default THP heuristic in
> mempolicy.

agreed

> I think we should defer the problem of what is better between 4k NUMA
> local or remote THP by default for later, I provided two options
> myself because it didn't matter so much which option we picked in the
> short term, as long as the bug was fixed.
> 
> I wasn't particularly happy about your patch because it still swaps
> with certain defrag settings which is still allowing things that
> shouldn't happen without some kind of privileged capability.

Well, I am not really sure about defrag=always. I would rather care
about the default behavior to plug the regression first. And think about
`always' mode on top. Or is this a no-go from your POV?

-- 
Michal Hocko
SUSE Labs
