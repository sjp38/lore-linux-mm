Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 825E36B0261
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:07:54 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id r88so15394916pfi.23
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:07:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s20si6435655pgn.363.2017.11.22.13.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:07:48 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 06/62] idr: Make cursor explicit for cyclic allocation
Date: Wed, 22 Nov 2017 13:06:43 -0800
Message-Id: <20171122210739.29916-7-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The struct idr was 24 bytes (on 64 bit architectures) due to the idr_next
element which was only used for the very few idr_alloc_cyclic users.
Save 8 bytes per struct idr by making idr_alloc_cyclic() take a pointer
to a cursor instead of using idr_next.  This also lets us remove the
idr_get_cursor / idr_set_cursor API as users can now manage access to
their own cursor however they like.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 arch/powerpc/platforms/cell/spufs/sched.c |  2 +-
 drivers/gpu/drm/drm_dp_aux_dev.c          |  5 +++--
 drivers/infiniband/core/cm.c              |  5 ++++-
 drivers/infiniband/hw/mlx4/cm.c           |  3 ++-
 drivers/infiniband/hw/mlx4/mlx4_ib.h      |  1 +
 drivers/rapidio/rio_cm.c                  |  3 ++-
 drivers/rpmsg/qcom_glink_native.c         |  7 +++++--
 drivers/target/target_core_device.c       |  4 +++-
 fs/kernfs/dir.c                           |  5 +++--
 fs/nfsd/nfs4state.c                       |  4 +++-
 fs/nfsd/state.h                           |  1 +
 fs/notify/inotify/inotify_user.c          | 15 +++++++--------
 fs/proc/loadavg.c                         |  2 +-
 include/linux/fsnotify_backend.h          |  1 +
 include/linux/idr.h                       | 31 ++-----------------------------
 include/linux/kernfs.h                    |  1 +
 include/linux/pid_namespace.h             |  1 +
 include/net/sctp/sctp.h                   |  1 +
 kernel/bpf/syscall.c                      |  8 ++++++--
 kernel/cgroup/cgroup.c                    |  4 +++-
 kernel/pid.c                              |  4 ++--
 kernel/pid_namespace.c                    | 12 +++++-------
 lib/idr.c                                 | 23 ++++++++++++++---------
 net/rxrpc/af_rxrpc.c                      |  2 +-
 net/rxrpc/ar-internal.h                   |  1 +
 net/rxrpc/conn_client.c                   | 20 ++++++++------------
 net/sctp/associola.c                      |  3 ++-
 net/sctp/protocol.c                       |  1 +
 tools/testing/radix-tree/idr-test.c       | 18 +++++++++++++++---
 29 files changed, 100 insertions(+), 88 deletions(-)

diff --git a/arch/powerpc/platforms/cell/spufs/sched.c b/arch/powerpc/platforms/cell/spufs/sched.c
index e47761cdcb98..d2c3078472ab 100644
--- a/arch/powerpc/platforms/cell/spufs/sched.c
+++ b/arch/powerpc/platforms/cell/spufs/sched.c
@@ -1093,7 +1093,7 @@ static int show_spu_loadavg(struct seq_file *s, void *private)
 		LOAD_INT(c), LOAD_FRAC(c),
 		count_active_contexts(),
 		atomic_read(&nr_spu_contexts),
-		idr_get_cursor(&task_active_pid_ns(current)->idr));
+		task_active_pid_ns(current)->next_pid - 1);
 	return 0;
 }
 
diff --git a/drivers/gpu/drm/drm_dp_aux_dev.c b/drivers/gpu/drm/drm_dp_aux_dev.c
index 053044201e31..3ce890908ede 100644
--- a/drivers/gpu/drm/drm_dp_aux_dev.c
+++ b/drivers/gpu/drm/drm_dp_aux_dev.c
@@ -50,6 +50,7 @@ struct drm_dp_aux_dev {
 #define DRM_AUX_MINORS	256
 #define AUX_MAX_OFFSET	(1 << 20)
 static DEFINE_IDR(aux_idr);
+static int aux_cursor;
 static DEFINE_MUTEX(aux_idr_mutex);
 static struct class *drm_dp_aux_dev_class;
 static int drm_dev_major = -1;
@@ -80,8 +81,8 @@ static struct drm_dp_aux_dev *alloc_drm_dp_aux_dev(struct drm_dp_aux *aux)
 	kref_init(&aux_dev->refcount);
 
 	mutex_lock(&aux_idr_mutex);
-	index = idr_alloc_cyclic(&aux_idr, aux_dev, 0, DRM_AUX_MINORS,
-				 GFP_KERNEL);
+	index = idr_alloc_cyclic(&aux_idr, &aux_cursor, aux_dev, 0,
+				DRM_AUX_MINORS, GFP_KERNEL);
 	mutex_unlock(&aux_idr_mutex);
 	if (index < 0) {
 		kfree(aux_dev);
diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index f6b159d79977..42d7b37382c4 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -125,6 +125,7 @@ static struct ib_cm {
 	struct rb_root remote_id_table;
 	struct rb_root remote_sidr_table;
 	struct idr local_id_table;
+	int local_id_cursor;
 	__be32 random_id_operand;
 	struct list_head timewait_list;
 	struct workqueue_struct *wq;
@@ -519,7 +520,8 @@ static int cm_alloc_id(struct cm_id_private *cm_id_priv)
 	idr_preload(GFP_KERNEL);
 	spin_lock_irqsave(&cm.lock, flags);
 
-	id = idr_alloc_cyclic(&cm.local_id_table, cm_id_priv, 0, 0, GFP_NOWAIT);
+	id = idr_alloc_cyclic(&cm.local_id_table, &cm.local_id_cursor,
+				cm_id_priv, 0, 0, GFP_NOWAIT);
 
 	spin_unlock_irqrestore(&cm.lock, flags);
 	idr_preload_end();
@@ -4322,6 +4324,7 @@ static int __init ib_cm_init(void)
 	cm.remote_qp_table = RB_ROOT;
 	cm.remote_sidr_table = RB_ROOT;
 	idr_init(&cm.local_id_table);
+	cm.local_id_cursor = 0;
 	get_random_bytes(&cm.random_id_operand, sizeof cm.random_id_operand);
 	INIT_LIST_HEAD(&cm.timewait_list);
 
diff --git a/drivers/infiniband/hw/mlx4/cm.c b/drivers/infiniband/hw/mlx4/cm.c
index fedaf8260105..288a796b9f14 100644
--- a/drivers/infiniband/hw/mlx4/cm.c
+++ b/drivers/infiniband/hw/mlx4/cm.c
@@ -259,7 +259,8 @@ id_map_alloc(struct ib_device *ibdev, int slave_id, u32 sl_cm_id)
 	idr_preload(GFP_KERNEL);
 	spin_lock(&to_mdev(ibdev)->sriov.id_map_lock);
 
-	ret = idr_alloc_cyclic(&sriov->pv_id_table, ent, 0, 0, GFP_NOWAIT);
+	ret = idr_alloc_cyclic(&sriov->pv_id_table, &sriov->pv_id_cursor,
+				ent, 0, 0, GFP_NOWAIT);
 	if (ret >= 0) {
 		ent->pv_cm_id = (u32)ret;
 		sl_id_map_add(ibdev, ent);
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index e14919c15b06..dfa8727254b7 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -501,6 +501,7 @@ struct mlx4_ib_sriov {
 	spinlock_t id_map_lock;
 	struct rb_root sl_id_map;
 	struct idr pv_id_table;
+	int pv_id_cursor;
 };
 
 struct gid_cache_context {
diff --git a/drivers/rapidio/rio_cm.c b/drivers/rapidio/rio_cm.c
index bad0e0ea4f30..56ff8e1a0b09 100644
--- a/drivers/rapidio/rio_cm.c
+++ b/drivers/rapidio/rio_cm.c
@@ -238,6 +238,7 @@ static int riocm_ch_close(struct rio_channel *ch);
 
 static DEFINE_SPINLOCK(idr_lock);
 static DEFINE_IDR(ch_idr);
+static int ch_cursor;
 
 static LIST_HEAD(cm_dev_list);
 static DECLARE_RWSEM(rdev_sem);
@@ -1307,7 +1308,7 @@ static struct rio_channel *riocm_ch_alloc(u16 ch_num)
 
 	idr_preload(GFP_KERNEL);
 	spin_lock_bh(&idr_lock);
-	id = idr_alloc_cyclic(&ch_idr, ch, start, end, GFP_NOWAIT);
+	id = idr_alloc_cyclic(&ch_idr, &ch_cursor, ch, start, end, GFP_NOWAIT);
 	spin_unlock_bh(&idr_lock);
 	idr_preload_end();
 
diff --git a/drivers/rpmsg/qcom_glink_native.c b/drivers/rpmsg/qcom_glink_native.c
index 40d76d2a5eff..bd8709b06c8a 100644
--- a/drivers/rpmsg/qcom_glink_native.c
+++ b/drivers/rpmsg/qcom_glink_native.c
@@ -116,6 +116,7 @@ struct qcom_glink {
 	struct mutex tx_lock;
 
 	spinlock_t idr_lock;
+	int lccursor;
 	struct idr lcids;
 	struct idr rcids;
 	unsigned long features;
@@ -169,6 +170,7 @@ struct glink_channel {
 	unsigned int rcid;
 
 	spinlock_t intent_lock;
+	int licursor;
 	struct idr liids;
 	struct idr riids;
 	struct work_struct intent_work;
@@ -394,7 +396,7 @@ static int qcom_glink_send_open_req(struct qcom_glink *glink,
 	kref_get(&channel->refcount);
 
 	spin_lock_irqsave(&glink->idr_lock, flags);
-	ret = idr_alloc_cyclic(&glink->lcids, channel,
+	ret = idr_alloc_cyclic(&glink->lcids, &glink->lccursor, channel,
 			       RPM_GLINK_CID_MIN, RPM_GLINK_CID_MAX,
 			       GFP_ATOMIC);
 	spin_unlock_irqrestore(&glink->idr_lock, flags);
@@ -644,7 +646,8 @@ qcom_glink_alloc_intent(struct qcom_glink *glink,
 		goto free_intent;
 
 	spin_lock_irqsave(&channel->intent_lock, flags);
-	ret = idr_alloc_cyclic(&channel->liids, intent, 1, -1, GFP_ATOMIC);
+	ret = idr_alloc_cyclic(&channel->liids, &channel->licursor, intent,
+				1, -1, GFP_ATOMIC);
 	if (ret < 0) {
 		spin_unlock_irqrestore(&channel->intent_lock, flags);
 		goto free_data;
diff --git a/drivers/target/target_core_device.c b/drivers/target/target_core_device.c
index e8dd6da164b2..f25dcad8d4d8 100644
--- a/drivers/target/target_core_device.c
+++ b/drivers/target/target_core_device.c
@@ -52,6 +52,7 @@
 static DEFINE_MUTEX(device_mutex);
 static LIST_HEAD(device_list);
 static DEFINE_IDR(devices_idr);
+static int devices_cursor;
 
 static struct se_hba *lun0_hba;
 /* not static, needed by tpg.c */
@@ -968,7 +969,8 @@ int target_configure_device(struct se_device *dev)
 	 * Use cyclic to try and avoid collisions with devices
 	 * that were recently removed.
 	 */
-	id = idr_alloc_cyclic(&devices_idr, dev, 0, INT_MAX, GFP_KERNEL);
+	id = idr_alloc_cyclic(&devices_idr, &devices_cursor, dev, 0, INT_MAX,
+				GFP_KERNEL);
 	mutex_unlock(&device_mutex);
 	if (id < 0) {
 		ret = -ENOMEM;
diff --git a/fs/kernfs/dir.c b/fs/kernfs/dir.c
index 89d1dc19340b..843f93de4b88 100644
--- a/fs/kernfs/dir.c
+++ b/fs/kernfs/dir.c
@@ -636,8 +636,9 @@ static struct kernfs_node *__kernfs_new_node(struct kernfs_root *root,
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&kernfs_idr_lock);
-	cursor = idr_get_cursor(&root->ino_idr);
-	ret = idr_alloc_cyclic(&root->ino_idr, kn, 1, 0, GFP_ATOMIC);
+	cursor = root->ino_cursor;
+	ret = idr_alloc_cyclic(&root->ino_idr, &root->ino_cursor, kn,
+				1, 0, GFP_ATOMIC);
 	if (ret >= 0 && ret < cursor)
 		root->next_generation++;
 	gen = root->next_generation;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b82817767b9d..2b243f086838 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -645,7 +645,8 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&cl->cl_lock);
-	new_id = idr_alloc_cyclic(&cl->cl_stateids, stid, 0, 0, GFP_NOWAIT);
+	new_id = idr_alloc_cyclic(&cl->cl_stateids, &cl->cl_cursor, stid,
+					0, 0, GFP_NOWAIT);
 	spin_unlock(&cl->cl_lock);
 	idr_preload_end();
 	if (new_id < 0)
@@ -1771,6 +1772,7 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 	clp->cl_name.len = name.len;
 	INIT_LIST_HEAD(&clp->cl_sessions);
 	idr_init(&clp->cl_stateids);
+	clp->cl_cursor = 0;
 	atomic_set(&clp->cl_refcount, 0);
 	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
 	INIT_LIST_HEAD(&clp->cl_idhash);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f3772ea8ba0d..5525df3ef826 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -300,6 +300,7 @@ struct nfs4_client {
 	struct list_head	*cl_ownerstr_hashtbl;
 	struct list_head	cl_openowners;
 	struct idr		cl_stateids;	/* stateid lookup */
+	int			cl_cursor;
 	struct list_head	cl_delegations;
 	struct list_head	cl_revoked;	/* unacknowledged, revoked 4.1 state */
 	struct list_head        cl_lru;         /* tail queue */
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index d3c20e0bb046..cb84886230c2 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -341,22 +341,23 @@ static int inotify_find_inode(const char __user *dirname, struct path *path, uns
 	return error;
 }
 
-static int inotify_add_to_idr(struct idr *idr, spinlock_t *idr_lock,
-			      struct inotify_inode_mark *i_mark)
+static int inotify_add_to_idr(struct inotify_group_private_data *group,
+				struct inotify_inode_mark *i_mark)
 {
 	int ret;
 
 	idr_preload(GFP_KERNEL);
-	spin_lock(idr_lock);
+	spin_lock(&group->idr_lock);
 
-	ret = idr_alloc_cyclic(idr, i_mark, 1, 0, GFP_NOWAIT);
+	ret = idr_alloc_cyclic(&group->idr, &group->idr_cursor, i_mark, 1, 0,
+				GFP_NOWAIT);
 	if (ret >= 0) {
 		/* we added the mark to the idr, take a reference */
 		i_mark->wd = ret;
 		fsnotify_get_mark(&i_mark->fsn_mark);
 	}
 
-	spin_unlock(idr_lock);
+	spin_unlock(&group->idr_lock);
 	idr_preload_end();
 	return ret < 0 ? ret : 0;
 }
@@ -539,8 +540,6 @@ static int inotify_new_watch(struct fsnotify_group *group,
 	struct inotify_inode_mark *tmp_i_mark;
 	__u32 mask;
 	int ret;
-	struct idr *idr = &group->inotify_data.idr;
-	spinlock_t *idr_lock = &group->inotify_data.idr_lock;
 
 	mask = inotify_arg_to_mask(arg);
 
@@ -552,7 +551,7 @@ static int inotify_new_watch(struct fsnotify_group *group,
 	tmp_i_mark->fsn_mark.mask = mask;
 	tmp_i_mark->wd = -1;
 
-	ret = inotify_add_to_idr(idr, idr_lock, tmp_i_mark);
+	ret = inotify_add_to_idr(&group->inotify_data, tmp_i_mark);
 	if (ret)
 		goto out_err;
 
diff --git a/fs/proc/loadavg.c b/fs/proc/loadavg.c
index a000d7547479..84b628f4056b 100644
--- a/fs/proc/loadavg.c
+++ b/fs/proc/loadavg.c
@@ -24,7 +24,7 @@ static int loadavg_proc_show(struct seq_file *m, void *v)
 		LOAD_INT(avnrun[1]), LOAD_FRAC(avnrun[1]),
 		LOAD_INT(avnrun[2]), LOAD_FRAC(avnrun[2]),
 		nr_running(), nr_threads,
-		idr_get_cursor(&task_active_pid_ns(current)->idr));
+		task_active_pid_ns(current)->next_pid - 1);
 	return 0;
 }
 
diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backend.h
index 067d52e95f02..fb97158f3b97 100644
--- a/include/linux/fsnotify_backend.h
+++ b/include/linux/fsnotify_backend.h
@@ -178,6 +178,7 @@ struct fsnotify_group {
 #ifdef CONFIG_INOTIFY_USER
 		struct inotify_group_private_data {
 			spinlock_t	idr_lock;
+			int		idr_cursor;
 			struct idr      idr;
 			struct ucounts *ucounts;
 		} inotify_data;
diff --git a/include/linux/idr.h b/include/linux/idr.h
index 7c3a365f7e12..10bfe62423df 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -18,7 +18,6 @@
 
 struct idr {
 	struct radix_tree_root	idr_rt;
-	unsigned int		idr_next;
 };
 
 /*
@@ -36,32 +35,6 @@ struct idr {
 }
 #define DEFINE_IDR(name)	struct idr name = IDR_INIT
 
-/**
- * idr_get_cursor - Return the current position of the cyclic allocator
- * @idr: idr handle
- *
- * The value returned is the value that will be next returned from
- * idr_alloc_cyclic() if it is free (otherwise the search will start from
- * this position).
- */
-static inline unsigned int idr_get_cursor(const struct idr *idr)
-{
-	return READ_ONCE(idr->idr_next);
-}
-
-/**
- * idr_set_cursor - Set the current position of the cyclic allocator
- * @idr: idr handle
- * @val: new position
- *
- * The next call to idr_alloc_cyclic() will return @val if it is free
- * (otherwise the search will start from this position).
- */
-static inline void idr_set_cursor(struct idr *idr, unsigned int val)
-{
-	WRITE_ONCE(idr->idr_next, val);
-}
-
 /**
  * DOC: idr sync
  * idr synchronization (stolen from radix-tree.h)
@@ -130,7 +103,8 @@ static inline int idr_alloc_ext(struct idr *idr, void *ptr,
 	return idr_alloc_cmn(idr, ptr, index, start, end, gfp, true);
 }
 
-int idr_alloc_cyclic(struct idr *, void *entry, int start, int end, gfp_t);
+int idr_alloc_cyclic(struct idr *, int *cursor, void *entry,
+			int start, int end, gfp_t);
 int idr_for_each(const struct idr *,
 		 int (*fn)(int id, void *p, void *data), void *data);
 void *idr_get_next(struct idr *, int *nextid);
@@ -152,7 +126,6 @@ static inline void *idr_remove(struct idr *idr, int id)
 static inline void idr_init(struct idr *idr)
 {
 	INIT_RADIX_TREE(&idr->idr_rt, IDR_RT_MARKER);
-	idr->idr_next = 0;
 }
 
 static inline bool idr_is_empty(const struct idr *idr)
diff --git a/include/linux/kernfs.h b/include/linux/kernfs.h
index ab25c8b6d9e3..2e74b1b361aa 100644
--- a/include/linux/kernfs.h
+++ b/include/linux/kernfs.h
@@ -185,6 +185,7 @@ struct kernfs_root {
 
 	/* private fields, do not use outside kernfs proper */
 	struct idr		ino_idr;
+	int			ino_cursor;
 	u32			next_generation;
 	struct kernfs_syscall_ops *syscall_ops;
 
diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index 49538b172483..dce073d7b2fa 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -25,6 +25,7 @@ struct pid_namespace {
 	struct kref kref;
 	struct idr idr;
 	struct rcu_head rcu;
+	int next_pid;
 	unsigned int pid_allocated;
 	struct task_struct *child_reaper;
 	struct kmem_cache *pid_cachep;
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 749a42882437..b920f6890bf3 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -505,6 +505,7 @@ void sctp_put_port(struct sock *sk);
 
 extern struct idr sctp_assocs_id;
 extern spinlock_t sctp_assocs_id_lock;
+extern int sctp_assocs_cursor;
 
 /* Static inline functions. */
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 09badc37e864..9c09f042c351 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -38,8 +38,10 @@
 
 DEFINE_PER_CPU(int, bpf_prog_active);
 static DEFINE_IDR(prog_idr);
+static int prog_cursor;
 static DEFINE_SPINLOCK(prog_idr_lock);
 static DEFINE_IDR(map_idr);
+static int map_cursor;
 static DEFINE_SPINLOCK(map_idr_lock);
 
 int sysctl_unprivileged_bpf_disabled __read_mostly;
@@ -178,7 +180,8 @@ static int bpf_map_alloc_id(struct bpf_map *map)
 	int id;
 
 	spin_lock_bh(&map_idr_lock);
-	id = idr_alloc_cyclic(&map_idr, map, 1, INT_MAX, GFP_ATOMIC);
+	id = idr_alloc_cyclic(&map_idr, &map_cursor, map, 1, INT_MAX,
+				GFP_ATOMIC);
 	if (id > 0)
 		map->id = id;
 	spin_unlock_bh(&map_idr_lock);
@@ -893,7 +896,8 @@ static int bpf_prog_alloc_id(struct bpf_prog *prog)
 	int id;
 
 	spin_lock_bh(&prog_idr_lock);
-	id = idr_alloc_cyclic(&prog_idr, prog, 1, INT_MAX, GFP_ATOMIC);
+	id = idr_alloc_cyclic(&prog_idr, &prog_cursor, prog, 1, INT_MAX,
+				GFP_ATOMIC);
 	if (id > 0)
 		prog->aux->id = id;
 	spin_unlock_bh(&prog_idr_lock);
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 0b1ffe147f24..351b355336d4 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -173,6 +173,7 @@ static int cgroup_root_count;
 
 /* hierarchy ID allocation and mapping, protected by cgroup_mutex */
 static DEFINE_IDR(cgroup_hierarchy_idr);
+static int cgroup_hierarchy_cursor;
 
 /*
  * Assign a monotonically increasing serial number to csses.  It guarantees
@@ -1213,7 +1214,8 @@ static int cgroup_init_root_id(struct cgroup_root *root)
 
 	lockdep_assert_held(&cgroup_mutex);
 
-	id = idr_alloc_cyclic(&cgroup_hierarchy_idr, root, 0, 0, GFP_KERNEL);
+	id = idr_alloc_cyclic(&cgroup_hierarchy_idr, &cgroup_hierarchy_cursor,
+				root, 0, 0, GFP_KERNEL);
 	if (id < 0)
 		return id;
 
diff --git a/kernel/pid.c b/kernel/pid.c
index b13b624e2c49..aae5f3307c35 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -170,14 +170,14 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 		 * init really needs pid 1, but after reaching the maximum
 		 * wrap back to RESERVED_PIDS
 		 */
-		if (idr_get_cursor(&tmp->idr) > RESERVED_PIDS)
+		if (tmp->next_pid > RESERVED_PIDS)
 			pid_min = RESERVED_PIDS;
 
 		/*
 		 * Store a null pointer so find_pid_ns does not find
 		 * a partially initialized PID (see below).
 		 */
-		nr = idr_alloc_cyclic(&tmp->idr, NULL, pid_min,
+		nr = idr_alloc_cyclic(&tmp->idr, &tmp->next_pid, NULL, pid_min,
 				      pid_max, GFP_ATOMIC);
 		spin_unlock_irq(&pidmap_lock);
 		idr_preload_end();
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index 0b53eef7d34b..8246d92adc56 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -287,24 +287,22 @@ static int pid_ns_ctl_handler(struct ctl_table *table, int write,
 {
 	struct pid_namespace *pid_ns = task_active_pid_ns(current);
 	struct ctl_table tmp = *table;
-	int ret, next;
+	int ret, prev;
 
 	if (write && !ns_capable(pid_ns->user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 
 	/*
 	 * Writing directly to ns' last_pid field is OK, since this field
-	 * is volatile in a living namespace anyway and a code writing to
+	 * is volatile in a living namespace anyway and code writing to
 	 * it should synchronize its usage with external means.
 	 */
 
-	next = idr_get_cursor(&pid_ns->idr) - 1;
-
-	tmp.data = &next;
+	prev = pid_ns->next_pid - 1;
+	tmp.data = &prev;
 	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
 	if (!ret && write)
-		idr_set_cursor(&pid_ns->idr, next + 1);
-
+		pid_ns->next_pid = prev + 1;
 	return ret;
 }
 
diff --git a/lib/idr.c b/lib/idr.c
index 2593ce513a18..26cb99412b8f 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -17,6 +17,9 @@ int idr_alloc_cmn(struct idr *idr, void *ptr, unsigned long *index,
 	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
 		return -EINVAL;
 
+	if (WARN_ON_ONCE(!(idr->idr_rt.gfp_mask & ROOT_IS_IDR)))
+		idr->idr_rt.gfp_mask |= IDR_RT_MARKER;
+
 	radix_tree_iter_init(&iter, start);
 	if (ext)
 		slot = idr_get_free_ext(&idr->idr_rt, &iter, gfp, end);
@@ -35,20 +38,22 @@ int idr_alloc_cmn(struct idr *idr, void *ptr, unsigned long *index,
 EXPORT_SYMBOL_GPL(idr_alloc_cmn);
 
 /**
- * idr_alloc_cyclic - allocate new idr entry in a cyclical fashion
- * @idr: idr handle
- * @ptr: pointer to be associated with the new id
- * @start: the minimum id (inclusive)
- * @end: the maximum id (exclusive)
- * @gfp: memory allocation flags
+ * idr_alloc_cyclic() - Allocate new idr entry in a cyclical fashion.
+ * @idr: idr handle.
+ * @cursor: A pointer to the next ID to allocate.
+ * @ptr: Pointer to be associated with the new id.
+ * @start: The minimum id (inclusive).
+ * @end: The maximum id (exclusive).
+ * @gfp: Memory allocation flags.
  *
  * Allocates an ID larger than the last ID allocated if one is available.
  * If not, it will attempt to allocate the smallest ID that is larger or
  * equal to @start.
  */
-int idr_alloc_cyclic(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
+int idr_alloc_cyclic(struct idr *idr, int *cursor, void *ptr,
+			int start, int end, gfp_t gfp)
 {
-	int id, curr = idr->idr_next;
+	int id, curr = *cursor;
 
 	if (curr < start)
 		curr = start;
@@ -58,7 +63,7 @@ int idr_alloc_cyclic(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
 		id = idr_alloc(idr, ptr, start, curr, gfp);
 
 	if (id >= 0)
-		idr->idr_next = id + 1U;
+		*cursor = id + 1U;
 
 	return id;
 }
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 9b5c46b052fd..e10f35c2b8c3 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -959,7 +959,7 @@ static int __init af_rxrpc_init(void)
 	tmp &= 0x3fffffff;
 	if (tmp == 0)
 		tmp = 1;
-	idr_set_cursor(&rxrpc_client_conn_ids, tmp);
+	rxrpc_client_conn_cursor = tmp;
 
 	ret = -ENOMEM;
 	rxrpc_call_jar = kmem_cache_create(
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index b2151993d384..a6fb30b08a30 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -806,6 +806,7 @@ extern unsigned int rxrpc_reap_client_connections;
 extern unsigned int rxrpc_conn_idle_client_expiry;
 extern unsigned int rxrpc_conn_idle_client_fast_expiry;
 extern struct idr rxrpc_client_conn_ids;
+extern int rxrpc_client_conn_cursor;
 
 void rxrpc_destroy_client_conn_ids(void);
 int rxrpc_connect_call(struct rxrpc_call *, struct rxrpc_conn_parameters *,
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 5f9624bd311c..7e8bf10fec86 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -91,8 +91,9 @@ __read_mostly unsigned int rxrpc_conn_idle_client_fast_expiry = 2 * HZ;
 /*
  * We use machine-unique IDs for our client connections.
  */
-DEFINE_IDR(rxrpc_client_conn_ids);
 static DEFINE_SPINLOCK(rxrpc_conn_id_lock);
+int rxrpc_client_conn_cursor;
+DEFINE_IDR(rxrpc_client_conn_ids);
 
 static void rxrpc_cull_active_client_conns(struct rxrpc_net *);
 
@@ -112,14 +113,12 @@ static int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
 
 	idr_preload(gfp);
 	spin_lock(&rxrpc_conn_id_lock);
-
-	id = idr_alloc_cyclic(&rxrpc_client_conn_ids, conn,
-			      1, 0x40000000, GFP_NOWAIT);
-	if (id < 0)
-		goto error;
-
+	id = idr_alloc_cyclic(&rxrpc_client_conn_ids, &rxrpc_client_conn_cursor,
+				conn, 1, 0x40000000, GFP_NOWAIT);
 	spin_unlock(&rxrpc_conn_id_lock);
 	idr_preload_end();
+	if (id < 0)
+		goto error;
 
 	conn->proto.epoch = rxnet->epoch;
 	conn->proto.cid = id << RXRPC_CIDSHIFT;
@@ -128,8 +127,6 @@ static int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
 	return 0;
 
 error:
-	spin_unlock(&rxrpc_conn_id_lock);
-	idr_preload_end();
 	_leave(" = %d", id);
 	return id;
 }
@@ -238,7 +235,7 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 static bool rxrpc_may_reuse_conn(struct rxrpc_connection *conn)
 {
 	struct rxrpc_net *rxnet = conn->params.local->rxnet;
-	int id_cursor, id, distance, limit;
+	int id, distance, limit;
 
 	if (test_bit(RXRPC_CONN_DONT_REUSE, &conn->flags))
 		goto dont_reuse;
@@ -252,9 +249,8 @@ static bool rxrpc_may_reuse_conn(struct rxrpc_connection *conn)
 	 * times the maximum number of client conns away from the current
 	 * allocation point to try and keep the IDs concentrated.
 	 */
-	id_cursor = idr_get_cursor(&rxrpc_client_conn_ids);
 	id = conn->proto.cid >> RXRPC_CIDSHIFT;
-	distance = id - id_cursor;
+	distance = id - rxrpc_client_conn_cursor;
 	if (distance < 0)
 		distance = -distance;
 	limit = max(rxrpc_max_client_connections * 4, 1024U);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 69394f4d6091..77178d7456fd 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1622,7 +1622,8 @@ int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
 		idr_preload(gfp);
 	spin_lock_bh(&sctp_assocs_id_lock);
 	/* 0 is not a valid assoc_id, must be >= 1 */
-	ret = idr_alloc_cyclic(&sctp_assocs_id, asoc, 1, 0, GFP_NOWAIT);
+	ret = idr_alloc_cyclic(&sctp_assocs_id, &sctp_assocs_cursor,
+				asoc, 1, 0, GFP_NOWAIT);
 	spin_unlock_bh(&sctp_assocs_id_lock);
 	if (preload)
 		idr_preload_end();
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index f5172c21349b..13b2c34c9502 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -67,6 +67,7 @@ struct sctp_globals sctp_globals __read_mostly;
 
 struct idr sctp_assocs_id;
 DEFINE_SPINLOCK(sctp_assocs_id_lock);
+int sctp_assocs_cursor;
 
 static struct sctp_pf *sctp_pf_inet6_specific;
 static struct sctp_pf *sctp_pf_inet_specific;
diff --git a/tools/testing/radix-tree/idr-test.c b/tools/testing/radix-tree/idr-test.c
index 193450b29bf0..1dff94c15da5 100644
--- a/tools/testing/radix-tree/idr-test.c
+++ b/tools/testing/radix-tree/idr-test.c
@@ -42,9 +42,10 @@ void idr_alloc_test(void)
 {
 	unsigned long i;
 	DEFINE_IDR(idr);
+	int cursor = 0;
 
-	assert(idr_alloc_cyclic(&idr, DUMMY_PTR, 0, 0x4000, GFP_KERNEL) == 0);
-	assert(idr_alloc_cyclic(&idr, DUMMY_PTR, 0x3ffd, 0x4000, GFP_KERNEL) == 0x3ffd);
+	assert(idr_alloc_cyclic(&idr, &cursor, DUMMY_PTR, 0, 0x4000, GFP_KERNEL) == 0);
+	assert(idr_alloc_cyclic(&idr, &cursor, DUMMY_PTR, 0x3ffd, 0x4000, GFP_KERNEL) == 0x3ffd);
 	idr_remove(&idr, 0x3ffd);
 	idr_remove(&idr, 0);
 
@@ -57,7 +58,18 @@ void idr_alloc_test(void)
 		else
 			item = item_create(i - 0x3fff, 0);
 
-		id = idr_alloc_cyclic(&idr, item, 1, 0x4000, GFP_KERNEL);
+		id = idr_alloc_cyclic(&idr, &cursor, item, 1, 0x4000, GFP_KERNEL);
+		assert(id == item->index);
+	}
+
+	idr_for_each(&idr, item_idr_free, &idr);
+	idr_destroy(&idr);
+
+	cursor = 0x7ffffffe;
+	for (i = 0x7ffffffe; i < 0x80000003; i++) {
+		struct item *item = item_create(i & 0x7fffffff, 0);
+		int id = idr_alloc_cyclic(&idr, &cursor, item, 0, 0,
+								GFP_KERNEL);
 		assert(id == item->index);
 	}
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
