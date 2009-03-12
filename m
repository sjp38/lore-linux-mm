Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9DFBA6B0047
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 20:57:37 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C0vZlx004371
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 09:57:35 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0295E45DE55
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:57:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC9EB45DD79
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:57:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B4304E38001
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:57:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 55C691DB803A
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:57:34 +0900 (JST)
Date: Thu, 12 Mar 2009 09:56:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/5] add softlimit to res_counter
Message-Id: <20090312095612.4a7758e1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Adds an interface for defining sotlimit per memcg. (no handler in this patch.)
softlimit paramater itself is added to res_counter and 
 res_counter_set_softlimit() and
 res_counter_check_under_softlimit() is provided as an interface.


Changelog v2->v3:
 - softlimit is moved to res_counter
Changelog v1->v2:
 - For refactoring, divided a patch into 2 part and this patch just
   involves memory.softlimit interface.
 - Removed governor-detect routine, it was buggy in design.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/res_counter.h |    9 +++++++++
 kernel/res_counter.c        |   29 +++++++++++++++++++++++++++++
 mm/memcontrol.c             |   12 ++++++++++++
 3 files changed, 50 insertions(+)

Index: mmotm-2.6.29-Mar10/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Mar10.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Mar10/mm/memcontrol.c
@@ -2002,6 +2002,12 @@ static int mem_cgroup_write(struct cgrou
 		else
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		break;
+	case RES_SOFTLIMIT:
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		ret = res_counter_set_softlimit(&memcg->res, val);
+		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
 		break;
@@ -2251,6 +2257,12 @@ static struct cftype mem_cgroup_files[] 
 		.read_u64 = mem_cgroup_read,
 	},
 	{
+		.name = "softlimit_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEM, RES_SOFTLIMIT),
+		.write_string = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
 		.name = "failcnt",
 		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
 		.trigger = mem_cgroup_reset,
Index: mmotm-2.6.29-Mar10/include/linux/res_counter.h
===================================================================
--- mmotm-2.6.29-Mar10.orig/include/linux/res_counter.h
+++ mmotm-2.6.29-Mar10/include/linux/res_counter.h
@@ -39,6 +39,10 @@ struct res_counter {
 	 */
 	unsigned long long failcnt;
 	/*
+	 * the softlimit.
+	 */
+	unsigned long long softlimit;
+	/*
 	 * the lock to protect all of the above.
 	 * the routines below consider this to be IRQ-safe
 	 */
@@ -85,6 +89,7 @@ enum {
 	RES_MAX_USAGE,
 	RES_LIMIT,
 	RES_FAILCNT,
+	RES_SOFTLIMIT,
 };
 
 /*
@@ -178,4 +183,8 @@ static inline int res_counter_set_limit(
 	return ret;
 }
 
+/* res_counter's softlimit check can handles hierarchy in proper way */
+int res_counter_set_softlimit(struct res_counter *cnt, unsigned long long val);
+bool res_counter_check_under_softlimit(struct res_counter *cnt);
+
 #endif
Index: mmotm-2.6.29-Mar10/kernel/res_counter.c
===================================================================
--- mmotm-2.6.29-Mar10.orig/kernel/res_counter.c
+++ mmotm-2.6.29-Mar10/kernel/res_counter.c
@@ -20,6 +20,7 @@ void res_counter_init(struct res_counter
 	spin_lock_init(&counter->lock);
 	counter->limit = (unsigned long long)LLONG_MAX;
 	counter->parent = parent;
+	counter->softlimit = (unsigned long long)LLONG_MAX;
 }
 
 int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
@@ -88,6 +89,32 @@ void res_counter_uncharge(struct res_cou
 	local_irq_restore(flags);
 }
 
+int res_counter_set_softlimit(struct res_counter *cnt, unsigned long long val)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	cnt->softlimit = val;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return 0;
+}
+
+bool res_counter_check_under_softlimit(struct res_counter *cnt)
+{
+	struct res_counter *c;
+	unsigned long flags;
+	bool ret = true;
+
+	local_irq_save(flags);
+	for (c = cnt; ret && c != NULL; c = c->parent) {
+		spin_lock(&c->lock);
+		if (c->softlimit < c->usage)
+			ret = false;
+		spin_unlock(&c->lock);
+	}
+	local_irq_restore(flags);
+	return ret;
+}
 
 static inline unsigned long long *
 res_counter_member(struct res_counter *counter, int member)
@@ -101,6 +128,8 @@ res_counter_member(struct res_counter *c
 		return &counter->limit;
 	case RES_FAILCNT:
 		return &counter->failcnt;
+	case RES_SOFTLIMIT:
+		return &counter->softlimit;
 	};
 
 	BUG();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
