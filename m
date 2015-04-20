From: Juergen Gross <jgross@suse.com>
Subject: [Patch V3 07/15] xen: check memory area against e820 map
Date: Mon, 20 Apr 2015 07:23:32 +0200
Message-ID: <1429507420-18201-8-git-send-email-jgross@suse.com>
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

Provide a service routine to check a physical memory area against the
E820 map. The routine will return false if the complete area is RAM
according to the E820 map and true otherwise.

Signed-off-by: Juergen Gross <jgross@suse.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 arch/x86/xen/setup.c   | 23 +++++++++++++++++++++++
 arch/x86/xen/xen-ops.h |  1 +
 2 files changed, 24 insertions(+)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 87251b4..99ef82c 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -573,6 +573,29 @@ static unsigned long __init xen_count_remap_pages(unsigned long max_pfn)
 	return extra;
 }
 
+bool __init xen_is_e820_reserved(phys_addr_t start, phys_addr_t size)
+{
+	struct e820entry *entry;
+	unsigned mapcnt;
+	phys_addr_t end;
+
+	if (!size)
+		return false;
+
+	end = start + size;
+	entry = xen_e820_map;
+
+	for (mapcnt = 0; mapcnt < xen_e820_map_entries; mapcnt++) {
+		if (entry->type == E820_RAM && entry->addr <= start &&
+		    (entry->addr + entry->size) >= end)
+			return false;
+
+		entry++;
+	}
+
+	return true;
+}
+
 /*
  * Reserve Xen mfn_list.
  * See comment above "struct start_info" in <xen/interface/xen.h>
diff --git a/arch/x86/xen/xen-ops.h b/arch/x86/xen/xen-ops.h
index 9e195c6..c1385b8 100644
--- a/arch/x86/xen/xen-ops.h
+++ b/arch/x86/xen/xen-ops.h
@@ -39,6 +39,7 @@ void xen_reserve_top(void);
 void xen_mm_pin_all(void);
 void xen_mm_unpin_all(void);
 
+bool __init xen_is_e820_reserved(phys_addr_t start, phys_addr_t size);
 unsigned long __ref xen_chk_extra_mem(unsigned long pfn);
 void __init xen_inv_extra_mem(void);
 void __init xen_remap_memory(void);
-- 
2.1.4
