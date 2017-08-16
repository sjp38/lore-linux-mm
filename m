From: Chris Mi <chrism-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [patch net-next 3/3] net/sched: Change act_api and act_xxx
 modules to use IDR
Date: Tue, 15 Aug 2017 22:12:18 -0400
Message-ID: <1502849538-14284-4-git-send-email-chrism@mellanox.com>
References: <1502849538-14284-1-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <nbd-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1502849538-14284-1-git-send-email-chrism-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/nbd-general>,
 <mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nbd-general>
List-Post: <mailto:nbd-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nbd-general>,
 <mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: nbd-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org, sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org, markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org, zhi.a.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nsekhar-l0cyMroinI0@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, jinpu.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org, pshelar-LZ6Gd1LRuIk@public.gmane.org, sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, AlexBin.Xie-5C7GfCeVMHo@public.gmane.org, david1.zhou-5C7GfCeVMHo@public.gmane.org, linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, maximlevitsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, sudarsana.kalluru-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, dtwlin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, michel.daenzer-5C7GfCeVMHo@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, tpmdd-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, longman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org, shli-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, ohad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org, pmladek-IBi9RG/b67k@public.gmane.org, dick.kennedy-dY08KVG/lbpWk0Htik3J/w@public.gmane.orglinux-
List-Id: linux-mm.kvack.org

Typically, each TC filter has its own action. All the actions of the
same type are saved in its hash table. But the hash buckets are too
small that it degrades to a list. And the performance is greatly
affected. For example, it takes about 0m11.914s to insert 64K rules.
If we convert the hash table to IDR, it only takes about 0m1.500s.
The improvement is huge.

But please note that the test result is based on previous patch that
cls_flower uses IDR.

Signed-off-by: Chris Mi <chrism-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 include/net/act_api.h      |  76 +++++---------
 net/sched/act_api.c        | 249 ++++++++++++++++++++++-----------------------
 net/sched/act_bpf.c        |  17 ++--
 net/sched/act_connmark.c   |  16 ++-
 net/sched/act_csum.c       |  16 ++-
 net/sched/act_gact.c       |  16 ++-
 net/sched/act_ife.c        |  20 ++--
 net/sched/act_ipt.c        |  26 +++--
 net/sched/act_mirred.c     |  19 ++--
 net/sched/act_nat.c        |  16 ++-
 net/sched/act_pedit.c      |  18 ++--
 net/sched/act_police.c     |  18 ++--
 net/sched/act_sample.c     |  17 ++--
 net/sched/act_simple.c     |  20 ++--
 net/sched/act_skbedit.c    |  18 ++--
 net/sched/act_skbmod.c     |  18 ++--
 net/sched/act_tunnel_key.c |  20 ++--
 net/sched/act_vlan.c       |  22 ++--
 18 files changed, 277 insertions(+), 345 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 26ffd83..8f3d5d8 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -10,12 +10,9 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
-
-struct tcf_hashinfo {
-	struct hlist_head	*htab;
-	unsigned int		hmask;
-	spinlock_t		lock;
-	u32			index;
+struct tcf_idrinfo {
+	spinlock_t	lock;
+	struct idr	action_idr;
 };
 
 struct tc_action_ops;
@@ -25,9 +22,8 @@ struct tc_action {
 	__u32				type; /* for backward compat(TCA_OLD_COMPAT) */
 	__u32				order;
 	struct list_head		list;
-	struct tcf_hashinfo		*hinfo;
+	struct tcf_idrinfo		*idrinfo;
 
-	struct hlist_node		tcfa_head;
 	u32				tcfa_index;
 	int				tcfa_refcnt;
 	int				tcfa_bindcnt;
@@ -44,7 +40,6 @@ struct tc_action {
 	struct tc_cookie	*act_cookie;
 	struct tcf_chain	*goto_chain;
 };
-#define tcf_head	common.tcfa_head
 #define tcf_index	common.tcfa_index
 #define tcf_refcnt	common.tcfa_refcnt
 #define tcf_bindcnt	common.tcfa_bindcnt
@@ -57,27 +52,6 @@ struct tc_action {
 #define tcf_lock	common.tcfa_lock
 #define tcf_rcu		common.tcfa_rcu
 
-static inline unsigned int tcf_hash(u32 index, unsigned int hmask)
-{
-	return index & hmask;
-}
-
-static inline int tcf_hashinfo_init(struct tcf_hashinfo *hf, unsigned int mask)
-{
-	int i;
-
-	spin_lock_init(&hf->lock);
-	hf->index = 0;
-	hf->hmask = mask;
-	hf->htab = kzalloc((mask + 1) * sizeof(struct hlist_head),
-			   GFP_KERNEL);
-	if (!hf->htab)
-		return -ENOMEM;
-	for (i = 0; i < mask + 1; i++)
-		INIT_HLIST_HEAD(&hf->htab[i]);
-	return 0;
-}
-
 /* Update lastuse only if needed, to avoid dirtying a cache line.
  * We use a temp variable to avoid fetching jiffies twice.
  */
@@ -126,53 +100,51 @@ struct tc_action_ops {
 };
 
 struct tc_action_net {
-	struct tcf_hashinfo *hinfo;
+	struct tcf_idrinfo *idrinfo;
 	const struct tc_action_ops *ops;
 };
 
 static inline
 int tc_action_net_init(struct tc_action_net *tn,
-		       const struct tc_action_ops *ops, unsigned int mask)
+		       const struct tc_action_ops *ops)
 {
 	int err = 0;
 
-	tn->hinfo = kmalloc(sizeof(*tn->hinfo), GFP_KERNEL);
-	if (!tn->hinfo)
+	tn->idrinfo = kmalloc(sizeof(*tn->idrinfo), GFP_KERNEL);
+	if (!tn->idrinfo)
 		return -ENOMEM;
 	tn->ops = ops;
-	err = tcf_hashinfo_init(tn->hinfo, mask);
-	if (err)
-		kfree(tn->hinfo);
+	spin_lock_init(&tn->idrinfo->lock);
+	idr_init(&tn->idrinfo->action_idr);
 	return err;
 }
 
-void tcf_hashinfo_destroy(const struct tc_action_ops *ops,
-			  struct tcf_hashinfo *hinfo);
+void tcf_idrinfo_destroy(const struct tc_action_ops *ops,
+			 struct tcf_idrinfo *idrinfo);
 
 static inline void tc_action_net_exit(struct tc_action_net *tn)
 {
-	tcf_hashinfo_destroy(tn->ops, tn->hinfo);
-	kfree(tn->hinfo);
+	tcf_idrinfo_destroy(tn->ops, tn->idrinfo);
+	kfree(tn->idrinfo);
 }
 
 int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,
 		       struct netlink_callback *cb, int type,
 		       const struct tc_action_ops *ops);
-int tcf_hash_search(struct tc_action_net *tn, struct tc_action **a, u32 index);
-u32 tcf_hash_new_index(struct tc_action_net *tn);
-bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action **a,
+int tcf_idr_search(struct tc_action_net *tn, struct tc_action **a, u32 index);
+bool tcf_idr_check(struct tc_action_net *tn, u32 index, struct tc_action **a,
 		    int bind);
-int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
-		    struct tc_action **a, const struct tc_action_ops *ops, int bind,
-		    bool cpustats);
-void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est);
-void tcf_hash_insert(struct tc_action_net *tn, struct tc_action *a);
+int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
+		   struct tc_action **a, const struct tc_action_ops *ops,
+		   int bind, bool cpustats);
+void tcf_idr_cleanup(struct tc_action *a, struct nlattr *est);
+void tcf_idr_insert(struct tc_action_net *tn, struct tc_action *a);
 
-int __tcf_hash_release(struct tc_action *a, bool bind, bool strict);
+int __tcf_idr_release(struct tc_action *a, bool bind, bool strict);
 
-static inline int tcf_hash_release(struct tc_action *a, bool bind)
+static inline int tcf_idr_release(struct tc_action *a, bool bind)
 {
-	return __tcf_hash_release(a, bind, false);
+	return __tcf_idr_release(a, bind, false);
 }
 
 int tcf_register_action(struct tc_action_ops *a, struct pernet_operations *ops);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 02fcb0c..7a10a90 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -70,11 +70,11 @@ static void free_tcf(struct rcu_head *head)
 	kfree(p);
 }
 
-static void tcf_hash_destroy(struct tcf_hashinfo *hinfo, struct tc_action *p)
+static void tcf_idr_remove(struct tcf_idrinfo *idrinfo, struct tc_action *p)
 {
-	spin_lock_bh(&hinfo->lock);
-	hlist_del(&p->tcfa_head);
-	spin_unlock_bh(&hinfo->lock);
+	spin_lock_bh(&idrinfo->lock);
+	idr_remove(&idrinfo->action_idr, p->tcfa_index);
+	spin_unlock_bh(&idrinfo->lock);
 	gen_kill_estimator(&p->tcfa_rate_est);
 	/*
 	 * gen_estimator est_timer() might access p->tcfa_lock
@@ -83,7 +83,7 @@ static void tcf_hash_destroy(struct tcf_hashinfo *hinfo, struct tc_action *p)
 	call_rcu(&p->tcfa_rcu, free_tcf);
 }
 
-int __tcf_hash_release(struct tc_action *p, bool bind, bool strict)
+int __tcf_idr_release(struct tc_action *p, bool bind, bool strict)
 {
 	int ret = 0;
 
@@ -97,64 +97,60 @@ int __tcf_hash_release(struct tc_action *p, bool bind, bool strict)
 		if (p->tcfa_bindcnt <= 0 && p->tcfa_refcnt <= 0) {
 			if (p->ops->cleanup)
 				p->ops->cleanup(p, bind);
-			tcf_hash_destroy(p->hinfo, p);
+			tcf_idr_remove(p->idrinfo, p);
 			ret = ACT_P_DELETED;
 		}
 	}
 
 	return ret;
 }
-EXPORT_SYMBOL(__tcf_hash_release);
+EXPORT_SYMBOL(__tcf_idr_release);
 
-static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
+static int tcf_dump_walker(struct tcf_idrinfo *idrinfo, struct sk_buff *skb,
 			   struct netlink_callback *cb)
 {
-	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
+	int err = 0, index = -1, s_i = 0, n_i = 0;
 	u32 act_flags = cb->args[2];
 	unsigned long jiffy_since = cb->args[3];
 	struct nlattr *nest;
+	struct idr *idr = &idrinfo->action_idr;
+	struct tc_action *p;
+	unsigned long id = 1;
 
-	spin_lock_bh(&hinfo->lock);
+	spin_lock_bh(&idrinfo->lock);
 
 	s_i = cb->args[0];
 
-	for (i = 0; i < (hinfo->hmask + 1); i++) {
-		struct hlist_head *head;
-		struct tc_action *p;
-
-		head = &hinfo->htab[tcf_hash(i, hinfo->hmask)];
-
-		hlist_for_each_entry_rcu(p, head, tcfa_head) {
-			index++;
-			if (index < s_i)
-				continue;
-
-			if (jiffy_since &&
-			    time_after(jiffy_since,
-				       (unsigned long)p->tcfa_tm.lastuse))
-				continue;
-
-			nest = nla_nest_start(skb, n_i);
-			if (nest == NULL)
-				goto nla_put_failure;
-			err = tcf_action_dump_1(skb, p, 0, 0);
-			if (err < 0) {
-				index--;
-				nlmsg_trim(skb, nest);
-				goto done;
-			}
-			nla_nest_end(skb, nest);
-			n_i++;
-			if (!(act_flags & TCA_FLAG_LARGE_DUMP_ON) &&
-			    n_i >= TCA_ACT_MAX_PRIO)
-				goto done;
+	idr_for_each_entry(idr, p, id) {
+		index++;
+		if (index < s_i)
+			continue;
+
+		if (jiffy_since &&
+		    time_after(jiffy_since,
+			       (unsigned long)p->tcfa_tm.lastuse))
+			continue;
+
+		nest = nla_nest_start(skb, n_i);
+		if (!nest)
+			goto nla_put_failure;
+		err = tcf_action_dump_1(skb, p, 0, 0);
+		if (err < 0) {
+			index--;
+			nlmsg_trim(skb, nest);
+			goto done;
 		}
+		nla_nest_end(skb, nest);
+		n_i++;
+		if (!(act_flags & TCA_FLAG_LARGE_DUMP_ON) &&
+		    n_i >= TCA_ACT_MAX_PRIO)
+			goto done;
 	}
 done:
 	if (index >= 0)
 		cb->args[0] = index + 1;
 
-	spin_unlock_bh(&hinfo->lock);
+	spin_unlock_bh(&idrinfo->lock);
 	if (n_i) {
 		if (act_flags & TCA_FLAG_LARGE_DUMP_ON)
 			cb->args[1] = n_i;
@@ -166,31 +162,29 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 	goto done;
 }
 
-static int tcf_del_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
+static int tcf_del_walker(struct tcf_idrinfo *idrinfo, struct sk_buff *skb,
 			  const struct tc_action_ops *ops)
 {
 	struct nlattr *nest;
-	int i = 0, n_i = 0;
+	int n_i = 0;
 	int ret = -EINVAL;
+	struct idr *idr = &idrinfo->action_idr;
+	struct tc_action *p;
+	unsigned long id = 1;
 
 	nest = nla_nest_start(skb, 0);
 	if (nest == NULL)
 		goto nla_put_failure;
 	if (nla_put_string(skb, TCA_KIND, ops->kind))
 		goto nla_put_failure;
-	for (i = 0; i < (hinfo->hmask + 1); i++) {
-		struct hlist_head *head;
-		struct hlist_node *n;
-		struct tc_action *p;
-
-		head = &hinfo->htab[tcf_hash(i, hinfo->hmask)];
-		hlist_for_each_entry_safe(p, n, head, tcfa_head) {
-			ret = __tcf_hash_release(p, false, true);
-			if (ret == ACT_P_DELETED) {
-				module_put(p->ops->owner);
-				n_i++;
-			} else if (ret < 0)
-				goto nla_put_failure;
+
+	idr_for_each_entry(idr, p, id) {
+		ret = __tcf_idr_release(p, false, true);
+		if (ret == ACT_P_DELETED) {
+			module_put(p->ops->owner);
+			n_i++;
+		} else if (ret < 0) {
+			goto nla_put_failure;
 		}
 	}
 	if (nla_put_u32(skb, TCA_FCNT, n_i))
@@ -207,12 +201,12 @@ int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,
 		       struct netlink_callback *cb, int type,
 		       const struct tc_action_ops *ops)
 {
-	struct tcf_hashinfo *hinfo = tn->hinfo;
+	struct tcf_idrinfo *idrinfo = tn->idrinfo;
 
 	if (type == RTM_DELACTION) {
-		return tcf_del_walker(hinfo, skb, ops);
+		return tcf_del_walker(idrinfo, skb, ops);
 	} else if (type == RTM_GETACTION) {
-		return tcf_dump_walker(hinfo, skb, cb);
+		return tcf_dump_walker(idrinfo, skb, cb);
 	} else {
 		WARN(1, "tcf_generic_walker: unknown action %d\n", type);
 		return -EINVAL;
@@ -220,40 +214,21 @@ int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(tcf_generic_walker);
 
-static struct tc_action *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
+static struct tc_action *tcf_idr_lookup(u32 index, struct tcf_idrinfo *idrinfo)
 {
 	struct tc_action *p = NULL;
-	struct hlist_head *head;
 
-	spin_lock_bh(&hinfo->lock);
-	head = &hinfo->htab[tcf_hash(index, hinfo->hmask)];
-	hlist_for_each_entry_rcu(p, head, tcfa_head)
-		if (p->tcfa_index == index)
-			break;
-	spin_unlock_bh(&hinfo->lock);
+	spin_lock_bh(&idrinfo->lock);
+	p = idr_find(&idrinfo->action_idr, index);
+	spin_unlock_bh(&idrinfo->lock);
 
 	return p;
 }
 
-u32 tcf_hash_new_index(struct tc_action_net *tn)
-{
-	struct tcf_hashinfo *hinfo = tn->hinfo;
-	u32 val = hinfo->index;
-
-	do {
-		if (++val == 0)
-			val = 1;
-	} while (tcf_hash_lookup(val, hinfo));
-
-	hinfo->index = val;
-	return val;
-}
-EXPORT_SYMBOL(tcf_hash_new_index);
-
-int tcf_hash_search(struct tc_action_net *tn, struct tc_action **a, u32 index)
+int tcf_idr_search(struct tc_action_net *tn, struct tc_action **a, u32 index)
 {
-	struct tcf_hashinfo *hinfo = tn->hinfo;
-	struct tc_action *p = tcf_hash_lookup(index, hinfo);
+	struct tcf_idrinfo *idrinfo = tn->idrinfo;
+	struct tc_action *p = tcf_idr_lookup(index, idrinfo);
 
 	if (p) {
 		*a = p;
@@ -261,15 +236,15 @@ int tcf_hash_search(struct tc_action_net *tn, struct tc_action **a, u32 index)
 	}
 	return 0;
 }
-EXPORT_SYMBOL(tcf_hash_search);
+EXPORT_SYMBOL(tcf_idr_search);
 
-bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action **a,
-		    int bind)
+bool tcf_idr_check(struct tc_action_net *tn, u32 index, struct tc_action **a,
+		   int bind)
 {
-	struct tcf_hashinfo *hinfo = tn->hinfo;
-	struct tc_action *p = NULL;
+	struct tcf_idrinfo *idrinfo = tn->idrinfo;
+	struct tc_action *p = tcf_idr_lookup(index, idrinfo);
 
-	if (index && (p = tcf_hash_lookup(index, hinfo)) != NULL) {
+	if (index && p) {
 		if (bind)
 			p->tcfa_bindcnt++;
 		p->tcfa_refcnt++;
@@ -278,23 +253,25 @@ bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action **a,
 	}
 	return false;
 }
-EXPORT_SYMBOL(tcf_hash_check);
+EXPORT_SYMBOL(tcf_idr_check);
 
-void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est)
+void tcf_idr_cleanup(struct tc_action *a, struct nlattr *est)
 {
 	if (est)
 		gen_kill_estimator(&a->tcfa_rate_est);
 	call_rcu(&a->tcfa_rcu, free_tcf);
 }
-EXPORT_SYMBOL(tcf_hash_cleanup);
+EXPORT_SYMBOL(tcf_idr_cleanup);
 
-int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
-		    struct tc_action **a, const struct tc_action_ops *ops,
-		    int bind, bool cpustats)
+int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
+		   struct tc_action **a, const struct tc_action_ops *ops,
+		   int bind, bool cpustats)
 {
 	struct tc_action *p = kzalloc(ops->size, GFP_KERNEL);
-	struct tcf_hashinfo *hinfo = tn->hinfo;
+	struct tcf_idrinfo *idrinfo = tn->idrinfo;
+	struct idr *idr = &idrinfo->action_idr;
 	int err = -ENOMEM;
+	unsigned long idr_index;
 
 	if (unlikely(!p))
 		return -ENOMEM;
@@ -317,8 +294,26 @@ int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 		}
 	}
 	spin_lock_init(&p->tcfa_lock);
-	INIT_HLIST_NODE(&p->tcfa_head);
-	p->tcfa_index = index ? index : tcf_hash_new_index(tn);
+	/* user doesn't specify an index */
+	if (!index) {
+		spin_lock_bh(&idrinfo->lock);
+		err = idr_alloc(idr, NULL, &idr_index, 1, 0, GFP_KERNEL);
+		spin_unlock_bh(&idrinfo->lock);
+		if (err) {
+err3:
+			free_percpu(p->cpu_qstats);
+			goto err2;
+		}
+		p->tcfa_index = idr_index;
+	} else {
+		spin_lock_bh(&idrinfo->lock);
+		err = idr_alloc(idr, NULL, NULL, index, index + 1, GFP_KERNEL);
+		spin_unlock_bh(&idrinfo->lock);
+		if (err)
+			goto err3;
+		p->tcfa_index = index;
+	}
+
 	p->tcfa_tm.install = jiffies;
 	p->tcfa_tm.lastuse = jiffies;
 	p->tcfa_tm.firstuse = 0;
@@ -327,52 +322,46 @@ int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 					&p->tcfa_rate_est,
 					&p->tcfa_lock, NULL, est);
 		if (err) {
-			free_percpu(p->cpu_qstats);
-			goto err2;
+			goto err3;
 		}
 	}
 
-	p->hinfo = hinfo;
+	p->idrinfo = idrinfo;
 	p->ops = ops;
 	INIT_LIST_HEAD(&p->list);
 	*a = p;
 	return 0;
 }
-EXPORT_SYMBOL(tcf_hash_create);
+EXPORT_SYMBOL(tcf_idr_create);
 
-void tcf_hash_insert(struct tc_action_net *tn, struct tc_action *a)
+void tcf_idr_insert(struct tc_action_net *tn, struct tc_action *a)
 {
-	struct tcf_hashinfo *hinfo = tn->hinfo;
-	unsigned int h = tcf_hash(a->tcfa_index, hinfo->hmask);
+	struct tcf_idrinfo *idrinfo = tn->idrinfo;
 
-	spin_lock_bh(&hinfo->lock);
-	hlist_add_head(&a->tcfa_head, &hinfo->htab[h]);
-	spin_unlock_bh(&hinfo->lock);
+	spin_lock_bh(&idrinfo->lock);
+	idr_replace(&idrinfo->action_idr, a, a->tcfa_index);
+	spin_unlock_bh(&idrinfo->lock);
 }
-EXPORT_SYMBOL(tcf_hash_insert);
+EXPORT_SYMBOL(tcf_idr_insert);
 
-void tcf_hashinfo_destroy(const struct tc_action_ops *ops,
-			  struct tcf_hashinfo *hinfo)
+void tcf_idrinfo_destroy(const struct tc_action_ops *ops,
+			 struct tcf_idrinfo *idrinfo)
 {
-	int i;
-
-	for (i = 0; i < hinfo->hmask + 1; i++) {
-		struct tc_action *p;
-		struct hlist_node *n;
-
-		hlist_for_each_entry_safe(p, n, &hinfo->htab[i], tcfa_head) {
-			int ret;
+	struct idr *idr = &idrinfo->action_idr;
+	struct tc_action *p;
+	int ret;
+	unsigned long id = 1;
 
-			ret = __tcf_hash_release(p, false, true);
-			if (ret == ACT_P_DELETED)
-				module_put(ops->owner);
-			else if (ret < 0)
-				return;
-		}
+	idr_for_each_entry(idr, p, id) {
+		ret = __tcf_idr_release(p, false, true);
+		if (ret == ACT_P_DELETED)
+			module_put(ops->owner);
+		else if (ret < 0)
+			return;
 	}
-	kfree(hinfo->htab);
+	idr_destroy(&idrinfo->action_idr);
 }
-EXPORT_SYMBOL(tcf_hashinfo_destroy);
+EXPORT_SYMBOL(tcf_idrinfo_destroy);
 
 static LIST_HEAD(act_base);
 static DEFINE_RWLOCK(act_mod_lock);
@@ -524,7 +513,7 @@ int tcf_action_destroy(struct list_head *actions, int bind)
 	int ret = 0;
 
 	list_for_each_entry_safe(a, tmp, actions, list) {
-		ret = __tcf_hash_release(a, bind, true);
+		ret = __tcf_idr_release(a, bind, true);
 		if (ret == ACT_P_DELETED)
 			module_put(a->ops->owner);
 		else if (ret < 0)
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 9afe133..c0c707e 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -21,7 +21,6 @@
 #include <linux/tc_act/tc_bpf.h>
 #include <net/tc_act/tc_bpf.h>
 
-#define BPF_TAB_MASK		15
 #define ACT_BPF_NAME_LEN	256
 
 struct tcf_bpf_cfg {
@@ -295,9 +294,9 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 
 	parm = nla_data(tb[TCA_ACT_BPF_PARMS]);
 
-	if (!tcf_hash_check(tn, parm->index, act, bind)) {
-		ret = tcf_hash_create(tn, parm->index, est, act,
-				      &act_bpf_ops, bind, true);
+	if (!tcf_idr_check(tn, parm->index, act, bind)) {
+		ret = tcf_idr_create(tn, parm->index, est, act,
+				     &act_bpf_ops, bind, true);
 		if (ret < 0)
 			return ret;
 
@@ -307,7 +306,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 		if (bind)
 			return 0;
 
-		tcf_hash_release(*act, bind);
+		tcf_idr_release(*act, bind);
 		if (!replace)
 			return -EEXIST;
 	}
@@ -343,7 +342,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 	rcu_assign_pointer(prog->filter, cfg.filter);
 
 	if (res == ACT_P_CREATED) {
-		tcf_hash_insert(tn, *act);
+		tcf_idr_insert(tn, *act);
 	} else {
 		/* make sure the program being replaced is no longer executing */
 		synchronize_rcu();
@@ -353,7 +352,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 	return res;
 out:
 	if (res == ACT_P_CREATED)
-		tcf_hash_cleanup(*act, est);
+		tcf_idr_cleanup(*act, est);
 
 	return ret;
 }
@@ -379,7 +378,7 @@ static int tcf_bpf_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, bpf_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_bpf_ops __read_mostly = {
@@ -399,7 +398,7 @@ static __net_init int bpf_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, bpf_net_id);
 
-	return tc_action_net_init(tn, &act_bpf_ops, BPF_TAB_MASK);
+	return tc_action_net_init(tn, &act_bpf_ops);
 }
 
 static void __net_exit bpf_exit_net(struct net *net)
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 2155bc6..10b7a88 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -28,8 +28,6 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
-#define CONNMARK_TAB_MASK     3
-
 static unsigned int connmark_net_id;
 static struct tc_action_ops act_connmark_ops;
 
@@ -119,9 +117,9 @@ static int tcf_connmark_init(struct net *net, struct nlattr *nla,
 
 	parm = nla_data(tb[TCA_CONNMARK_PARMS]);
 
-	if (!tcf_hash_check(tn, parm->index, a, bind)) {
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_connmark_ops, bind, false);
+	if (!tcf_idr_check(tn, parm->index, a, bind)) {
+		ret = tcf_idr_create(tn, parm->index, est, a,
+				     &act_connmark_ops, bind, false);
 		if (ret)
 			return ret;
 
@@ -130,13 +128,13 @@ static int tcf_connmark_init(struct net *net, struct nlattr *nla,
 		ci->net = net;
 		ci->zone = parm->zone;
 
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 		ret = ACT_P_CREATED;
 	} else {
 		ci = to_connmark(*a);
 		if (bind)
 			return 0;
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 		/* replacing action and zone */
@@ -189,7 +187,7 @@ static int tcf_connmark_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, connmark_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_connmark_ops = {
@@ -208,7 +206,7 @@ static __net_init int connmark_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, connmark_net_id);
 
-	return tc_action_net_init(tn, &act_connmark_ops, CONNMARK_TAB_MASK);
+	return tc_action_net_init(tn, &act_connmark_ops);
 }
 
 static void __net_exit connmark_exit_net(struct net *net)
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 67afc12..1c40caa 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -37,8 +37,6 @@
 #include <linux/tc_act/tc_csum.h>
 #include <net/tc_act/tc_csum.h>
 
-#define CSUM_TAB_MASK 15
-
 static const struct nla_policy csum_policy[TCA_CSUM_MAX + 1] = {
 	[TCA_CSUM_PARMS] = { .len = sizeof(struct tc_csum), },
 };
@@ -67,16 +65,16 @@ static int tcf_csum_init(struct net *net, struct nlattr *nla,
 		return -EINVAL;
 	parm = nla_data(tb[TCA_CSUM_PARMS]);
 
-	if (!tcf_hash_check(tn, parm->index, a, bind)) {
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_csum_ops, bind, false);
+	if (!tcf_idr_check(tn, parm->index, a, bind)) {
+		ret = tcf_idr_create(tn, parm->index, est, a,
+				     &act_csum_ops, bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)/* dont override defaults */
 			return 0;
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -88,7 +86,7 @@ static int tcf_csum_init(struct net *net, struct nlattr *nla,
 	spin_unlock_bh(&p->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 
 	return ret;
 }
@@ -609,7 +607,7 @@ static int tcf_csum_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, csum_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_csum_ops = {
@@ -628,7 +626,7 @@ static __net_init int csum_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, csum_net_id);
 
-	return tc_action_net_init(tn, &act_csum_ops, CSUM_TAB_MASK);
+	return tc_action_net_init(tn, &act_csum_ops);
 }
 
 static void __net_exit csum_exit_net(struct net *net)
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 99afe8b..e29a48e 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -23,8 +23,6 @@
 #include <linux/tc_act/tc_gact.h>
 #include <net/tc_act/tc_gact.h>
 
-#define GACT_TAB_MASK	15
-
 static unsigned int gact_net_id;
 static struct tc_action_ops act_gact_ops;
 
@@ -92,16 +90,16 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 	}
 #endif
 
-	if (!tcf_hash_check(tn, parm->index, a, bind)) {
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_gact_ops, bind, true);
+	if (!tcf_idr_check(tn, parm->index, a, bind)) {
+		ret = tcf_idr_create(tn, parm->index, est, a,
+				     &act_gact_ops, bind, true);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)/* dont override defaults */
 			return 0;
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -122,7 +120,7 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 	}
 #endif
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 	return ret;
 }
 
@@ -214,7 +212,7 @@ static int tcf_gact_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, gact_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_gact_ops = {
@@ -234,7 +232,7 @@ static __net_init int gact_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, gact_net_id);
 
-	return tc_action_net_init(tn, &act_gact_ops, GACT_TAB_MASK);
+	return tc_action_net_init(tn, &act_gact_ops);
 }
 
 static void __net_exit gact_exit_net(struct net *net)
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index c5dec30..770c5d9 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -34,8 +34,6 @@
 #include <linux/etherdevice.h>
 #include <net/ife.h>
 
-#define IFE_TAB_MASK 15
-
 static unsigned int ife_net_id;
 static int max_metacnt = IFE_META_MAX + 1;
 static struct tc_action_ops act_ife_ops;
@@ -452,7 +450,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 
 	parm = nla_data(tb[TCA_IFE_PARMS]);
 
-	exists = tcf_hash_check(tn, parm->index, a, bind);
+	exists = tcf_idr_check(tn, parm->index, a, bind);
 	if (exists && bind)
 		return 0;
 
@@ -462,20 +460,20 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 		**/
 		if (!tb[TCA_IFE_TYPE]) {
 			if (exists)
-				tcf_hash_release(*a, bind);
+				tcf_idr_release(*a, bind);
 			pr_info("You MUST pass etherype for encoding\n");
 			return -EINVAL;
 		}
 	}
 
 	if (!exists) {
-		ret = tcf_hash_create(tn, parm->index, est, a, &act_ife_ops,
-				      bind, false);
+		ret = tcf_idr_create(tn, parm->index, est, a, &act_ife_ops,
+				     bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -518,7 +516,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 		if (err) {
 metadata_parse_err:
 			if (exists)
-				tcf_hash_release(*a, bind);
+				tcf_idr_release(*a, bind);
 			if (ret == ACT_P_CREATED)
 				_tcf_ife_cleanup(*a, bind);
 
@@ -552,7 +550,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 		spin_unlock_bh(&ife->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 
 	return ret;
 }
@@ -811,7 +809,7 @@ static int tcf_ife_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, ife_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_ife_ops = {
@@ -831,7 +829,7 @@ static __net_init int ife_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, ife_net_id);
 
-	return tc_action_net_init(tn, &act_ife_ops, IFE_TAB_MASK);
+	return tc_action_net_init(tn, &act_ife_ops);
 }
 
 static void __net_exit ife_exit_net(struct net *net)
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index d516ba8..c59f600 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -28,8 +28,6 @@
 #include <linux/netfilter_ipv4/ip_tables.h>
 
 
-#define IPT_TAB_MASK     15
-
 static unsigned int ipt_net_id;
 static struct tc_action_ops act_ipt_ops;
 
@@ -116,33 +114,33 @@ static int __tcf_ipt_init(struct net *net, unsigned int id, struct nlattr *nla,
 	if (tb[TCA_IPT_INDEX] != NULL)
 		index = nla_get_u32(tb[TCA_IPT_INDEX]);
 
-	exists = tcf_hash_check(tn, index, a, bind);
+	exists = tcf_idr_check(tn, index, a, bind);
 	if (exists && bind)
 		return 0;
 
 	if (tb[TCA_IPT_HOOK] == NULL || tb[TCA_IPT_TARG] == NULL) {
 		if (exists)
-			tcf_hash_release(*a, bind);
+			tcf_idr_release(*a, bind);
 		return -EINVAL;
 	}
 
 	td = (struct xt_entry_target *)nla_data(tb[TCA_IPT_TARG]);
 	if (nla_len(tb[TCA_IPT_TARG]) < td->u.target_size) {
 		if (exists)
-			tcf_hash_release(*a, bind);
+			tcf_idr_release(*a, bind);
 		return -EINVAL;
 	}
 
 	if (!exists) {
-		ret = tcf_hash_create(tn, index, est, a, ops, bind,
-				      false);
+		ret = tcf_idr_create(tn, index, est, a, ops, bind,
+				     false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)/* dont override defaults */
 			return 0;
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 
 		if (!ovr)
 			return -EEXIST;
@@ -178,7 +176,7 @@ static int __tcf_ipt_init(struct net *net, unsigned int id, struct nlattr *nla,
 	ipt->tcfi_hook  = hook;
 	spin_unlock_bh(&ipt->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 	return ret;
 
 err3:
@@ -187,7 +185,7 @@ static int __tcf_ipt_init(struct net *net, unsigned int id, struct nlattr *nla,
 	kfree(tname);
 err1:
 	if (ret == ACT_P_CREATED)
-		tcf_hash_cleanup(*a, est);
+		tcf_idr_cleanup(*a, est);
 	return err;
 }
 
@@ -314,7 +312,7 @@ static int tcf_ipt_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, ipt_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_ipt_ops = {
@@ -334,7 +332,7 @@ static __net_init int ipt_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, ipt_net_id);
 
-	return tc_action_net_init(tn, &act_ipt_ops, IPT_TAB_MASK);
+	return tc_action_net_init(tn, &act_ipt_ops);
 }
 
 static void __net_exit ipt_exit_net(struct net *net)
@@ -364,7 +362,7 @@ static int tcf_xt_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, xt_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_xt_ops = {
@@ -384,7 +382,7 @@ static __net_init int xt_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, xt_net_id);
 
-	return tc_action_net_init(tn, &act_xt_ops, IPT_TAB_MASK);
+	return tc_action_net_init(tn, &act_xt_ops);
 }
 
 static void __net_exit xt_exit_net(struct net *net)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 1b5549a..416627c 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -28,7 +28,6 @@
 #include <linux/tc_act/tc_mirred.h>
 #include <net/tc_act/tc_mirred.h>
 
-#define MIRRED_TAB_MASK     7
 static LIST_HEAD(mirred_list);
 static DEFINE_SPINLOCK(mirred_list_lock);
 
@@ -94,7 +93,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		return -EINVAL;
 	parm = nla_data(tb[TCA_MIRRED_PARMS]);
 
-	exists = tcf_hash_check(tn, parm->index, a, bind);
+	exists = tcf_idr_check(tn, parm->index, a, bind);
 	if (exists && bind)
 		return 0;
 
@@ -106,14 +105,14 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		break;
 	default:
 		if (exists)
-			tcf_hash_release(*a, bind);
+			tcf_idr_release(*a, bind);
 		return -EINVAL;
 	}
 	if (parm->ifindex) {
 		dev = __dev_get_by_index(net, parm->ifindex);
 		if (dev == NULL) {
 			if (exists)
-				tcf_hash_release(*a, bind);
+				tcf_idr_release(*a, bind);
 			return -ENODEV;
 		}
 		mac_header_xmit = dev_is_mac_header_xmit(dev);
@@ -124,13 +123,13 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	if (!exists) {
 		if (dev == NULL)
 			return -EINVAL;
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_mirred_ops, bind, true);
+		ret = tcf_idr_create(tn, parm->index, est, a,
+				     &act_mirred_ops, bind, true);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -152,7 +151,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		spin_lock_bh(&mirred_list_lock);
 		list_add(&m->tcfm_list, &mirred_list);
 		spin_unlock_bh(&mirred_list_lock);
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 	}
 
 	return ret;
@@ -283,7 +282,7 @@ static int tcf_mirred_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, mirred_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static int mirred_device_event(struct notifier_block *unused,
@@ -344,7 +343,7 @@ static __net_init int mirred_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, mirred_net_id);
 
-	return tc_action_net_init(tn, &act_mirred_ops, MIRRED_TAB_MASK);
+	return tc_action_net_init(tn, &act_mirred_ops);
 }
 
 static void __net_exit mirred_exit_net(struct net *net)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 9016ab8..c365d01 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -29,8 +29,6 @@
 #include <net/udp.h>
 
 
-#define NAT_TAB_MASK	15
-
 static unsigned int nat_net_id;
 static struct tc_action_ops act_nat_ops;
 
@@ -58,16 +56,16 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 		return -EINVAL;
 	parm = nla_data(tb[TCA_NAT_PARMS]);
 
-	if (!tcf_hash_check(tn, parm->index, a, bind)) {
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_nat_ops, bind, false);
+	if (!tcf_idr_check(tn, parm->index, a, bind)) {
+		ret = tcf_idr_create(tn, parm->index, est, a,
+				     &act_nat_ops, bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)
 			return 0;
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -83,7 +81,7 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	spin_unlock_bh(&p->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 
 	return ret;
 }
@@ -290,7 +288,7 @@ static int tcf_nat_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, nat_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_nat_ops = {
@@ -309,7 +307,7 @@ static __net_init int nat_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, nat_net_id);
 
-	return tc_action_net_init(tn, &act_nat_ops, NAT_TAB_MASK);
+	return tc_action_net_init(tn, &act_nat_ops);
 }
 
 static void __net_exit nat_exit_net(struct net *net)
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 7dc5892..491fe5de 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -24,8 +24,6 @@
 #include <net/tc_act/tc_pedit.h>
 #include <uapi/linux/tc_act/tc_pedit.h>
 
-#define PEDIT_TAB_MASK	15
-
 static unsigned int pedit_net_id;
 static struct tc_action_ops act_pedit_ops;
 
@@ -168,17 +166,17 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	if (IS_ERR(keys_ex))
 		return PTR_ERR(keys_ex);
 
-	if (!tcf_hash_check(tn, parm->index, a, bind)) {
+	if (!tcf_idr_check(tn, parm->index, a, bind)) {
 		if (!parm->nkeys)
 			return -EINVAL;
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_pedit_ops, bind, false);
+		ret = tcf_idr_create(tn, parm->index, est, a,
+				     &act_pedit_ops, bind, false);
 		if (ret)
 			return ret;
 		p = to_pedit(*a);
 		keys = kmalloc(ksize, GFP_KERNEL);
 		if (keys == NULL) {
-			tcf_hash_cleanup(*a, est);
+			tcf_idr_cleanup(*a, est);
 			kfree(keys_ex);
 			return -ENOMEM;
 		}
@@ -186,7 +184,7 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	} else {
 		if (bind)
 			return 0;
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 		p = to_pedit(*a);
@@ -214,7 +212,7 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 
 	spin_unlock_bh(&p->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 	return ret;
 }
 
@@ -432,7 +430,7 @@ static int tcf_pedit_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, pedit_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_pedit_ops = {
@@ -452,7 +450,7 @@ static __net_init int pedit_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, pedit_net_id);
 
-	return tc_action_net_init(tn, &act_pedit_ops, PEDIT_TAB_MASK);
+	return tc_action_net_init(tn, &act_pedit_ops);
 }
 
 static void __net_exit pedit_exit_net(struct net *net)
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index b062bc8..3bb2ebf 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -40,8 +40,6 @@ struct tcf_police {
 
 #define to_police(pc) ((struct tcf_police *)pc)
 
-#define POL_TAB_MASK     15
-
 /* old policer structure from before tc actions */
 struct tc_police_compat {
 	u32			index;
@@ -101,18 +99,18 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 		return -EINVAL;
 
 	parm = nla_data(tb[TCA_POLICE_TBF]);
-	exists = tcf_hash_check(tn, parm->index, a, bind);
+	exists = tcf_idr_check(tn, parm->index, a, bind);
 	if (exists && bind)
 		return 0;
 
 	if (!exists) {
-		ret = tcf_hash_create(tn, parm->index, NULL, a,
-				      &act_police_ops, bind, false);
+		ret = tcf_idr_create(tn, parm->index, NULL, a,
+				     &act_police_ops, bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -188,7 +186,7 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 		return ret;
 
 	police->tcfp_t_c = ktime_get_ns();
-	tcf_hash_insert(tn, *a);
+	tcf_idr_insert(tn, *a);
 
 	return ret;
 
@@ -196,7 +194,7 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 	qdisc_put_rtab(P_tab);
 	qdisc_put_rtab(R_tab);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_cleanup(*a, est);
+		tcf_idr_cleanup(*a, est);
 	return err;
 }
 
@@ -310,7 +308,7 @@ static int tcf_police_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, police_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 MODULE_AUTHOR("Alexey Kuznetsov");
@@ -333,7 +331,7 @@ static __net_init int police_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, police_net_id);
 
-	return tc_action_net_init(tn, &act_police_ops, POL_TAB_MASK);
+	return tc_action_net_init(tn, &act_police_ops);
 }
 
 static void __net_exit police_exit_net(struct net *net)
diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
index 59d6645..ec986ae 100644
--- a/net/sched/act_sample.c
+++ b/net/sched/act_sample.c
@@ -25,7 +25,6 @@
 
 #include <linux/if_arp.h>
 
-#define SAMPLE_TAB_MASK     7
 static unsigned int sample_net_id;
 static struct tc_action_ops act_sample_ops;
 
@@ -59,18 +58,18 @@ static int tcf_sample_init(struct net *net, struct nlattr *nla,
 
 	parm = nla_data(tb[TCA_SAMPLE_PARMS]);
 
-	exists = tcf_hash_check(tn, parm->index, a, bind);
+	exists = tcf_idr_check(tn, parm->index, a, bind);
 	if (exists && bind)
 		return 0;
 
 	if (!exists) {
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_sample_ops, bind, false);
+		ret = tcf_idr_create(tn, parm->index, est, a,
+				     &act_sample_ops, bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -82,7 +81,7 @@ static int tcf_sample_init(struct net *net, struct nlattr *nla,
 	psample_group = psample_group_get(net, s->psample_group_num);
 	if (!psample_group) {
 		if (ret == ACT_P_CREATED)
-			tcf_hash_release(*a, bind);
+			tcf_idr_release(*a, bind);
 		return -ENOMEM;
 	}
 	RCU_INIT_POINTER(s->psample_group, psample_group);
@@ -93,7 +92,7 @@ static int tcf_sample_init(struct net *net, struct nlattr *nla,
 	}
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 	return ret;
 }
 
@@ -221,7 +220,7 @@ static int tcf_sample_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, sample_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_sample_ops = {
@@ -241,7 +240,7 @@ static __net_init int sample_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, sample_net_id);
 
-	return tc_action_net_init(tn, &act_sample_ops, SAMPLE_TAB_MASK);
+	return tc_action_net_init(tn, &act_sample_ops);
 }
 
 static void __net_exit sample_exit_net(struct net *net)
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 43605e7..e7b57e5 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -24,8 +24,6 @@
 #include <linux/tc_act/tc_defact.h>
 #include <net/tc_act/tc_defact.h>
 
-#define SIMP_TAB_MASK     7
-
 static unsigned int simp_net_id;
 static struct tc_action_ops act_simp_ops;
 
@@ -102,28 +100,28 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 		return -EINVAL;
 
 	parm = nla_data(tb[TCA_DEF_PARMS]);
-	exists = tcf_hash_check(tn, parm->index, a, bind);
+	exists = tcf_idr_check(tn, parm->index, a, bind);
 	if (exists && bind)
 		return 0;
 
 	if (tb[TCA_DEF_DATA] == NULL) {
 		if (exists)
-			tcf_hash_release(*a, bind);
+			tcf_idr_release(*a, bind);
 		return -EINVAL;
 	}
 
 	defdata = nla_data(tb[TCA_DEF_DATA]);
 
 	if (!exists) {
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_simp_ops, bind, false);
+		ret = tcf_idr_create(tn, parm->index, est, a,
+				     &act_simp_ops, bind, false);
 		if (ret)
 			return ret;
 
 		d = to_defact(*a);
 		ret = alloc_defdata(d, defdata);
 		if (ret < 0) {
-			tcf_hash_cleanup(*a, est);
+			tcf_idr_cleanup(*a, est);
 			return ret;
 		}
 		d->tcf_action = parm->action;
@@ -131,7 +129,7 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	} else {
 		d = to_defact(*a);
 
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 
@@ -139,7 +137,7 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	}
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 	return ret;
 }
 
@@ -183,7 +181,7 @@ static int tcf_simp_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, simp_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_simp_ops = {
@@ -203,7 +201,7 @@ static __net_init int simp_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, simp_net_id);
 
-	return tc_action_net_init(tn, &act_simp_ops, SIMP_TAB_MASK);
+	return tc_action_net_init(tn, &act_simp_ops);
 }
 
 static void __net_exit simp_exit_net(struct net *net)
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 6b3e65d..59949d6 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -27,8 +27,6 @@
 #include <linux/tc_act/tc_skbedit.h>
 #include <net/tc_act/tc_skbedit.h>
 
-#define SKBEDIT_TAB_MASK     15
-
 static unsigned int skbedit_net_id;
 static struct tc_action_ops act_skbedit_ops;
 
@@ -118,18 +116,18 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 
 	parm = nla_data(tb[TCA_SKBEDIT_PARMS]);
 
-	exists = tcf_hash_check(tn, parm->index, a, bind);
+	exists = tcf_idr_check(tn, parm->index, a, bind);
 	if (exists && bind)
 		return 0;
 
 	if (!flags) {
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		return -EINVAL;
 	}
 
 	if (!exists) {
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_skbedit_ops, bind, false);
+		ret = tcf_idr_create(tn, parm->index, est, a,
+				     &act_skbedit_ops, bind, false);
 		if (ret)
 			return ret;
 
@@ -137,7 +135,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		ret = ACT_P_CREATED;
 	} else {
 		d = to_skbedit(*a);
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -163,7 +161,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	spin_unlock_bh(&d->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 	return ret;
 }
 
@@ -221,7 +219,7 @@ static int tcf_skbedit_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, skbedit_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_skbedit_ops = {
@@ -240,7 +238,7 @@ static __net_init int skbedit_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, skbedit_net_id);
 
-	return tc_action_net_init(tn, &act_skbedit_ops, SKBEDIT_TAB_MASK);
+	return tc_action_net_init(tn, &act_skbedit_ops);
 }
 
 static void __net_exit skbedit_exit_net(struct net *net)
diff --git a/net/sched/act_skbmod.c b/net/sched/act_skbmod.c
index a73c4bb..b642ad3 100644
--- a/net/sched/act_skbmod.c
+++ b/net/sched/act_skbmod.c
@@ -20,8 +20,6 @@
 #include <linux/tc_act/tc_skbmod.h>
 #include <net/tc_act/tc_skbmod.h>
 
-#define SKBMOD_TAB_MASK     15
-
 static unsigned int skbmod_net_id;
 static struct tc_action_ops act_skbmod_ops;
 
@@ -129,7 +127,7 @@ static int tcf_skbmod_init(struct net *net, struct nlattr *nla,
 	if (parm->flags & SKBMOD_F_SWAPMAC)
 		lflags = SKBMOD_F_SWAPMAC;
 
-	exists = tcf_hash_check(tn, parm->index, a, bind);
+	exists = tcf_idr_check(tn, parm->index, a, bind);
 	if (exists && bind)
 		return 0;
 
@@ -137,14 +135,14 @@ static int tcf_skbmod_init(struct net *net, struct nlattr *nla,
 		return -EINVAL;
 
 	if (!exists) {
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_skbmod_ops, bind, true);
+		ret = tcf_idr_create(tn, parm->index, est, a,
+				     &act_skbmod_ops, bind, true);
 		if (ret)
 			return ret;
 
 		ret = ACT_P_CREATED;
 	} else {
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -155,7 +153,7 @@ static int tcf_skbmod_init(struct net *net, struct nlattr *nla,
 	p = kzalloc(sizeof(struct tcf_skbmod_params), GFP_KERNEL);
 	if (unlikely(!p)) {
 		if (ovr)
-			tcf_hash_release(*a, bind);
+			tcf_idr_release(*a, bind);
 		return -ENOMEM;
 	}
 
@@ -182,7 +180,7 @@ static int tcf_skbmod_init(struct net *net, struct nlattr *nla,
 		kfree_rcu(p_old, rcu);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 	return ret;
 }
 
@@ -245,7 +243,7 @@ static int tcf_skbmod_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, skbmod_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_skbmod_ops = {
@@ -265,7 +263,7 @@ static __net_init int skbmod_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, skbmod_net_id);
 
-	return tc_action_net_init(tn, &act_skbmod_ops, SKBMOD_TAB_MASK);
+	return tc_action_net_init(tn, &act_skbmod_ops);
 }
 
 static void __net_exit skbmod_exit_net(struct net *net)
diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index fd7e756..30c9627 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -20,8 +20,6 @@
 #include <linux/tc_act/tc_tunnel_key.h>
 #include <net/tc_act/tc_tunnel_key.h>
 
-#define TUNNEL_KEY_TAB_MASK     15
-
 static unsigned int tunnel_key_net_id;
 static struct tc_action_ops act_tunnel_key_ops;
 
@@ -100,7 +98,7 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 		return -EINVAL;
 
 	parm = nla_data(tb[TCA_TUNNEL_KEY_PARMS]);
-	exists = tcf_hash_check(tn, parm->index, a, bind);
+	exists = tcf_idr_check(tn, parm->index, a, bind);
 	if (exists && bind)
 		return 0;
 
@@ -159,14 +157,14 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 	}
 
 	if (!exists) {
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_tunnel_key_ops, bind, true);
+		ret = tcf_idr_create(tn, parm->index, est, a,
+				     &act_tunnel_key_ops, bind, true);
 		if (ret)
 			return ret;
 
 		ret = ACT_P_CREATED;
 	} else {
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -177,7 +175,7 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 	params_new = kzalloc(sizeof(*params_new), GFP_KERNEL);
 	if (unlikely(!params_new)) {
 		if (ret == ACT_P_CREATED)
-			tcf_hash_release(*a, bind);
+			tcf_idr_release(*a, bind);
 		return -ENOMEM;
 	}
 
@@ -193,13 +191,13 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 		kfree_rcu(params_old, rcu);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 
 	return ret;
 
 err_out:
 	if (exists)
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 	return ret;
 }
 
@@ -304,7 +302,7 @@ static int tunnel_key_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_tunnel_key_ops = {
@@ -324,7 +322,7 @@ static __net_init int tunnel_key_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
 
-	return tc_action_net_init(tn, &act_tunnel_key_ops, TUNNEL_KEY_TAB_MASK);
+	return tc_action_net_init(tn, &act_tunnel_key_ops);
 }
 
 static void __net_exit tunnel_key_exit_net(struct net *net)
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index 13ba3a8..16eb067 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -19,8 +19,6 @@
 #include <linux/tc_act/tc_vlan.h>
 #include <net/tc_act/tc_vlan.h>
 
-#define VLAN_TAB_MASK     15
-
 static unsigned int vlan_net_id;
 static struct tc_action_ops act_vlan_ops;
 
@@ -128,7 +126,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	if (!tb[TCA_VLAN_PARMS])
 		return -EINVAL;
 	parm = nla_data(tb[TCA_VLAN_PARMS]);
-	exists = tcf_hash_check(tn, parm->index, a, bind);
+	exists = tcf_idr_check(tn, parm->index, a, bind);
 	if (exists && bind)
 		return 0;
 
@@ -139,13 +137,13 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	case TCA_VLAN_ACT_MODIFY:
 		if (!tb[TCA_VLAN_PUSH_VLAN_ID]) {
 			if (exists)
-				tcf_hash_release(*a, bind);
+				tcf_idr_release(*a, bind);
 			return -EINVAL;
 		}
 		push_vid = nla_get_u16(tb[TCA_VLAN_PUSH_VLAN_ID]);
 		if (push_vid >= VLAN_VID_MASK) {
 			if (exists)
-				tcf_hash_release(*a, bind);
+				tcf_idr_release(*a, bind);
 			return -ERANGE;
 		}
 
@@ -167,20 +165,20 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 		break;
 	default:
 		if (exists)
-			tcf_hash_release(*a, bind);
+			tcf_idr_release(*a, bind);
 		return -EINVAL;
 	}
 	action = parm->v_action;
 
 	if (!exists) {
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_vlan_ops, bind, false);
+		ret = tcf_idr_create(tn, parm->index, est, a,
+				     &act_vlan_ops, bind, false);
 		if (ret)
 			return ret;
 
 		ret = ACT_P_CREATED;
 	} else {
-		tcf_hash_release(*a, bind);
+		tcf_idr_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -199,7 +197,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	spin_unlock_bh(&v->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, *a);
+		tcf_idr_insert(tn, *a);
 	return ret;
 }
 
@@ -252,7 +250,7 @@ static int tcf_vlan_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, vlan_net_id);
 
-	return tcf_hash_search(tn, a, index);
+	return tcf_idr_search(tn, a, index);
 }
 
 static struct tc_action_ops act_vlan_ops = {
@@ -271,7 +269,7 @@ static __net_init int vlan_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, vlan_net_id);
 
-	return tc_action_net_init(tn, &act_vlan_ops, VLAN_TAB_MASK);
+	return tc_action_net_init(tn, &act_vlan_ops);
 }
 
 static void __net_exit vlan_exit_net(struct net *net)
-- 
1.8.3.1


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
