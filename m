Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3556C6B029A
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 18:07:33 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id td3so18776866pab.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 15:07:33 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id oi7si10199891pab.183.2016.04.05.15.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 15:07:32 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id 184so19151631pff.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 15:07:32 -0700 (PDT)
Date: Tue, 5 Apr 2016 15:07:29 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 31/31] huge tmpfs: no kswapd by default on sync allocations
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051505580.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Andres Lagar-Cavilla <andreslc@google.com>

This triggers early compaction abort while in process context, to
ameliorate mmap semaphore stalls.

Suggested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 Documentation/filesystems/tmpfs.txt |    5 +++--
 mm/shmem.c                          |    3 ++-
 2 files changed, 5 insertions(+), 3 deletions(-)

--- a/Documentation/filesystems/tmpfs.txt
+++ b/Documentation/filesystems/tmpfs.txt
@@ -194,8 +194,9 @@ to force huge off for all (intended for
 
 /proc/sys/vm/shmem_huge_gfpmask (intended for experimentation only):
 
-Default 38146762, that is 0x24612ca:
-GFP_HIGHUSER_MOVABLE|__GFP_NOWARN|__GFP_THISNODE|__GFP_NORETRY.
+Default 4592330, that is 0x4612ca:
+GFP_HIGHUSER_MOVABLE|__GFP_NOWARN|__GFP_THISNODE|__GFP_NORETRY
+minus __GFP_KSWAPD_RECLAIM.
 Write a gfpmask built from __GFP flags in include/linux/gfp.h, to experiment
 with better alternatives for the synchronous huge tmpfs allocation used
 when faulting or writing.
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -324,7 +324,8 @@ int shmem_huge __read_mostly;
 int shmem_huge_recoveries __read_mostly = 8;	/* concurrent recovery limit */
 
 int shmem_huge_gfpmask __read_mostly =
-	(int)(GFP_HIGHUSER_MOVABLE|__GFP_NOWARN|__GFP_THISNODE|__GFP_NORETRY);
+	(int)(GFP_HIGHUSER_MOVABLE|__GFP_NOWARN|__GFP_THISNODE|__GFP_NORETRY) &
+	~__GFP_KSWAPD_RECLAIM;
 int shmem_recovery_gfpmask __read_mostly =
 	(int)(GFP_HIGHUSER_MOVABLE|__GFP_NOWARN|__GFP_THISNODE);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
