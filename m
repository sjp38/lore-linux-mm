Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA5C6B002E
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 14:23:10 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id a188so7418411qkg.4
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 11:23:10 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id n49si1636716qtn.53.2018.02.09.11.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 11:23:09 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v3 0/1] initialize pages on demand during boot
Date: Fri,  9 Feb 2018 14:22:15 -0500
Message-Id: <20180209192216.20509-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, pasha.tatashin@oracle.com, m.mizuma@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Change log:
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

Pavel Tatashin (1):
  mm: initialize pages on demand during boot

 include/linux/memblock.h |  10 ---
 mm/memblock.c            |  23 -------
 mm/page_alloc.c          | 175 ++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 136 insertions(+), 72 deletions(-)

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
