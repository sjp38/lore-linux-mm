From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] vmalloc: back off only when the current task is OOM killed
Date: Tue, 10 Oct 2017 19:58:53 +0900
Message-ID: <1507633133-5720-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: alan@llwyncelyn.cymru, hch@lst.de, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
List-Id: linux-mm.kvack.org

Commit 5d17a73a2ebeb8d1 ("vmalloc: back off when the current task is
killed") revealed two bugs [1] [2] that were not ready to fail vmalloc()
upon SIGKILL. But since the intent of that commit was to avoid unlimited
access to memory reserves, we should have checked tsk_is_oom_victim()
rather than fatal_signal_pending().

Note that even with commit cd04ae1e2dc8e365 ("mm, oom: do not rely on
TIF_MEMDIE for memory reserves access"), it is possible to trigger
"complete depletion of memory reserves" and "extra OOM kills due to
depletion of memory reserves" by doing a large vmalloc() request if commit
5d17a73a2ebeb8d1 is reverted. Thus, let's keep checking tsk_is_oom_victim()
rather than removing fatal_signal_pending().

  [1] http://lkml.kernel.org/r/42eb5d53-5ceb-a9ce-791a-9469af30810c@I-love.SAKURA.ne.jp
  [2] http://lkml.kernel.org/r/20171003225504.GA966@cmpxchg.org

Fixes: 5d17a73a2ebeb8d1 ("vmalloc: back off when the current task is killed")
Cc: stable # 4.11+
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/vmalloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8a43db6..6add29d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -31,6 +31,7 @@
 #include <linux/compiler.h>
 #include <linux/llist.h>
 #include <linux/bitops.h>
+#include <linux/oom.h>
 
 #include <linux/uaccess.h>
 #include <asm/tlbflush.h>
@@ -1695,7 +1696,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	for (i = 0; i < area->nr_pages; i++) {
 		struct page *page;
 
-		if (fatal_signal_pending(current)) {
+		if (tsk_is_oom_victim(current)) {
 			area->nr_pages = i;
 			goto fail_no_warn;
 		}
-- 
1.8.3.1
