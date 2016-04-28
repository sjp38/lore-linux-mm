Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF096B0273
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 09:24:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r12so3607492wme.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 06:24:51 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id eh3si10917192wjd.44.2016.04.28.06.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 06:24:26 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e201so23389424wme.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 06:24:26 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 19/20] md: simplify free_params for kmalloc vs vmalloc fallback
Date: Thu, 28 Apr 2016 15:24:05 +0200
Message-Id: <1461849846-27209-20-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Shaohua Li <shli@kernel.org>, Mikulas Patocka <mpatocka@redhat.com>, dm-devel@redhat.com

From: Michal Hocko <mhocko@suse.com>

Use kvfree rather than DM_PARAMS_[KV]MALLOC specific param flags.

Cc: Shaohua Li <shli@kernel.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>
Cc: dm-devel@redhat.com
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/md/dm-ioctl.c | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
index fe0b57d7573c..2b48c49774bc 100644
--- a/drivers/md/dm-ioctl.c
+++ b/drivers/md/dm-ioctl.c
@@ -1670,19 +1670,14 @@ static int check_version(unsigned int cmd, struct dm_ioctl __user *user)
 	return r;
 }
 
-#define DM_PARAMS_KMALLOC	0x0001	/* Params alloced with kmalloc */
-#define DM_PARAMS_VMALLOC	0x0002	/* Params alloced with vmalloc */
-#define DM_WIPE_BUFFER		0x0010	/* Wipe input buffer before returning from ioctl */
+#define DM_WIPE_BUFFER		0x0001	/* Wipe input buffer before returning from ioctl */
 
 static void free_params(struct dm_ioctl *param, size_t param_size, int param_flags)
 {
 	if (param_flags & DM_WIPE_BUFFER)
 		memset(param, 0, param_size);
 
-	if (param_flags & DM_PARAMS_KMALLOC)
-		kfree(param);
-	if (param_flags & DM_PARAMS_VMALLOC)
-		vfree(param);
+	kvfree(param);
 }
 
 static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kernel,
@@ -1714,17 +1709,11 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
 	 * Use kmalloc() rather than vmalloc() when we can.
 	 */
 	dmi = NULL;
-	if (param_kernel->data_size <= KMALLOC_MAX_SIZE) {
+	if (param_kernel->data_size <= KMALLOC_MAX_SIZE)
 		dmi = kmalloc(param_kernel->data_size, GFP_KERNEL | __GFP_NORETRY | __GFP_NOWARN);
-		if (dmi)
-			*param_flags |= DM_PARAMS_KMALLOC;
-	}
 
-	if (!dmi) {
+	if (!dmi)
 		dmi = __vmalloc(param_kernel->data_size, GFP_KERNEL | __GFP_HIGH | __GFP_HIGHMEM, PAGE_KERNEL);
-		if (dmi)
-			*param_flags |= DM_PARAMS_VMALLOC;
-	}
 
 	if (!dmi) {
 		if (secure_data && clear_user(user, param_kernel->data_size))
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
