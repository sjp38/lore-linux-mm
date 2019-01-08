Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED708E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 06:09:57 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so1476207edz.15
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 03:09:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f14si673014edw.282.2019.01.08.03.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 03:09:55 -0800 (PST)
From: Roman Penyaev <rpenyaev@suse.de>
Subject: [PATCH 1/1] mm/vmalloc: Make vmalloc_32_user() align base kernel virtual address to SHMLBA
Date: Tue,  8 Jan 2019 12:09:44 +0100
Message-Id: <20190108110944.23591-1-rpenyaev@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Roman Penyaev <rpenyaev@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, "David S . Miller" <davem@davemloft.net>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch repeats the original one from David S. Miller:

  2dca6999eed5 ("mm, perf_event: Make vmalloc_user() align base kernel virtual address to SHMLBA")

but for missed vmalloc_32_user() case, which also requires correct
alignment of virtual address on kernel side to avoid D-caches
aliases.  A bit of copy-paste from original patch to recover in
memory of what is all about:

  When a vmalloc'd area is mmap'd into userspace, some kind of
  co-ordination is necessary for this to work on platforms with cpu
  D-caches which can have aliases.

  Otherwise kernel side writes won't be seen properly in userspace
  and vice versa.

  If the kernel side mapping and the user side one have the same
  alignment, modulo SHMLBA, this can work as long as VM_SHARED is
  shared of VMA and for all current users this is true.  VM_SHARED
  will force SHMLBA alignment of the user side mmap on platforms with
  D-cache aliasing matters.

  David S. Miller

Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 50b17c745149..e83961767dc1 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1971,7 +1971,7 @@ EXPORT_SYMBOL(vmalloc_32);
  */
 void *vmalloc_32_user(unsigned long size)
 {
-	return __vmalloc_node_range(size, 1,  VMALLOC_START, VMALLOC_END,
+	return __vmalloc_node_range(size, SHMLBA,  VMALLOC_START, VMALLOC_END,
 				    GFP_VMALLOC32 | __GFP_ZERO, PAGE_KERNEL,
 				    VM_USERMAP, NUMA_NO_NODE,
 				    __builtin_return_address(0));
-- 
2.19.1
