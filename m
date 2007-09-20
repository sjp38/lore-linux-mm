Date: Thu, 20 Sep 2007 13:23:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/9] oom: move prototypes to appropriate header file
In-Reply-To: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Move the OOM killer's extern function prototypes to include/linux/oom.h
and include it where necessary.

Cc: Andrea Arcangeli <andrea@suse.de>
Acked-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 drivers/char/sysrq.c |    1 +
 include/linux/oom.h  |   11 ++++++++++-
 include/linux/swap.h |    5 -----
 mm/page_alloc.c      |    1 +
 4 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/char/sysrq.c b/drivers/char/sysrq.c
--- a/drivers/char/sysrq.c
+++ b/drivers/char/sysrq.c
@@ -36,6 +36,7 @@
 #include <linux/kexec.h>
 #include <linux/irq.h>
 #include <linux/hrtimer.h>
+#include <linux/oom.h>
 
 #include <asm/ptrace.h>
 #include <asm/irq_regs.h>
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -1,10 +1,19 @@
 #ifndef __INCLUDE_LINUX_OOM_H
 #define __INCLUDE_LINUX_OOM_H
 
+#include <linux/sched.h>
+
 /* /proc/<pid>/oom_adj set to -17 protects from the oom-killer */
 #define OOM_DISABLE (-17)
 /* inclusive */
 #define OOM_ADJUST_MIN (-16)
 #define OOM_ADJUST_MAX 15
 
-#endif
+#ifdef __KERNEL__
+
+extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
+extern int register_oom_notifier(struct notifier_block *nb);
+extern int unregister_oom_notifier(struct notifier_block *nb);
+
+#endif /* __KERNEL__*/
+#endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -158,11 +158,6 @@ struct swap_list_t {
 /* Swap 50% full? Release swapcache more aggressively.. */
 #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
 
-/* linux/mm/oom_kill.c */
-extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
-extern int register_oom_notifier(struct notifier_block *nb);
-extern int unregister_oom_notifier(struct notifier_block *nb);
-
 /* linux/mm/memory.c */
 extern void swapin_readahead(swp_entry_t, unsigned long, struct vm_area_struct *);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -41,6 +41,7 @@
 #include <linux/pfn.h>
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
+#include <linux/oom.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
