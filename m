From: Juergen Gross <jgross@suse.com>
Subject: [Patch V3 11/15] xen: check for initrd conflicting with
	e820 map
Date: Mon, 20 Apr 2015 07:23:36 +0200
Message-ID: <1429507420-18201-12-git-send-email-jgross@suse.com>
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

Check whether the initrd is placed at a location which is conflicting
with the target E820 map. If this is the case relocate it to a new
area unused up to now and compliant to the E820 map.

Signed-off-by: Juergen Gross <jgross@suse.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 arch/x86/xen/setup.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 3fca9c1..0d7f881 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -632,6 +632,36 @@ phys_addr_t __init xen_find_free_area(phys_addr_t size)
 }
 
 /*
+ * Like memcpy, but with physical addresses for dest and src.
+ */
+static void __init xen_phys_memcpy(phys_addr_t dest, phys_addr_t src,
+				   phys_addr_t n)
+{
+	phys_addr_t dest_off, src_off, dest_len, src_len, len;
+	void *from, *to;
+
+	while (n) {
+		dest_off = dest & ~PAGE_MASK;
+		src_off = src & ~PAGE_MASK;
+		dest_len = n;
+		if (dest_len > (NR_FIX_BTMAPS << PAGE_SHIFT) - dest_off)
+			dest_len = (NR_FIX_BTMAPS << PAGE_SHIFT) - dest_off;
+		src_len = n;
+		if (src_len > (NR_FIX_BTMAPS << PAGE_SHIFT) - src_off)
+			src_len = (NR_FIX_BTMAPS << PAGE_SHIFT) - src_off;
+		len = min(dest_len, src_len);
+		to = early_memremap(dest - dest_off, dest_len + dest_off);
+		from = early_memremap(src - src_off, src_len + src_off);
+		memcpy(to, from, len);
+		early_memunmap(to, dest_len + dest_off);
+		early_memunmap(from, src_len + src_off);
+		n -= len;
+		dest += len;
+		src += len;
+	}
+}
+
+/*
  * Reserve Xen mfn_list.
  * See comment above "struct start_info" in <xen/interface/xen.h>
  * We tried to make the the memblock_reserve more selective so
@@ -810,6 +840,27 @@ char * __init xen_memory_setup(void)
 
 	xen_reserve_xen_mfnlist();
 
+	/* Check for a conflict of the initrd with the target E820 map. */
+	if (xen_is_e820_reserved(boot_params.hdr.ramdisk_image,
+				 boot_params.hdr.ramdisk_size)) {
+		phys_addr_t new_area, start, size;
+
+		new_area = xen_find_free_area(boot_params.hdr.ramdisk_size);
+		if (!new_area) {
+			xen_raw_console_write("Can't find new memory area for initrd needed due to E820 map conflict\n");
+			BUG();
+		}
+
+		start = boot_params.hdr.ramdisk_image;
+		size = boot_params.hdr.ramdisk_size;
+		xen_phys_memcpy(new_area, start, size);
+		pr_info("initrd moved from [mem %#010llx-%#010llx] to [mem %#010llx-%#010llx]\n",
+			start, start + size, new_area, new_area + size);
+		memblock_free(start, size);
+		boot_params.hdr.ramdisk_image = new_area;
+		boot_params.ext_ramdisk_image = new_area >> 32;
+	}
+
 	/*
 	 * Set identity map on non-RAM pages and prepare remapping the
 	 * underlying RAM.
-- 
2.1.4
