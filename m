Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id BEFAC9003C7
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 17:41:59 -0400 (EDT)
Received: by qkcs67 with SMTP id s67so8950091qkc.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 14:41:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 140si6180211qhx.55.2015.08.06.14.41.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 14:41:59 -0700 (PDT)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH V2 3/3] x86: use generic early mem copy
Date: Thu,  6 Aug 2015 17:41:39 -0400
Message-Id: <1438897299-2266-4-git-send-email-msalter@redhat.com>
In-Reply-To: <1438897299-2266-1-git-send-email-msalter@redhat.com>
References: <1438897299-2266-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Mark Salter <msalter@redhat.com>

The early_ioremap library now has a generic copy_from_early_mem()
function. Use the generic copy function for x86 relocate_initrd().

Signed-off-by: Mark Salter <msalter@redhat.com>
---
 arch/x86/kernel/setup.c | 21 +--------------------
 1 file changed, 1 insertion(+), 20 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 80f874b..b2a8446 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -324,8 +324,6 @@ static void __init relocate_initrd(void)
 	u64 ramdisk_image = get_ramdisk_image();
 	u64 ramdisk_size  = get_ramdisk_size();
 	u64 area_size     = PAGE_ALIGN(ramdisk_size);
-	unsigned long slop, clen, mapaddr;
-	char *p, *q;
 
 	/* We need to move the initrd down into directly mapped mem */
 	relocated_ramdisk = memblock_find_in_range(0, PFN_PHYS(max_pfn_mapped),
@@ -343,25 +341,8 @@ static void __init relocate_initrd(void)
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
