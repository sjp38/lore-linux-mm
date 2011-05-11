Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BD1E06B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 11:29:42 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/3] Reduce impact to overall system of SLUB using high-order allocations
Date: Wed, 11 May 2011 16:29:30 +0100
Message-Id: <1305127773-10570-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Debian (and probably Ubuntu) have recently have changed to the default
option of SLUB. There are a few reports of people experiencing hangs
when copying large amounts of data with kswapd using a large amount of
CPU. It appears this is down to SLUB using high orders by default and
the page allocator and reclaim struggling to keep up. The following
three patches reduce the cost of using those high orders.

Patch 1 prevents kswapd waking up in response to SLUBs speculative
	use of high orders. This eliminates the hangs and while the
	system can still stall for long periods, it recovers.

Patch 2 further reduces the cost by prevent SLUB entering direct
	compaction or reclaim paths on the grounds that falling
	back to order-0 should be cheaper.

Patch 3 defaults SLUB to using order-0 on the grounds that the
	systems that heavily benefit from using high-order are also
	sized to fit in physical memory. On such systems, they should
	manually tune slub_max_order=3.

My own data on this is not great. I haven't really been able to
reproduce the same problem locally but a significant failing is
that the tests weren't stressing X but I couldn't make meaningful
comparisons by just randomly clicking on things (working on fixing
this problem).

The test case is simple. "download tar" wgets a large tar file and
stores it locally. "unpack" is expanding it (15 times physical RAM
in this case) and "delete source dirs" is the tarfile being deleted
again. I also experimented with having the tar copied numerous times
and into deeper directories to increase the size but the results were
not particularly interesting so I left it as one tar.

Test server, 4 CPU threads (AMD Phenom), x86_64, 2G of RAM, no X running
                             -       nowake    
             largecopy-vanilla       kswapd-v1r1  noexstep-v1r1     default0-v1r1
download tar           94 ( 0.00%)   94 ( 0.00%)   94 ( 0.00%)   93 ( 1.08%)
unpack tar            521 ( 0.00%)  551 (-5.44%)  482 ( 8.09%)  488 ( 6.76%)
delete source dirs    208 ( 0.00%)  218 (-4.59%)  194 ( 7.22%)  194 ( 7.22%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)        740.82    777.73    739.98    747.47
Total Elapsed Time (seconds)               1046.66   1273.91    962.47    936.17

Disabling kswapd alone hurts performance slightly even though testers
report it fixes hangs. I would guess it's because SLUB callers are
calling direct reclaim more frequently (I belatedly noticed that
compaction was disabled so it's not a factor) but haven't confirmed
it. However, preventing kswapd waking or entering direct reclaim and
having SLUB falling back to order-0 performed noticeably faster. Just
using order-0 in the first place was fastest of all.

I tried running the same test on a test laptop but unfortunately
due to a misconfiguration the results were lost. It would take a few
hours to rerun so am posting without them.

If the testers verify this series help and we agree the patches are
appropriate, they should be considered a stable candidate for 2.6.38.

 Documentation/vm/slub.txt |    2 +-
 mm/page_alloc.c           |    3 ++-
 mm/slub.c                 |    5 +++--
 3 files changed, 6 insertions(+), 4 deletions(-)

-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
