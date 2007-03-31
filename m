From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH 01/11] RFP: new bitmask_trans in <linux/bitops.h>
Date: Sat, 31 Mar 2007 02:35:13 +0200
Message-ID: <20070331003513.3415.6211.stgit@americanbeauty.home.lan>
In-Reply-To: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
References: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

Generalize _calc_vm_trans macro for subsequent use in remap_file_pages
protection support.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 include/linux/bitops.h |   10 ++++++++++
 include/linux/mman.h   |   25 ++++++++-----------------
 2 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/include/linux/bitops.h b/include/linux/bitops.h
index 638165f..d8cdfd0 100644
--- a/include/linux/bitops.h
+++ b/include/linux/bitops.h
@@ -3,6 +3,16 @@
 #include <asm/types.h>
 
 /*
+ * Optimisation macro.  It is equivalent to:
+ *      (x & bit1) ? bit2 : 0
+ * but this version is faster.
+ * ("bit1" and "bit2" must be single bits)
+ */
+#define bitmask_trans(x, bit1, bit2) \
+  ((bit1) <= (bit2) ? ((x) & (bit1)) * ((bit2) / (bit1)) \
+   : ((x) & (bit1)) / ((bit1) / (bit2)))
+
+/*
  * Include this here because some architectures need generic_ffs/fls in
  * scope
  */
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 87920a0..6ac90be 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -14,6 +14,7 @@
 #include <linux/mm.h>
 
 #include <asm/atomic.h>
+#include <linux/bitops.h>
 
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
@@ -34,24 +35,14 @@ static inline void vm_unacct_memory(long pages)
 }
 
 /*
- * Optimisation macro.  It is equivalent to:
- *      (x & bit1) ? bit2 : 0
- * but this version is faster.
- * ("bit1" and "bit2" must be single bits)
- */
-#define _calc_vm_trans(x, bit1, bit2) \
-  ((bit1) <= (bit2) ? ((x) & (bit1)) * ((bit2) / (bit1)) \
-   : ((x) & (bit1)) / ((bit1) / (bit2)))
-
-/*
  * Combine the mmap "prot" argument into "vm_flags" used internally.
  */
 static inline unsigned long
 calc_vm_prot_bits(unsigned long prot)
 {
-	return _calc_vm_trans(prot, PROT_READ,  VM_READ ) |
-	       _calc_vm_trans(prot, PROT_WRITE, VM_WRITE) |
-	       _calc_vm_trans(prot, PROT_EXEC,  VM_EXEC );
+	return bitmask_trans(prot, PROT_READ,  VM_READ ) |
+	       bitmask_trans(prot, PROT_WRITE, VM_WRITE) |
+	       bitmask_trans(prot, PROT_EXEC,  VM_EXEC );
 }
 
 /*
@@ -60,10 +51,10 @@ calc_vm_prot_bits(unsigned long prot)
 static inline unsigned long
 calc_vm_flag_bits(unsigned long flags)
 {
-	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
-	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
-	       _calc_vm_trans(flags, MAP_EXECUTABLE, VM_EXECUTABLE) |
-	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    );
+	return bitmask_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
+	       bitmask_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
+	       bitmask_trans(flags, MAP_EXECUTABLE, VM_EXECUTABLE) |
+	       bitmask_trans(flags, MAP_LOCKED,     VM_LOCKED    );
 }
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MMAN_H */



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
