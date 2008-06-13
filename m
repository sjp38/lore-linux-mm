Date: Fri, 13 Jun 2008 18:36:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 5/6] res_counter: HARDWALL hierarchy
Message-Id: <20080613183656.55520100.kamezawa.hiroyu@jp.fujitsu.com>
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

This patch adds new hierarchy model, called Hardwall Hierarchy, to res_counter.

Change log v3 -> v4.
 - restructured the whole set, cut out from memcg hierarchy patch set.
 - just handles HardWall Hierarchy.
 - renamed variables and functions, again.

HardWall implements following model
 - A cgroup's tree means hierarchy of resource.
 - All child's resource is moved from its parents.
 - The resource moved to children is charged as parent's usage.
 - The resource moves when child->limit is changed.
 - The sum of resource for children and its own usage is limited by "limit".

This implies
 - No dynamic automatic hierarhcy balancing in the kernel.
 - Each resource is isolated completely.
 - The kernel just supports resource-move-at-change-in-limit.
 - The user (middle-ware) is responsible to make hierarhcy balanced well.
   Good balance can be achieved by changing limit from user land.

I think there are 4 characteristics of hierarchy.

  - fairness    ... how fairness is kept under policy

  - performance ... should be _fast_. multi-level resource balancing tend
                 to use much amount of CPU and can cause soft lockup.

  - predictability ... resource management are usually used for resource
                 isolation. the kernel must not break the isolation and
                 predictability of users against application's progress.

  - flexibility ... some sophisticated dynamic resource balancing with
                 soft-limit is welcomed when the user doesn't want strict
                 resource isolation or when the user cannot estimate how much
                 they want correctly.

 This model allows the move of resource only between a parent and its children.
 The resource is moved to a child when it declares the amount of resources
 to be used. (by limit)
 Automatic resource balancing is not supported in this code. This means
 this model is useful when a user want strict resource isolation under
 hierarchy.

 - fairness    ... ???  no resource sharing. works as specified by users.
 - performance ... good. each resources are capsuled to its own level.
 - predictability ... good. resources are completely isolated. balancing only
                occurs at the event of changes in limit.
 - flexibility ... bad. no flexibility and scheduling in the kernel level.
                need middle-ware's help.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 Documentation/controllers/resource_counter.txt |    9 +
 include/linux/res_counter.h                    |    6 +
 kernel/res_counter.c                           |  140 ++++++++++++++++++++++++-
 3 files changed, 154 insertions(+), 1 deletion(-)

Index: linux-2.6.26-rc5-mm3/include/linux/res_counter.h
===================================================================
--- linux-2.6.26-rc5-mm3.orig/include/linux/res_counter.h
+++ linux-2.6.26-rc5-mm3/include/linux/res_counter.h
@@ -23,6 +23,7 @@
 
 enum res_cont_hierarchy_model {
 	RES_CONT_NO_HIERARCHY,
+	RES_CONT_HARDWALL_HIERARCHY,
 };
 
 struct res_counter;
@@ -55,6 +56,10 @@ struct res_counter {
 	 */
 	struct res_counter *parent;
 	/*
+	 * resources assigned to children.
+	 */
+	unsigned long long used_by_children;
+	/*
 	 * registered callbacks etc...for res_counter.
 	 */
 	struct res_counter_ops ops;
@@ -96,6 +101,7 @@ enum {
 	RES_MAX_USAGE,
 	RES_LIMIT,
 	RES_FAILCNT,
+	RES_USED_BY_CHILDREN,
 };
 
 /*
Index: linux-2.6.26-rc5-mm3/kernel/res_counter.c
===================================================================
--- linux-2.6.26-rc5-mm3.orig/kernel/res_counter.c
+++ linux-2.6.26-rc5-mm3/kernel/res_counter.c
@@ -39,6 +39,10 @@ void __res_counter_init_hierarchy_core(s
 	case RES_CONT_NO_HIERARCHY:
 		counter->limit = (unsigned long long)LLONG_MAX;
 		break;
+	case RES_CONT_HARDWALL_HIERARCHY:
+		counter->limit = 0;
+		counter->used_by_children = 0;
+		break;
 	default:
 		break;
 	}
@@ -148,6 +152,8 @@ res_counter_member(struct res_counter *c
 		return &counter->limit;
 	case RES_FAILCNT:
 		return &counter->failcnt;
+	case RES_USED_BY_CHILDREN:
+		return &counter->used_by_children;
 	};
 
 	BUG();
@@ -177,6 +183,114 @@ u64 res_counter_read_u64(struct res_coun
 }
 
 /*
+ * Move resource from a parent to a child.
+ *  parent->usage        += val
+ *  parent->used_by_children += val
+ *  child->limit         += val
+ * To do this, ops->shrink_usage() is called against parent.
+ *
+ * Returns 0 at success.
+ * Returns -EBUSY or return code of ops->shrink_usage().
+ */
+static int res_counter_borrow_resource(struct res_counter *child,
+				unsigned long long val)
+{
+	struct res_counter *parent = child->parent;
+	unsigned long flags;
+	unsigned long long diff;
+	int ret;
+	int retry_count = 0;
+
+	BUG_ON(!parent);
+
+	spin_lock_irqsave(&child->lock, flags);
+	diff = val - child->limit;
+	spin_unlock_irqrestore(&child->lock, flags);
+
+	while (1) {
+		ret = -EBUSY;
+		spin_lock_irqsave(&parent->lock, flags);
+		if (parent->usage + diff <= parent->limit) {
+			parent->used_by_children += diff;
+			parent->usage += diff;
+			break;
+		}
+		spin_unlock_irqrestore(&parent->lock, flags);
+
+		if (!parent->ops.shrink_usage)
+			goto fail;
+		cond_resched();
+		ret = parent->ops.shrink_usage(parent, val, retry_count);
+		if (ret)
+			goto fail;
+		retry_count++;
+	}
+	ret = 0;
+	spin_unlock_irqrestore(&parent->lock, flags);
+
+	spin_lock_irqsave(&child->lock, flags);
+	child->limit = val;
+	spin_unlock_irqrestore(&child->lock, flags);
+fail:
+	return ret;
+}
+
+
+/*
+ * Move resource from a child to a parent.
+ *  parent->usage        -= val
+ *  parent->used_by_children -= val
+ *  child->limit         -= val
+ * To do this, ops->shrink_usage() is called against child.
+ *
+ * Returns 0 at success.
+ * Returns -EBUSY or return code passed by ops->shrink_usage().
+ */
+
+static int res_counter_return_resource(struct res_counter *child,
+				unsigned long long val)
+
+{
+	unsigned long flags;
+	struct res_counter *parent = child->parent;
+	int retry_count = 0;
+	unsigned long long diff;
+	int ret;
+
+	BUG_ON(!parent);
+
+	while (1) {
+		ret = -EBUSY;
+		spin_lock_irqsave(&child->lock, flags);
+		if (child->usage  <= val) {
+			diff = child->limit - val;
+			child->limit = val;
+			break;
+		}
+		spin_unlock_irqrestore(&child->lock, flags);
+
+		if (!child->ops.shrink_usage)
+			goto fail;
+
+		ret = child->ops.shrink_usage(child, val, retry_count);
+		if (ret)
+			goto fail;
+		retry_count++;
+	}
+	ret = 0;
+	spin_unlock_irqrestore(&child->lock, flags);
+
+	spin_lock_irqsave(&parent->lock, flags);
+	BUG_ON(parent->used_by_children < val);
+	BUG_ON(parent->usage < val);
+	parent->used_by_children -= diff;
+	parent->usage -= diff;
+	spin_unlock_irqrestore(&parent->lock, flags);
+fail:
+	return ret;
+}
+
+/*
  * Called when the limit changes if res_counter has ops->shrink_usage.
  * This function uses shrink usage to below new limit. returns 0 at success.
  */
@@ -187,10 +301,15 @@ static int res_counter_resize_limit(stru
 	int retry_count = 0;
 	int ret = -EBUSY;
 	unsigned long flags;
-	enum model = RES_CONT_NO_HIERARCHY;
+	enum res_cont_hierarchy_model model = RES_CONT_NO_HIERARCHY;
+	struct res_counter *parent;
 
 	BUG_ON(!cnt->ops.shrink_usage);
 
+	parent = cnt->parent;
+	if (parent)
+		model = parent->ops.hierarchy_model;
+
 	switch (model) {
 	case RES_CONT_NO_HIERARCHY:
 		/*
@@ -218,6 +337,25 @@ static int res_counter_resize_limit(stru
 			retry_count++;
 		}
 		break;
+	case RES_CONT_HARDWALL_HIERARCHY:
+		/*
+		 * Both of increasing/decreasing limit have to interact with
+		 * parent.
+		 */
+		{
+			int direction;
+			spin_lock_irqsave(&cnt->lock, flags);
+			if (val > cnt->limit)
+				direction = 1; /* increase */
+			else
+				direction = 0; /* decrease */
+			spin_unlock_irqrestore(&cnt->lock, flags);
+			if (direction)
+				ret = res_counter_borrow_resource(cnt, val);
+			else
+				ret = res_counter_return_resource(cnt, val);
+		}
+		break;
 	default:
 		BUG();
 	}
Index: linux-2.6.26-rc5-mm3/Documentation/controllers/resource_counter.txt
===================================================================
--- linux-2.6.26-rc5-mm3.orig/Documentation/controllers/resource_counter.txt
+++ linux-2.6.26-rc5-mm3/Documentation/controllers/resource_counter.txt
@@ -177,6 +177,15 @@ counter fields. They are recommended to 
  a. Independent hierarchy (RES_CONT_NO_HIERARCHY) model
    This is no relationship between parent and children.
 
+ b. Strict Hard-limit (RES_CONT_HARDWALL_HIERARCHY) model
+   This model allows strict resource isolation under hierarchy.
+   The rule is.
+    - A cgroup's tree means hierarchy of resource.
+    - All child's resource is moved from its parents.
+    - The resource moved to children is charged as parent's usage.
+    - The resource moves when child->limit is changed.
+    - The sum of resource for children and its own usage is limited by "limit".
+   See controllers/memory.txt if unsure. There will be an example.
 
 7. Usage example
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
