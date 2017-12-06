Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFEC6B02E3
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:44:02 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a13so1517411pgt.0
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:44:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 62si471384ply.175.2017.12.05.16.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:42:15 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 62/73] dax: Convert dax_insert_pfn_mkwrite to XArray
Date: Tue,  5 Dec 2017 16:41:48 -0800
Message-Id: <20171206004159.3755-63-willy@infradead.org>
In-Reply-To: <20171206004159.3755-1-willy@infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 7bd94f1b61d0..619aff70583f 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1498,21 +1498,21 @@ static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
 	void *entry;
 	int vmf_ret, error;
 
-	xa_lock_irq(&mapping->pages);
+	xas_lock_irq(&xas);
 	entry = get_unlocked_mapping_entry(&xas);
 	/* Did we race with someone splitting entry or so? */
 	if (!entry ||
 	    (pe_size == PE_SIZE_PTE && !dax_is_pte_entry(entry)) ||
 	    (pe_size == PE_SIZE_PMD && !dax_is_pmd_entry(entry))) {
 		put_unlocked_mapping_entry(&xas, entry);
-		xa_unlock_irq(&mapping->pages);
+		xas_unlock_irq(&xas);
 		trace_dax_insert_pfn_mkwrite_no_entry(mapping->host, vmf,
 						      VM_FAULT_NOPAGE);
 		return VM_FAULT_NOPAGE;
 	}
-	radix_tree_tag_set(&mapping->pages, index, PAGECACHE_TAG_DIRTY);
+	xas_set_tag(&xas, PAGECACHE_TAG_DIRTY);
 	entry = lock_slot(&xas);
-	xa_unlock_irq(&mapping->pages);
+	xas_unlock_irq(&xas);
 	switch (pe_size) {
 	case PE_SIZE_PTE:
 		error = vm_insert_mixed_mkwrite(vmf->vma, vmf->address, pfn);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
