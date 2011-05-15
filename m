Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CE06190010D
	for <linux-mm@kvack.org>; Sun, 15 May 2011 18:22:53 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 6/9] mm: declare mpol_to_str() when CONFIG_TMPFS=n
Date: Sun, 15 May 2011 18:20:26 -0400
Message-Id: <1305498029-11677-7-git-send-email-wilsons@start.ca>
In-Reply-To: <1305498029-11677-1-git-send-email-wilsons@start.ca>
References: <1305498029-11677-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>

When CONFIG_TMPFS=n mpol_to_str() is not declared in mempolicy.h.
However, in the NUMA case, the definition is always compiled.

Since it is not strictly true that tmpfs is the only client, and since
the symbol was always lurking around anyways, export mpol_to_str()
unconditionally.  Furthermore, this will allow us to move
show_numa_map() out of mempolicy.c and into the procfs subsystem.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@xenotime.net>
---
 include/linux/mempolicy.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index c2f6032..7978eec 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -231,10 +231,10 @@ int do_migrate_pages(struct mm_struct *mm,
 
 #ifdef CONFIG_TMPFS
 extern int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context);
+#endif
 
 extern int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol,
 			int no_context);
-#endif
 
 /* Check if a vma is migratable */
 static inline int vma_migratable(struct vm_area_struct *vma)
@@ -371,13 +371,13 @@ static inline int mpol_parse_str(char *str, struct mempolicy **mpol,
 {
 	return 1;	/* error */
 }
+#endif
 
 static inline int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol,
 				int no_context)
 {
 	return 0;
 }
-#endif
 
 #endif /* CONFIG_NUMA */
 #endif /* __KERNEL__ */
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
