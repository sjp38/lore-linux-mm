Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv2 3/3] powerpc/numa: make all possible node be instanced against NULL reference in node_zonelist()
Date: Thu, 20 Dec 2018 17:50:39 +0800
Message-Id: <1545299439-31370-4-git-send-email-kernelfans@gmail.com>
In-Reply-To: <1545299439-31370-1-git-send-email-kernelfans@gmail.com>
References: <1545299439-31370-1-git-send-email-kernelfans@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
List-ID: <linux-mm.kvack.org>

This patch tries to resolve a bug rooted at mm when using nr_cpus. It was
reported at [1]. The root cause is: device->numa_node info is used as
preferred_nid param for __alloc_pages_nodemask(), which causes NULL
reference when ac->zonelist = node_zonelist(preferred_nid, gfp_mask), due to
the preferred_nid is not online and not instanced. Hence the bug affects
all archs if a machine having a memory less numa-node, but a device on the
node is used and provide numa_node info to __alloc_pages_nodemask().
This patch makes all possible node online for ppc.

[1]: https://lore.kernel.org/patchwork/patch/1020838/

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: x86@kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
---
Note:
[1-2/3] implements one way to fix the bug, while this patch tries another way.
Hence using this patch when [1-2/3] is not acceptable.

 arch/powerpc/mm/numa.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index ce28ae5..31d81a4 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -864,10 +864,19 @@ void __init initmem_init(void)
 
 	memblock_dump_all();
 
-	for_each_online_node(nid) {
+	/* Instance all possible nodes to overcome potential NULL reference
+	 * issue on node_zonelist() when using nr_cpus
+	 */
+	for_each_node(nid) {
 		unsigned long start_pfn, end_pfn;
 
-		get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
+		if (node_online(nid))
+			get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
+		else {
+			start_pfn = end_pfn = 0;
+			/* online it, so later zonelists[] will be built */
+			node_set_online(nid);
+		}
 		setup_node_data(nid, start_pfn, end_pfn);
 		sparse_memory_present_with_active_regions(nid);
 	}
-- 
2.7.4
