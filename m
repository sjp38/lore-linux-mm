Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC7856B0261
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:24:26 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id t9so704818ywg.6
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 11:24:26 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i11-v6si148504ybk.557.2018.03.13.11.24.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 11:24:25 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v6 0/2] initialize pages on demand during boot
Date: Tue, 13 Mar 2018 14:23:53 -0400
Message-Id: <20180313182355.17669-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, pasha.tatashin@oracle.com, m.mizuma@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Change log:
	v5 - v6
	- Fixed issues found by Andrew Morton: replaced cond_resched() with
	  touch_nmi_watchdog(), instead of simply deleting it.
	- Removed useless pgdata_resize_lock_irq(), as regular
	  pgdata_resize_lock() does exactly what is needed.
	- Included fixes to comments by Andrew from
	  mm-initialize-pages-on-demand-during-boot-v5-fix.patch.

	v4 - v5
	- Fix issue reported by Vlasimil Babka:
	  > I've noticed that this function first disables the
	  > on-demand initialization, and then runs the kthreads.
	  > Doesn't that leave a window where allocations can fail? The
	  > chances are probably small, but I think it would be better
	  > to avoid it completely, rare failures suck.
	  >
	  > Fixing that probably means rethinking the whole
	  > synchronization more dramatically though :/
	- Introduced a new patch that uses node resize lock to synchronize
	  on-demand deferred page initialization, and regular deferred page
	  initialization.

	v3 - v4
	- Fix !CONFIG_NUMA issue.

	v2 - v3
	Andrew Morton's comments:
	- Moved read of pgdat->first_deferred_pfn into
	  deferred_zone_grow_lock, thus got rid of READ_ONCE()/WRITE_ONCE()
	- Replaced spin_lock() with spin_lock_irqsave() in
	  deferred_grow_zone
	- Updated comments for deferred_zone_grow_lock
	- Updated comment before deferred_grow_zone() explaining return
	  value, and also noinline specifier.
	- Fixed comment before _deferred_grow_zone().

	v1 - v2
	Added Tested-by: Masayoshi Mizuma

This change helps for three reasons:

1. Insufficient amount of reserved memory due to arguments provided by
user. User may request some buffers, increased hash tables sizes etc.
Currently, machine panics during boot if it can't allocate memory due
to insufficient amount of reserved memory. With this change, it will
be able to grow zone before deferred pages are initialized.

One observed example is described in the linked discussion [1] Mel
Gorman writes:

"
Yasuaki Ishimatsu reported a premature OOM when trace_buf_size=100m was
specified on a machine with many CPUs. The kernel tried to allocate 38.4GB
but only 16GB was available due to deferred memory initialisation.
"

The allocations in the above scenario happen per-cpu in smp_init(),
and before deferred pages are initialized. So, there is no way to
predict how much memory we should put aside to boot successfully with
deferred page initialization feature compiled in.

2. The second reason is future proof. The kernel memory requirements
may change, and we do not want to constantly update
reset_deferred_meminit() to satisfy the new requirements. In addition,
this function is currently in common code, but potentially would need
to be split into arch specific variants, as more arches will start
taking advantage of deferred page initialization feature.

3. On demand initialization of reserved pages guarantees that we will
initialize only as many pages early in boot using only one thread as
needed, the rest are going to be efficiently initialized in parallel.

[1] https://www.spinics.net/lists/linux-mm/msg139087.html

Pavel Tatashin (2):
  mm: disable interrupts while initializing deferred pages
  mm: initialize pages on demand during boot

 include/linux/memblock.h       |  10 --
 include/linux/memory_hotplug.h |  53 ++++++-----
 include/linux/mmzone.h         |   5 +-
 mm/memblock.c                  |  23 -----
 mm/page_alloc.c                | 202 +++++++++++++++++++++++++++++++----------
 5 files changed, 186 insertions(+), 107 deletions(-)

-- 
2.16.2
