Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 671386B0078
	for <linux-mm@kvack.org>; Sun, 28 Oct 2012 15:04:00 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so2905575qcq.14
        for <linux-mm@kvack.org>; Sun, 28 Oct 2012 12:04:00 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v7 15/16] openvswitch: use new hashtable implementation
Date: Sun, 28 Oct 2012 15:02:27 -0400
Message-Id: <1351450948-15618-15-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

Switch openvswitch to use the new hashtable implementation. This reduces the amount of
generic unrelated code in openvswitch.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/openvswitch/vport.c | 34 +++++++++++++---------------------
 1 file changed, 13 insertions(+), 21 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 03779e8..3cb9caa 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -28,6 +28,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/compat.h>
 #include <net/net_namespace.h>
+#include <linux/hashtable.h>
 
 #include "datapath.h"
 #include "vport.h"
@@ -41,8 +42,8 @@ static const struct vport_ops *vport_ops_list[] = {
 };
 
 /* Protected by RCU read lock for reading, RTNL lock for writing. */
-static struct hlist_head *dev_table;
-#define VPORT_HASH_BUCKETS 1024
+#define VPORT_HASH_BITS 10
+static DEFINE_HASHTABLE(dev_table, VPORT_HASH_BITS);
 
 /**
  *	ovs_vport_init - initialize vport subsystem
@@ -51,10 +52,7 @@ static struct hlist_head *dev_table;
  */
 int ovs_vport_init(void)
 {
-	dev_table = kzalloc(VPORT_HASH_BUCKETS * sizeof(struct hlist_head),
-			    GFP_KERNEL);
-	if (!dev_table)
-		return -ENOMEM;
+	hash_init(dev_table);
 
 	return 0;
 }
@@ -69,12 +67,6 @@ void ovs_vport_exit(void)
 	kfree(dev_table);
 }
 
-static struct hlist_head *hash_bucket(struct net *net, const char *name)
-{
-	unsigned int hash = jhash(name, strlen(name), (unsigned long) net);
-	return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
-}
-
 /**
  *	ovs_vport_locate - find a port that has already been created
  *
@@ -84,13 +76,12 @@ static struct hlist_head *hash_bucket(struct net *net, const char *name)
  */
 struct vport *ovs_vport_locate(struct net *net, const char *name)
 {
-	struct hlist_head *bucket = hash_bucket(net, name);
 	struct vport *vport;
 	struct hlist_node *node;
+	int key = full_name_hash(name, strlen(name));
 
-	hlist_for_each_entry_rcu(vport, node, bucket, hash_node)
-		if (!strcmp(name, vport->ops->get_name(vport)) &&
-		    net_eq(ovs_dp_get_net(vport->dp), net))
+	hash_for_each_possible_rcu(dev_table, vport, node, hash_node, key)
+		if (!strcmp(name, vport->ops->get_name(vport)))
 			return vport;
 
 	return NULL;
@@ -174,7 +165,8 @@ struct vport *ovs_vport_add(const struct vport_parms *parms)
 
 	for (i = 0; i < ARRAY_SIZE(vport_ops_list); i++) {
 		if (vport_ops_list[i]->type == parms->type) {
-			struct hlist_head *bucket;
+			int key;
+			const char *name;
 
 			vport = vport_ops_list[i]->create(parms);
 			if (IS_ERR(vport)) {
@@ -182,9 +174,9 @@ struct vport *ovs_vport_add(const struct vport_parms *parms)
 				goto out;
 			}
 
-			bucket = hash_bucket(ovs_dp_get_net(vport->dp),
-					     vport->ops->get_name(vport));
-			hlist_add_head_rcu(&vport->hash_node, bucket);
+			name = vport->ops->get_name(vport);
+			key = full_name_hash(name, strlen(name));
+			hash_add_rcu(dev_table, &vport->hash_node, key);
 			return vport;
 		}
 	}
@@ -225,7 +217,7 @@ void ovs_vport_del(struct vport *vport)
 {
 	ASSERT_RTNL();
 
-	hlist_del_rcu(&vport->hash_node);
+	hash_del_rcu(&vport->hash_node);
 
 	vport->ops->destroy(vport);
 }
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
