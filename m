Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C927B6B013C
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 15:33:11 -0400 (EDT)
Date: Fri, 29 Oct 2010 14:33:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
 threshold when memory is low
In-Reply-To: <20101029112541.8ab906bb.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1010291425360.26312@router.home>
References: <1288278816-32667-1-git-send-email-mel@csn.ul.ie> <1288278816-32667-2-git-send-email-mel@csn.ul.ie> <20101028150433.fe4f2d77.akpm@linux-foundation.org> <alpine.DEB.2.00.1010290955510.20370@router.home>
 <20101029112541.8ab906bb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010, Andrew Morton wrote:

> > Doing that caused cache misses in the past and reduced the performance of
> > the ZVCs. This way the threshold is in the same cacheline as the
> > differentials.
>
> This sounds wrong.  As long as that threshold isn't stored in a
> cacheline which other CPUs are modifying, all CPUs should be able to
> happily cache it.  Maybe it needed a bit of padding inside the zone
> struct.

High speed cpu caches are a very scarce resource. The differentials are
not in the zone struct. Tried to put it onto a single cacheline. Even that
did not do the trick for the large configurations.

The same optimizations are done in the slab allocators by the way.

Use of the percpu_counter() would at least quadruple the cache footprint
in use for the counters. percpu_counters() is using s32 and not s8.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
