Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B44438308D
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 05:40:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so11780501wml.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 02:40:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kr8si37072226wjc.226.2016.08.30.02.40.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Aug 2016 02:40:08 -0700 (PDT)
Date: Tue, 30 Aug 2016 10:39:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: what is the purpose of SLAB and SLUB (was: Re: [PATCH v3]
 mm/slab: Improve performance of gathering slabinfo) stats
Message-ID: <20160830093955.GV2693@suse.de>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
 <20160818115218.GJ30162@dhcp22.suse.cz>
 <20160823021303.GB17039@js1304-P5Q-DELUXE>
 <20160823153807.GN23577@dhcp22.suse.cz>
 <20160824082057.GT2693@suse.de>
 <alpine.DEB.2.20.1608242240460.1837@east.gentwo.org>
 <20160825100707.GU2693@suse.de>
 <alpine.DEB.2.20.1608251451070.10766@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1608251451070.10766@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>

On Thu, Aug 25, 2016 at 02:55:43PM -0500, Christoph Lameter wrote:
> On Thu, 25 Aug 2016, Mel Gorman wrote:
> 
> > Flipping the lid aside, there will always be a need for fast management
> > of 4K pages. The primary use case is networking that sometimes uses
> > high-order pages to avoid allocator overhead and amortise DMA setup.
> > Userspace-mapped pages will always be 4K although fault-around may benefit
> > from bulk allocating the pages. That is relatively low hanging fruit that
> > would take a few weeks given a free schedule.
> 
> Userspace mapped pages can be hugepages as well as giant pages and that
> has been there for a long time. Intermediate sizes would be useful too in
> order to avoid having to keep lists of 4k pages around and continually
> scan them.
> 

Userspace pages cannot always be mapped as huge or giant. mprotect on a
4K boundary is an obvious example.

> > Dirty tracking of pages on a 4K boundary will always be required to avoid IO
> > multiplier effects that cannot be side-stepped by increasing the fundamental
> > unit of allocation.
> 
> Huge pages cannot be dirtied?

I didn't say that, I said they are required to avoid IO multiplier
effects. If a file is mapped as 2M or 1G then even a 1 byte write requires
2M or 1G of IO to writeback.

> This is an issue of hardware support. On
> x867 you only have one size. I am pretty such that even intel would
> support other sizes if needed. The case has been repeatedly made that 64k
> pages f.e. would be useful to have on x86.
> 

64K pages are not a universal win even on the arches that do support them.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
