Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A98656B20F6
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 18:05:08 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y130-v6so19389363qka.1
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 15:05:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h123-v6si5623995qkd.111.2018.08.21.15.05.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 15:05:07 -0700 (PDT)
Date: Tue, 21 Aug 2018 18:05:04 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/2] fix for "pathological THP behavior"
Message-ID: <20180821220504.GH13047@redhat.com>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820115818.mmeayjkplux2z6im@kshutemo-mobl1>
 <20180820151905.GB13047@redhat.com>
 <6120e1b6-b4d2-96cb-2555-d8fab65c23c8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6120e1b6-b4d2-96cb-2555-d8fab65c23c8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>

On Tue, Aug 21, 2018 at 05:30:11PM +0200, Vlastimil Babka wrote:
> If it's "not possible to compact" then the expected outcome of this is
> to fail?

It'll just call __alloc_pages_direct_compact once and fail if that
fails.

> You could do that without calling watermark checking explicitly, but
> it's rather complicated:
> 
> 1. try alocating with __GFP_THISNODE and ~GFP_DIRECT_RECLAIM
> 2. if that fails, try PAGE_SIZE with same flags
> 3. if that fails, try THP size without __GFP_THISNODE
> 4. PAGE_SIZE without __GFP_THISNODE

It's not complicated, it's slow, why to call 4 times into the
allocator, just to skip 1 watermark check?

> Yeah, not possible in current alloc_pages_vma() which should return the
> requested order. But the advantage is that it's not prone to races
> between watermark checking and actual attempt.

Watermark checking is always racy, zone_watermark_fast doesn't take
any lock before invoking rmqueue.

The racy in this case is the least issue because it doesn't need to be
perfect: if once in a while a THP is allocated from a remote node
despite there was a bit more of PAGE_SIZEd memory free than expected
in the local node it wouldn't be an issue. If it's wrong in the other
way around it'll just behave not-optimally (like today) once in a while.

> Frankly, I would rather go with this option and assume that if someone
> explicitly wants THP's, they don't care about NUMA locality that much.

I'm fine either ways, either way will work, large NUMA will prefer
__GFP_COMPACT_ONLY option 1), small NUMA will likely prefer option
2) and making this configurable at runtime with a different default is
possible too later but then I'm not sure it's worth it.

The main benefit of 1) really is to cause the least possible
interference to NUMA balancing (and the further optimization possible
with the watermark check would not cause interference either).

> (Note: I hate __GFP_THISNODE, it's an endless source of issues.)
> Trying to be clever about "is there still PAGE_SIZEd free memory in the
> local node" is imperfect anyway. If there isn't, is it because there's
> clean page cache that we can easily reclaim (so it would be worth
> staying local) or is it really exhausted? Watermark check won't tell...

I'm not sure if it's worth reclaiming cache to stay local, I mean it
totally depends on the app running, reclaim cache to stay local is
even harder to tell if it's worth it. This is why especially on small
NUMA option 2) that removes __GFP_THISNODE is likely to perform best.

However the tradeoff about clean cache reclaiming or not combined if
to do or not the watermark check on the PAGE_SIZEd free memory, is all
about the MADV_HUGEPAGE case only.

The default case (not even calling compaction in the page fault) would
definitely benefit from the (imperfect racy) heuristic "is there still
PAGE_SIZEd free memory in the local node" and that remains true even
if we go with option 2) to solve the bug (option 2 only changes the
behavior of MADV_HUGEPAGE, not the default).

The imperfect watermark check it's net gain for the default case
without __GFP_DIRECT_RECLAIM set, because currently the code has zero
chance to get THP even if already free and available in other nodes
and it only tries to get them from the local node. It costs a
watermark fast check only to get THP from all nodes if already
available (or if made available from kswapd). Costs 1 cacheline just
for the pcp test, but then we're in the page allocator anyway so all
cachelines involving watermarks may be activated regardless.

Thanks,
Andrea
