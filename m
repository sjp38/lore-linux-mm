Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF7F6B0256
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:38:36 -0500 (EST)
Received: by obbww6 with SMTP id ww6so24381310obb.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:38:36 -0800 (PST)
Received: from g4t3428.houston.hp.com (g4t3428.houston.hp.com. [15.201.208.56])
        by mx.google.com with ESMTPS id g76si12958173oib.27.2015.11.24.13.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:38:32 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 3/3] ACPI/APEI/EINJ: Allow memory error injection to NVDIMM
Date: Tue, 24 Nov 2015 15:33:38 -0700
Message-Id: <1448404418-28800-4-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
References: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rjw@rjwysocki.net, dan.j.williams@intel.com
Cc: tony.luck@intel.com, bp@alien8.de, vishal.l.verma@intel.com, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

In the case of memory error injection, einj_error_inject() checks
if a target address is regular RAM.  Update this check to add a call
to region_intersects_pmem() to verify if a target address range is
NVDIMM.  This allows injecting a memory error to both RAM and NVDIMM
for testing.

In addition, the current RAM check, page_is_ram(), is replaced with
region_intersects_ram() so that it can verify a target address range
with the requested size.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Acked-by: Tony Luck <tony.luck@intel.com>
Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Vishal Verma <vishal.l.verma@intel.com>
---
 drivers/acpi/apei/einj.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/apei/einj.c b/drivers/acpi/apei/einj.c
index 0431883..52792d2 100644
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
@@ -545,10 +545,15 @@ static int einj_error_inject(u32 type, u32 flags, u64 param1, u64 param2,
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
+	    ((region_intersects_ram(base_addr, size) != REGION_INTERSECTS) &&
+	     (region_intersects_pmem(base_addr, size) != REGION_INTERSECTS)))
 		return -EINVAL;
 
 inject:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
