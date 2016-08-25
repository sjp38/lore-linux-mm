Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6A2783093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 06:07:21 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k135so28677401lfb.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:07:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fg10si13004045wjb.215.2016.08.25.03.07.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Aug 2016 03:07:20 -0700 (PDT)
Date: Thu, 25 Aug 2016 11:07:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: what is the purpose of SLAB and SLUB (was: Re: [PATCH v3]
 mm/slab: Improve performance of gathering slabinfo) stats
Message-ID: <20160825100707.GU2693@suse.de>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
 <20160818115218.GJ30162@dhcp22.suse.cz>
 <20160823021303.GB17039@js1304-P5Q-DELUXE>
 <20160823153807.GN23577@dhcp22.suse.cz>
 <20160824082057.GT2693@suse.de>
 <alpine.DEB.2.20.1608242240460.1837@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1608242240460.1837@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>

On Wed, Aug 24, 2016 at 11:01:43PM -0500, Christoph Lameter wrote:
> On Wed, 24 Aug 2016, Mel Gorman wrote:
> > If/when I get back to the page allocator, the priority would be a bulk
> > API for faster allocs of batches of order-0 pages instead of allocating
> > a large page and splitting.
> >
> 
> OMG. Do we really want to continue this? There are billions of Linux
> devices out there that require a reboot at least once a week. This is now
> standard with certain Android phones. In our company we reboot all
> machines every week because fragmentation degrades performance
> significantly. We need to finally face up to it and deal with the issue
> instead of continuing to produce more half ass-ed solutions.
> 

Flipping the lid aside, there will always be a need for fast management
of 4K pages. The primary use case is networking that sometimes uses
high-order pages to avoid allocator overhead and amortise DMA setup.
Userspace-mapped pages will always be 4K although fault-around may benefit
from bulk allocating the pages. That is relatively low hanging fruit that
would take a few weeks given a free schedule.

Dirty tracking of pages on a 4K boundary will always be required to avoid IO
multiplier effects that cannot be side-stepped by increasing the fundamental
unit of allocation.

Batching of tree_lock during reclaim for large files and swapping is also
relatively low hanging fruit that also is doable in a week or two.

A high-order per-cpu cache for SLUB to reduce zone->lock contention is
also relatively low hanging fruit with the caveat it makes per_cpu_pages
larger than a cache line.

If you want to rework the VM to use a larger fundamental unit, track
sub-units where required and deal with the internal fragmentation issues
then by all means go ahead and deal with it.
 
-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
