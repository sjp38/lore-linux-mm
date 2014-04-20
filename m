Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0DE6B003D
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 22:26:57 -0400 (EDT)
Received: by mail-oa0-f52.google.com with SMTP id l6so3115316oag.11
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 19:26:52 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id jh2si26032365obb.113.2014.04.19.19.26.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 19:26:52 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 5/6] drivers,sgi-gru/grufault.c: call find_vma with the mmap_sem held
Date: Sat, 19 Apr 2014 19:26:30 -0700
Message-Id: <1397960791-16320-6-git-send-email-davidlohr@hp.com>
In-Reply-To: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
References: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zeus@gnu.org, aswin@hp.com, davidlohr@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dimitri@domain.invalid, "Sivanich <sivanich"@sgi.com

From: Jonathan Gonzalez V <zeus@gnu.org>

Performing vma lookups without taking the mm->mmap_sem is asking
for trouble. While doing the search, the vma in question can
be modified or even removed before returning to the caller.
Take the lock in order to avoid races while iterating through
the vmacache and/or rbtree.

This patch is completely *untested*.

Signed-off-by: Jonathan Gonzalez V <zeus@gnu.org>
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
Cc: Dimitri Sivanich <sivanich@sgi.com
---
 drivers/misc/sgi-gru/grufault.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index f74fc0c..15adc84 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -266,6 +266,7 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
 	unsigned long paddr;
 	int ret, ps;
 
+	down_write(&mm->mmap_sem);
 	vma = find_vma(mm, vaddr);
 	if (!vma)
 		goto inval;
@@ -277,22 +278,26 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
 	rmb();	/* Must/check ms_range_active before loading PTEs */
 	ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
 	if (ret) {
-		if (atomic)
-			goto upm;
+		if (atomic) {
+			up_write(&mm->mmap_sem);
+			return VTOP_RETRY;
+		}
 		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
 			goto inval;
 	}
 	if (is_gru_paddr(paddr))
 		goto inval;
+
+	up_write(&mm->mmap_sem);
+
 	paddr = paddr & ~((1UL << ps) - 1);
 	*gpa = uv_soc_phys_ram_to_gpa(paddr);
 	*pageshift = ps;
 	return VTOP_SUCCESS;
 
 inval:
+	up_write(&mm->mmap_sem);
 	return VTOP_INVALID;
-upm:
-	return VTOP_RETRY;
 }
 
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
