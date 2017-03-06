Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5670F6B0388
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 05:30:44 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c143so27928365wmd.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:30:44 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 7si25955774wrs.18.2017.03.06.02.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 02:30:43 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id u132so4912787wmg.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:30:42 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/9] mm: support __GFP_REPEAT in kvmalloc_node for >32kB
Date: Mon,  6 Mar 2017 11:30:25 +0100
Message-Id: <20170306103032.2540-3-mhocko@kernel.org>
In-Reply-To: <20170306103032.2540-1-mhocko@kernel.org>
References: <20170306103032.2540-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

vhost code uses __GFP_REPEAT when allocating vhost_virtqueue resp.
vhost_vsock because it would really like to prefer kmalloc to the
vmalloc fallback - see 23cc5a991c7a ("vhost-net: extend device
allocation to vmalloc") for more context. Michael Tsirkin has also
noted:
"
__GFP_REPEAT overhead is during allocation time.  Using vmalloc means all
accesses are slowed down.  Allocation is not on data path, accesses are.
"

The similar applies to other vhost_kvzalloc users.

Let's teach kvmalloc_node to handle __GFP_REPEAT properly. There are two
things to be careful about. First we should prevent from the OOM killer
and so have to involve __GFP_NORETRY by default and secondly override
__GFP_REPEAT for !costly order requests as the __GFP_REPEAT is ignored
for !costly orders.

Supporting __GFP_REPEAT like semantic for !costly request is possible
it would require changes in the page allocator. This is out of scope of
this patch.

This patch shouldn't introduce any functional change.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/vhost/net.c   |  9 +++------
 drivers/vhost/vhost.c | 15 +++------------
 drivers/vhost/vsock.c |  9 +++------
 mm/util.c             | 20 ++++++++++++++++----
 4 files changed, 25 insertions(+), 28 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 9b519897cc17..f61f852d6cfd 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -817,12 +817,9 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	struct vhost_virtqueue **vqs;
 	int i;
 
-	n = kmalloc(sizeof *n, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
-	if (!n) {
-		n = vmalloc(sizeof *n);
-		if (!n)
-			return -ENOMEM;
-	}
+	n = kvmalloc(sizeof *n, GFP_KERNEL | __GFP_REPEAT);
+	if (!n)
+		return -ENOMEM;
 	vqs = kmalloc(VHOST_NET_VQ_MAX * sizeof(*vqs), GFP_KERNEL);
 	if (!vqs) {
 		kvfree(n);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index f0ba362d4c10..042030e5a035 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -534,18 +534,9 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
 }
 EXPORT_SYMBOL_GPL(vhost_dev_set_owner);
 
-static void *vhost_kvzalloc(unsigned long size)
-{
-	void *n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
-
-	if (!n)
-		n = vzalloc(size);
-	return n;
-}
-
 struct vhost_umem *vhost_dev_reset_owner_prepare(void)
 {
-	return vhost_kvzalloc(sizeof(struct vhost_umem));
+	return kvzalloc(sizeof(struct vhost_umem), GFP_KERNEL);
 }
 EXPORT_SYMBOL_GPL(vhost_dev_reset_owner_prepare);
 
@@ -1276,7 +1267,7 @@ EXPORT_SYMBOL_GPL(vhost_vq_access_ok);
 
 static struct vhost_umem *vhost_umem_alloc(void)
 {
-	struct vhost_umem *umem = vhost_kvzalloc(sizeof(*umem));
+	struct vhost_umem *umem = kvzalloc(sizeof(*umem), GFP_KERNEL);
 
 	if (!umem)
 		return NULL;
@@ -1302,7 +1293,7 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 		return -EOPNOTSUPP;
 	if (mem.nregions > max_mem_regions)
 		return -E2BIG;
-	newmem = vhost_kvzalloc(size + mem.nregions * sizeof(*m->regions));
+	newmem = kvzalloc(size + mem.nregions * sizeof(*m->regions), GFP_KERNEL);
 	if (!newmem)
 		return -ENOMEM;
 
diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index ce5e63d2c66a..d403c647ba56 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -460,12 +460,9 @@ static int vhost_vsock_dev_open(struct inode *inode, struct file *file)
 	/* This struct is large and allocation could fail, fall back to vmalloc
 	 * if there is no other way.
 	 */
-	vsock = kzalloc(sizeof(*vsock), GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
-	if (!vsock) {
-		vsock = vmalloc(sizeof(*vsock));
-		if (!vsock)
-			return -ENOMEM;
-	}
+	vsock = kvmalloc(sizeof(*vsock), GFP_KERNEL | __GFP_REPEAT);
+	if (!vsock)
+		return -ENOMEM;
 
 	vqs = kmalloc_array(ARRAY_SIZE(vsock->vqs), sizeof(*vqs), GFP_KERNEL);
 	if (!vqs) {
diff --git a/mm/util.c b/mm/util.c
index 10a14a0ac3c2..7c71407e5078 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -338,8 +338,10 @@ EXPORT_SYMBOL(vm_mmap);
  *
  * Uses kmalloc to get the memory but if the allocation fails then falls back
  * to the vmalloc allocator. Use kvfree for freeing the memory.
- *
- * Reclaim modifiers - __GFP_NORETRY, __GFP_REPEAT and __GFP_NOFAIL are not supported
+ * 
+ * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. __GFP_REPEAT
+ * is supported only for large (>32kB) allocations, and it should be used only if
+ * kmalloc is preferable to the vmalloc fallback, due to visible performance drawbacks.
  *
  * Any use of gfp flags outside of GFP_KERNEL should be consulted with mm people.
  */
@@ -358,8 +360,18 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 	 * Make sure that larger requests are not too disruptive - no OOM
 	 * killer and no allocation failure warnings as we have a fallback
 	 */
-	if (size > PAGE_SIZE)
-		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
+	if (size > PAGE_SIZE) {
+		kmalloc_flags |= __GFP_NOWARN;
+
+		/*
+		 * We have to override __GFP_REPEAT by __GFP_NORETRY for !costly
+		 * requests because there is no other way to tell the allocator
+		 * that we want to fail rather than retry endlessly.
+		 */
+		if (!(kmalloc_flags & __GFP_REPEAT) ||
+				(size <= PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
+			kmalloc_flags |= __GFP_NORETRY;
+	}
 
 	ret = kmalloc_node(size, kmalloc_flags, node);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
