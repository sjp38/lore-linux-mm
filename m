Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 162EE6B0003
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 04:07:04 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y73-v6so17782238pfi.16
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 01:07:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j65-v6si22117874pge.589.2018.10.19.01.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 01:07:02 -0700 (PDT)
Date: Fri, 19 Oct 2018 10:06:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, thp: consolidate THP gfp handling into
 alloc_hugepage_direct_gfpmask
Message-ID: <20181019080657.GJ18839@dhcp22.suse.cz>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-3-mhocko@kernel.org>
 <20180926133039.y7o5x4nafovxzh2s@kshutemo-mobl1>
 <20180926141708.GX6278@dhcp22.suse.cz>
 <20180926142227.GZ6278@dhcp22.suse.cz>
 <20181018191147.33e8d5e1ebd785c06aab7b30@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018191147.33e8d5e1ebd785c06aab7b30@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 18-10-18 19:11:47, Andrew Morton wrote:
> On Wed, 26 Sep 2018 16:22:27 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > MPOL_PREFERRED is handled by policy_node() before we call __alloc_pages_nodemask.
> > > __GFP_THISNODE is applied only when we are not using
> > > __GFP_DIRECT_RECLAIM which is handled in alloc_hugepage_direct_gfpmask
> > > now.
> > > Lastly MPOL_BIND wasn't handled explicitly but in the end the removed
> > > late check would remove __GFP_THISNODE for it as well. So in the end we
> > > are doing the same thing unless I miss something
> > 
> > Forgot to add. One notable exception would be that the previous code
> > would allow to hit
> > 	WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
> > in policy_node if the requested node (e.g. cpu local one) was outside of
> > the mbind nodemask. This is not possible now. We haven't heard about any
> > such warning yet so it is unlikely that it happens though.
> 
> Perhaps a changelog addition is needed to cover the above?

: THP allocation mode is quite complex and it depends on the defrag
: mode. This complexity is hidden in alloc_hugepage_direct_gfpmask from a
: large part currently. The NUMA special casing (namely __GFP_THISNODE) is
: however independent and placed in alloc_pages_vma currently. This both
: adds an unnecessary branch to all vma based page allocation requests and
: it makes the code more complex unnecessarily as well. Not to mention
: that e.g. shmem THP used to do the node reclaiming unconditionally
: regardless of the defrag mode until recently. This was not only
: unexpected behavior but it was also hardly a good default behavior and I
: strongly suspect it was just a side effect of the code sharing more than
: a deliberate decision which suggests that such a layering is wrong.
: 
: Moreover the oriinal code allowed to trigger
: 	WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
: in policy_node if the requested node (e.g. cpu local one) was outside of
: the mbind nodemask. This is not possible now. We haven't heard about any
: such warning yet so it is unlikely that it happens but still a signal of
: a wrong code layering.
: 
: Get rid of the thp special casing from alloc_pages_vma and move the logic
: to alloc_hugepage_direct_gfpmask. __GFP_THISNODE is applied to
: the resulting gfp mask only when the direct reclaim is not requested and
: when there is no explicit numa binding to preserve the current logic.
: 
: This allows for removing alloc_hugepage_vma as well.

Better?
 
> I assume that David's mbind() concern has gone away.

Either I've misunderstood it or it was not really a real issue.
-- 
Michal Hocko
SUSE Labs
