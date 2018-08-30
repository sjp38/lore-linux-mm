Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7576B5007
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 03:00:26 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r2-v6so4582702pgp.3
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 00:00:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k14-v6si5965631pfd.0.2018.08.30.00.00.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 00:00:25 -0700 (PDT)
Date: Thu, 30 Aug 2018 09:00:21 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180830070021.GB2656@dhcp22.suse.cz>
References: <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On Wed 29-08-18 18:54:23, Zi Yan wrote:
[...]
> I tested it against Linusa??s tree with a??memhog -r3 130ga?? in a two-socket machine with 128GB memory on
> each node and got the results below. I expect this test should fill one node, then fall back to the other.
> 
> 1. madvise(MADV_HUGEPAGE) + defrag = {always, madvise, defer+madvise}:
> no swap, THPs are allocated in the fallback node.
> 2. madvise(MADV_HUGEPAGE) + defrag = defer: pages got swapped to the
> disk instead of being allocated in the fallback node.
> 3. no madvise, THP is on by default + defrag = {always, defer,
> defer+madvise}: pages got swapped to the disk instead of being
> allocated in the fallback node.
> 4. no madvise, THP is on by default + defrag = madvise: no swap, base
> pages are allocated in the fallback node.
> 
> The result 2 and 3 seems unexpected, since pages should be allocated in the fallback node.
> 
> The reason, as Andrea mentioned in his email, is that the combination
> of __THIS_NODE and __GFP_DIRECT_RECLAIM (plus __GFP_KSWAPD_RECLAIM
> from this experiment).

But we do not set __GFP_THISNODE along with __GFP_DIRECT_RECLAIM AFAICS.
We do for __GFP_KSWAPD_RECLAIM though and I guess that it is expected to
see kswapd do the reclaim to balance the node. If the node is full of
anonymous pages then there is no other way than swap out.

> __THIS_NODE uses ZONELIST_NOFALLBACK, which
> removes the fallback possibility and __GFP_*_RECLAIM triggers page
> reclaim in the first page allocation node when fallback nodes are
> removed by ZONELIST_NOFALLBACK.

Yes but the point is that the allocations which use __GFP_THISNODE are
optimistic so they shouldn't fallback to remote NUMA nodes.

> IMHO, __THIS_NODE should not be used for user memory allocation at
> all, since it fights against most of memory policies.  But kernel
> memory allocation would need it as a kernel MPOL_BIND memory policy.

__GFP_THISNODE is indeed an ugliness. I would really love to get rid of
it here. But the problem is that optimistic THP allocations should
prefer a local node because a remote node might easily offset the
advantage of the THP. I do not have a great idea how to achieve that
without __GFP_THISNODE though.
-- 
Michal Hocko
SUSE Labs
