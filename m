Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 8D3086B015E
	for <linux-mm@kvack.org>; Wed,  8 May 2013 14:41:59 -0400 (EDT)
Date: Wed, 8 May 2013 18:41:58 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 09/22] mm: page allocator: Allocate/free order-0 pages
 from a per-zone magazine
In-Reply-To: <1368028987-8369-10-git-send-email-mgorman@suse.de>
Message-ID: <0000013e85732d03-05e35c8e-205e-4242-98f5-2ae7bda64c5c-000000@email.amazonses.com>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de> <1368028987-8369-10-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, LKML <linux-kernel@vger.kernel.org>

On Wed, 8 May 2013, Mel Gorman wrote:

> 1. IRQs do not have to be disabled to access the lists reducing IRQs
>    disabled times.

The per cpu structure access also would not need to disable irq if the
fast path would be using this_cpu ops.

> 2. As the list is protected by a spinlock, it is not necessary to
>    send IPI to drain the list. As the lists are accessible by multiple CPUs,
>    it is easier to tune.

The lists are a problem since traversing list heads creates a lot of
pressure on the processor and TLB caches. Could we either move to an array
of pointers to page structs (like in SLAB) or to a linked list that is
constrained within physical boundaries like within a PMD? (comparable
to the SLUB approach)?

> > 3. The magazine_lock is potentially hot but it can be split to have
>    one lock per CPU socket to reduce contention. Draining the lists
>    in this case would acquire multiple locks be acquired.

IMHO the use of per cpu RMV operations would be lower latency than the use
of spinlocks. There is no "lock" prefix overhead with those. Page
allocation is a frequent operation that I would think needs to be as fast
as possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
