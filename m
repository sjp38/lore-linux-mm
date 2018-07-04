Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07C4F6B026F
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 09:18:29 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b203-v6so2083144wme.2
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 06:18:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l1-v6si1660451wre.114.2018.07.04.06.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 06:18:27 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w64D9C6V045405
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 09:18:26 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0wb5mk99-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 09:18:26 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 14:18:24 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/3] of: ignore sub-page memory regions
Date: Wed,  4 Jul 2018 16:18:13 +0300
In-Reply-To: <1530710295-10774-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530710295-10774-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1530710295-10774-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ley Foon Tan <lftan@altera.com>
Cc: Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Michal Hocko <mhocko@kernel.org>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Memory region size is rounded down to page boundary and with sub-page
region it becomes 0 and there is no point to add an empty region.
Moreover, when the base is less than PAGE_SIZE we get a bogus size as
(base + size - 1) evaluates to -1.

The commit 8cccffc52694 ("of: check for size < 0 after rounding in
early_init_dt_add_memory_arch") introduced a test for wrap around for the
case when base is not page aligned, the same test can be used to ignore
sub-page region sizes.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
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
