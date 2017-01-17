Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D63A16B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 04:15:52 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r144so32167080wme.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:15:52 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id s17si8107721wra.167.2017.01.17.01.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 01:15:51 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id r144so36916069wme.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:15:51 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/4 v2] show_mem updates 
Date: Tue, 17 Jan 2017 10:15:39 +0100
Message-Id: <20170117091543.25850-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Helge Deller <deller@gmx.de>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Michal Hocko <mhocko@suse.com>, Tony Luck <tony.luck@intel.com>

Hi,
the previous version has been posted [1] and there didn't seem to be
any opposition so I am reposting it for inclusion. There was only
one change and warn_alloc_show_mem does cpuset_print_current_mems_allowed
now. Besides that acks have been added.

This is a mixture of one bug fix (patch 1), an enhancement (patch 2)
and cleanups (the rest of the series). First two patches should be
really straightforward. Patch 3 removes some arch specific show_mem
implementations because I think they are quite outdated and do not
really serve any useful purpose anymore. I think we should really strive
to have a consistent show_mem output regardless of the architecture. If
some architecture is really special and wants to dump something
additional we should do that via an arch specific hook.

The last patch adds nodemask parameter so that we do not rely on
the hardcoded mems_allowed of the current task when doing the node
filtering.  I consider this more a cleanup than a fix because basically
all users use a nodemask which is a subset of mems_allowed. There is
only one call path in the memory hotplug which doesn't comply with this
but that is hardly something to worry about.

[1] http://lkml.kernel.org/r/20170112131659.23058-1-mhocko@kernel.org

This is on top of the current mmotm (mmotm-2016-12-19-16-31) tree .
Michal Hocko (4):
      mm, page_alloc: do not report all nodes in show_mem
      mm, page_alloc: warn_alloc print nodemask
      arch, mm: remove arch specific show_mem
      lib/show_mem.c: teach show_mem to work with the given nodemask

 arch/ia64/mm/init.c                 | 48 ------------------------------------
 arch/parisc/mm/init.c               | 49 -------------------------------------
 arch/powerpc/xmon/xmon.c            |  2 +-
 arch/sparc/kernel/setup_32.c        |  2 +-
 arch/sparc/mm/init_32.c             | 11 ---------
 arch/tile/mm/pgtable.c              | 45 ----------------------------------
 arch/unicore32/mm/init.c            | 44 ---------------------------------
 drivers/net/ethernet/sgi/ioc3-eth.c |  2 +-
 drivers/tty/sysrq.c                 |  2 +-
 drivers/tty/vt/keyboard.c           |  2 +-
 include/linux/mm.h                  |  9 +++----
 lib/show_mem.c                      |  4 +--
 mm/nommu.c                          |  6 ++---
 mm/oom_kill.c                       |  2 +-
 mm/page_alloc.c                     | 49 ++++++++++++++++++++-----------------
 mm/vmalloc.c                        |  4 +--
 16 files changed, 44 insertions(+), 237 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
