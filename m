Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA876B026F
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:56:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p2so35309996pfk.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:56:15 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m6si9351744pff.595.2017.10.10.07.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 07:56:14 -0700 (PDT)
Subject: [PATCH v8 09/14] xfs: wire up ->lease_direct()
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Oct 2017 07:49:48 -0700
Message-ID: <150764698865.16882.6963827339963112876.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, iommu@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>, Ross Zwisler <ross.zwisler@linux.intel.com>

A 'lease_direct' lease requires that the vma have a valid MAP_DIRECT
mapping established. For xfs we use the generic_map_direct_lease()
handler for ->lease_direct(). It establishes a new lease and then checks
if the MAP_DIRECT mapping has been broken. We want to be sure that the
process will receive notification that the MAP_DIRECT mapping is being
torn down so it knows why other code paths are throwing failures.

For example in the RDMA/ibverbs case we want ibv_reg_mr() to fail if the
MAP_DIRECT mapping is invalid or in the process of being invalidated.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/xfs/xfs_file.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 4bee027c9366..bc512a9a8df5 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1157,6 +1157,7 @@ static const struct vm_operations_struct xfs_file_vm_direct_ops = {
 
 	.open		= generic_map_direct_open,
 	.close		= generic_map_direct_close,
+	.lease_direct	= generic_map_direct_lease,
 };
 
 static const struct vm_operations_struct xfs_file_vm_ops = {
@@ -1209,8 +1210,8 @@ xfs_file_mmap_direct(
 	vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
 
 	/*
-	 * generic_map_direct_{open,close} expect ->vm_private_data is
-	 * set to the result of map_direct_register
+	 * generic_map_direct_{open,close,lease} expect
+	 * ->vm_private_data is set to the result of map_direct_register
 	 */
 	vma->vm_private_data = mds;
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
