Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 742686B20D9
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 17:40:52 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 77-v6so10589808qkz.5
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 14:40:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 51-v6si4463212qtv.60.2018.08.21.14.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 14:40:51 -0700 (PDT)
Date: Tue, 21 Aug 2018 17:40:49 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180821214049.GG13047@redhat.com>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180821115057.GY29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Aug 21, 2018 at 01:50:57PM +0200, Michal Hocko wrote:
> So does reverting 5265047ac301 ("mm, thp: really limit transparent
> hugepage allocation to local node") help?

That won't revert clean, to be sure you'd need to bisect around it
which I haven't tried because I don't think there was doubt around it
(and only the part in mempolicy.c is relevant at it).

It's not so important to focus on that commit the code changed again
later, I'm focusing on the code as a whole.

It's not just that commit that is the problem here, the problem starts
in the previous commits that adds the NUMA locality logic, the
addition of __GFP_THISNODE is the icing on the cake that makes things
fall apart.

> I really detest a new gfp flag for one time semantic that is muddy as
> hell.

Well there's no way to fix this other than to prevent reclaim to run,
if you still want to give a chance to page faults to obtain THP under
MADV_HUGEPAGE in the page fault without waiting minutes or hours for
khugpaged to catch up with it.

> This is simply incomprehensible. How can anybody who is not deeply
> familiar with the allocator/reclaim internals know when to use it.

Nobody should use this in drivers, it's a __GFP flag.

Note:

	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {

#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)

Only THP is ever affected by the BUG so nothing else will ever need to
call __GFP_COMPACT_ONLY. It is a VM internal flag, I wish there was a
way to make the build fail if a driver would use it but there isn't
right now.

All other order 9 or 10 allocations from drivers won't call
alloc_hugepage_vma. Only mm/huge_memory.c ever calls that which is why
the regression only happens with MADV_HUGEPAGE (i.e. qemu is being
bitten badly on NUMA hosts).

> If this is really a regression then we should start by pinpointing the

You can check yourself, create a 2 node vnuma guest or pick any host
with more than one node. Set defrag=always and run "memhog -r11111111
18g" if host has 16g per node. Add some swap and notice the swap storm
while all ram is left free in the other node.

> real culprit and go from there. If this is really 5265047ac301 then just

In my view there's no single culprit, but it was easy to identify the
last drop that made the MADV_HUGEPAGE glass overflow, and it's that
commit that adds __GFP_THISNODE. The combination of the previous code
that prioritized NUMA over THP and then the MADV_HUGEPAGE logic that
still uses compaction (and in turn reclaim if compaction fails with
COMPACT_SKIPPED because there's no 4k page in the local node) just
falls apart with __GFP_THISNODE set as well on top of it and it
doesn't do the expected thing either without it (i.e. THP gets
priority over NUMA locality without such flag).

__GFP_THISNODE and the logic there, only works ok when
__GFP_DIRECT_RECLAIM is not set, i.e. MADV_HUGEPAGE not set.

We don't want to wait hours for khugepaged to catch up in qemu to get
THP. Compaction is certainly worth it to run if the userland
explicitly gives the hint to the kernel the allocations are long
lived.

> start by reverting it. I strongly suspect there is some mismatch in
> expectations here. What others consider acceptable seems to be a problem
> for others. I believe that was one of the reasons why we have changed
> the default THP direct compaction behavior, no?

This is not about the "default" though, I'm not changing the default
either, this is about MADV_HUGEPAGE behavior and when you change from
the defrag "default" value to "always" (which is equivalent than
having have all vmas set with MADV_HUGEPAGE).

QEMU is being optimal in setting MADV_HUGEPAGE, and rightfully so, but
it's getting punished badly because of this kernel bug.

Thanks,
Andrea
