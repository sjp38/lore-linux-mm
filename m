Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B7D676B026B
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 13:03:34 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id e1so53848063itb.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:03:34 -0700 (PDT)
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net (p3plsmtps2ded04.prod.phx3.secureserver.net. [208.109.80.198])
        by mx.google.com with ESMTPS id d95si2973871ioj.42.2016.09.22.10.03.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 10:03:34 -0700 (PDT)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 2/2] radix-tree: Fix optimisation problem
Date: Thu, 22 Sep 2016 11:53:35 -0700
Message-Id: <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

When compiling the radix tree with -O2, GCC thinks it can optimise:

	void *entry = parent->slots[offset];
	int siboff = entry - parent->slots;
	void *slot = parent->slots + siboff;

into

	void *slot = entry;

Unfortunately, 'entry' is a tagged pointer, so this optimisation leads
to getting an unaligned pointer back from radix_tree_lookup_slot().
The test suite wasn't being compiled with optimisation, so we hadn't
spotted it before now.  Change the test suite to compile with -O2, and
fix the optimisation problem by passing 'entry' through entry_to_node()
so gcc knows this isn't a plain pointer.
---
 lib/radix-tree.c                  | 3 ++-
 tools/testing/radix-tree/Makefile | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 1b7bf73..8bf1f32 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -105,7 +105,8 @@ static unsigned int radix_tree_descend(struct radix_tree_node *parent,
 
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
 	if (radix_tree_is_internal_node(entry)) {
-		unsigned long siboff = get_slot_offset(parent, entry);
+		unsigned long siboff = get_slot_offset(parent,
+						(void **)entry_to_node(entry));
 		if (siboff < RADIX_TREE_MAP_SIZE) {
 			offset = siboff;
 			entry = rcu_dereference_raw(parent->slots[offset]);
diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index 3b53046..9d0919ed 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -1,5 +1,5 @@
 
-CFLAGS += -I. -g -Wall -D_LGPL_SOURCE
+CFLAGS += -I. -g -O2 -Wall -D_LGPL_SOURCE
 LDFLAGS += -lpthread -lurcu
 TARGETS = main
 OFILES = main.o radix-tree.o linux.o test.o tag_check.o find_next_bit.o \
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
