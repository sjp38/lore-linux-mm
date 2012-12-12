Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id E91526B002B
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 13:23:10 -0500 (EST)
From: Joe Perches <joe@perches.com>
Subject: [TRIVIAL PATCH 23/26] mm: Convert print_symbol to %pSR
Date: Wed, 12 Dec 2012 10:19:12 -0800
Message-Id: <96a83ddb7f8571afe8b3b3b6e7fc9dc3ff81dda5.1355335228.git.joe@perches.com>
In-Reply-To: <cover.1355335227.git.joe@perches.com>
References: <cover.1355335227.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <trivial@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use the new vsprintf extension to avoid any possible
message interleaving.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/memory.c |    8 ++++----
 mm/slab.c   |    8 +++-----
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index d81bdd7..a14c194 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -711,11 +711,11 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 	 * Choose text because data symbols depend on CONFIG_KALLSYMS_ALL=y
 	 */
 	if (vma->vm_ops)
-		print_symbol(KERN_ALERT "vma->vm_ops->fault: %s\n",
-				(unsigned long)vma->vm_ops->fault);
+		printk(KERN_ALERT "vma->vm_ops->fault: %pSR\n",
+		       vma->vm_ops->fault);
 	if (vma->vm_file && vma->vm_file->f_op)
-		print_symbol(KERN_ALERT "vma->vm_file->f_op->mmap: %s\n",
-				(unsigned long)vma->vm_file->f_op->mmap);
+		printk(KERN_ALERT "vma->vm_file->f_op->mmap: %pSR\n",
+		       vma->vm_file->f_op->mmap);
 	dump_stack();
 	add_taint(TAINT_BAD_PAGE);
 }
diff --git a/mm/slab.c b/mm/slab.c
index 23daffa..d23ab4f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2081,11 +2081,9 @@ static void print_objinfo(struct kmem_cache *cachep, void *objp, int lines)
 	}
 
 	if (cachep->flags & SLAB_STORE_USER) {
-		printk(KERN_ERR "Last user: [<%p>]",
-			*dbg_userword(cachep, objp));
-		print_symbol("(%s)",
-				(unsigned long)*dbg_userword(cachep, objp));
-		printk("\n");
+		printk(KERN_ERR "Last user: [<%p>](%pSR)\n",
+		       *dbg_userword(cachep, objp),
+		       *dbg_userword(cachep, objp));
 	}
 	realobj = (char *)objp + obj_offset(cachep);
 	size = cachep->object_size;
-- 
1.7.8.112.g3fd21

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
