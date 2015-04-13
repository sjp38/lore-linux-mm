Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id DABF96B006C
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:17:12 -0400 (EDT)
Received: by wiun10 with SMTP id n10so60670963wiu.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:17:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s5si16817128wjo.138.2015.04.13.03.17.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 03:17:10 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/14] Parallel memory initialisation
Date: Mon, 13 Apr 2015 11:16:52 +0100
Message-Id: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Memory initialisation had been identified as one of the reasons why large
machines take a long time to boot. Patches were posted a long time ago
that attempted to move deferred initialisation into the page allocator
paths. This was rejected on the grounds it should not be necessary to hurt
the fast paths to parallelise initialisation. This series reuses much of
the work from that time but defers the initialisation of memory to kswapd
so that one thread per node initialises memory local to that node. The
issue is that on the machines I tested with, memory initialisation was not
a major contributor to boot times. I'm posting the RFC to both review the
series and see if it actually helps users of very large machines.

After applying the series and setting the appropriate Kconfig variable I
see this in the boot log on a 64G machine

[    7.383764] kswapd 0 initialised deferred memory in 188ms
[    7.404253] kswapd 1 initialised deferred memory in 208ms
[    7.411044] kswapd 3 initialised deferred memory in 216ms
[    7.411551] kswapd 2 initialised deferred memory in 216ms

On a 1TB machine, I see

[   11.913324] kswapd 0 initialised deferred memory in 1168ms
[   12.220011] kswapd 2 initialised deferred memory in 1476ms
[   12.245369] kswapd 3 initialised deferred memory in 1500ms
[   12.271680] kswapd 1 initialised deferred memory in 1528ms

Once booted the machine appears to work as normal. Boot times were measured
from the time shutdown was called until ssh was available again.  In the
64G case, the boot time savings are negligible. On the 1TB machine, the
savings were 10 seconds (about 8% improvement on kernel times but 1-2%
overall as POST takes so long).

It would be nice if the people that have access to really large machines
would test this series and report back if the complexity is justified.

Patches are against 4.0-rc7.

 Documentation/kernel-parameters.txt |   8 +
 arch/ia64/mm/numa.c                 |  19 +-
 arch/x86/Kconfig                    |   2 +
 include/linux/memblock.h            |  18 ++
 include/linux/mm.h                  |   8 +-
 include/linux/mmzone.h              |  37 +++-
 init/main.c                         |   1 +
 mm/Kconfig                          |  29 +++
 mm/bootmem.c                        |   6 +-
 mm/internal.h                       |  23 ++-
 mm/memblock.c                       |  34 ++-
 mm/mm_init.c                        |   9 +-
 mm/nobootmem.c                      |   7 +-
 mm/page_alloc.c                     | 398 +++++++++++++++++++++++++++++++-----
 mm/vmscan.c                         |   6 +-
 15 files changed, 507 insertions(+), 98 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
