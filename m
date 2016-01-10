Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id E715E828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 09:03:46 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id f206so183552189wmf.0
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 06:03:46 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id o82si14931186wmg.112.2016.01.10.06.03.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 06:03:46 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id u188so186205088wmu.1
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 06:03:45 -0800 (PST)
Message-ID: <569264BF.8010905@plexistor.com>
Date: Sun, 10 Jan 2016 16:03:43 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] dax: Only fault once on mmap write access
References: <569263BA.5060503@plexistor.com>
In-Reply-To: <569263BA.5060503@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>


In current code for any mmap-write access there are two page faults.
One that maps the pfn into the vma (vm_insert_mixed()), and a second
one that converts the read-only mapping to read-write (via pfn_mkwrite).

But since we already know that this is a write access we can map the
pfn read-write and save the extra fault.

Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 fs/dax.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index a86d3cc..3fee696 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -289,6 +289,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	sector_t sector = bh->b_blocknr << (inode->i_blkbits - 9);
 	unsigned long vaddr = (unsigned long)vmf->virtual_address;
 	void __pmem *addr;
+	pgprot_t prot = vma->vm_page_prot;
 	unsigned long pfn;
 	pgoff_t size;
 	int error;
@@ -321,7 +322,10 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 		wmb_pmem();
 	}
 
-	error = vm_insert_mixed(vma, vaddr, pfn);
+	if (vmf->flags & FAULT_FLAG_WRITE)
+		prot = pgprot_modify(prot, PAGE_SHARED);
+
+	error = vm_insert_mixed_prot(vma, vaddr, pfn, prot);
 
  out:
 	i_mmap_unlock_read(mapping);
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
