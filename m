Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC066B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 04:49:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 81so7225356wms.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 01:49:39 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0134.outbound.protection.outlook.com. [104.47.1.134])
        by mx.google.com with ESMTPS id k5si22207139wmg.1.2016.05.24.01.49.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 01:49:37 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH RESEND 0/8] More stuff to charge to kmemcg
Date: Tue, 24 May 2016 11:49:22 +0300
Message-ID: <cover.1464079537.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

[resending with all relevant lists in Cc]

Hi,

This patch implements per kmemcg accounting of page tables (x86-only),
pipe buffers, and unix socket buffers.

Basically, this is v2 of my earlier attempt [1], addressing comments by
Andrew, namely: lack of comments to non-standard _mapcount usage, extra
overhead even when kmemcg is unused, wrong handling of stolen pipe
buffer pages.

Patches 1-3 are just cleanups that are not supposed to introduce any
functional changes. Patches 4 and 5 move charge/uncharge to generic page
allocator paths for the sake of accounting pipe and unix socket buffers.
Patches 5-7 make x86 page tables, pipe buffers, and unix socket buffers
accountable.

[1] http://lkml.kernel.org/r/%3Ccover.1443262808.git.vdavydov@parallels.com%3E

Thanks,

Vladimir Davydov (8):
  mm: remove pointless struct in struct page definition
  mm: clean up non-standard page->_mapcount users
  mm: memcontrol: cleanup kmem charge functions
  mm: charge/uncharge kmemcg from generic page allocator paths
  mm: memcontrol: teach uncharge_list to deal with kmem pages
  arch: x86: charge page tables to kmemcg
  pipe: account to kmemcg
  af_unix: charge buffers to kmemcg

 arch/x86/include/asm/pgalloc.h |  12 ++++-
 arch/x86/mm/pgtable.c          |  11 ++--
 fs/pipe.c                      |  32 ++++++++---
 include/linux/gfp.h            |  10 +---
 include/linux/memcontrol.h     | 103 +++---------------------------------
 include/linux/mm_types.h       |  73 ++++++++++++-------------
 include/linux/page-flags.h     |  78 +++++++++++++--------------
 kernel/fork.c                  |   6 +--
 mm/memcontrol.c                | 117 ++++++++++++++++++++++++++++-------------
 mm/page_alloc.c                |  63 +++++-----------------
 mm/slab.h                      |  16 ++++--
 mm/slab_common.c               |   2 +-
 mm/slub.c                      |   6 +--
 mm/vmalloc.c                   |   6 +--
 net/unix/af_unix.c             |   1 +
 scripts/tags.sh                |   3 ++
 16 files changed, 245 insertions(+), 294 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
