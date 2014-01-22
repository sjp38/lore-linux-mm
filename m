Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E99B96B003B
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 06:32:17 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so255362pdj.18
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 03:32:17 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id nf8si2487274pbc.240.2014.01.22.03.31.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 03:32:16 -0800 (PST)
From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 2/3] ARM: kexec: copying code to ioremapped area
Date: Wed, 22 Jan 2014 19:25:15 +0800
Message-ID: <1390389916-8711-3-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1390389916-8711-1-git-send-email-wangnan0@huawei.com>
References: <1390389916-8711-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kexec@lists.infradead.org
Cc: Eric Biederman <ebiederm@xmission.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Geng Hui <hui.geng@huawei.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wang Nan <wangnan0@huawei.com>, stable@vger.kernel.org

ARM's kdump is actually corrupted (at least for omap4460), mainly because of
cache problem: flush_icache_range can't reliably ensure the copied data
correctly goes into RAM. After mmu turned off and jump to the trampoline, kexec
always failed due to random undef instructions.

This patch use ioremap to make sure the destnation of all memcpy() is
uncachable memory, including copying of target kernel and trampoline.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: <stable@vger.kernel.org> # 3.4+
Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Geng Hui <hui.geng@huawei.com>
---
 arch/arm/kernel/machine_kexec.c | 18 ++++++++++++++++--
 kernel/kexec.c                  | 40 +++++++++++++++++++++++++++++++++++-----
 2 files changed, 51 insertions(+), 7 deletions(-)

diff --git a/arch/arm/kernel/machine_kexec.c b/arch/arm/kernel/machine_kexec.c
index f0d180d..ba0a5a8 100644
--- a/arch/arm/kernel/machine_kexec.c
+++ b/arch/arm/kernel/machine_kexec.c
@@ -144,6 +144,7 @@ void machine_kexec(struct kimage *image)
 	unsigned long page_list;
 	unsigned long reboot_code_buffer_phys;
 	unsigned long reboot_entry = (unsigned long)relocate_new_kernel;
+	void __iomem *reboot_entry_remap;
 	unsigned long reboot_entry_phys;
 	void *reboot_code_buffer;
 
@@ -171,9 +172,22 @@ void machine_kexec(struct kimage *image)
 
 
 	/* copy our kernel relocation code to the control code page */
-	reboot_entry = fncpy(reboot_code_buffer,
-			     reboot_entry,
+	reboot_entry_remap = ioremap_nocache(reboot_code_buffer_phys,
+					     relocate_new_kernel_size);
+	if (reboot_entry_remap == NULL) {
+		pr_warn("startup code may not be reliably flushed\n");
+		reboot_entry_remap = (void __iomem *)reboot_code_buffer;
+	}
+
+	reboot_entry = fncpy(reboot_entry_remap, reboot_entry,
 			     relocate_new_kernel_size);
+	reboot_entry = (unsigned long)reboot_code_buffer +
+			(reboot_entry -
+			 (unsigned long)reboot_entry_remap);
+
+	if (reboot_entry_remap != reboot_code_buffer)
+		iounmap(reboot_entry_remap);
+
 	reboot_entry_phys = (unsigned long)reboot_entry +
 		(reboot_code_buffer_phys - (unsigned long)reboot_code_buffer);
 
diff --git a/kernel/kexec.c b/kernel/kexec.c
index 9c97016..3e92999 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -806,6 +806,7 @@ static int kimage_load_normal_segment(struct kimage *image,
 	while (mbytes) {
 		struct page *page;
 		char *ptr;
+		void __iomem *ioptr;
 		size_t uchunk, mchunk;
 
 		page = kimage_alloc_page(image, GFP_HIGHUSER, maddr);
@@ -818,7 +819,17 @@ static int kimage_load_normal_segment(struct kimage *image,
 		if (result < 0)
 			goto out;
 
-		ptr = kmap(page);
+		/*
+		 * Try ioremap to make sure the copied data goes into RAM
+		 * reliably. If failed (some archs don't allow ioremap RAM),
+		 * use kmap instead.
+		 */
+		ioptr = ioremap(page_to_pfn(page) << PAGE_SHIFT,
+				PAGE_SIZE);
+		if (ioptr != NULL)
+			ptr = ioptr;
+		else
+			ptr = kmap(page);
 		/* Start with a clear page */
 		clear_page(ptr);
 		ptr += maddr & ~PAGE_MASK;
@@ -827,7 +838,10 @@ static int kimage_load_normal_segment(struct kimage *image,
 		uchunk = min(ubytes, mchunk);
 
 		result = copy_from_user(ptr, buf, uchunk);
-		kunmap(page);
+		if (ioptr != NULL)
+			iounmap(ioptr);
+		else
+			kunmap(page);
 		if (result) {
 			result = -EFAULT;
 			goto out;
@@ -846,7 +860,7 @@ static int kimage_load_crash_segment(struct kimage *image,
 {
 	/* For crash dumps kernels we simply copy the data from
 	 * user space to it's destination.
-	 * We do things a page at a time for the sake of kmap.
+	 * We do things a page at a time for the sake of ioremap/kmap.
 	 */
 	unsigned long maddr;
 	size_t ubytes, mbytes;
@@ -861,6 +875,7 @@ static int kimage_load_crash_segment(struct kimage *image,
 	while (mbytes) {
 		struct page *page;
 		char *ptr;
+		void __iomem *ioptr;
 		size_t uchunk, mchunk;
 
 		page = pfn_to_page(maddr >> PAGE_SHIFT);
@@ -868,7 +883,18 @@ static int kimage_load_crash_segment(struct kimage *image,
 			result  = -ENOMEM;
 			goto out;
 		}
-		ptr = kmap(page);
+		/*
+		 * Try ioremap to make sure the copied data goes into RAM
+		 * reliably. If failed (some archs don't allow ioremap RAM),
+		 * use kmap instead.
+		 */
+		ioptr = ioremap_nocache(page_to_pfn(page) << PAGE_SHIFT,
+				        PAGE_SIZE);
+		if (ioptr != NULL)
+			ptr = ioptr;
+		else
+			ptr = kmap(page);
+
 		ptr += maddr & ~PAGE_MASK;
 		mchunk = min_t(size_t, mbytes,
 				PAGE_SIZE - (maddr & ~PAGE_MASK));
@@ -879,7 +905,11 @@ static int kimage_load_crash_segment(struct kimage *image,
 		}
 		result = copy_from_user(ptr, buf, uchunk);
 		kexec_flush_icache_page(page);
-		kunmap(page);
+		if (ioptr != NULL)
+			iounmap(ioptr);
+		else
+			kunmap(page);
+
 		if (result) {
 			result = -EFAULT;
 			goto out;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
