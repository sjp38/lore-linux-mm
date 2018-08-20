Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB6D6B1838
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 04:55:35 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id l45-v6so7886508wre.4
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 01:55:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o5-v6sor2757246wrf.33.2018.08.20.01.55.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 01:55:34 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH] mm: Fix comment for NODEMASK_ALLOC
Date: Mon, 20 Aug 2018 10:55:16 +0200
Message-Id: <20180820085516.9687-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: tglx@linutronix.de, joe@perches.com, arnd@arndb.de, mhocko@suse.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Currently, NODEMASK_ALLOC allocates a nodemask_t with kmalloc when
NODES_SHIFT is higher than 8, otherwise it declares it within the stack.

The comment says that the reasoning behind this, is that nodemask_t will be
256 bytes when NODES_SHIFT is higher than 8, but this is not true.
For example, NODES_SHIFT = 9 will give us a 64 bytes nodemask_t.
Let us fix up the comment for that.

Another thing is that it might make sense to let values lower than 128bytes
be allocated in the stack.
Although this all depends on the depth of the stack
(and this changes from function to function), I think that 64 bytes
is something we can easily afford.
So we could even bump the limit by 1 (from > 8 to > 9).

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 include/linux/nodemask.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 1fbde8a880d9..5a30ad594ccc 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -518,7 +518,7 @@ static inline int node_random(const nodemask_t *mask)
  * NODEMASK_ALLOC(type, name) allocates an object with a specified type and
  * name.
  */
-#if NODES_SHIFT > 8 /* nodemask_t > 256 bytes */
+#if NODES_SHIFT > 8 /* nodemask_t > 32 bytes */
 #define NODEMASK_ALLOC(type, name, gfp_flags)	\
 			type *name = kmalloc(sizeof(*name), gfp_flags)
 #define NODEMASK_FREE(m)			kfree(m)
-- 
2.13.6
