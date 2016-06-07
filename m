Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3DFA06B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 12:23:20 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h68so81595593lfh.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 09:23:20 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i143si26100288wmd.97.2016.06.07.09.23.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 09:23:18 -0700 (PDT)
Date: Tue, 7 Jun 2016 12:23:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 10/10] mm: balance LRU lists based on relative thrashing
Message-ID: <20160607162311.GG9978@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-11-hannes@cmpxchg.org>
 <1465257023.22178.205.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1465257023.22178.205.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, kernel-team@fb.com

Hi Tim,

On Mon, Jun 06, 2016 at 04:50:23PM -0700, Tim Chen wrote:
> On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> > To tell inactive from active refaults, a page flag is introduced that
> > marks pages that have been on the active list in their lifetime. This
> > flag is remembered in the shadow page entry on reclaim, and restored
> > when the page refaults. It is also set on anonymous pages during
> > swapin. When a page with that flag set is added to the LRU, the LRU
> > balance is adjusted for the IO cost of reclaiming the thrashing list.
> 
> Johannes,
> 
> It seems like you are saying that the shadow entry is also present
> for anonymous pages that are swapped out.  But once a page is swapped
> out, its entry is removed from the radix tree and we won't be able
> to store the shadow page entry as for file mapped page 
> in __remove_mapping.  Or are you thinking of modifying
> the current code to keep the radix tree entry? I may be missing something
> so will appreciate if you can clarify.

Sorry if this was ambiguously phrased.

You are correct, there are no shadow entries for anonymous evictions,
only page cache evictions. All swap-ins are treated as "eligible"
refaults and push back against cache, whereas cache only pushes
against anon if the cache workingset is determined to fit into memory.

That implies a fixed hierarchy where the VM always tries to fit the
anonymous workingset into memory first and the page cache second. If
the anonymous set is bigger than memory, the algorithm won't stop
counting IO cost from anonymous refaults and pressuring page cache.

[ Although you can set the effective cost of these refaults to 0
  (swappiness = 200) and reduce effective cache to a minimum -
  possibly to a level where LRU rotations consume most of it.
  But yeah. ]

So the current code works well when we assume that cache workingsets
might exceed memory, but anonymous workingsets don't.

For SSDs and non-DIMM pmem devices this assumption is fine, because
nobody wants half their frequent anonymous memory accesses to be major
faults. Anonymous workingsets will continue to target RAM size there.

Secondary memory types, which userspace can continue to map directly
after "swap out", are a different story. That might need workingset
estimation for anonymous pages. But it would have to build on top of
this series here. These patches are about eliminating or mitigating IO
by swapping idle or colder anon pages when the cache is thrashing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
