Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 31D4E6B0296
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:37:04 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r25so2788398pgn.23
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:37:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y2si1263049pgo.89.2017.11.01.08.37.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 08:37:03 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 06/18] dax: Create local variable for vmf->flags & FAULT_FLAG_WRITE test
Date: Wed,  1 Nov 2017 16:36:35 +0100
Message-Id: <20171101153648.30166-7-jack@suse.cz>
In-Reply-To: <20171101153648.30166-1-jack@suse.cz>
References: <20171101153648.30166-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>

There are already two users and more are coming.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index c09465884bbe..5ea71381dba0 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1116,6 +1116,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 	struct iomap iomap = { 0 };
 	unsigned flags = IOMAP_FAULT;
 	int error, major = 0;
+	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	int vmf_ret = 0;
 	void *entry;
 
@@ -1130,7 +1131,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 		goto out;
 	}
 
-	if ((vmf->flags & FAULT_FLAG_WRITE) && !vmf->cow_page)
+	if (write && !vmf->cow_page)
 		flags |= IOMAP_WRITE;
 
 	entry = grab_mapping_entry(mapping, vmf->pgoff, 0);
@@ -1207,7 +1208,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 		break;
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
-		if (!(vmf->flags & FAULT_FLAG_WRITE)) {
+		if (!write) {
 			vmf_ret = dax_load_hole(mapping, entry, vmf);
 			goto finish_iomap;
 		}
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
