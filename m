Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 51FD482F6B
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 00:02:53 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id f6so7217201ith.3
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 21:02:53 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [69.252.207.44])
        by mx.google.com with ESMTPS id x83si15501720ioi.180.2016.08.24.21.02.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 21:02:46 -0700 (PDT)
Date: Wed, 24 Aug 2016 23:01:43 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: what is the purpose of SLAB and SLUB (was: Re: [PATCH v3] mm/slab:
 Improve performance of gathering slabinfo) stats
In-Reply-To: <20160824082057.GT2693@suse.de>
Message-ID: <alpine.DEB.2.20.1608242240460.1837@east.gentwo.org>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com> <20160818115218.GJ30162@dhcp22.suse.cz> <20160823021303.GB17039@js1304-P5Q-DELUXE> <20160823153807.GN23577@dhcp22.suse.cz> <20160824082057.GT2693@suse.de>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>

On Wed, 24 Aug 2016, Mel Gorman wrote:
> If/when I get back to the page allocator, the priority would be a bulk
> API for faster allocs of batches of order-0 pages instead of allocating
> a large page and splitting.
>

OMG. Do we really want to continue this? There are billions of Linux
devices out there that require a reboot at least once a week. This is now
standard with certain Android phones. In our company we reboot all
machines every week because fragmentation degrades performance
significantly. We need to finally face up to it and deal with the issue
instead of continuing to produce more half ass-ed solutions.

Managing memory in 4K chunks is not reasonable if you have
machines with terabytes of memory and thus billions of individual page
structs to manage. I/O devices are throttling because they cannot manage
so much meta data and we get grotesque devices.

The kernel needs an effective way to handle large contiguous memory. It
needs the ability to do effective defragmentation for that. And the way
forward has been clear also for awhile. All objects must be either
movable or be reclaimable so that things can be moved to allow contiguity
to be restored.


We have support for that for the page cache and interestingly enough for
CMA now. So this is gradually developing because it is necessary. We need
to go with that and provide a full fledged implementation in the kernel
that allows effective handling of large objects in the page allocator and
we need general logic in the kernel for effective handling of large
sized chunks of memory.

Lets stop churning tiny 4k segments in the world where even our cell
phones have capacities measured in Gigabytes which certainly then already
means millions of 4k objects whose management one by one is a drag on
performance and makes operating system coding extremely complex. The core
of Linux must support that for the future in which we will see even larger
memory capacities.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
