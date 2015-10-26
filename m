Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id C5D506B0038
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 17:26:17 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so82541008igb.0
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 14:26:17 -0700 (PDT)
Received: from g2t4620.austin.hp.com (g2t4620.austin.hp.com. [15.73.212.81])
        by mx.google.com with ESMTPS id u75si26696617ioi.92.2015.10.26.14.26.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 14:26:17 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 UPDATE-2 3/3] ACPI/APEI/EINJ: Allow memory error injection to NVDIMM
Date: Mon, 26 Oct 2015 15:22:24 -0600
Message-Id: <1445894544-21382-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, tony.luck@intel.com, akpm@linux-foundation.org, dan.j.williams@intel.com, rjw@rjwysocki.net
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

In the case of memory error injection, einj_error_inject() checks
if a target address is regular RAM.  Update this check to add a call
to region_intersects_pmem() to verify if a target address range is
NVDIMM.  This allows injecting a memory error to both RAM and NVDIMM
for testing.

Also, the current RAM check, page_is_ram(), is replaced with
region_intersects_ram() so that it can verify a target address
range with the requested size.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
UPDATE:
 - Add a blank line before if-statement. (Borislav Petkov)
 - Check the param2 value before target memory type. (Tony Luck)
---
 drivers/acpi/apei/einj.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/apei/einj.c b/drivers/acpi/apei/einj.c
index 0431883..5d7c0b4 100644
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
+	size = (~param2) + 1;
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
