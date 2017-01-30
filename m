Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0606B0268
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 04:50:02 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id h7so60386857wjy.6
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 01:50:02 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id p13si12747845wmi.13.2017.01.30.01.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 01:50:01 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id un2so7020078wjb.0
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 01:50:00 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 7/9] md: use kvmalloc rather than opencoded variant
Date: Mon, 30 Jan 2017 10:49:38 +0100
Message-Id: <20170130094940.13546-8-mhocko@kernel.org>
In-Reply-To: <20170130094940.13546-1-mhocko@kernel.org>
References: <20170130094940.13546-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Mikulas Patocka <mpatocka@redhat.com>, Mike Snitzer <snitzer@redhat.com>

From: Michal Hocko <mhocko@suse.com>

copy_params uses kmalloc with vmalloc fallback. We already have a helper
for that - kvmalloc. This caller requires GFP_NOIO semantic so it hasn't
been converted with many others by previous patches. All we need to
achieve this semantic is to use the scope memalloc_noio_{save,restore}
around kvmalloc.

Cc: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/md/dm-ioctl.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
index a5a9b17f0f7f..dbf5b981f7d7 100644
--- a/drivers/md/dm-ioctl.c
+++ b/drivers/md/dm-ioctl.c
@@ -1698,6 +1698,7 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
 	struct dm_ioctl *dmi;
 	int secure_data;
 	const size_t minimum_data_size = offsetof(struct dm_ioctl, data);
+	unsigned noio_flag;
 
 	if (copy_from_user(param_kernel, user, minimum_data_size))
 		return -EFAULT;
@@ -1720,15 +1721,9 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
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
