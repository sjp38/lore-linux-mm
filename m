Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 00A6482F65
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 14:57:56 -0400 (EDT)
Received: by pasz6 with SMTP id z6so125244955pas.2
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 11:57:55 -0700 (PDT)
Received: from g2t4620.austin.hp.com (g2t4620.austin.hp.com. [15.73.212.81])
        by mx.google.com with ESMTPS id ck5si31488491pbb.91.2015.10.23.11.57.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 11:57:53 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 3/3] ACPI/APEI/EINJ: Allow memory error injection to NVDIMM
Date: Fri, 23 Oct 2015 12:53:59 -0600
Message-Id: <1445626439-8424-4-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1445626439-8424-1-git-send-email-toshi.kani@hpe.com>
References: <1445626439-8424-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, rjw@rjwysocki.net
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
---
 drivers/acpi/apei/einj.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/apei/einj.c b/drivers/acpi/apei/einj.c
index 0431883..ab55bbe 100644
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
@@ -545,10 +545,14 @@ static int einj_error_inject(u32 type, u32 flags, u64 param1, u64 param2,
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
+	if (((region_intersects_ram(base_addr, size) != REGION_INTERSECTS) &&
+	     (region_intersects_pmem(base_addr, size) != REGION_INTERSECTS)) ||
+	    ((param2 & PAGE_MASK) != PAGE_MASK))
 		return -EINVAL;
 
 inject:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
