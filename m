Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 2F41B6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 07:34:36 -0400 (EDT)
Date: Mon, 5 Aug 2013 13:34:23 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130805113423.GB6703@redhat.com>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
 <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
 <20130805103456.GB1039@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130805103456.GB1039@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 05, 2013 at 06:34:56PM +0800, Wanpeng Li wrote:
> Why round robin allocator don't consume ZONE_DMA?

I guess lowmem reserve reserves it all, 4GB/256(ratio)=16MB.

The only way to relax it would be 1) to account depending on memblock
types and allow only the movable ones to bypass the lowmem reserve and
prevent a change from movable type if lowmem reserve doesn't pass, 2)
use memory migration to move the movable pages from the lower zones to
the highest zone if reclaim fails if __GFP_DMA32 or __GFP_DMA is set,
or highmem is missing on 32bit kernels. The last point involving
memory migration would work similarly to compaction but it isn't black
and white, and it would cost CPU as well. The memory used by the
simple lowmem reserve mechanism is probably not significant enough to
warrant such an effort.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
