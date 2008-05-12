Received: by wf-out-1314.google.com with SMTP id 28so2907773wfc.11
        for <linux-mm@kvack.org>; Mon, 12 May 2008 03:32:22 -0700 (PDT)
From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 3/4] [mm/nommu]: use copy_to_user_page to call flush icache for [#811] toolchain old bug
Date: Mon, 12 May 2008 18:32:04 +0800
Message-Id: <1210588325-11027-4-git-send-email-cooloney@kernel.org>
In-Reply-To: <1210588325-11027-1-git-send-email-cooloney@kernel.org>
References: <1210588325-11027-1-git-send-email-cooloney@kernel.org>
Sender: owner-linux-mm@kvack.org
From: Jie Zhang <jie.zhang@analog.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dwmw2@infradead.org
Cc: Jie Zhang <jie.zhang@analog.com>, Bryan Wu <cooloney@kernel.org>
List-ID: <linux-mm.kvack.org>

access_process_vm in mm/memory.c uses copy_to_user_page and
copy_from_user_page. So for !MMU we'd better do the same thing.
Other archs with mmu do the cache flush in copy_to_user_page.
It gives me hint that copy_to_user_page is designed to flush
the cache. On other side, no archs do the cache flush ptrace.

Signed-off-by: Jie Zhang <jie.zhang@analog.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 mm/nommu.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index c11e5cc..56bb447 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1458,9 +1458,11 @@ int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, in
 
 		/* only read or write mappings where it is permitted */
 		if (write && vma->vm_flags & VM_MAYWRITE)
-			len -= copy_to_user((void *) addr, buf, len);
+			copy_to_user_page(vma, NULL, NULL,
+					  (void *) addr, buf, len);
 		else if (!write && vma->vm_flags & VM_MAYREAD)
-			len -= copy_from_user(buf, (void *) addr, len);
+			copy_from_user_page(vma, NULL, NULL,
+					    buf, (void *) addr, len);
 		else
 			len = 0;
 	} else {
-- 
1.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
