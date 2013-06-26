Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 0DBAF6B0034
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 16:48:24 -0400 (EDT)
Date: Wed, 26 Jun 2013 22:48:16 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/7] mm: compaction: don't depend on kswapd to invoke
 reset_isolation_suitable
Message-ID: <20130626204816.GD28030@redhat.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-4-git-send-email-aarcange@redhat.com>
 <20130606091148.GE1936@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130606091148.GE1936@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Thu, Jun 06, 2013 at 10:11:48AM +0100, Mel Gorman wrote:
> That was part of a series that addressed a problem where processes
> stalled for prolonged periods of time in compaction. I see your point

Yes.

> and I do not have a better suggestion at this time but I'll keep an eye
> out for regressions in that area.

That's my exact concern too, and there's not much we can do about
it. But not calling compaction reliably, simply guarantees spurious
failures where it would be trivial to allocate THP and we just don't
even try to compact memory.

Of course we have khugepaged that fixes it up for THP.

But in the NUMA case (without automatic NUMA balancing enabled), the
transparent hugepage could be allocated in the wrong node and it will
stay there forever.

In general it should be more optimal not to require khugepaged or
automatic NUMA balancing to fix up allocator errors after the fact,
especially because they both won't help with short lived
allocations. And especially the NUMA effect could be measurable for
short lived allocations that may go in the wrong node (like while
building with gcc).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
