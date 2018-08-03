Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 486EB6B000A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 15:59:13 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d5-v6so2132609edq.3
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 12:59:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b40-v6si5262418edf.140.2018.08.03.12.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 12:59:11 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w73Jx6BE076469
	for <linux-mm@kvack.org>; Fri, 3 Aug 2018 15:59:09 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kmu30necd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Aug 2018 15:59:09 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 3 Aug 2018 20:59:06 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/7] of: ignore sub-page memory regions
Date: Fri,  3 Aug 2018 22:58:45 +0300
In-Reply-To: <1533326330-31677-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1533326330-31677-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1533326330-31677-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Kuo <rkuo@codeaurora.org>, Ley Foon Tan <lftan@altera.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@pku.edu.cn>, Michal Hocko <mhocko@kernel.org>, linux-hexagon@vger.kernel.org, nios2-dev@lists.rocketboards.org, linux-um@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Memory region size is rounded down to page boundary and with sub-page
region it becomes 0 and there is no point to add an empty region.
Moreover, when the base is less than PAGE_SIZE we get a bogus size as
(base + size - 1) evaluates to -1.

The commit 8cccffc52694 ("of: check for size < 0 after rounding in
early_init_dt_add_memory_arch") introduced a test for wrap around for the
case when base is not page aligned, the same test can be used to ignore
sub-page region sizes.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Reviewed-by: Rob Herring <robh@kernel.org>
---
 drivers/of/fdt.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
index 6da20b9..e866745 100644
--- a/drivers/of/fdt.c
+++ b/drivers/of/fdt.c
@@ -1134,12 +1134,13 @@ void __init __weak early_init_dt_add_memory_arch(u64 base, u64 size)
 {
 	const u64 phys_offset = MIN_MEMBLOCK_ADDR;
 
+	if (size < PAGE_SIZE - (base & ~PAGE_MASK)) {
+		pr_warn("Ignoring memory block 0x%llx - 0x%llx\n",
+			base, base + size);
+		return;
+	}
+
 	if (!PAGE_ALIGNED(base)) {
-		if (size < PAGE_SIZE - (base & ~PAGE_MASK)) {
-			pr_warn("Ignoring memory block 0x%llx - 0x%llx\n",
-				base, base + size);
-			return;
-		}
 		size -= PAGE_SIZE - (base & ~PAGE_MASK);
 		base = PAGE_ALIGN(base);
 	}
-- 
2.7.4
