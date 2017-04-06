Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 167FB6B03AA
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 20:01:03 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g2so18965449pge.7
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 17:01:03 -0700 (PDT)
Received: from mail-pg0-x235.google.com (mail-pg0-x235.google.com. [2607:f8b0:400e:c05::235])
        by mx.google.com with ESMTPS id g19si21983042pfd.391.2017.04.05.17.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 17:01:02 -0700 (PDT)
Received: by mail-pg0-x235.google.com with SMTP id x125so18881528pgb.0
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 17:01:01 -0700 (PDT)
Date: Wed, 5 Apr 2017 17:00:59 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [RFC][PATCH] mm: Tighten x86 /dev/mem with zeroing
Message-ID: <20170406000059.GA136863@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tommi Rantala <tommi.t.rantala@nokia.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>

This changes the x86 exception for the low 1MB by reading back zeros for
RAM areas instead of blindly allowing them. (It may be possible for heap
to end up getting allocated in low 1MB RAM, and then read out, possibly
tripping hardened usercopy.)

Unfinished: this still needs mmap support.

Reported-by: Tommi Rantala <tommi.t.rantala@nokia.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
Tommi, can you check and see if this fixes what you're seeing? I want to
make sure this actually works first. (x86info uses seek/read not mmap.)
---

 arch/x86/mm/init.c | 41 +++++++++++++++++++--------
 drivers/char/mem.c | 82 ++++++++++++++++++++++++++++++++++--------------------
 2 files changed, 82 insertions(+), 41 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 22af912d66d2..889e7619a091 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -643,21 +643,40 @@ void __init init_mem_mapping(void)
  * devmem_is_allowed() checks to see if /dev/mem access to a certain address
  * is valid. The argument is a physical page number.
  *
- *
- * On x86, access has to be given to the first megabyte of ram because that area
- * contains BIOS code and data regions used by X and dosemu and similar apps.
- * Access has to be given to non-kernel-ram areas as well, these contain the PCI
- * mmio resources as well as potential bios/acpi data regions.
+ * On x86, access has to be given to the first megabyte of RAM because that
+ * area traditionally contains BIOS code and data regions used by X, dosemu,
+ * and similar apps. Since they map the entire memory range, the whole range
+ * must be allowed (for mapping), but any areas that would otherwise be
+ * disallowed are flagged as being "zero filled" instead of rejected.
+ * Access has to be given to non-kernel-ram areas as well, these contain the
+ * PCI mmio resources as well as potential bios/acpi data regions.
  */
 int devmem_is_allowed(unsigned long pagenr)
 {
-	if (pagenr < 256)
-		return 1;
-	if (iomem_is_exclusive(pagenr << PAGE_SHIFT))
+	if (page_is_ram(pagenr)) {
+		/*
+		 * For disallowed memory regions in the low 1MB range,
+		 * request that the page be shown as all zeros.
+		 */
+		if (pagenr < 256)
+			return 2;
+
+		return 0;
+	}
+
+	/*
+	 * This must follow RAM test, since System RAM is considered a
+	 * restricted resource under CONFIG_STRICT_IOMEM.
+	 */
+	if (iomem_is_exclusive(pagenr << PAGE_SHIFT)) {
+		/* Low 1MB bypasses iomem restrictions. */
+		if (pagenr < 256)
+			return 1;
+
 		return 0;
-	if (!page_is_ram(pagenr))
-		return 1;
-	return 0;
+	}
+
+	return 1;
 }
 
 void free_init_pages(char *what, unsigned long begin, unsigned long end)
diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 6d9cc2d39d22..7e4a9d1296bb 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -60,6 +60,10 @@ static inline int valid_mmap_phys_addr_range(unsigned long pfn, size_t size)
 #endif
 
 #ifdef CONFIG_STRICT_DEVMEM
+static inline int page_is_allowed(unsigned long pfn)
+{
+	return devmem_is_allowed(pfn);
+}
 static inline int range_is_allowed(unsigned long pfn, unsigned long size)
 {
 	u64 from = ((u64)pfn) << PAGE_SHIFT;
@@ -75,6 +79,10 @@ static inline int range_is_allowed(unsigned long pfn, unsigned long size)
 	return 1;
 }
 #else
+static inline int page_is_allowed(unsigned long pfn)
+{
+	return 1;
+}
 static inline int range_is_allowed(unsigned long pfn, unsigned long size)
 {
 	return 1;
@@ -122,23 +130,31 @@ static ssize_t read_mem(struct file *file, char __user *buf,
 
 	while (count > 0) {
 		unsigned long remaining;
+		int allowed;
 
 		sz = size_inside_page(p, count);
 
-		if (!range_is_allowed(p >> PAGE_SHIFT, count))
+		allowed = page_is_allowed(p >> PAGE_SHIFT);
+		if (!allowed)
 			return -EPERM;
+		if (allowed == 2) {
+			/* Show zeros for restricted memory. */
+			remaining = clear_user(buf, sz);
+		} else {
+			/*
+			 * On ia64 if a page has been mapped somewhere as
+			 * uncached, then it must also be accessed uncached
+			 * by the kernel or data corruption may occur.
+			 */
+			ptr = xlate_dev_mem_ptr(p);
+			if (!ptr)
+				return -EFAULT;
 
-		/*
-		 * On ia64 if a page has been mapped somewhere as uncached, then
-		 * it must also be accessed uncached by the kernel or data
-		 * corruption may occur.
-		 */
-		ptr = xlate_dev_mem_ptr(p);
-		if (!ptr)
-			return -EFAULT;
+			remaining = copy_to_user(buf, ptr, sz);
+
+			unxlate_dev_mem_ptr(p, ptr);
+		}
 
-		remaining = copy_to_user(buf, ptr, sz);
-		unxlate_dev_mem_ptr(p, ptr);
 		if (remaining)
 			return -EFAULT;
 
@@ -181,30 +197,36 @@ static ssize_t write_mem(struct file *file, const char __user *buf,
 #endif
 
 	while (count > 0) {
+		int allowed;
+
 		sz = size_inside_page(p, count);
 
-		if (!range_is_allowed(p >> PAGE_SHIFT, sz))
+		allowed = page_is_allowed(p >> PAGE_SHIFT);
+		if (!allowed)
 			return -EPERM;
 
-		/*
-		 * On ia64 if a page has been mapped somewhere as uncached, then
-		 * it must also be accessed uncached by the kernel or data
-		 * corruption may occur.
-		 */
-		ptr = xlate_dev_mem_ptr(p);
-		if (!ptr) {
-			if (written)
-				break;
-			return -EFAULT;
-		}
+		/* Skip actual writing when a page is marked as restricted. */
+		if (allowed == 1) {
+			/*
+			 * On ia64 if a page has been mapped somewhere as
+			 * uncached, then it must also be accessed uncached
+			 * by the kernel or data corruption may occur.
+			 */
+			ptr = xlate_dev_mem_ptr(p);
+			if (!ptr) {
+				if (written)
+					break;
+				return -EFAULT;
+			}
 
-		copied = copy_from_user(ptr, buf, sz);
-		unxlate_dev_mem_ptr(p, ptr);
-		if (copied) {
-			written += sz - copied;
-			if (written)
-				break;
-			return -EFAULT;
+			copied = copy_from_user(ptr, buf, sz);
+			unxlate_dev_mem_ptr(p, ptr);
+			if (copied) {
+				written += sz - copied;
+				if (written)
+					break;
+				return -EFAULT;
+			}
 		}
 
 		buf += sz;
-- 
2.7.4


-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
