Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E160C6B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 22:57:38 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s74so147124351pfe.10
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 19:57:38 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id g10si14041495plk.578.2017.06.20.19.57.37
        for <linux-mm@kvack.org>;
        Tue, 20 Jun 2017 19:57:38 -0700 (PDT)
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Subject: [PATCH v2] mm: Drop useless local parameters of __register_one_node()
Date: Wed, 21 Jun 2017 10:57:26 +0800
Message-ID: <1498013846-20149-1-git-send-email-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Dou Liyang <douly.fnst@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, isimatu.yasuaki@jp.fujitsu.com

... initializes local parameters "p_node" & "parent" for
register_node().

But, register_node() does not use them.

Remove the related code of "parent" node, cleanup __register_one_node()
and register_node().

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: isimatu.yasuaki@jp.fujitsu.com
Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
Acked-by: David Rientjes <rientjes@google.com>
---
V1 --> V2:
Rebase it on 
git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git akpm

 drivers/base/node.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 73d39bc..d8dc830 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -288,7 +288,7 @@ static void node_device_release(struct device *dev)
  *
  * Initialize and register the node device.
  */
-static int register_node(struct node *node, int num, struct node *parent)
+static int register_node(struct node *node, int num)
 {
 	int error;
 
@@ -567,19 +567,14 @@ static void init_node_hugetlb_work(int nid) { }
 
 int __register_one_node(int nid)
 {
-	int p_node = parent_node(nid);
-	struct node *parent = NULL;
 	int error;
 	int cpu;
 
-	if (p_node != nid)
-		parent = node_devices[p_node];
-
 	node_devices[nid] = kzalloc(sizeof(struct node), GFP_KERNEL);
 	if (!node_devices[nid])
 		return -ENOMEM;
 
-	error = register_node(node_devices[nid], nid, parent);
+	error = register_node(node_devices[nid], nid);
 
 	/* link cpu under this node */
 	for_each_present_cpu(cpu) {
-- 
2.5.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
