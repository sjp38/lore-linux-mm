Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1339F83093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 12:43:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so98665643pfg.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 09:43:32 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id pj6si16219210pac.250.2016.08.25.09.43.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Aug 2016 09:43:31 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 RESEND] mm: silently skip readahead for DAX inodes
Date: Thu, 25 Aug 2016 10:42:32 -0600
Message-Id: <20160825164232.8989-1-ross.zwisler@linux.intel.com>
In-Reply-To: <20160824221429.21158-1-ross.zwisler@linux.intel.com>
References: <20160824221429.21158-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jan Kara <jack@suse.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Jeff Moyer <jmoyer@redhat.com>, stable@vger.kernel.org

For DAX inodes we need to be careful to never have page cache pages in the
mapping->page_tree.  This radix tree should be composed only of DAX
exceptional entries and zero pages.

ltp's readahead02 test was triggering a warning because we were trying to
insert a DAX exceptional entry but found that a page cache page had
already been inserted into the tree.  This page was being inserted into the
radix tree in response to a readahead(2) call.

Readahead doesn't make sense for DAX inodes, but we don't want it to report
a failure either.  Instead, we just return success and don't do any work.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reported-by: Jeff Moyer <jmoyer@redhat.com>
Cc: <stable@vger.kernel.org>    [4.5+]
---

Changes from v1:
 - Added a comment so readers don't have to go putzing around in the git
   tree to understand why we're doing what we're doing. :)  (akpm)
 - Resending, adding stable@vger.kernel.org.  Thank you, akpm, for the
   catch.

---
 mm/readahead.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/readahead.c b/mm/readahead.c
index 65ec288..c8a955b 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/dax.h>
 #include <linux/gfp.h>
 #include <linux/export.h>
 #include <linux/blkdev.h>
@@ -544,6 +545,14 @@ do_readahead(struct address_space *mapping, struct file *filp,
 	if (!mapping || !mapping->a_ops)
 		return -EINVAL;
 
+	/*
+	 * Readahead doesn't make sense for DAX inodes, but we don't want it
+	 * to report a failure either.  Instead, we just return success and
+	 * don't do any work.
+	 */
+	if (dax_mapping(mapping))
+		return 0;
+
 	return force_page_cache_readahead(mapping, filp, index, nr);
 }
 
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
