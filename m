Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C888F9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 14:09:14 -0400 (EDT)
Date: Wed, 28 Sep 2011 11:09:09 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: RFC -- new zone type
Message-ID: <20110928180909.GA7007@labbmf-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: vgandhi@codeaurora.org

We need to create a large (~100M) contiguous physical memory region
which will only be needed occasionally. As this region will
use up 10-20% of all of the available memory, we do not want
to pre-reserve it at boot time. Instead, we want to create
this memory region "on the fly" when asked to by userspace,
and do it as quickly as possible, and return it to
system use when not needed.

AFAIK, this sort of operation is currently done using memory
compaction (as CMA does for instance).
Alternatively, this memory region (if it is in a fixed place)
could be created using "logical memory hotremove" and returned
to the system using "logical memory hotplug". In either case,
the contiguous physical memory would be created via migrating
pages from the "movable zone".

The problem with this approach is that the copying of up to 25000
pages may take considerable time (as well as finding destinations
for all of the pages if free memory is scarce -- this may
even fail, causing the memory region not to be created).

It was suggested to me that a new zone type which would be similar
to the "movable zone" but is only allowed to contain pages
that can be discarded (such as text) could solve this problem,
so that there is no copying or finding destination pages needed (thus
considerably reducing latency).

The downside I see is that there may not be anywhere near
25000 such discardable pages, so most of this zone would go unused, and
the memory would be "wasted" as in the case where it is pre-reserved.
Also, this is not currently supported, so new code would
have to be designed and implemented.

I would appreciate people's comments about:

1. Does this type of zone make any sense? It
would have to co-exist with the current movable zone type.

2. How hard would it be to implement this? The new zone type would
need to be supported and "discardable" pages steered into this zone.

3. Are there better ways of allocating a large memory region
with minimal latency that I haven't mentioned here?

Thanks.

Larry Bassel

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
