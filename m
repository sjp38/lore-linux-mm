Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id D8BF8800CA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:55:49 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id l9so251966534oia.2
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:55:49 -0800 (PST)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id kh6si18984405obb.58.2016.01.05.10.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 10:55:49 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 15/17] x86/kexec: Remove walk_iomem_res() call with GART
Date: Tue,  5 Jan 2016 11:54:39 -0700
Message-Id: <1452020081-26534-15-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
References: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Young <dyoung@redhat.com>, Minfei Huang <mhuang@redhat.com>, x86@kernel.org, kexec@lists.infradead.org, Toshi Kani <toshi.kani@hpe.com>

There is no longer any driver inserting a "GART" region in the kernel
since 'commit 707d4eefbdb3 ("Revert "[PATCH] Insert GART region into
resource map"")' was made.

Remove the call to walk_iomem_res() with "GART", its callback function,
and GART-specific variables set by the callback.

Cc: Borislav Petkov <bp@alien8.de>
Cc: Dave Young <dyoung@redhat.com>
Cc: Minfei Huang <mhuang@redhat.com>
Cc: x86@kernel.org
Cc: kexec@lists.infradead.org
Link: http://lkml.kernel.org/r/<20160104110427.GA2965@dhcp-128-65.nay.redhat.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 arch/x86/kernel/crash.c |   37 +------------------------------------
 1 file changed, 1 insertion(+), 36 deletions(-)

diff --git a/arch/x86/kernel/crash.c b/arch/x86/kernel/crash.c
index 082373b..f5069e7 100644
--- a/arch/x86/kernel/crash.c
+++ b/arch/x86/kernel/crash.c
@@ -56,10 +56,9 @@ struct crash_elf_data {
 	struct kimage *image;
 	/*
 	 * Total number of ram ranges we have after various adjustments for
-	 * GART, crash reserved region etc.
+	 * crash reserved region, etc.
 	 */
 	unsigned int max_nr_ranges;
-	unsigned long gart_start, gart_end;
 
 	/* Pointer to elf header */
 	void *ehdr;
@@ -190,17 +189,6 @@ static int get_nr_ram_ranges_callback(u64 start, u64 end, void *arg)
 	return 0;
 }
 
-static int get_gart_ranges_callback(u64 start, u64 end, void *arg)
-{
-	struct crash_elf_data *ced = arg;
-
-	ced->gart_start = start;
-	ced->gart_end = end;
-
-	/* Not expecting more than 1 gart aperture */
-	return 1;
-}
-
 
 /* Gather all the required information to prepare elf headers for ram regions */
 static void fill_up_crash_elf_data(struct crash_elf_data *ced,
@@ -215,22 +203,6 @@ static void fill_up_crash_elf_data(struct crash_elf_data *ced,
 
 	ced->max_nr_ranges = nr_ranges;
 
-	/*
-	 * We don't create ELF headers for GART aperture as an attempt
-	 * to dump this memory in second kernel leads to hang/crash.
-	 * If gart aperture is present, one needs to exclude that region
-	 * and that could lead to need of extra phdr.
-	 */
-	walk_iomem_res("GART", IORESOURCE_MEM, 0, -1,
-				ced, get_gart_ranges_callback);
-
-	/*
-	 * If we have gart region, excluding that could potentially split
-	 * a memory range, resulting in extra header. Account for  that.
-	 */
-	if (ced->gart_end)
-		ced->max_nr_ranges++;
-
 	/* Exclusion of crash region could split memory ranges */
 	ced->max_nr_ranges++;
 
@@ -339,13 +311,6 @@ static int elf_header_exclude_ranges(struct crash_elf_data *ced,
 			return ret;
 	}
 
-	/* Exclude GART region */
-	if (ced->gart_end) {
-		ret = exclude_mem_range(cmem, ced->gart_start, ced->gart_end);
-		if (ret)
-			return ret;
-	}
-
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
