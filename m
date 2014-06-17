Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 13C806B0036
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 10:28:17 -0400 (EDT)
Received: by mail-yh0-f44.google.com with SMTP id f10so5544863yha.3
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 07:28:16 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u7si22493500yhc.15.2014.06.17.07.28.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 07:28:16 -0700 (PDT)
Message-ID: <53A05071.2010905@oracle.com>
Date: Tue, 17 Jun 2014 22:28:01 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [PATCH 03/24] slub: return actual error on sysfs functions
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

From: Jie Liu <jeff.liu@oracle.com>

Return the actual error code if call kset_create_and_add() failed

Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Jie Liu <jeff.liu@oracle.com>
---
 mm/slub.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index b2b0473..fc9f5bc 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5215,8 +5215,8 @@ static int sysfs_slab_add(struct kmem_cache *s)
 #ifdef CONFIG_MEMCG_KMEM
 	if (is_root_cache(s)) {
 		s->memcg_kset = kset_create_and_add("cgroup", NULL, &s->kobj);
-		if (!s->memcg_kset) {
-			err = -ENOMEM;
+		if (IS_ERR(s->memcg_kset)) {
+			err = PTR_ERR(s->memcg_kset);
 			goto out_del_kobj;
 		}
 	}
@@ -5298,10 +5298,10 @@ static int __init slab_sysfs_init(void)
 	mutex_lock(&slab_mutex);
 
 	slab_kset = kset_create_and_add("slab", &slab_uevent_ops, kernel_kobj);
-	if (!slab_kset) {
+	if (IS_ERR(slab_kset)) {
 		mutex_unlock(&slab_mutex);
 		pr_err("Cannot register slab subsystem.\n");
-		return -ENOSYS;
+		return PTR_ERR(slab_kset);
 	}
 
 	slab_state = FULL;
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
