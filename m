Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 717C36B0035
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 21:45:58 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so9831590pde.21
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 18:45:58 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id l8si318347paa.344.2014.02.12.18.45.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 18:45:57 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id y10so9833771pdj.18
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 18:45:57 -0800 (PST)
Date: Wed, 12 Feb 2014 18:45:07 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] swapoff tmpfs radix_tree: remember to rcu_read_unlock
Message-ID: <alpine.LSU.2.11.1402121840500.6398@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Running fsx on tmpfs with concurrent memhog-swapoff-swapon, lots of

BUG: sleeping function called from invalid context at kernel/fork.c:606
in_atomic(): 0, irqs_disabled(): 0, pid: 1394, name: swapoff
1 lock held by swapoff/1394:
 #0:  (rcu_read_lock){.+.+.+}, at: [<ffffffff812520a1>] radix_tree_locate_item+0x1f/0x2b6
followed by
================================================
[ BUG: lock held when returning to user space! ]
3.14.0-rc1 #3 Not tainted
------------------------------------------------
swapoff/1394 is leaving the kernel with locks still held!
1 lock held by swapoff/1394:
 #0:  (rcu_read_lock){.+.+.+}, at: [<ffffffff812520a1>] radix_tree_locate_item+0x1f/0x2b6
after which the system recovered nicely.

Whoops, I long ago forgot the rcu_read_unlock() on one unlikely branch.

Fixes: e504f3fdd63d ("tmpfs radix_tree: locate_item to speed up swapoff")
Signed-off-by: Hugh Dickins <hughd@google.com>
---

Of course, the truth is that I had been hoping to break Johannes's
patchset in mmotm, was thrilled to get this on that, then despondent
to realize that the only bug I had found was mine.  Surprised I've
not seen it before in 2.5 years: tried again on 3.14-rc1, got the
same after 25 minutes.  Probably not serious enough for -stable,
but please can we slip the fix into 3.14 - sorry, Johannes's
mm-keep-page-cache-radix-tree-nodes-in-check.patch will need a refresh.

 lib/radix-tree.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- 3.14-rc2/lib/radix-tree.c	2013-11-03 15:41:51.000000000 -0800
+++ linux/lib/radix-tree.c	2014-02-09 21:47:22.688092825 -0800
@@ -1253,8 +1253,10 @@ unsigned long radix_tree_locate_item(str
 
 		node = indirect_to_ptr(node);
 		max_index = radix_tree_maxindex(node->height);
-		if (cur_index > max_index)
+		if (cur_index > max_index) {
+			rcu_read_unlock();
 			break;
+		}
 
 		cur_index = __locate(node, item, cur_index, &found_index);
 		rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
