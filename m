Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78EA18E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 20:10:52 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q64so14770836pfa.18
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 17:10:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k11sor15803694pll.39.2019.01.20.17.10.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 17:10:51 -0800 (PST)
From: Sandeep Patil <sspatil@android.com>
Subject: [PATCH] mm: proc: smaps_rollup: Fix pss_locked calculation
Date: Sun, 20 Jan 2019 17:10:49 -0800
Message-Id: <20190121011049.160505-1-sspatil@android.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, adobriyan@gmail.com, akpm@linux-foundation.org, avagin@openvz.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, kernel-team@android.com, dancol@google.com

The 'pss_locked' field of smaps_rollup was being calculated incorrectly
as it accumulated the current pss everytime a locked VMA was found.

Fix that by making sure we record the current pss value before each VMA
is walked. So, we can only add the delta if the VMA was found to be
VM_LOCKED.

Fixes: 493b0e9d945f ("mm: add /proc/pid/smaps_rollup")
Cc: stable@vger.kernel.org # 4.14.y 4.19.y
Signed-off-by: Sandeep Patil <sspatil@android.com>
---
 fs/proc/task_mmu.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f0ec9edab2f3..51a00a2b4733 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -709,6 +709,7 @@ static void smap_gather_stats(struct vm_area_struct *vma,
 #endif
 		.mm = vma->vm_mm,
 	};
+	unsigned long pss;
 
 	smaps_walk.private = mss;
 
@@ -737,11 +738,12 @@ static void smap_gather_stats(struct vm_area_struct *vma,
 		}
 	}
 #endif
-
+	/* record current pss so we can calculate the delta after page walk */
+	pss = mss->pss;
 	/* mmap_sem is held in m_start */
 	walk_page_vma(vma, &smaps_walk);
 	if (vma->vm_flags & VM_LOCKED)
-		mss->pss_locked += mss->pss;
+		mss->pss_locked += mss->pss - pss;
 }
 
 #define SEQ_PUT_DEC(str, val) \
-- 
2.20.1.321.g9e740568ce-goog
