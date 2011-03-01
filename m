Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 94FAC8D003C
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 03:02:40 -0500 (EST)
Message-ID: <4D6CA85B.5030107@cn.fujitsu.com>
Date: Tue, 01 Mar 2011 16:03:39 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 3/4] slab,rcu: don't assume the size of struct rcu_head
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org


The size of struct rcu_head may be changed. When it becomes larger,
it may pollute the data after struct slab.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
diff --git a/mm/slab.c b/mm/slab.c
index 37961d1..52cf0b4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -191,22 +191,6 @@ typedef unsigned int kmem_bufctl_t;
 #define	SLAB_LIMIT	(((kmem_bufctl_t)(~0U))-3)
 
 /*
- * struct slab
- *
- * Manages the objs in a slab. Placed either at the beginning of mem allocated
- * for a slab, or allocated from an general cache.
- * Slabs are chained into three list: fully used, partial, fully free slabs.
- */
-struct slab {
-	struct list_head list;
-	unsigned long colouroff;
-	void *s_mem;		/* including colour offset */
-	unsigned int inuse;	/* num of objs active in slab */
-	kmem_bufctl_t free;
-	unsigned short nodeid;
-};
-
-/*
  * struct slab_rcu
  *
  * slab_destroy on a SLAB_DESTROY_BY_RCU cache uses this structure to
@@ -219,8 +203,6 @@ struct slab {
  *
  * rcu_read_lock before reading the address, then rcu_read_unlock after
  * taking the spinlock within the structure expected at that address.
- *
- * We assume struct slab_rcu can overlay struct slab when destroying.
  */
 struct slab_rcu {
 	struct rcu_head head;
@@ -229,6 +211,27 @@ struct slab_rcu {
 };
 
 /*
+ * struct slab
+ *
+ * Manages the objs in a slab. Placed either at the beginning of mem allocated
+ * for a slab, or allocated from an general cache.
+ * Slabs are chained into three list: fully used, partial, fully free slabs.
+ */
+struct slab {
+	union {
+		struct {
+			struct list_head list;
+			unsigned long colouroff;
+			void *s_mem;		/* including colour offset */
+			unsigned int inuse;	/* num of objs active in slab */
+			kmem_bufctl_t free;
+			unsigned short nodeid;
+		};
+		struct slab_rcu __slab_cover_slab_rcu;
+	};
+};
+
+/*
  * struct array_cache
  *
  * Purpose:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
