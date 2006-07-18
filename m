Date: Tue, 18 Jul 2006 19:08:12 +0100 (IST)
From: Dave Airlie <airlied@linux.ie>
Subject: [PATCH] vm/agp: remove private page protection map
Message-ID: <Pine.LNX.4.64.0607181905140.26533@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: davej@codemonkey.org.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

AGP keeps its own copy of the protection_map, upcoming DRM changes
will also require access to this map from modules.

Signed-off-by: Dave Airlie <airlied@linux.ie>
---
  drivers/char/agp/frontend.c |    8 +-------
  include/linux/mm.h          |    1 +
  mm/mmap.c                   |    6 ++++++
  3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/char/agp/frontend.c b/drivers/char/agp/frontend.c
index d9c5a91..1842427 100644
--- a/drivers/char/agp/frontend.c
+++ b/drivers/char/agp/frontend.c
@@ -157,12 +157,6 @@ static void agp_add_seg_to_client(struct
   * some routine which does the conversion for you
   */

-static const pgprot_t my_protect_map[16] =
-{
-	__P000, __P001, __P010, __P011, __P100, __P101, __P110, __P111,
-	__S000, __S001, __S010, __S011, __S100, __S101, __S110, __S111
-};
-
  static pgprot_t agp_convert_mmap_flags(int prot)
  {
  #define _trans(x,bit1,bit2) \
@@ -177,7 +171,7 @@ ((bit1==bit2)?(x&bit1):(x&bit1)?bit2:0)

  	prot_bits |= VM_SHARED;

-	temp = my_protect_map[prot_bits & 0x0000000f];
+	temp = vm_get_page_prot(prot_bits & 0x0000000f);

  	return temp;
  }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 990957e..52d6193 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1012,6 +1012,7 @@ static inline unsigned long vma_pages(st
  	return (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
  }

+pgprot_t vm_get_page_prot(u8 vm_flags);
  struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
  struct page *vmalloc_to_page(void *addr);
  unsigned long vmalloc_to_pfn(void *addr);
diff --git a/mm/mmap.c b/mm/mmap.c
index c1868ec..d4c9b2a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -60,6 +60,12 @@ pgprot_t protection_map[16] = {
  	__S000, __S001, __S010, __S011, __S100, __S101, __S110, __S111
  };

+pgprot_t vm_get_page_prot(u8 vm_flags)
+{
+	return protection_map[vm_flags];
+}
+EXPORT_SYMBOL(vm_get_page_prot);
+
  int sysctl_overcommit_memory = OVERCOMMIT_GUESS;  /* heuristic overcommit */
  int sysctl_overcommit_ratio = 50;	/* default is 50% */
  int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
-- 
1.4.1.ga3e6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
