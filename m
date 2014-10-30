From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 05/10] uprobes: share the i_mmap_rwsem
Date: Thu, 30 Oct 2014 12:34:12 -0700
Message-ID: <1414697657-1678-6-git-send-email-dave@stgolabs.net>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>
List-Id: linux-mm.kvack.org

Both register and unregister call build_map_info() in order
to create the list of mappings before installing or removing
breakpoints for every mm which maps file backed memory. As
such, there is no reason to hold the i_mmap_rwsem exclusively,
so share it and allow concurrent readers to build the mapping
data.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Acked-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@intel.linux.com>
---
 kernel/events/uprobes.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index e1bb60d..6158a64b 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -724,7 +724,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 	int more = 0;
 
  again:
-	i_mmap_lock_write(mapping);
+	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		if (!valid_vma(vma, is_register))
 			continue;
@@ -755,7 +755,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 		info->mm = vma->vm_mm;
 		info->vaddr = offset_to_vaddr(vma, offset);
 	}
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 
 	if (!more)
 		goto out;
-- 
1.8.4.5
