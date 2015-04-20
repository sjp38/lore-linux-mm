From: Juergen Gross <jgross@suse.com>
Subject: [Patch V3 08/15] xen: find unused contiguous memory area
Date: Mon, 20 Apr 2015 07:23:33 +0200
Message-ID: <1429507420-18201-9-git-send-email-jgross@suse.com>
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

For being able to relocate pre-allocated data areas like initrd or
p2m list it is mandatory to find a contiguous memory area which is
not yet in use and doesn't conflict with the memory map we want to
be in effect.

In case such an area is found reserve it at once as this will be
required to be done in any case.

Signed-off-by: Juergen Gross <jgross@suse.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 arch/x86/xen/setup.c   | 34 ++++++++++++++++++++++++++++++++++
 arch/x86/xen/xen-ops.h |  1 +
 2 files changed, 35 insertions(+)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 99ef82c..973d294 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -597,6 +597,40 @@ bool __init xen_is_e820_reserved(phys_addr_t start, phys_addr_t size)
 }
 
 /*
+ * Find a free area in physical memory not yet reserved and compliant with
+ * E820 map.
+ * Used to relocate pre-allocated areas like initrd or p2m list which are in
+ * conflict with the to be used E820 map.
+ * In case no area is found, return 0. Otherwise return the physical address
+ * of the area which is already reserved for convenience.
+ */
+phys_addr_t __init xen_find_free_area(phys_addr_t size)
+{
+	unsigned mapcnt;
+	phys_addr_t addr, start;
+	struct e820entry *entry = xen_e820_map;
+
+	for (mapcnt = 0; mapcnt < xen_e820_map_entries; mapcnt++, entry++) {
+		if (entry->type != E820_RAM || entry->size < size)
+			continue;
+		start = entry->addr;
+		for (addr = start; addr < start + size; addr += PAGE_SIZE) {
+			if (!memblock_is_reserved(addr))
+				continue;
+			start = addr + PAGE_SIZE;
+			if (start + size > entry->addr + entry->size)
+				break;
+		}
+		if (addr >= start + size) {
+			memblock_reserve(start, size);
+			return start;
+		}
+	}
+
+	return 0;
+}
+
+/*
  * Reserve Xen mfn_list.
  * See comment above "struct start_info" in <xen/interface/xen.h>
  * We tried to make the the memblock_reserve more selective so
diff --git a/arch/x86/xen/xen-ops.h b/arch/x86/xen/xen-ops.h
index c1385b8..3f1669c 100644
--- a/arch/x86/xen/xen-ops.h
+++ b/arch/x86/xen/xen-ops.h
@@ -43,6 +43,7 @@ bool __init xen_is_e820_reserved(phys_addr_t start, phys_addr_t size);
 unsigned long __ref xen_chk_extra_mem(unsigned long pfn);
 void __init xen_inv_extra_mem(void);
 void __init xen_remap_memory(void);
+phys_addr_t __init xen_find_free_area(phys_addr_t size);
 char * __init xen_memory_setup(void);
 char * xen_auto_xlated_memory_setup(void);
 void __init xen_arch_setup(void);
-- 
2.1.4
