Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5E76B038A
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 05:33:42 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t193so27811308wmt.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:33:42 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id u5si25317973wru.142.2017.03.06.02.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 02:33:41 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id n11so12957669wma.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:33:41 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 8/9] md: use kvmalloc rather than opencoded variant
Date: Mon,  6 Mar 2017 11:33:26 +0100
Message-Id: <20170306103327.2766-4-mhocko@kernel.org>
In-Reply-To: <20170306103327.2766-1-mhocko@kernel.org>
References: <20170306103032.2540-1-mhocko@kernel.org>
 <20170306103327.2766-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Mike Snitzer <snitzer@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

copy_params uses kmalloc with vmalloc fallback. We already have a helper
for that - kvmalloc. This caller requires GFP_NOIO semantic so it hasn't
been converted with many others by previous patches. All we need to
achieve this semantic is to use the scope memalloc_noio_{save,restore}
around kvmalloc.

Cc: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/md/dm-ioctl.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
index 4da6fc6b1ffd..4951bf99dfb1 100644
--- a/drivers/md/dm-ioctl.c
+++ b/drivers/md/dm-ioctl.c
@@ -1699,6 +1699,7 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
 	struct dm_ioctl *dmi;
 	int secure_data;
 	const size_t minimum_data_size = offsetof(struct dm_ioctl, data);
+	unsigned noio_flag;
 
 	if (copy_from_user(param_kernel, user, minimum_data_size))
 		return -EFAULT;
@@ -1721,15 +1722,9 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
 	 * Use kmalloc() rather than vmalloc() when we can.
 	 */
 	dmi = NULL;
-	if (param_kernel->data_size <= KMALLOC_MAX_SIZE)
-		dmi = kmalloc(param_kernel->data_size, GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN);
-
-	if (!dmi) {
-		unsigned noio_flag;
-		noio_flag = memalloc_noio_save();
-		dmi = __vmalloc(param_kernel->data_size, GFP_NOIO | __GFP_HIGH | __GFP_HIGHMEM, PAGE_KERNEL);
-		memalloc_noio_restore(noio_flag);
-	}
+	noio_flag = memalloc_noio_save();
+	dmi = kvmalloc(param_kernel->data_size, GFP_KERNEL);
+	memalloc_noio_restore(noio_flag);
 
 	if (!dmi) {
 		if (secure_data && clear_user(user, param_kernel->data_size))
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
