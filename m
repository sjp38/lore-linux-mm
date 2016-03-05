Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 101E56B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 19:46:49 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id x188so20205289pfb.2
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 16:46:49 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id s80si9161173pfi.55.2016.03.04.16.46.48
        for <linux-mm@kvack.org>;
        Fri, 04 Mar 2016 16:46:48 -0800 (PST)
Subject: [PATCH] nfit: Continue init even if ARS commands are unimplemented
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 04 Mar 2016 16:46:24 -0800
Message-ID: <20160305004624.12825.93210.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Haozhong Zhang <haozhong.zhang@intel.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, linux-kernel@vger.kernel.org, Vishal Verma <vishal.l.verma@intel.com>

From: Vishal Verma <vishal.l.verma@intel.com>

If firmware doesn't implement any of the ARS commands, take that to
mean that ARS is unsupported, and continue to initialize regions without
bad block lists. We cannot make the assumption that ARS commands will be
unconditionally supported on all NVDIMMs.

Reported-by: Haozhong Zhang <haozhong.zhang@intel.com>
Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
Acked-by: Xiao Guangrong <guangrong.xiao@linux.intel.com>
Tested-by: Haozhong Zhang <haozhong.zhang@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/acpi/nfit.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/nfit.c b/drivers/acpi/nfit.c
index fb53db187854..35947ac87644 100644
--- a/drivers/acpi/nfit.c
+++ b/drivers/acpi/nfit.c
@@ -1590,14 +1590,21 @@ static int acpi_nfit_find_poison(struct acpi_nfit_desc *acpi_desc,
 	start = ndr_desc->res->start;
 	len = ndr_desc->res->end - ndr_desc->res->start + 1;
 
+	/*
+	 * If ARS is unimplemented, unsupported, or if the 'Persistent Memory
+	 * Scrub' flag in extended status is not set, skip this but continue
+	 * initialization
+	 */
 	rc = ars_get_cap(nd_desc, ars_cap, start, len);
+	if (rc == -ENOTTY) {
+		dev_dbg(acpi_desc->dev,
+			"Address Range Scrub is not implemented, won't create an error list\n");
+		rc = 0;
+		goto out;
+	}
 	if (rc)
 		goto out;
 
-	/*
-	 * If ARS is unsupported, or if the 'Persistent Memory Scrub' flag in
-	 * extended status is not set, skip this but continue initialization
-	 */
 	if ((ars_cap->status & 0xffff) ||
 		!(ars_cap->status >> 16 & ND_ARS_PERSISTENT)) {
 		dev_warn(acpi_desc->dev,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
