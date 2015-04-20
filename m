From: Juergen Gross <jgross@suse.com>
Subject: [Patch V3 15/15] xen: remove no longer needed p2m.h
Date: Mon, 20 Apr 2015 07:23:40 +0200
Message-ID: <1429507420-18201-16-git-send-email-jgross@suse.com>
References: <1429507420-18201-1-git-send-email-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1429507420-18201-1-git-send-email-jgross@suse.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
To: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.comlinux-mm, @kvack.org
Cc: Juergen Gross <jgross@suse.com>
List-Id: linux-mm.kvack.org

Cleanup by removing arch/x86/xen/p2m.h as it isn't needed any more.

Most definitions in this file are used in p2m.c only. Move those into
p2m.c.

set_phys_range_identity() is already declared in
arch/x86/include/asm/xen/page.h, add __init annotation there.

MAX_REMAP_RANGES isn't used at all, just delete it.

The only define left is P2M_PER_PAGE which is moved to page.h as well.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/include/asm/xen/page.h |  6 ++++--
 arch/x86/xen/p2m.c              |  6 +++++-
 arch/x86/xen/p2m.h              | 15 ---------------
 arch/x86/xen/setup.c            |  1 -
 4 files changed, 9 insertions(+), 19 deletions(-)
 delete mode 100644 arch/x86/xen/p2m.h

diff --git a/arch/x86/include/asm/xen/page.h b/arch/x86/include/asm/xen/page.h
index 18a11f2..b858592 100644
--- a/arch/x86/include/asm/xen/page.h
+++ b/arch/x86/include/asm/xen/page.h
@@ -35,6 +35,8 @@ typedef struct xpaddr {
 #define FOREIGN_FRAME(m)	((m) | FOREIGN_FRAME_BIT)
 #define IDENTITY_FRAME(m)	((m) | IDENTITY_FRAME_BIT)
 
+#define P2M_PER_PAGE		(PAGE_SIZE / sizeof(unsigned long))
+
 extern unsigned long *machine_to_phys_mapping;
 extern unsigned long  machine_to_phys_nr;
 extern unsigned long *xen_p2m_addr;
@@ -44,8 +46,8 @@ extern unsigned long  xen_max_p2m_pfn;
 extern unsigned long get_phys_to_machine(unsigned long pfn);
 extern bool set_phys_to_machine(unsigned long pfn, unsigned long mfn);
 extern bool __set_phys_to_machine(unsigned long pfn, unsigned long mfn);
-extern unsigned long set_phys_range_identity(unsigned long pfn_s,
-					     unsigned long pfn_e);
+extern unsigned long __init set_phys_range_identity(unsigned long pfn_s,
+						    unsigned long pfn_e);
 
 extern int set_foreign_p2m_mapping(struct gnttab_map_grant_ref *map_ops,
 				   struct gnttab_map_grant_ref *kmap_ops,
diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
index 365a64a..1f63ad2 100644
--- a/arch/x86/xen/p2m.c
+++ b/arch/x86/xen/p2m.c
@@ -78,10 +78,14 @@
 #include <xen/balloon.h>
 #include <xen/grant_table.h>
 
-#include "p2m.h"
 #include "multicalls.h"
 #include "xen-ops.h"
 
+#define P2M_MID_PER_PAGE	(PAGE_SIZE / sizeof(unsigned long *))
+#define P2M_TOP_PER_PAGE	(PAGE_SIZE / sizeof(unsigned long **))
+
+#define MAX_P2M_PFN	(P2M_TOP_PER_PAGE * P2M_MID_PER_PAGE * P2M_PER_PAGE)
+
 #define PMDS_PER_MID_PAGE	(P2M_MID_PER_PAGE / PTRS_PER_PTE)
 
 unsigned long *xen_p2m_addr __read_mostly;
diff --git a/arch/x86/xen/p2m.h b/arch/x86/xen/p2m.h
deleted file mode 100644
index ad8aee2..0000000
--- a/arch/x86/xen/p2m.h
+++ /dev/null
@@ -1,15 +0,0 @@
-#ifndef _XEN_P2M_H
-#define _XEN_P2M_H
-
-#define P2M_PER_PAGE        (PAGE_SIZE / sizeof(unsigned long))
-#define P2M_MID_PER_PAGE    (PAGE_SIZE / sizeof(unsigned long *))
-#define P2M_TOP_PER_PAGE    (PAGE_SIZE / sizeof(unsigned long **))
-
-#define MAX_P2M_PFN         (P2M_TOP_PER_PAGE * P2M_MID_PER_PAGE * P2M_PER_PAGE)
-
-#define MAX_REMAP_RANGES    10
-
-extern unsigned long __init set_phys_range_identity(unsigned long pfn_s,
-                                      unsigned long pfn_e);
-
-#endif  /* _XEN_P2M_H */
diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index f960021..a1a77ea 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -30,7 +30,6 @@
 #include <xen/hvc-console.h>
 #include "xen-ops.h"
 #include "vdso.h"
-#include "p2m.h"
 #include "mmu.h"
 
 #define GB(x) ((uint64_t)(x) * 1024 * 1024 * 1024)
-- 
2.1.4
