Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAA56B0283
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:22 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id b77so2190059pfl.2
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o1si13784262plk.182.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:21 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 61/62] net: Redesign act_api use of IDR
Date: Wed, 22 Nov 2017 13:07:38 -0800
Message-Id: <20171122210739.29916-62-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The IDR now has its own internal locking, so remove the idrinfo->lock.
Use the IDR's lock to protect the walks that were formerly protected by
our own lock.  Remove the preloading as it is no longer necessary with
the internal locking.  Then embed the action_idr in the struct tc_action
instead of separately allocating it.  Adjust various function signatures
to work with this.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/net/act_api.h |  27 ++-----------
 net/sched/act_api.c   | 105 ++++++++++++++++++--------------------------------
 2 files changed, 41 insertions(+), 91 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index fd08df74c466..a353e7a3fb22 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -11,11 +11,6 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
-struct tcf_idrinfo {
-	spinlock_t	lock;
-	struct idr	action_idr;
-};
-
 struct tc_action_ops;
 
 struct tc_action {
@@ -23,7 +18,7 @@ struct tc_action {
 	__u32				type; /* for backward compat(TCA_OLD_COMPAT) */
 	__u32				order;
 	struct list_head		list;
-	struct tcf_idrinfo		*idrinfo;
+	struct idr			*action_idr;
 
 	u32				tcfa_index;
 	int				tcfa_refcnt;
@@ -98,7 +93,7 @@ struct tc_action_ops {
 };
 
 struct tc_action_net {
-	struct tcf_idrinfo *idrinfo;
+	struct idr	action_idr;
 	const struct tc_action_ops *ops;
 };
 
@@ -108,25 +103,11 @@ int tc_action_net_init(struct tc_action_net *tn,
 {
 	int err = 0;
 
-	tn->idrinfo = kmalloc(sizeof(*tn->idrinfo), GFP_KERNEL);
-	if (!tn->idrinfo)
-		return -ENOMEM;
 	tn->ops = ops;
-	spin_lock_init(&tn->idrinfo->lock);
-	idr_init(&tn->idrinfo->action_idr);
+	idr_init(&tn->action_idr);
 	return err;
 }
-
-void tcf_idrinfo_destroy(const struct tc_action_ops *ops,
-			 struct tcf_idrinfo *idrinfo);
-
-static inline void tc_action_net_exit(struct tc_action_net *tn)
-{
-	rtnl_lock();
-	tcf_idrinfo_destroy(tn->ops, tn->idrinfo);
-	rtnl_unlock();
-	kfree(tn->idrinfo);
-}
+void tc_action_net_exit(struct tc_action_net *tn);
 
 int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,
 		       struct netlink_callback *cb, int type,
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index a6aa606b5e99..058e78088569 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -75,11 +75,9 @@ static void free_tcf(struct tc_action *p)
 	kfree(p);
 }
 
-static void tcf_idr_remove(struct tcf_idrinfo *idrinfo, struct tc_action *p)
+static void tcf_idr_remove(struct idr *idr, struct tc_action *p)
 {
-	spin_lock_bh(&idrinfo->lock);
-	idr_remove(&idrinfo->action_idr, p->tcfa_index);
-	spin_unlock_bh(&idrinfo->lock);
+	idr_remove(idr, p->tcfa_index);
 	gen_kill_estimator(&p->tcfa_rate_est);
 	free_tcf(p);
 }
@@ -100,7 +98,7 @@ int __tcf_idr_release(struct tc_action *p, bool bind, bool strict)
 		if (p->tcfa_bindcnt <= 0 && p->tcfa_refcnt <= 0) {
 			if (p->ops->cleanup)
 				p->ops->cleanup(p, bind);
-			tcf_idr_remove(p->idrinfo, p);
+			tcf_idr_remove(p->action_idr, p);
 			ret = ACT_P_DELETED;
 		}
 	}
@@ -109,18 +107,18 @@ int __tcf_idr_release(struct tc_action *p, bool bind, bool strict)
 }
 EXPORT_SYMBOL(__tcf_idr_release);
 
-static int tcf_dump_walker(struct tcf_idrinfo *idrinfo, struct sk_buff *skb,
+static int tcf_dump_walker(struct tc_action_net *tn, struct sk_buff *skb,
 			   struct netlink_callback *cb)
 {
 	int err = 0, index = -1, s_i = 0, n_i = 0;
 	u32 act_flags = cb->args[2];
 	unsigned long jiffy_since = cb->args[3];
 	struct nlattr *nest;
-	struct idr *idr = &idrinfo->action_idr;
+	struct idr *idr = &tn->action_idr;
 	struct tc_action *p;
 	unsigned long id = 1;
 
-	spin_lock_bh(&idrinfo->lock);
+	idr_lock_bh(idr);
 
 	s_i = cb->args[0];
 
@@ -153,7 +151,7 @@ static int tcf_dump_walker(struct tcf_idrinfo *idrinfo, struct sk_buff *skb,
 	if (index >= 0)
 		cb->args[0] = index + 1;
 
-	spin_unlock_bh(&idrinfo->lock);
+	idr_unlock_bh(idr);
 	if (n_i) {
 		if (act_flags & TCA_FLAG_LARGE_DUMP_ON)
 			cb->args[1] = n_i;
@@ -165,13 +163,13 @@ static int tcf_dump_walker(struct tcf_idrinfo *idrinfo, struct sk_buff *skb,
 	goto done;
 }
 
-static int tcf_del_walker(struct tcf_idrinfo *idrinfo, struct sk_buff *skb,
+static int tcf_del_walker(struct tc_action_net *tn, struct sk_buff *skb,
 			  const struct tc_action_ops *ops)
 {
 	struct nlattr *nest;
 	int n_i = 0;
 	int ret = -EINVAL;
-	struct idr *idr = &idrinfo->action_idr;
+	struct idr *idr = &tn->action_idr;
 	struct tc_action *p;
 	unsigned long id = 1;
 
@@ -204,12 +202,10 @@ int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,
 		       struct netlink_callback *cb, int type,
 		       const struct tc_action_ops *ops)
 {
-	struct tcf_idrinfo *idrinfo = tn->idrinfo;
-
 	if (type == RTM_DELACTION) {
-		return tcf_del_walker(idrinfo, skb, ops);
+		return tcf_del_walker(tn, skb, ops);
 	} else if (type == RTM_GETACTION) {
-		return tcf_dump_walker(idrinfo, skb, cb);
+		return tcf_dump_walker(tn, skb, cb);
 	} else {
 		WARN(1, "tcf_generic_walker: unknown action %d\n", type);
 		return -EINVAL;
@@ -217,21 +213,9 @@ int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(tcf_generic_walker);
 
-static struct tc_action *tcf_idr_lookup(u32 index, struct tcf_idrinfo *idrinfo)
-{
-	struct tc_action *p;
-
-	spin_lock_bh(&idrinfo->lock);
-	p = idr_find(&idrinfo->action_idr, index);
-	spin_unlock_bh(&idrinfo->lock);
-
-	return p;
-}
-
 int tcf_idr_search(struct tc_action_net *tn, struct tc_action **a, u32 index)
 {
-	struct tcf_idrinfo *idrinfo = tn->idrinfo;
-	struct tc_action *p = tcf_idr_lookup(index, idrinfo);
+	struct tc_action *p = idr_find(&tn->action_idr, index);
 
 	if (p) {
 		*a = p;
@@ -244,8 +228,7 @@ EXPORT_SYMBOL(tcf_idr_search);
 bool tcf_idr_check(struct tc_action_net *tn, u32 index, struct tc_action **a,
 		   int bind)
 {
-	struct tcf_idrinfo *idrinfo = tn->idrinfo;
-	struct tc_action *p = tcf_idr_lookup(index, idrinfo);
+	struct tc_action *p = idr_find(&tn->action_idr, index);
 
 	if (index && p) {
 		if (bind)
@@ -271,12 +254,11 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 		   int bind, bool cpustats)
 {
 	struct tc_action *p = kzalloc(ops->size, GFP_KERNEL);
-	struct tcf_idrinfo *idrinfo = tn->idrinfo;
-	struct idr *idr = &idrinfo->action_idr;
+	struct idr *idr = &tn->action_idr;
 	int err = -ENOMEM;
 
 	if (unlikely(!p))
-		return -ENOMEM;
+		goto free;
 	p->tcfa_refcnt = 1;
 	if (bind)
 		p->tcfa_bindcnt = 1;
@@ -284,31 +266,21 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 	if (cpustats) {
 		p->cpu_bstats = netdev_alloc_pcpu_stats(struct gnet_stats_basic_cpu);
 		if (!p->cpu_bstats)
-			goto err1;
+			goto free;
 		p->cpu_qstats = alloc_percpu(struct gnet_stats_queue);
 		if (!p->cpu_qstats)
-			goto err2;
+			goto free_bstats;
 	}
 	spin_lock_init(&p->tcfa_lock);
 	/* user doesn't specify an index */
 	if (!index) {
 		index = 1;
-		idr_preload(GFP_KERNEL);
-		spin_lock_bh(&idrinfo->lock);
-		err = idr_alloc_u32(idr, NULL, &index, UINT_MAX, GFP_ATOMIC);
-		spin_unlock_bh(&idrinfo->lock);
-		idr_preload_end();
-		if (err)
-			goto err3;
+		err = idr_alloc_u32(idr, NULL, &index, UINT_MAX, GFP_KERNEL);
 	} else {
-		idr_preload(GFP_KERNEL);
-		spin_lock_bh(&idrinfo->lock);
-		err = idr_alloc_u32(idr, NULL, &index, index, GFP_ATOMIC);
-		spin_unlock_bh(&idrinfo->lock);
-		idr_preload_end();
-		if (err)
-			goto err3;
+		err = idr_alloc_u32(idr, NULL, &index, index, GFP_KERNEL);
 	}
+	if (err)
+		goto free_qstats;
 
 	p->tcfa_index = index;
 	p->tcfa_tm.install = jiffies;
@@ -319,21 +291,22 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 					&p->tcfa_rate_est,
 					&p->tcfa_lock, NULL, est);
 		if (err)
-			goto err4;
+			goto free_idr;
 	}
 
-	p->idrinfo = idrinfo;
+	p->action_idr = idr;
 	p->ops = ops;
 	INIT_LIST_HEAD(&p->list);
 	*a = p;
 	return 0;
-err4:
+
+free_idr:
 	idr_remove(idr, index);
-err3:
+free_qstats:
 	free_percpu(p->cpu_qstats);
-err2:
+free_bstats:
 	free_percpu(p->cpu_bstats);
-err1:
+free:
 	kfree(p);
 	return err;
 }
@@ -341,32 +314,28 @@ EXPORT_SYMBOL(tcf_idr_create);
 
 void tcf_idr_insert(struct tc_action_net *tn, struct tc_action *a)
 {
-	struct tcf_idrinfo *idrinfo = tn->idrinfo;
-
-	spin_lock_bh(&idrinfo->lock);
-	idr_replace(&idrinfo->action_idr, a, a->tcfa_index);
-	spin_unlock_bh(&idrinfo->lock);
+	idr_replace(&tn->action_idr, a, a->tcfa_index);
 }
 EXPORT_SYMBOL(tcf_idr_insert);
 
-void tcf_idrinfo_destroy(const struct tc_action_ops *ops,
-			 struct tcf_idrinfo *idrinfo)
+void tc_action_net_exit(struct tc_action_net *tn)
 {
-	struct idr *idr = &idrinfo->action_idr;
+	struct idr *idr = &tn->action_idr;
 	struct tc_action *p;
 	int ret;
 	unsigned long id = 1;
 
+	rtnl_lock();
 	idr_for_each_entry_ul(idr, p, id) {
 		ret = __tcf_idr_release(p, false, true);
 		if (ret == ACT_P_DELETED)
-			module_put(ops->owner);
-		else if (ret < 0)
-			return;
+			module_put(tn->ops->owner);
+		WARN_ON(ret < 0);
 	}
-	idr_destroy(&idrinfo->action_idr);
+	idr_destroy(idr);
+	rtnl_unlock();
 }
-EXPORT_SYMBOL(tcf_idrinfo_destroy);
+EXPORT_SYMBOL(tc_action_net_exit);
 
 static LIST_HEAD(act_base);
 static DEFINE_RWLOCK(act_mod_lock);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
