Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Roman Penyaev <rpenyaev@suse.de>
Subject: [PATCH 3/3] mm/vmalloc: pass VM_USERMAP flags directly to __vmalloc_node_range()
Date: Thu,  3 Jan 2019 15:59:54 +0100
Message-Id: <20190103145954.16942-4-rpenyaev@suse.de>
In-Reply-To: <20190103145954.16942-1-rpenyaev@suse.de>
References: <20190103145954.16942-1-rpenyaev@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
Cc: Roman Penyaev <rpenyaev@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

vmalloc_user*() calls differ from normal vmalloc() only in that they
set VM_USERMAP flags for the area.  During the whole history of
vmalloc.c changes now it is possible simply to pass VM_USERMAP flags
directly to __vmalloc_node_range() call instead of finding the area
(which obviously takes time) after the allocation.

Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joe Perches <joe@perches.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/vmalloc.c | 30 ++++++++----------------------
 1 file changed, 8 insertions(+), 22 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index dc6a62bca503..83fa4c642f5e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1865,18 +1865,10 @@ EXPORT_SYMBOL(vzalloc);
  */
 void *vmalloc_user(unsigned long size)
 {
-	struct vm_struct *area;
-	void *ret;
-
-	ret = __vmalloc_node(size, SHMLBA,
-			     GFP_KERNEL | __GFP_ZERO,
-			     PAGE_KERNEL, NUMA_NO_NODE,
-			     __builtin_return_address(0));
-	if (ret) {
-		area = find_vm_area(ret);
-		area->flags |= VM_USERMAP;
-	}
-	return ret;
+	return __vmalloc_node_range(size, SHMLBA,  VMALLOC_START, VMALLOC_END,
+				    GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL,
+				    VM_USERMAP, NUMA_NO_NODE,
+				    __builtin_return_address(0));
 }
 EXPORT_SYMBOL(vmalloc_user);
 
@@ -1970,16 +1962,10 @@ EXPORT_SYMBOL(vmalloc_32);
  */
 void *vmalloc_32_user(unsigned long size)
 {
-	struct vm_struct *area;
-	void *ret;
-
-	ret = __vmalloc_node(size, 1, GFP_VMALLOC32 | __GFP_ZERO, PAGE_KERNEL,
-			     NUMA_NO_NODE, __builtin_return_address(0));
-	if (ret) {
-		area = find_vm_area(ret);
-		area->flags |= VM_USERMAP;
-	}
-	return ret;
+	return __vmalloc_node_range(size, 1,  VMALLOC_START, VMALLOC_END,
+				    GFP_VMALLOC32 | __GFP_ZERO, PAGE_KERNEL,
+				    VM_USERMAP, NUMA_NO_NODE,
+				    __builtin_return_address(0));
 }
 EXPORT_SYMBOL(vmalloc_32_user);
 
-- 
2.19.1
