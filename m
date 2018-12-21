Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F252F8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 16:46:02 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id n17so6099707pfk.23
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:46:02 -0800 (PST)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id q14si22013778pgg.433.2018.12.21.13.46.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 13:46:01 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v3 PATCH 1/2] mm: swap: check if swap backing device is congested or not
Date: Sat, 22 Dec 2018 05:40:19 +0800
Message-Id: <1545428420-126557-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Swap readahead would read in a few pages regardless if the underlying
device is busy or not.  It may incur long waiting time if the device is
congested, and it may also exacerbate the congestion.

Use inode_read_congested() to check if the underlying device is busy or
not like what file page readahead does.  Get inode from swap_info_struct.
Although we can add inode information in swap_address_space
(address_space->host), it may lead some unexpected side effect, i.e.
it may break mapping_cap_account_dirty().  Using inode from
swap_info_struct seems simple and good enough.

Just does the check in vma_cluster_readahead() since
swap_vma_readahead() is just used for non-rotational device which
much less likely has congestion than traditional HDD.

Although swap slots may be consecutive on swap partition, it still may be
fragmented on swap file. This check would help to reduce excessive stall
for such case.

Cc: Huang Ying <ying.huang@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
v3: Move inode deference under swap device type check per Tim Chen
v2: Check the swap device type per Tim Chen

 mm/swap_state.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index fd2f21e..78d500e 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -538,11 +538,18 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	bool do_poll = true, page_allocated;
 	struct vm_area_struct *vma = vmf->vma;
 	unsigned long addr = vmf->address;
+	struct inode *inode = NULL;
 
 	mask = swapin_nr_pages(offset) - 1;
 	if (!mask)
 		goto skip;
 
+	if (si->flags & (SWP_BLKDEV | SWP_FS)) {
+		inode = si->swap_file->f_mapping->host;
+		if (inode_read_congested(inode))
+			goto skip;
+	}
+
 	do_poll = false;
 	/* Read a page_cluster sized and aligned cluster around offset. */
 	start_offset = offset & ~mask;
-- 
1.8.3.1
