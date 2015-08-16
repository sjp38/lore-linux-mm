Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id BA9EF9003C8
	for <linux-mm@kvack.org>; Sun, 16 Aug 2015 16:49:42 -0400 (EDT)
Received: by qgj62 with SMTP id 62so82744542qgj.2
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 13:49:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 71si21829760qhx.123.2015.08.16.13.49.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Aug 2015 13:49:39 -0700 (PDT)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH V3 3/3] x86: use generic early mem copy
Date: Sun, 16 Aug 2015 16:49:28 -0400
Message-Id: <1439758168-29427-4-git-send-email-msalter@redhat.com>
In-Reply-To: <1439758168-29427-1-git-send-email-msalter@redhat.com>
References: <1439758168-29427-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Mark Salter <msalter@redhat.com>

The early_ioremap library now has a generic copy_from_early_mem()
function. Use the generic copy function for x86 relocate_initrd().

Signed-off-by: Mark Salter <msalter@redhat.com>
---
 arch/x86/kernel/setup.c | 22 +---------------------
 1 file changed, 1 insertion(+), 21 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 80f874b..21fa9a3 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -317,15 +317,12 @@ static u64 __init get_ramdisk_size(void)
 	return ramdisk_size;
 }
 
-#define MAX_MAP_CHUNK	(NR_FIX_BTMAPS << PAGE_SHIFT)
 static void __init relocate_initrd(void)
 {
 	/* Assume only end is not page aligned */
 	u64 ramdisk_image = get_ramdisk_image();
 	u64 ramdisk_size  = get_ramdisk_size();
 	u64 area_size     = PAGE_ALIGN(ramdisk_size);
-	unsigned long slop, clen, mapaddr;
-	char *p, *q;
 
 	/* We need to move the initrd down into directly mapped mem */
 	relocated_ramdisk = memblock_find_in_range(0, PFN_PHYS(max_pfn_mapped),
@@ -343,25 +340,8 @@ static void __init relocate_initrd(void)
 	printk(KERN_INFO "Allocated new RAMDISK: [mem %#010llx-%#010llx]\n",
 	       relocated_ramdisk, relocated_ramdisk + ramdisk_size - 1);
 
-	q = (char *)initrd_start;
-
-	/* Copy the initrd */
-	while (ramdisk_size) {
-		slop = ramdisk_image & ~PAGE_MASK;
-		clen = ramdisk_size;
-		if (clen > MAX_MAP_CHUNK-slop)
-			clen = MAX_MAP_CHUNK-slop;
-		mapaddr = ramdisk_image & PAGE_MASK;
-		p = early_memremap(mapaddr, clen+slop);
-		memcpy(q, p+slop, clen);
-		early_memunmap(p, clen+slop);
-		q += clen;
-		ramdisk_image += clen;
-		ramdisk_size  -= clen;
-	}
+	copy_from_early_mem((void *)initrd_start, ramdisk_image, ramdisk_size);
 
-	ramdisk_image = get_ramdisk_image();
-	ramdisk_size  = get_ramdisk_size();
 	printk(KERN_INFO "Move RAMDISK from [mem %#010llx-%#010llx] to"
 		" [mem %#010llx-%#010llx]\n",
 		ramdisk_image, ramdisk_image + ramdisk_size - 1,
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
