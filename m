Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40E206B2529
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:52:56 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id d1-v6so1847740qth.21
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 08:52:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m18-v6si1936430qkk.222.2018.08.22.08.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 08:52:55 -0700 (PDT)
Date: Wed, 22 Aug 2018 11:52:50 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180822155250.GP13047@redhat.com>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz>
 <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822090214.GF29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Aug 22, 2018 at 11:02:14AM +0200, Michal Hocko wrote:
> I am not disputing the bug itself. How hard should defrag=allways really
> try is good question and I would say different people would have
> different ideas but a swapping storm sounds like genuinely unwanted
> behavior. I would expect that to be handled in the reclaim/compaction.
> GFP_TRANSHUGE doesn't have ___GFP_RETRY_MAYFAIL so it shouldn't really
> try too hard to reclaim.

Everything was ok as long as the THP allocation is not bind to the
local node with __GFP_THISNODE. Calling reclaim to free memory is part
of how compaction works if all free memory has been extinguished from
all nodes. At that point it's much more likely compaction fails not
because there's not at least 2m free but because of all memory is
fragmented. So it's true that MADV_HUGEPAGE may run better on not-NUMA
by not setting __GFP_COMPACT_ONLY though (i.e. like right now,
__GFP_THISNODE would be a noop there).

How hard defrag=always should try, I think it should at least call
compaction once, so at least in the case there's plenty of free memory
in the local node it'll have a chance. It sounds a sure win that way.

Calling compaction with __GFP_THISNODE will at least defrag all free
memory, it'll give MADV_HUGEPAGE a chance.

> I still have to digest the __GFP_THISNODE thing but I _think_ that the
> alloc_pages_vma code is just trying to be overly clever and
> __GFP_THISNODE is not a good fit for it. 

My option 2 did just that, it removed __GFP_THISNODE but only for
MADV_HUGEPAGE and in general whenever reclaim was activated by
__GFP_DIRECT_RECLAIM. That is also signal that the user really wants
THP so then it's less bad to prefer THP over NUMA locality.

For the default which is tuned for short lived allocation, preferring
local memory is most certainly better win for short lived allocation
where THP can't help much, this is why I didn't remove __GFP_THISNODE
from the default defrag policy.

Thanks,
Andrea
