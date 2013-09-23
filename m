Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1ABB36B003B
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:06:16 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so3173742pdi.28
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 05:06:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 09/22] block: implement add_bdi_stat()
Date: Mon, 23 Sep 2013 15:05:37 +0300
Message-Id: <1379937950-8411-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to add/remove a number of page cache entries at once. This
patch implements add_bdi_stat() which adjusts bdi stats by arbitrary
amount. It's required for batched page cache manipulations.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 include/linux/backing-dev.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 5f66d519a7..39acfa974b 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -166,6 +166,16 @@ static inline void __dec_bdi_stat(struct backing_dev_info *bdi,
 	__add_bdi_stat(bdi, item, -1);
 }
 
+static inline void add_bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item, s64 amount)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__add_bdi_stat(bdi, item, amount);
+	local_irq_restore(flags);
+}
+
 static inline void dec_bdi_stat(struct backing_dev_info *bdi,
 		enum bdi_stat_item item)
 {
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
