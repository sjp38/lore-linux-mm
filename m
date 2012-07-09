Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id D9AA76B0073
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:35:44 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so24193846pbb.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 16:35:44 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 03/13] rbtree: fix incorrect rbtree node insertion in fs/proc/proc_sysctl.c
Date: Mon,  9 Jul 2012 16:35:13 -0700
Message-Id: <1341876923-12469-4-git-send-email-walken@google.com>
In-Reply-To: <1341876923-12469-1-git-send-email-walken@google.com>
References: <1341876923-12469-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

The recently added code to use rbtrees in sysctl did not follow the proper
rbtree interface on insertion - it was calling rb_link_node() which
inserts a new node into the binary tree, but missed the call to
rb_insert_color() which properly balances the rbtree and establishes all
expected rbtree invariants.

I found out about this only because faulty commit also used rb_init_node(),
which I am removing within this patchset. But I think it's an easy mistake
to make, and it makes me wonder if we should change the rbtree API so that
insertions would be done with a single rb_insert() call (even if its
implementation could still inline the rb_link_node() part and call
a private __rb_insert_color function to do the rebalancing).

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 fs/proc/proc_sysctl.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 33aea86..77602c1a 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -142,6 +142,7 @@ static int insert_entry(struct ctl_table_header *head, struct ctl_table *entry)
 	}
 
 	rb_link_node(node, parent, p);
+	rb_insert_color(node, &head->parent->root);
 	return 0;
 }
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
