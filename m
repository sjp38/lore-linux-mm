Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 968756B0007
	for <linux-mm@kvack.org>; Mon, 21 May 2018 11:20:53 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id a14-v6so10207879plt.7
        for <linux-mm@kvack.org>; Mon, 21 May 2018 08:20:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q26-v6sor5348421pfh.87.2018.05.21.08.20.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 08:20:52 -0700 (PDT)
From: Huaisheng Ye <yehs2007@gmail.com>
Subject: [RFC PATCH v2 02/12] arch/x86/kernel/amd_gart_64: update usage of address zone modifiers
Date: Mon, 21 May 2018 23:20:23 +0800
Message-Id: <1526916033-4877-3-git-send-email-yehs2007@gmail.com>
In-Reply-To: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Robin Murphy <robin.murphy@arm.com>

From: Huaisheng Ye <yehs1@lenovo.com>

Use __GFP_ZONE_MASK to replace (__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32).

___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP
bitmasks, the bottom three bits of GFP mask is reserved for storing
encoded zone number.
__GFP_DMA, __GFP_HIGHMEM and __GFP_DMA32 should not be operated by OR.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Robin Murphy <robin.murphy@arm.com>
---
 arch/x86/kernel/amd_gart_64.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/amd_gart_64.c b/arch/x86/kernel/amd_gart_64.c
index ecd486c..1dd6971 100644
--- a/arch/x86/kernel/amd_gart_64.c
+++ b/arch/x86/kernel/amd_gart_64.c
@@ -485,7 +485,7 @@ static int gart_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 	struct page *page;
 
 	if (force_iommu && !(flag & GFP_DMA)) {
-		flag &= ~(__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32);
+		flag &= ~__GFP_ZONE_MASK;
 		page = alloc_pages(flag | __GFP_ZERO, get_order(size));
 		if (!page)
 			return NULL;
-- 
1.8.3.1
