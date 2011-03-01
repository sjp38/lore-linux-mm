Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C9F38D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 03:02:30 -0500 (EST)
Message-ID: <4D6CA860.3020409@cn.fujitsu.com>
Date: Tue, 01 Mar 2011 16:03:44 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 4/4] net,rcu: don't assume the size of struct rcu_head
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org


struct dst_entry assumes the size of struct rcu_head as 2 * sizeof(long)
and manually adds pads for aligning for "__refcnt".

When the size of struct rcu_head is changed, these manual padding
is wrong. Use __attribute__((aligned (64))) instead.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
diff --git a/include/net/dst.h b/include/net/dst.h
index 93b0310..4ef6c4a 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -62,8 +62,6 @@ struct dst_entry {
 	struct hh_cache		*hh;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
-#else
-	void			*__pad1;
 #endif
 	int			(*input)(struct sk_buff*);
 	int			(*output)(struct sk_buff*);
@@ -74,23 +72,18 @@ struct dst_entry {
 
 #ifdef CONFIG_NET_CLS_ROUTE
 	__u32			tclassid;
-#else
-	__u32			__pad2;
 #endif
 
 
 	/*
 	 * Align __refcnt to a 64 bytes alignment
 	 * (L1_CACHE_SIZE would be too much)
-	 */
-#ifdef CONFIG_64BIT
-	long			__pad_to_align_refcnt[1];
-#endif
-	/*
+	 *
 	 * __refcnt wants to be on a different cache line from
 	 * input/output/ops or performance tanks badly
 	 */
-	atomic_t		__refcnt;	/* client references	*/
+	atomic_t		__refcnt	/* client references	*/
+				__attribute__((aligned (64)));
 	int			__use;
 	unsigned long		lastuse;
 	union {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
