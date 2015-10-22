Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id DCCBC6B0255
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 19:24:38 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so99417447pad.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 16:24:38 -0700 (PDT)
Received: from g1t6216.austin.hp.com (g1t6216.austin.hp.com. [15.73.96.123])
        by mx.google.com with ESMTPS id b1si24534224pat.193.2015.10.22.16.24.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 16:24:37 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 3/3] ACPI/APEI/EINJ: Allow memory error injection to NVDIMM
Date: Thu, 22 Oct 2015 17:20:44 -0600
Message-Id: <1445556044-30322-4-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1445556044-30322-1-git-send-email-toshi.kani@hpe.com>
References: <1445556044-30322-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, rjw@rjwysocki.net
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

In the case of memory error injection, einj_error_inject() checks
if a target address is regular RAM.  Change this check to allow
injecting a memory error to both RAM and NVDIMM so that memory
errors can be tested on NVDIMM as well.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 drivers/acpi/apei/einj.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/apei/einj.c b/drivers/acpi/apei/einj.c
index 0431883..696f45a 100644
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
+	if (((!page_is_ram(PFN_DOWN(base_addr))) &&
+	     (region_intersects_pmem(base_addr, size) != REGION_INTERSECTS)) ||
+	    ((param2 & PAGE_MASK) != PAGE_MASK))
 		return -EINVAL;
 
 inject:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
