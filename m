From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 17/17] ACPI/EINJ: Allow memory error injection to NVDIMM
Date: Tue, 26 Jan 2016 21:57:33 +0100
Message-ID: <1453841853-11383-18-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp@alien8.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jarkko Nikula <jarkko.nikula@linux.intel.com>, Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Vishal Verma <vishal.l.verma@intel.com>
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

In the case of memory error injection, einj_error_inject() checks if
a target address is System RAM. Change this check to allow injecting
a memory error into NVDIMM memory by calling region_intersects() with
IORES_DESC_PERSISTENT_MEMORY. This enables memory error testing on both
System RAM and NVDIMM.

In addition, page_is_ram() is replaced with region_intersects() with
IORESOURCE_SYSTEM_RAM, so that it can verify a target address range with
the requested size.

Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Acked-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jarkko Nikula <jarkko.nikula@linux.intel.com>
Cc: Len Brown <lenb@kernel.org>
Cc: linux-acpi@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Link: http://lkml.kernel.org/r/1452020081-26534-17-git-send-email-toshi.kani@hpe.com
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 drivers/acpi/apei/einj.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/apei/einj.c b/drivers/acpi/apei/einj.c
index 0431883653be..559c1173de1c 100644
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
+	    ((region_intersects(base_addr, size, IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE)
+				!= REGION_INTERSECTS) &&
+	     (region_intersects(base_addr, size, IORESOURCE_MEM, IORES_DESC_PERSISTENT_MEMORY)
+				!= REGION_INTERSECTS)))
 		return -EINVAL;
 
 inject:
-- 
2.3.5
