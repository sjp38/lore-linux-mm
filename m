Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id EB15B6B005C
	for <linux-mm@kvack.org>; Thu,  1 May 2014 04:45:04 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e53so2051899eek.39
        for <linux-mm@kvack.org>; Thu, 01 May 2014 01:45:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si33500953eef.112.2014.05.01.01.45.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 01:45:03 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/17] mm: shmem: Avoid atomic operation during shmem_getpage_gfp
Date: Thu,  1 May 2014 09:44:44 +0100
Message-Id: <1398933888-4940-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-1-git-send-email-mgorman@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>

shmem_getpage_gfp uses an atomic operation to set the SwapBacked field
before it's even added to the LRU or visible. This is unnecessary as what
could it possible race against?  Use an unlocked variant.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/page-flags.h | 1 +
 mm/shmem.c                 | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index d1fe1a7..4d4b39a 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -208,6 +208,7 @@ PAGEFLAG(Pinned, pinned) TESTSCFLAG(Pinned, pinned)	/* Xen */
 PAGEFLAG(SavePinned, savepinned);			/* Xen */
 PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
+	__SETPAGEFLAG(SwapBacked, swapbacked)
 
 __PAGEFLAG(SlobFree, slob_free)
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 9f70e02..f47fb38 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1132,7 +1132,7 @@ repeat:
 			goto decused;
 		}
 
-		SetPageSwapBacked(page);
+		__SetPageSwapBacked(page);
 		__set_page_locked(page);
 		error = mem_cgroup_charge_file(page, current->mm,
 						gfp & GFP_RECLAIM_MASK);
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
