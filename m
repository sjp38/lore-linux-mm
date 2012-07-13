Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 527586B0069
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:32:38 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so5512005pbb.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:32:37 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 03/12] rbtree: fix incorrect rbtree node insertion in fs/proc/proc_sysctl.c
Date: Thu, 12 Jul 2012 17:31:48 -0700
Message-Id: <1342139517-3451-4-git-send-email-walken@google.com>
In-Reply-To: <1342139517-3451-1-git-send-email-walken@google.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

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
