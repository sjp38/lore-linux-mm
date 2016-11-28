Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5666B0253
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:56:39 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id r94so258944815ioe.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:56:39 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id k204si41554439iok.169.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 10/33] radix tree test suite: Handle exceptional entries
Date: Mon, 28 Nov 2016 13:50:48 -0800
Message-Id: <1480369871-5271-45-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

item_kill_tree() assumes that everything in the tree is a pointer to a
struct item, which is annoying when testing the behaviour of exceptional
entries.  Fix it to delete exceptional entries on the assumption they
don't need to be freed.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/test.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index a6e8099..6f8dafc 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -200,9 +200,16 @@ void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag)
 
 void item_kill_tree(struct radix_tree_root *root)
 {
+	struct radix_tree_iter iter;
+	void **slot;
 	struct item *items[32];
 	int nfound;
 
+	radix_tree_for_each_slot(slot, root, &iter, 0) {
+		if (radix_tree_exceptional_entry(*slot))
+			radix_tree_delete(root, iter.index);
+	}
+
 	while ((nfound = radix_tree_gang_lookup(root, (void **)items, 0, 32))) {
 		int i;
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
