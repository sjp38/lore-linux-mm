Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 49573800CA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:55:54 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id wp13so146465225obc.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:55:54 -0800 (PST)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id l126si19174785oib.103.2016.01.05.10.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 10:55:53 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 17/17] ACPI/EINJ: Allow memory error injection to NVDIMM
Date: Tue,  5 Jan 2016 11:54:41 -0700
Message-Id: <1452020081-26534-17-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
References: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

In the case of memory error injection, einj_error_inject() checks
if a target address is System RAM.  Change this check to allow
injecting a memory error to NVDIMM by calling region_intersects()
with IORES_DESC_PERSISTENT_MEMORY.  This enables memory error
testing on both System RAM and NVDIMM.

In addition, page_is_ram() is replaced with region_intersects()
with IORESOURCE_SYSTEM_RAM, so that it can verify a target address
range with the requested size.

Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@lists.01.org
Cc: linux-acpi@vger.kernel.org
Acked-by: Tony Luck <tony.luck@intel.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 drivers/acpi/apei/einj.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/apei/einj.c b/drivers/acpi/apei/einj.c
index 0431883..16cae66 100644
--- a/drivers/acpi/apei/einj.c
+++ b/drivers/acpi/apei/einj.c
@@ -519,7 +519,7 @@ static int einj_error_inject(u32 type, u32 flags, u64 param1, u64 param2,
 			     u64 param3, u64 param4)
 {
 	int rc;
-	unsigned long pfn;
+	u64 base_addr, size;
 
 	/* If user manually set "flags", make sure it is legal */
 	if (flags && (flags &
@@ -545,10 +545,17 @@ static int einj_error_inject(u32 type, u32 flags, u64 param1, u64 param2,
 	/*
 	 * Disallow crazy address masks that give BIOS leeway to pick
 	 * injection address almost anywhere. Insist on page or
-	 * better granularity and that target address is normal RAM.
+	 * better granularity and that target address is normal RAM or
+	 * NVDIMM.
 	 */
-	pfn = PFN_DOWN(param1 & param2);
-	if (!page_is_ram(pfn) || ((param2 & PAGE_MASK) != PAGE_MASK))
+	base_addr = param1 & param2;
+	size = ~param2 + 1;
+
+	if (((param2 & PAGE_MASK) != PAGE_MASK) ||
+	    ((region_intersects(base_addr, size, IORESOURCE_SYSTEM_RAM,
+			IORES_DESC_NONE) != REGION_INTERSECTS) &&
+	     (region_intersects(base_addr, size, IORESOURCE_MEM,
+			IORES_DESC_PERSISTENT_MEMORY) != REGION_INTERSECTS)))
 		return -EINVAL;
 
 inject:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
