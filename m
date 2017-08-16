From: Chris Mi <chrism-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [patch net-next 2/3] net/sched: Change cls_flower to use IDR
Date: Tue, 15 Aug 2017 22:12:17 -0400
Message-ID: <1502849538-14284-3-git-send-email-chrism@mellanox.com>
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

Currently, all filters with the same priority are linked in a doubly
linked list. Every filter should have a unique handle. To make the
handle unique, we need to iterate the list every time to see if the
handle exists or not when inserting a new filter. It is time-consuming.
For example, it takes about 5m3.169s to insert 64K rules.

This patch changes cls_flower to use IDR. With this patch, it
takes about 0m1.127s to insert 64K rules. The improvement is huge.

But please note that in this testing, all filters share the same action.
If every filter has a unique action, that is another bottleneck.
Follow-up patch in this patchset addresses that.

Signed-off-by: Chris Mi <chrism-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 net/sched/cls_flower.c | 55 +++++++++++++++++++++-----------------------------
 1 file changed, 23 insertions(+), 32 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 052e902..071f0ef 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -68,7 +68,6 @@ struct cls_fl_head {
 	struct rhashtable ht;
 	struct fl_flow_mask mask;
 	struct flow_dissector dissector;
-	u32 hgen;
 	bool mask_assigned;
 	struct list_head filters;
 	struct rhashtable_params ht_params;
@@ -76,6 +75,7 @@ struct cls_fl_head {
 		struct work_struct work;
 		struct rcu_head	rcu;
 	};
+	struct idr handle_idr;
 };
 
 struct cls_fl_filter {
@@ -210,6 +210,7 @@ static int fl_init(struct tcf_proto *tp)
 
 	INIT_LIST_HEAD_RCU(&head->filters);
 	rcu_assign_pointer(tp->root, head);
+	idr_init(&head->handle_idr);
 
 	return 0;
 }
@@ -295,6 +296,9 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 
 static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
+	struct cls_fl_head *head = rtnl_dereference(tp->root);
+
+	idr_remove(&head->handle_idr, f->handle);
 	list_del_rcu(&f->list);
 	if (!tc_skip_hw(f->flags))
 		fl_hw_destroy_filter(tp, f);
@@ -327,6 +331,7 @@ static void fl_destroy(struct tcf_proto *tp)
 
 	list_for_each_entry_safe(f, next, &head->filters, list)
 		__fl_delete(tp, f);
+	idr_destroy(&head->handle_idr);
 
 	__module_get(THIS_MODULE);
 	call_rcu(&head->rcu, fl_destroy_rcu);
@@ -335,12 +340,8 @@ static void fl_destroy(struct tcf_proto *tp)
 static void *fl_get(struct tcf_proto *tp, u32 handle)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
-	struct cls_fl_filter *f;
 
-	list_for_each_entry(f, &head->filters, list)
-		if (f->handle == handle)
-			return f;
-	return NULL;
+	return idr_find(&head->handle_idr, handle);
 }
 
 static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
@@ -859,27 +860,6 @@ static int fl_set_parms(struct net *net, struct tcf_proto *tp,
 	return 0;
 }
 
-static u32 fl_grab_new_handle(struct tcf_proto *tp,
-			      struct cls_fl_head *head)
-{
-	unsigned int i = 0x80000000;
-	u32 handle;
-
-	do {
-		if (++head->hgen == 0x7FFFFFFF)
-			head->hgen = 1;
-	} while (--i > 0 && fl_get(tp, head->hgen));
-
-	if (unlikely(i == 0)) {
-		pr_err("Insufficient number of handles\n");
-		handle = 0;
-	} else {
-		handle = head->hgen;
-	}
-
-	return handle;
-}
-
 static int fl_change(struct net *net, struct sk_buff *in_skb,
 		     struct tcf_proto *tp, unsigned long base,
 		     u32 handle, struct nlattr **tca,
@@ -890,6 +870,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	struct cls_fl_filter *fnew;
 	struct nlattr **tb;
 	struct fl_flow_mask mask = {};
+	unsigned long idr_index;
 	int err;
 
 	if (!tca[TCA_OPTIONS])
@@ -920,13 +901,21 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 		goto errout;
 
 	if (!handle) {
-		handle = fl_grab_new_handle(tp, head);
-		if (!handle) {
-			err = -EINVAL;
+		err = idr_alloc(&head->handle_idr, fnew, &idr_index,
+				1, 0x80000000, GFP_KERNEL);
+		if (err)
 			goto errout;
-		}
+		fnew->handle = idr_index;
+	}
+
+	/* user specifies a handle and it doesn't exist */
+	if (handle && !fold) {
+		err = idr_alloc(&head->handle_idr, fnew, &idr_index,
+				handle, handle + 1, GFP_KERNEL);
+		if (err)
+			goto errout;
+		fnew->handle = idr_index;
 	}
-	fnew->handle = handle;
 
 	if (tb[TCA_FLOWER_FLAGS]) {
 		fnew->flags = nla_get_u32(tb[TCA_FLOWER_FLAGS]);
@@ -980,6 +969,8 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	*arg = fnew;
 
 	if (fold) {
+		fnew->handle = handle;
+		idr_replace(&head->handle_idr, fnew, fnew->handle);
 		list_replace_rcu(&fold->list, &fnew->list);
 		tcf_unbind_filter(tp, &fold->res);
 		call_rcu(&fold->rcu, fl_destroy_filter);
-- 
1.8.3.1


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
