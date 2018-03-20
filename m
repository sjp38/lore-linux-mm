Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 52EA66B000E
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:32:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s6so1505939pgn.3
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:32:42 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id 3-v6si2410248plt.124.2018.03.20.14.32.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 14:32:40 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC PATCH 4/8] mm: nommu: add atomic parameter to do_munmap()
Date: Wed, 21 Mar 2018 05:31:22 +0800
Message-Id: <1521581486-99134-5-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Just add atomic parameter to keep consistent with the API change and
pass "true" to the call site. Nommu code doesn't do the mmap_sem
unlock/relock.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/nommu.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index ebb6e61..5954c08 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1578,7 +1578,8 @@ static int shrink_vma(struct mm_struct *mm,
  * - under NOMMU conditions the chunk to be unmapped must be backed by a single
  *   VMA, though it need not cover the whole VMA
  */
-int do_munmap(struct mm_struct *mm, unsigned long start, size_t len, struct list_head *uf)
+int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
+	      struct list_head *ufi, bool atomic)
 {
 	struct vm_area_struct *vma;
 	unsigned long end;
@@ -1644,7 +1645,7 @@ int vm_munmap(unsigned long addr, size_t len)
 	int ret;
 
 	down_write(&mm->mmap_sem);
-	ret = do_munmap(mm, addr, len, NULL);
+	ret = do_munmap(mm, addr, len, NULL, true);
 	up_write(&mm->mmap_sem);
 	return ret;
 }
-- 
1.8.3.1
