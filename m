Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2729F6B0071
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 10:37:16 -0400 (EDT)
Received: by widdi4 with SMTP id di4so31729621wid.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 07:37:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bb1si2391582wjb.154.2015.04.28.07.37.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 07:37:14 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/13] Parallel struct page initialisation v4
Date: Tue, 28 Apr 2015 15:36:57 +0100
Message-Id: <1430231830-7702-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The bulk of the changes here are related to Andrew's feedback. Functionally
there is almost no difference.

Changelog since v3
o Fix section-related warning
o Comments, clarifications, checkpatch
o Report the number of pages initialised

Changelog since v2
o Reduce overhead of topology_init
o Remove boot-time kernel parameter to enable/disable
o Enable on UMA

Changelog since v1
o Always initialise low zones
o Typo corrections
o Rename parallel mem init to parallel struct page init
o Rebase to 4.0

Struct page initialisation had been identified as one of the reasons why
large machines take a long time to boot. Patches were posted a long time ago
to defer initialisation until they were first used.  This was rejected on
the grounds it should not be necessary to hurt the fast paths. This series
reuses much of the work from that time but defers the initialisation of
memory to kswapd so that one thread per node initialises memory local to
that node.

After applying the series and setting the appropriate Kconfig variable I
see this in the boot log on a 64G machine

[    7.383764] kswapd 0 initialised deferred memory in 188ms
[    7.404253] kswapd 1 initialised deferred memory in 208ms
[    7.411044] kswapd 3 initialised deferred memory in 216ms
[    7.411551] kswapd 2 initialised deferred memory in 216ms

On a 1TB machine, I see

[    8.406511] kswapd 3 initialised deferred memory in 1116ms
[    8.428518] kswapd 1 initialised deferred memory in 1140ms
[    8.435977] kswapd 0 initialised deferred memory in 1148ms
[    8.437416] kswapd 2 initialised deferred memory in 1148ms

Once booted the machine appears to work as normal. Boot times were measured
from the time shutdown was called until ssh was available again.  In the
64G case, the boot time savings are negligible. On the 1TB machine, the
savings were 16 seconds.

It would be nice if the people that have access to really large machines
would test this series and report how much boot time is reduced.

 arch/ia64/mm/numa.c      |  19 +--
 arch/x86/Kconfig         |   1 +
 drivers/base/node.c      |   6 +-
 include/linux/memblock.h |  18 +++
 include/linux/mm.h       |   8 +-
 include/linux/mmzone.h   |  23 ++-
 mm/Kconfig               |  18 +++
 mm/bootmem.c             |   8 +-
 mm/internal.h            |  29 +++-
 mm/memblock.c            |  34 +++-
 mm/mm_init.c             |   9 +-
 mm/nobootmem.c           |   7 +-
 mm/page_alloc.c          | 401 ++++++++++++++++++++++++++++++++++++++++-------
 mm/vmscan.c              |   6 +-
 14 files changed, 487 insertions(+), 100 deletions(-)

-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
