From: Juergen Gross <jgross@suse.com>
Subject: [Patch V3 03/15] xen: don't build mfn tree if tools
	don't need it
Date: Mon, 20 Apr 2015 07:23:28 +0200
Message-ID: <1429507420-18201-4-git-send-email-jgross@suse.com>
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

In case the Xen tools indicate they don't need the p2m 3 level tree
as they support the virtual mapped linear p2m list, just omit building
the tree.

Signed-off-by: Juergen Gross <jgross@suse.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 arch/x86/xen/p2m.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
index 703f803..6f80cd3 100644
--- a/arch/x86/xen/p2m.c
+++ b/arch/x86/xen/p2m.c
@@ -198,7 +198,8 @@ void __ref xen_build_mfn_list_list(void)
 	unsigned int level, topidx, mididx;
 	unsigned long *mid_mfn_p;
 
-	if (xen_feature(XENFEAT_auto_translated_physmap))
+	if (xen_feature(XENFEAT_auto_translated_physmap) ||
+	    xen_start_info->flags & SIF_VIRT_P2M_4TOOLS)
 		return;
 
 	/* Pre-initialize p2m_top_mfn to be completely missing */
@@ -259,8 +260,11 @@ void xen_setup_mfn_list_list(void)
 
 	BUG_ON(HYPERVISOR_shared_info == &xen_dummy_shared_info);
 
-	HYPERVISOR_shared_info->arch.pfn_to_mfn_frame_list_list =
-		virt_to_mfn(p2m_top_mfn);
+	if (xen_start_info->flags & SIF_VIRT_P2M_4TOOLS)
+		HYPERVISOR_shared_info->arch.pfn_to_mfn_frame_list_list = ~0UL;
+	else
+		HYPERVISOR_shared_info->arch.pfn_to_mfn_frame_list_list =
+			virt_to_mfn(p2m_top_mfn);
 	HYPERVISOR_shared_info->arch.max_pfn = xen_max_p2m_pfn;
 	HYPERVISOR_shared_info->arch.p2m_generation = 0;
 	HYPERVISOR_shared_info->arch.p2m_vaddr = (unsigned long)xen_p2m_addr;
-- 
2.1.4
