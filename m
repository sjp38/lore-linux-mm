Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7136B000A
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:30:26 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id uo6so199816088pac.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:30:26 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id ff7si41848899pab.184.2016.01.05.10.30.21
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 10:30:21 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v2 8/8] ext4: Support for PUD-sized transparent huge pages
Date: Tue,  5 Jan 2016 13:30:10 -0500
Message-Id: <1452018610-26090-9-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1452018610-26090-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1452018610-26090-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

ext4 needs to reserve enough space in the journal to allocate a PUD-sized
page.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/ext4/file.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 6615499..7f850d5 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -211,6 +211,10 @@ static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 			nblocks = ext4_chunk_trans_blocks(inode,
 						PMD_SIZE / PAGE_SIZE);
 			break;
+		case FAULT_FLAG_SIZE_PUD:
+			nblocks = ext4_chunk_trans_blocks(inode,
+						PUD_SIZE / PAGE_SIZE);
+			break;
 		default:
 			return VM_FAULT_FALLBACK;
 		}
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
