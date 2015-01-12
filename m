Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 708A46B0072
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 04:20:21 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so29476693pdb.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 01:20:21 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id xg13si22692591pac.74.2015.01.12.01.20.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 12 Jan 2015 01:20:20 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NI200HCJ4SJJY90@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 12 Jan 2015 09:24:19 +0000 (GMT)
From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 5/5] fs/namespace: convert devname allocation to kstrdup_const
Date: Mon, 12 Jan 2015 10:18:43 +0100
Message-id: <1421054323-14430-6-git-send-email-a.hajda@samsung.com>
In-reply-to: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrzej Hajda <a.hajda@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

VFS frequently performs duplication of strings located
in read-only memory section. Replacing kstrdup by kstrdup_const
allows to avoid such operations.

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 fs/namespace.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index cd1e968..6dae553 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -201,7 +201,7 @@ static struct mount *alloc_vfsmnt(const char *name)
 			goto out_free_cache;
 
 		if (name) {
-			mnt->mnt_devname = kstrdup(name, GFP_KERNEL);
+			mnt->mnt_devname = kstrdup_const(name, GFP_KERNEL);
 			if (!mnt->mnt_devname)
 				goto out_free_id;
 		}
@@ -234,7 +234,7 @@ static struct mount *alloc_vfsmnt(const char *name)
 
 #ifdef CONFIG_SMP
 out_free_devname:
-	kfree(mnt->mnt_devname);
+	kfree_const(mnt->mnt_devname);
 #endif
 out_free_id:
 	mnt_free_id(mnt);
@@ -568,7 +568,7 @@ int sb_prepare_remount_readonly(struct super_block *sb)
 
 static void free_vfsmnt(struct mount *mnt)
 {
-	kfree(mnt->mnt_devname);
+	kfree_const(mnt->mnt_devname);
 #ifdef CONFIG_SMP
 	free_percpu(mnt->mnt_pcp);
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
