Date: Wed, 2 Jul 2008 21:15:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][-mm] [6/7] res_counter distance to limit
Message-Id: <20080702211510.6f1fe470.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

I wonder wheher there is better name rather than "distance"...
give me a hint ;)
==
Charge the val to res_counter and returns distance to the limit.

Useful when a controller (memory controller) want to implement background
feedback ops depends on the rest of resource.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/res_counter.h |   21 ++++++++++++++++++++-
 kernel/res_counter.c        |   27 +++++++++++++++++++++++++++
 2 files changed, 47 insertions(+), 1 deletion(-)

Index: test-2.6.26-rc5-mm3++/include/linux/res_counter.h
===================================================================
--- test-2.6.26-rc5-mm3++.orig/include/linux/res_counter.h
+++ test-2.6.26-rc5-mm3++/include/linux/res_counter.h
@@ -104,7 +104,8 @@ int __must_check res_counter_charge_lock
 		unsigned long val);
 int __must_check res_counter_charge(struct res_counter *counter,
 		unsigned long val);
-
+int __must_check res_counter_charge_distance(struct res_counter *counter,
+	unsigned long val, unsigned long long *distance);
 /*
  * uncharge - tell that some portion of the resource is released
  *
@@ -173,4 +174,22 @@ static inline int res_counter_set_limit(
 	spin_unlock_irqrestore(&cnt->lock, flags);
 	return ret;
 }
+
+/*
+ * Returns limit - usage. if usage > limit, returns 0.
+ */
+
+static inline unsigned long long
+res_counter_distance_to_limit(struct res_counter *cnt)
+{
+	unsigned long flags;
+	unsigned long long distance = 0;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	if (cnt->usage < cnt->limit)
+		distance = cnt->limit - cnt->usage;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return distance;
+}
+
 #endif
Index: test-2.6.26-rc5-mm3++/kernel/res_counter.c
===================================================================
--- test-2.6.26-rc5-mm3++.orig/kernel/res_counter.c
+++ test-2.6.26-rc5-mm3++/kernel/res_counter.c
@@ -44,6 +44,33 @@ int res_counter_charge(struct res_counte
 	return ret;
 }
 
+/*
+ * res_counter_charge_distance - do res_counter_charge and returns distance to
+ * limit.
+ * @counter: the counter
+ * @val: the amount of the resource. each controller defines its own units.
+ * @distance: the rest of resource to the limit.
+ *
+ * returns 0 on success and <0 if the counter->usage will exceed the
+ * counter->limit.
+ */
+
+int res_counter_charge_distance(struct res_counter *counter, unsigned long val,
+	unsigned long long *distance)
+{
+	int ret;
+	unsigned long flags;
+
+	spin_lock_irqsave(&counter->lock, flags);
+	ret = res_counter_charge_locked(counter, val);
+	if (!ret)
+		*distance = counter->limit - counter->usage;
+	spin_unlock_irqrestore(&counter->lock, flags);
+	return ret;
+}
+
+
+
 void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
 {
 	if (WARN_ON(counter->usage < val))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
