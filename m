Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id AEE7D6B006C
	for <linux-mm@kvack.org>; Tue,  5 May 2015 05:45:56 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so190436102pdb.0
        for <linux-mm@kvack.org>; Tue, 05 May 2015 02:45:56 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bk10si23545168pac.111.2015.05.05.02.45.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 02:45:55 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 2/2] kernfs: do not account ino_ida allocations to memcg
Date: Tue, 5 May 2015 12:45:43 +0300
Message-ID: <0cf48f4219721952f182715a61910f626d7c4aca.1430819044.git.vdavydov@parallels.com>
In-Reply-To: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
References: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

root->ino_ida is used for kernfs inode number allocations. Since IDA has
a layered structure, different IDs can reside on the same layer, which
is currently accounted to some memory cgroup. The problem is that each
kmem cache of a memory cgroup has its own directory on sysfs (under
/sys/fs/kernel/<cache-name>/cgroup). If the inode number of such a
directory or any file in it gets allocated from a layer accounted to the
cgroup which the cache is created for, the cgroup will get pinned for
good, because one has to free all kmem allocations accounted to a cgroup
in order to release it and destroy all its kmem caches. That said we
must not account layers of ino_ida to any memory cgroup.

Since per net init operations may create new sysfs entries directly
(e.g. lo device) or indirectly (nf_conntrack creates a new kmem cache
per each namespace, which, in turn, creates new sysfs entries), an easy
way to reproduce this issue is by creating network namespace(s) from
inside a kmem-active memory cgroup.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/kernfs/dir.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/kernfs/dir.c b/fs/kernfs/dir.c
index f131fc23ffc4..fffca9517321 100644
--- a/fs/kernfs/dir.c
+++ b/fs/kernfs/dir.c
@@ -518,7 +518,14 @@ static struct kernfs_node *__kernfs_new_node(struct kernfs_root *root,
 	if (!kn)
 		goto err_out1;
 
-	ret = ida_simple_get(&root->ino_ida, 1, 0, GFP_KERNEL);
+	/*
+	 * If the ino of the sysfs entry created for a kmem cache gets
+	 * allocated from an ida layer, which is accounted to the memcg that
+	 * owns the cache, the memcg will get pinned forever. So do not account
+	 * ino ida allocations.
+	 */
+	ret = ida_simple_get(&root->ino_ida, 1, 0,
+			     GFP_KERNEL | __GFP_NOACCOUNT);
 	if (ret < 0)
 		goto err_out2;
 	kn->ino = ret;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
