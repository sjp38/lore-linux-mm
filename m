Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 20D668E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 15:59:10 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id u32so17962041qte.1
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:59:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e38sor76308827qtk.19.2019.01.11.12.59.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 12:59:09 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH v2] rbtree: fix the red root
Date: Fri, 11 Jan 2019 15:58:43 -0500
Message-Id: <20190111205843.25761-1-cai@lca.pw>
In-Reply-To: <20190111181600.GJ6310@bombadil.infradead.org>
References: <20190111181600.GJ6310@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: esploit@protonmail.ch, jejb@linux.ibm.com, dgilbert@interlog.com, martin.petersen@oracle.com, joeypabalinas@gmail.com, walken@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

A GPF was reported,

kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
        kasan_die_handler.cold.22+0x11/0x31
        notifier_call_chain+0x17b/0x390
        atomic_notifier_call_chain+0xa7/0x1b0
        notify_die+0x1be/0x2e0
        do_general_protection+0x13e/0x330
        general_protection+0x1e/0x30
        rb_insert_color+0x189/0x1480
        create_object+0x785/0xca0
        kmemleak_alloc+0x2f/0x50
        kmem_cache_alloc+0x1b9/0x3c0
        getname_flags+0xdb/0x5d0
        getname+0x1e/0x20
        do_sys_open+0x3a1/0x7d0
        __x64_sys_open+0x7e/0xc0
        do_syscall_64+0x1b3/0x820
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

It turned out,

gparent = rb_red_parent(parent);
tmp = gparent->rb_right; <-- GPF was triggered here.

Apparently, "gparent" is NULL which indicates "parent" is rbtree's root
which is red. Otherwise, it will be treated properly a few lines above.

/*
 * If there is a black parent, we are done.
 * Otherwise, take some corrective action as,
 * per 4), we don't want a red root or two
 * consecutive red nodes.
 */
if(rb_is_black(parent))
	break;

Hence, it violates the rule #1 (the root can't be red) and need a fix
up, and also add a regression test for it. This looks like was
introduced by 6d58452dc06 where it no longer always paint the root as
black.

Fixes: 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only
when necessary)
Reported-by: Esme <esploit@protonmail.ch>
Tested-by: Joey Pabalinas <joeypabalinas@gmail.com>
Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: add a regression test.

 lib/rbtree.c      |  7 +++++++
 lib/rbtree_test.c | 11 +++++++++++
 2 files changed, 18 insertions(+)

diff --git a/lib/rbtree.c b/lib/rbtree.c
index d3ff682fd4b8..acc969ad8de9 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -127,6 +127,13 @@ __rb_insert(struct rb_node *node, struct rb_root *root,
 			break;
 
 		gparent = rb_red_parent(parent);
+		if (unlikely(!gparent)) {
+			/*
+			 * The root is red so correct it.
+			 */
+			rb_set_parent_color(parent, NULL, RB_BLACK);
+			break;
+		}
 
 		tmp = gparent->rb_right;
 		if (parent != tmp) {	/* parent == gparent->rb_left */
diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
index b7055b2a07d3..afad0213a117 100644
--- a/lib/rbtree_test.c
+++ b/lib/rbtree_test.c
@@ -345,6 +345,17 @@ static int __init rbtree_test_init(void)
 		check(0);
 	}
 
+	/*
+	 * a little regression test to catch a bug may be introduced by
+	 * 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only when
+	 * necessary)
+	 */
+	insert(nodes, &root);
+	nodes->rb.__rb_parent_color = RB_RED;
+	insert(nodes + 1, &root);
+	erase(nodes + 1, &root);
+	erase(nodes, &root);
+
 	printk(KERN_ALERT "augmented rbtree testing");
 
 	init();
-- 
2.17.2 (Apple Git-113)
