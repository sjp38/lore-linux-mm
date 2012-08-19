Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 057B16B007B
	for <linux-mm@kvack.org>; Sat, 18 Aug 2012 20:52:46 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so2035235bkc.14
        for <linux-mm@kvack.org>; Sat, 18 Aug 2012 17:52:46 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 15/16] openvswitch: use new hashtable implementation
Date: Sun, 19 Aug 2012 02:52:29 +0200
Message-Id: <1345337550-24304-17-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
References: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

Switch openvswitch to use the new hashtable implementation. This reduces the amount of
generic unrelated code in openvswitch.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/openvswitch/vport.c |   30 +++++++++++++-----------------
 1 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 6140336..3484120 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -27,6 +27,7 @@
 #include <linux/rcupdate.h>
 #include <linux/rtnetlink.h>
 #include <linux/compat.h>
+#include <linux/hashtable.h>
 
 #include "vport.h"
 #include "vport-internal_dev.h"
@@ -39,8 +40,8 @@ static const struct vport_ops *vport_ops_list[] = {
 };
 
 /* Protected by RCU read lock for reading, RTNL lock for writing. */
-static struct hlist_head *dev_table;
-#define VPORT_HASH_BUCKETS 1024
+#define VPORT_HASH_BITS 10
+static DEFINE_HASHTABLE(dev_table, VPORT_HASH_BITS);
 
 /**
  *	ovs_vport_init - initialize vport subsystem
@@ -49,10 +50,7 @@ static struct hlist_head *dev_table;
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
@@ -67,12 +65,6 @@ void ovs_vport_exit(void)
 	kfree(dev_table);
 }
 
-static struct hlist_head *hash_bucket(const char *name)
-{
-	unsigned int hash = full_name_hash(name, strlen(name));
-	return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
-}
-
 /**
  *	ovs_vport_locate - find a port that has already been created
  *
@@ -82,11 +74,11 @@ static struct hlist_head *hash_bucket(const char *name)
  */
 struct vport *ovs_vport_locate(const char *name)
 {
-	struct hlist_head *bucket = hash_bucket(name);
 	struct vport *vport;
 	struct hlist_node *node;
+	int key = full_name_hash(name, strlen(name));
 
-	hlist_for_each_entry_rcu(vport, node, bucket, hash_node)
+	hash_for_each_possible_rcu(dev_table, vport, node, hash_node, key)
 		if (!strcmp(name, vport->ops->get_name(vport)))
 			return vport;
 
@@ -170,14 +162,18 @@ struct vport *ovs_vport_add(const struct vport_parms *parms)
 
 	for (i = 0; i < ARRAY_SIZE(vport_ops_list); i++) {
 		if (vport_ops_list[i]->type == parms->type) {
+			int key;
+			const char *name;
+
 			vport = vport_ops_list[i]->create(parms);
 			if (IS_ERR(vport)) {
 				err = PTR_ERR(vport);
 				goto out;
 			}
 
-			hlist_add_head_rcu(&vport->hash_node,
-					   hash_bucket(vport->ops->get_name(vport)));
+			name = vport->ops->get_name(vport);
+			key = full_name_hash(name, strlen(name));
+			hash_add_rcu(dev_table, &vport->hash_node, key);
 			return vport;
 		}
 	}
@@ -218,7 +214,7 @@ void ovs_vport_del(struct vport *vport)
 {
 	ASSERT_RTNL();
 
-	hlist_del_rcu(&vport->hash_node);
+	hash_del_rcu(&vport->hash_node);
 
 	vport->ops->destroy(vport);
 }
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
