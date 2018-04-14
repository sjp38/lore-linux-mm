Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5286B0031
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 10:13:34 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id h12-v6so7536708pls.23
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 07:13:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 2-v6si8130210pld.596.2018.04.14.07.13.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 07:13:33 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v11 59/63] dax: Return fault code from dax_load_hole
Date: Sat, 14 Apr 2018 07:13:12 -0700
Message-Id: <20180414141316.7167-60-willy@infradead.org>
In-Reply-To: <20180414141316.7167-1-willy@infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

dax_load_hole was swallowing the errors from vm_insert_mixed().
Use vmf_insert_mixed() instead to get a vm_fault_t, and convert
dax_load_hole() to the vm_fault_t convention.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index bcc3fd05ab03..44785346c02f 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -808,18 +808,19 @@ static int dax_iomap_pfn(struct iomap *iomap, loff_t pos, size_t size,
  * If this page is ever written to we will re-fault and change the mapping to
  * point to real DAX storage instead.
  */
-static int dax_load_hole(struct xa_state *xas, struct address_space *mapping,
-		void **entry, struct vm_fault *vmf)
+static vm_fault_t dax_load_hole(struct xa_state *xas,
+		struct address_space *mapping, void **entry,
+		struct vm_fault *vmf)
 {
 	struct inode *inode = mapping->host;
 	unsigned long vaddr = vmf->address;
-	int ret = VM_FAULT_NOPAGE;
+	vm_fault_t ret;
 	pfn_t pfn = pfn_to_pfn_t(my_zero_pfn(vaddr));
 
 	*entry = dax_insert_entry(xas, mapping, *entry, pfn, DAX_ZERO_PAGE,
 			false);
 
-	vm_insert_mixed(vmf->vma, vaddr, pfn);
+	ret = vmf_insert_mixed(vmf->vma, vaddr, pfn);
 	trace_dax_load_hole(inode, vmf, ret);
 	return ret;
 }
-- 
2.17.0
