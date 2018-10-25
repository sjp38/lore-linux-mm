Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56A7A6B02B1
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 12:45:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h25-v6so4239253eds.21
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 09:45:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2-v6si626426ejk.23.2018.10.25.09.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 09:45:25 -0700 (PDT)
Date: Thu, 25 Oct 2018 18:45:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, thp: consolidate THP gfp handling into
 alloc_hugepage_direct_gfpmask
Message-ID: <20181025164522.GU18839@dhcp22.suse.cz>
References: <20180926133039.y7o5x4nafovxzh2s@kshutemo-mobl1>
 <20180926141708.GX6278@dhcp22.suse.cz>
 <20180926142227.GZ6278@dhcp22.suse.cz>
 <20181018191147.33e8d5e1ebd785c06aab7b30@linux-foundation.org>
 <20181019080657.GJ18839@dhcp22.suse.cz>
 <583b20e5-4925-e175-1533-5c2d2bab9192@suse.cz>
 <20181024161754.0d174e7c22113f4f8aad1940@linux-foundation.org>
 <983e0c59-99ef-796c-bfc4-00e67782d1f1@suse.cz>
 <20181025161410.GT18839@dhcp22.suse.cz>
 <E0A009A6-FF31-459E-B223-6743C395F659@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E0A009A6-FF31-459E-B223-6743C395F659@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 25-10-18 09:18:05, Andrew Morton wrote:
> 
> 
> On October 25, 2018 9:14:10 AM PDT, Michal Hocko <mhocko@kernel.org> wrote:
> 
> >Andrew. Do you want me to repost the patch or you plan to update the
> >changelog yourself?
> 
> Please send a replacement changelog and I'll paste it in?

THP allocation mode is quite complex and it depends on the defrag
mode. This complexity is hidden in alloc_hugepage_direct_gfpmask from a
large part currently. The NUMA special casing (namely __GFP_THISNODE) is
however independent and placed in alloc_pages_vma currently. This both
adds an unnecessary branch to all vma based page allocation requests and
it makes the code more complex unnecessarily as well. Not to mention
that e.g. shmem THP used to do the node reclaiming unconditionally
regardless of the defrag mode until recently. This was not only
unexpected behavior but it was also hardly a good default behavior and I
strongly suspect it was just a side effect of the code sharing more than
a deliberate decision which suggests that such a layering is wrong.

Get rid of the thp special casing from alloc_pages_vma and move the logic
to alloc_hugepage_direct_gfpmask. __GFP_THISNODE is applied to
the resulting gfp mask only when the direct reclaim is not requested and
when there is no explicit numa binding to preserve the current logic.

Please note that there's also a slight difference wrt MPOL_BIND now. The
previous code would avoid using __GFP_THISNODE if the local node was
outside of policy_nodemask(). After this patch __GFP_THISNODE is avoided
for all MPOL_BIND policies. So there's a difference that if local
node is actually allowed by the bind policy's nodemask, previously
__GFP_THISNODE would be added, but now it won't be. From the behavior
POV this is still correct because the policy nodemask is used.

-- 
Michal Hocko
SUSE Labs
