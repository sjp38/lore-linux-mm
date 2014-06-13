From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 2/2] drm/i915: Use remap_pfn_range() to prefault
	all PTE in a single pass
Date: Fri, 13 Jun 2014 17:26:18 +0100
Message-ID: <1402676778-27174-2-git-send-email-chris@chris-wilson.co.uk>
References: <1402676778-27174-1-git-send-email-chris@chris-wilson.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <1402676778-27174-1-git-send-email-chris@chris-wilson.co.uk>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
To: intel-gfx@lists.freedesktop.org
Cc: linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On an Ivybridge i7-3720qm with 1600MHz DDR3, with 32 fences,
Upload rate for 2 linear surfaces:  8134MiB/s -> 8154MiB/s
Upload rate for 2 tiled surfaces:   8625MiB/s -> 8632MiB/s
Upload rate for 4 linear surfaces:  8127MiB/s -> 8134MiB/s
Upload rate for 4 tiled surfaces:   8602MiB/s -> 8629MiB/s
Upload rate for 8 linear surfaces:  8124MiB/s -> 8137MiB/s
Upload rate for 8 tiled surfaces:   8603MiB/s -> 8624MiB/s
Upload rate for 16 linear surfaces: 8123MiB/s -> 8128MiB/s
Upload rate for 16 tiled surfaces:  8606MiB/s -> 8618MiB/s
Upload rate for 32 linear surfaces: 8121MiB/s -> 8128MiB/s
Upload rate for 32 tiled surfaces:  8605MiB/s -> 8614MiB/s
Upload rate for 64 linear surfaces: 8121MiB/s -> 8127MiB/s
Upload rate for 64 tiled surfaces:  3017MiB/s -> 5127MiB/s

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Testcase: igt/gem_fence_upload/performance
Testcase: igt/gem_mmap_gtt
Reviewed-by: Brad Volkin <bradley.d.volkin@intel.com>
Cc: linux-mm@kvack.org
---
 drivers/gpu/drm/i915/i915_gem.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index c313cb2b641b..e6246634b419 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -1565,22 +1565,23 @@ int i915_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	pfn = dev_priv->gtt.mappable_base + i915_gem_obj_ggtt_offset(obj);
 	pfn >>= PAGE_SHIFT;
 
-	if (!obj->fault_mappable) {
-		int i;
+	ret = remap_pfn_range(vma, vma->vm_start,
+			      pfn, vma->vm_end - vma->vm_start,
+			      vma->vm_page_prot);
+	if (ret) {
+		/* After passing the sanity checks on remap_pfn_range(), we may
+		 * abort whilst updating the pagetables due to ENOMEM and leave
+		 * the tables in an inconsistent state. Reset them all now.
+		 * However, we do not want to undo the work of another thread
+		 * that beat us to prefaulting the PTEs.
+		 */
+		if (ret != -EBUSY)
+			zap_vma_ptes(vma, vma->vm_start, vma->vm_end - vma->vm_start);
+		goto unpin;
+	}
 
-		for (i = 0; i < obj->base.size >> PAGE_SHIFT; i++) {
-			ret = vm_insert_pfn(vma,
-					    (unsigned long)vma->vm_start + i * PAGE_SIZE,
-					    pfn + i);
-			if (ret)
-				break;
-		}
+	obj->fault_mappable = true;
 
-		obj->fault_mappable = true;
-	} else
-		ret = vm_insert_pfn(vma,
-				    (unsigned long)vmf->virtual_address,
-				    pfn + page_offset);
 unpin:
 	i915_gem_object_ggtt_unpin(obj);
 unlock:
-- 
2.0.0
