Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0BB6B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 11:55:13 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 31so9801257wrr.2
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 08:55:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t24si2996009edb.353.2018.04.03.08.55.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 08:55:11 -0700 (PDT)
Date: Tue, 3 Apr 2018 17:55:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg, thp: do not invoke oom killer on thp charges
Message-ID: <20180403155509.GD5501@dhcp22.suse.cz>
References: <20180321205928.22240-1-mhocko@kernel.org>
 <20180403145853.GB21411@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180403145853.GB21411@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 03-04-18 10:58:53, Johannes Weiner wrote:
> On Wed, Mar 21, 2018 at 09:59:28PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > David has noticed that THP memcg charge can trigger the oom killer
> > since 2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and
> > madvised allocations"). We have used an explicit __GFP_NORETRY
> > previously which ruled the OOM killer automagically.
> > 
> > Memcg charge path should be semantically compliant with the allocation
> > path and that means that if we do not trigger the OOM killer for costly
> > orders which should do the same in the memcg charge path as well.
> > Otherwise we are forcing callers to distinguish the two and use
> > different gfp masks which is both non-intuitive and bug prone. Not to
> > mention the maintenance burden.
> > 
> > Teach mem_cgroup_oom to bail out on costly order requests to fix the THP
> > issue as well as any other costly OOM eligible allocations to be added
> > in future.
> > 
> > Fixes: 2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and madvised allocations")
> > Reported-by: David Rientjes <rientjes@google.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> I also prefer this fix over having separate OOM behaviors (which is
> user-visible, and not just about technical ability to satisfy the
> allocation) between the allocator and memcg.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

I will repost the patch with the currently merged THP specific handling
reverted (see below). While 9d3c3354bb85 might have been an appropriate
quick fix, we shouldn't keep it longterm for 4.17+ IMHO.

Does you ack apply to that patch as well?
---
