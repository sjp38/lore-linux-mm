Date: Fri, 13 Jun 2008 18:34:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/6] res_counter: basic hierarchy support
Message-Id: <20080613183402.4f31eb96.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Add a hierarhy support to res_counter. This patch itself just supports
"No Hierarchy" hierarchy, as a default/basic hierarchy system.

Changelog: v3 -> v4.
  - cut out from hardwall hierarchy patch set.
  - just support "No hierarchy" model.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/controllers/resource_counter.txt |   27 +++++-
 include/linux/res_counter.h                    |   15 +++
 kernel/res_counter.c                           |  107 ++++++++++++++++++++-----
 mm/memcontrol.c                                |    1 
 4 files changed, 129 insertions(+), 21 deletions(-)

Index: linux-2.6.26-rc5-mm3/include/linux/res_counter.h
===================================================================
--- linux-2.6.26-rc5-mm3.orig/include/linux/res_counter.h
+++ linux-2.6.26-rc5-mm3/include/linux/res_counter.h
@@ -21,8 +21,13 @@
  * the helpers described beyond
  */
 
+enum res_cont_hierarchy_model {
+	RES_CONT_NO_HIERARCHY,
+};
+
 struct res_counter;
 struct res_counter_ops {
+	enum res_cont_hierarchy_model hierarchy_model;
 	/* called when the subsystem has to reduce the usage. */
 	int (*shrink_usage)(struct res_counter *cnt, unsigned long long val,
 			    int retry_count);
@@ -46,6 +51,10 @@ struct res_counter {
 	 */
 	unsigned long long failcnt;
 	/*
+	 * parent of this counter in hierarchy. if root, this is NULL.
+	 */
+	struct res_counter *parent;
+	/*
 	 * registered callbacks etc...for res_counter.
 	 */
 	struct res_counter_ops ops;
@@ -101,6 +110,12 @@ static inline void res_counter_init(stru
 	res_counter_init_ops(counter, NULL);
 }
 
+void res_counter_init_hierarchy(struct res_counter *counter,
+					struct res_counter *parent);
+
+int res_counter_set_ops(struct res_counter *counter,
+				struct res_counter_ops *ops);
+
 /*
  * charge - try to consume more resource.
  *
Index: linux-2.6.26-rc5-mm3/kernel/res_counter.c
===================================================================
--- linux-2.6.26-rc5-mm3.orig/kernel/res_counter.c
+++ linux-2.6.26-rc5-mm3/kernel/res_counter.c
@@ -30,8 +30,70 @@ void res_counter_init_ops(struct res_cou
 	counter->limit = (unsigned long long)LLONG_MAX;
 	if (ops)
 		counter->ops = *ops;
+	counter->parent = NULL;
+}
+
+void __res_counter_init_hierarchy_core(struct res_counter *counter)
+{
+	switch (counter->ops.hierarchy_model) {
+	case RES_CONT_NO_HIERARCHY:
+		counter->limit = (unsigned long long)LLONG_MAX;
+		break;
+	default:
+		break;
+	}
+	return;
+}
+
+
+/**
+ * res_counter_init_hierarchy() -- initialize res_counter under some hierarchy.
+ * @counter: a counter will be initialized.
+ * @parent: parent of counter.
+ *
+ * parent->ops is copied to counter->ops and counter will be initialized
+ * to be suitable style for the hierarchy model.
+ */
+void res_counter_init_hierarchy(struct res_counter *counter,
+					struct res_counter *parent)
+{
+	struct res_counter_ops *ops = NULL;
+
+	if (parent)
+		ops = &parent->ops;
+	res_counter_init_ops(counter, ops);
+	counter->parent = parent;
+
+	__res_counter_init_hierarchy_core(counter);
 }
 
+/**
+ * res_counter_set_ops() -- reset res->counter.ops to be passed ops.
+ * @coutner: a counter to be set ops.
+ * @ops: res_counter_ops
+ *
+ * This operations is allowed only when there is no parent or parent's
+ * hierarchy_model == RES_CONT_NO_HIERARCHY. returns 0 at success.
+ */
+
+int res_counter_set_ops(struct res_counter *counter,
+				struct res_counter_ops *ops)
+{
+	struct res_counter *parent;
+	/*
+	 * This operation is allowed only when parents's hierarchy
+	 * is NO_HIERARCHY or this is ROOT.
+	 */
+	parent = counter->parent;
+	if (parent && parent->ops.hierarchy_model != RES_CONT_NO_HIERARCHY)
+		return -EINVAL;
+
+	counter->ops = *ops;
+
+	return 0;
+}
+
+
 int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
 {
 	if (counter->usage + val > counter->limit) {
@@ -125,30 +187,39 @@ static int res_counter_resize_limit(stru
 	int retry_count = 0;
 	int ret = -EBUSY;
 	unsigned long flags;
+	enum model = RES_CONT_NO_HIERARCHY;
 
 	BUG_ON(!cnt->ops.shrink_usage);
-	while (1) {
-		spin_lock_irqsave(&cnt->lock, flags);
-		if (cnt->usage <= val) {
-			cnt->limit = val;
-			ret = 0;
-			spin_unlock_irqrestore(&cnt->lock, flags);
-			break;
-		}
-		BUG_ON(val > cnt->limit);
-		spin_unlock_irqrestore(&cnt->lock, flags);
 
+	switch (model) {
+	case RES_CONT_NO_HIERARCHY:
 		/*
-		 * Rest before calling callback().... rest after callback
-		 * tends to add difference between the result of callback and
-		 * the check in next loop.
+		 * shrink usage to be below the new limit.
 		 */
-		cond_resched();
+		while (1) {
+			spin_lock_irqsave(&cnt->lock, flags);
+			if (cnt->usage <= val) {
+				cnt->limit = val;
+				ret = 0;
+			}
+			spin_unlock_irqrestore(&cnt->lock, flags);
+			if (!ret)
+				break;
+			/*
+			 * Rest before calling callback().... rest after
+			 * callback tends to add difference between the result
+			 * of callback and the check in next loop.
+			 */
+			cond_resched();
 
-		ret = cnt->ops.shrink_usage(cnt, val, retry_count);
-		if (!ret)
-			break;
-		retry_count++;
+			ret = cnt->ops.shrink_usage(cnt, val, retry_count);
+			if (!ret)
+				break;
+			retry_count++;
+		}
+		break;
+	default:
+		BUG();
 	}
 	return ret;
 }
Index: linux-2.6.26-rc5-mm3/Documentation/controllers/resource_counter.txt
===================================================================
--- linux-2.6.26-rc5-mm3.orig/Documentation/controllers/resource_counter.txt
+++ linux-2.6.26-rc5-mm3/Documentation/controllers/resource_counter.txt
@@ -39,11 +39,14 @@ to work with it.
  	The failcnt stands for "failures counter". This is the number of
 	resource allocation attempts that failed.
 
- e. res_counter_ops.
+ e. parent
+	parent of this res_counter under hierarchy.
+
+ f. res_counter_ops.
 	Callbacks for helping resource_counter per each subsystem.
 	- shrink_usage() .... called at limit change (decrease).
 
- f. spinlock_t lock
+ g. spinlock_t lock
 
  	Protects changes of the above values.
 
@@ -157,7 +160,25 @@ counter fields. They are recommended to 
      Returns 0 at success. Any error code is acceptable but -EBUSY will be
      suitable to show "the kernel can't shrink usage."
 
-6. Usage example
+6. Hierarchy
+
+   Groups of res_counter can be controlled under some tree (cgroup tree).
+   Taking the tree into account, res_counter can be under some hierarchical
+   control. THe res_counter itself supports hierarchy_model and calls
+   registered callbacks at suitable events.
+
+   For keeping sanity of hierarchy, hierarchy_model of a res_counter can be
+   changed when parent's hierarchy_model is RES_CONT_NO_HIERARCHY.
+   res_counter doesn't count # of children by itself but some subysystem should
+   be aware that it has no children if necessary.
+   (don't want to fully duplicate cgroup's hierarchy. Cost of remembering parent
+    is cheap.)
+
+ a. Independent hierarchy (RES_CONT_NO_HIERARCHY) model
+   This is no relationship between parent and children.
+
+
+7. Usage example
 
  a. Declare a task group (take a look at cgroups subsystem for this) and
     fold a res_counter into it
Index: linux-2.6.26-rc5-mm3/mm/memcontrol.c
===================================================================
--- linux-2.6.26-rc5-mm3.orig/mm/memcontrol.c
+++ linux-2.6.26-rc5-mm3/mm/memcontrol.c
@@ -1086,6 +1086,7 @@ static void mem_cgroup_free(struct mem_c
 }
 
 struct res_counter_ops root_ops = {
+	.hierarchy_model = RES_CONT_NO_HIERARCHY,
 	.shrink_usage = mem_cgroup_shrink_usage_to,
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
