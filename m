Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 621CE6B026E
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 11:01:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 140so5512551wmv.12
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:01:50 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w127si4145588wmw.61.2016.10.25.08.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 08:01:49 -0700 (PDT)
Date: Tue, 25 Oct 2016 11:01:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: do not recurse in direct reclaim
Message-ID: <20161025150142.GA31081@cmpxchg.org>
References: <20161024203005.5547-1-hannes@cmpxchg.org>
 <20161025090747.GD31137@dhcp22.suse.cz>
 <20161025141050.GA13019@cmpxchg.org>
 <20161025144543.GL31137@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161025144543.GL31137@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Oct 25, 2016 at 04:45:44PM +0200, Michal Hocko wrote:
> On Tue 25-10-16 10:10:50, Johannes Weiner wrote:
> > Like other direct reclaimers, mark tasks in memcg reclaim PF_MEMALLOC
> > to avoid recursing into any other form of direct reclaim. Then let
> > recursive charges from PF_MEMALLOC contexts bypass the cgroup limit.
> 
> Should we mark this for stable (up to 4.5) which changed the out-out to
> opt-in?

Yes, good point.

Internally, we're pulling it into our 4.6 tree as well. The commit
that fixes the particular bug we encountered in btrfs is a9bb7e620efd
("memcg: only account kmem allocations marked as __GFP_ACCOUNT") in
4.5+, so you could argue that we don't need the backport in kernels
with this commit. And I'm not aware of other manifestations of this
problem. But the unbounded recursion hole is still there, technically,
so we might just want to put it into all stable kernels and be safe.

So either

Cc: <stable@vger.kernel.org>	# up to and including 4.5

or, and I'm leaning toward that, simply

Cc: <stable@vger.kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
