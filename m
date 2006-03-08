Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k28DfkFl005623 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:41:46 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s13.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k28Dfi0Y028082 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:41:44 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s13.gw.fujitsu.co.jp (s13 [127.0.0.1])
	by s13.gw.fujitsu.co.jp (Postfix) with ESMTP id CC6631CC102
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:41:44 +0900 (JST)
Received: from ml0.s.css.fujitsu.com (ml0.s.css.fujitsu.com [10.23.4.190])
	by s13.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FB7D1CC0BD
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:41:44 +0900 (JST)
Date: Wed, 08 Mar 2006 22:41:44 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 005/017](RFC) Memory hotplug for new nodes v.3. (generic refresh NODE_DATA())
Message-Id: <20060308212759.002C.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This function refresh NODE_DATA() for generic archs.
In this case, NODE_DATA(nid) == node_data[nid].
node_data[] is array of address of pgdat.
So, refresh is quite simple.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: pgdat6/include/linux/memory_hotplug.h
===================================================================
--- pgdat6.orig/include/linux/memory_hotplug.h	2006-03-06 19:42:21.000000000 +0900
+++ pgdat6/include/linux/memory_hotplug.h	2006-03-06 19:42:30.000000000 +0900
@@ -87,10 +87,13 @@ static inline int arch_nid_probe(u64 sta
  */
 extern struct pglist_data * arch_alloc_nodedata(int nid);
 extern void arch_free_nodedata(pg_data_t *pgdat);
+extern void arch_refresh_nodedata(int nid, pg_data_t *pgdat);
 
 #else /* !CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
 #define arch_alloc_nodedata(nid)	generic_alloc_nodedata(nid)
 #define arch_free_nodedata(pgdat)	generic_free_nodedata(pgdat)
+#define arch_refresh_nodedata(nid, pgdat)	\
+				generic_refresh_nodedata(nid, pgdat)
 
 #ifdef CONFIG_NUMA
 /*
@@ -109,6 +112,11 @@ static inline void generic_free_nodedata
 	kfree(pgdat);
 }
 
+static inline void generic_refresh_nodedata(int nid, struct pglist_data *pgdat)
+{
+	NODE_DATA(nid) = pgdat;
+}
+
 #else /* !CONFIG_NUMA */
 /* never called */
 static inline struct pglist_data *generic_alloc_nodedata(int nid)
@@ -119,6 +127,9 @@ static inline struct pglist_data *generi
 static inline void generic_free_nodedata(struct pglist_data *pgdat)
 {
 }
+static inline void generic_refresh_nodedata(int nid, struct pglist_data *pgdat)
+{
+}
 #endif /* CONFIG_NUMA */
 #endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
 

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
