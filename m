From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 2/4] io-mapping: Always create a struct to hold
	metadata about the io-mapping
Date: Sat, 21 Jun 2014 16:53:54 +0100
Message-ID: <1403366036-10169-2-git-send-email-chris@chris-wilson.co.uk>
References: <20140619135944.20837E00A3@blue.fi.intel.com>
 <1403366036-10169-1-git-send-email-chris@chris-wilson.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <1403366036-10169-1-git-send-email-chris@chris-wilson.co.uk>
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

Currently, we only allocate a structure to hold metadata if we need to
allocate an ioremap for every access, such as on x86-32. However, it
would be useful to store basic information about the io-mapping, such as
its page protection, on all platforms.

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-mm@kvack.org
---
 include/linux/io-mapping.h | 52 ++++++++++++++++++++++++++++------------------
 1 file changed, 32 insertions(+), 20 deletions(-)

diff --git a/include/linux/io-mapping.h b/include/linux/io-mapping.h
index 657fab4efab3..e053011f50bb 100644
--- a/include/linux/io-mapping.h
+++ b/include/linux/io-mapping.h
@@ -31,16 +31,17 @@
  * See Documentation/io-mapping.txt
  */
 
-#ifdef CONFIG_HAVE_ATOMIC_IOMAP
-
-#include <asm/iomap.h>
-
 struct io_mapping {
 	resource_size_t base;
 	unsigned long size;
 	pgprot_t prot;
+	void __iomem *iomem;
 };
 
+
+#ifdef CONFIG_HAVE_ATOMIC_IOMAP
+
+#include <asm/iomap.h>
 /*
  * For small address space machines, mapping large objects
  * into the kernel virtual space isn't practical. Where
@@ -119,48 +120,59 @@ io_mapping_unmap(void __iomem *vaddr)
 #else
 
 #include <linux/uaccess.h>
-
-/* this struct isn't actually defined anywhere */
-struct io_mapping;
+#include <asm/pgtable_types.h>
 
 /* Create the io_mapping object*/
 static inline struct io_mapping *
 io_mapping_create_wc(resource_size_t base, unsigned long size)
 {
-	return (struct io_mapping __force *) ioremap_wc(base, size);
+	struct io_mapping *iomap;
+
+	iomap = kmalloc(sizeof(*iomap), GFP_KERNEL);
+	if (!iomap)
+		return NULL;
+
+	iomap->base = base;
+	iomap->size = size;
+	iomap->iomem = ioremap_wc(base, size);
+	iomap->prot = pgprot_writecombine(PAGE_KERNEL_IO);
+
+	return iomap;
 }
 
 static inline void
 io_mapping_free(struct io_mapping *mapping)
 {
-	iounmap((void __force __iomem *) mapping);
+	iounmap(mapping->iomem);
+	kfree(mapping);
 }
 
-/* Atomic map/unmap */
+/* Non-atomic map/unmap */
 static inline void __iomem *
-io_mapping_map_atomic_wc(struct io_mapping *mapping,
-			 unsigned long offset)
+io_mapping_map_wc(struct io_mapping *mapping, unsigned long offset)
 {
-	pagefault_disable();
-	return ((char __force __iomem *) mapping) + offset;
+	return mapping->iomem + offset;
 }
 
 static inline void
-io_mapping_unmap_atomic(void __iomem *vaddr)
+io_mapping_unmap(void __iomem *vaddr)
 {
-	pagefault_enable();
 }
 
-/* Non-atomic map/unmap */
+/* Atomic map/unmap */
 static inline void __iomem *
-io_mapping_map_wc(struct io_mapping *mapping, unsigned long offset)
+io_mapping_map_atomic_wc(struct io_mapping *mapping,
+			 unsigned long offset)
 {
-	return ((char __force __iomem *) mapping) + offset;
+	pagefault_disable();
+	return io_mapping_map_wc(mapping, offset);
 }
 
 static inline void
-io_mapping_unmap(void __iomem *vaddr)
+io_mapping_unmap_atomic(void __iomem *vaddr)
 {
+	io_mapping_unmap(vaddr);
+	pagefault_enable();
 }
 
 #endif /* HAVE_ATOMIC_IOMAP */
-- 
2.0.0
