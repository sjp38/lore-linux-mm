Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9120E83093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 15:55:45 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e63so5356328ith.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 12:55:45 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id e123si20000088iof.90.2016.08.25.12.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 12:55:44 -0700 (PDT)
Date: Thu, 25 Aug 2016 14:55:43 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: what is the purpose of SLAB and SLUB (was: Re: [PATCH v3] mm/slab:
 Improve performance of gathering slabinfo) stats
In-Reply-To: <20160825100707.GU2693@suse.de>
Message-ID: <alpine.DEB.2.20.1608251451070.10766@east.gentwo.org>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com> <20160818115218.GJ30162@dhcp22.suse.cz> <20160823021303.GB17039@js1304-P5Q-DELUXE> <20160823153807.GN23577@dhcp22.suse.cz> <20160824082057.GT2693@suse.de>
 <alpine.DEB.2.20.1608242240460.1837@east.gentwo.org> <20160825100707.GU2693@suse.de>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>

On Thu, 25 Aug 2016, Mel Gorman wrote:

> Flipping the lid aside, there will always be a need for fast management
> of 4K pages. The primary use case is networking that sometimes uses
> high-order pages to avoid allocator overhead and amortise DMA setup.
> Userspace-mapped pages will always be 4K although fault-around may benefit
> from bulk allocating the pages. That is relatively low hanging fruit that
> would take a few weeks given a free schedule.

Userspace mapped pages can be hugepages as well as giant pages and that
has been there for a long time. Intermediate sizes would be useful too in
order to avoid having to keep lists of 4k pages around and continually
scan them.

> Dirty tracking of pages on a 4K boundary will always be required to avoid IO
> multiplier effects that cannot be side-stepped by increasing the fundamental
> unit of allocation.

Huge pages cannot be dirtied? This is an issue of hardware support. On
x867 you only have one size. I am pretty such that even intel would
support other sizes if needed. The case has been repeatedly made that 64k
pages f.e. would be useful to have on x86.


> Batching of tree_lock during reclaim for large files and swapping is also
> relatively low hanging fruit that also is doable in a week or two.

Ok these are good incremental improvement but they do not address the main
issue going forward.

> A high-order per-cpu cache for SLUB to reduce zone->lock contention is
> also relatively low hanging fruit with the caveat it makes per_cpu_pages
> larger than a cache line.

Would be great to have.

> If you want to rework the VM to use a larger fundamental unit, track
> sub-units where required and deal with the internal fragmentation issues
> then by all means go ahead and deal with it.

Hmmm... The time problem is always there. Tried various approaches over
the last decade. Could be a massive project. We really would need a
larger group of developers to effectively do this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
