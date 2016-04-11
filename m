Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1ACFE828DF
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:09:01 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id n3so99499476wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:09:01 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id v71si17820065wmd.18.2016.04.11.04.08.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 04:08:39 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id l6so20397478wml.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:08:38 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 17/19] dm: get rid of superfluous gfp flags
Date: Mon, 11 Apr 2016 13:08:10 +0200
Message-Id: <1460372892-8157-18-git-send-email-mhocko@kernel.org>
In-Reply-To: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Shaohua Li <shli@kernel.org>, Mikulas Patocka <mpatocka@redhat.com>

From: Michal Hocko <mhocko@suse.com>

copy_params seems to be little bit confused about which allocation flags
to use. It enforces GFP_NOIO even though it uses
memalloc_noio_{save,restore} which enforces GFP_NOIO at the page
allocator level automatically (via memalloc_noio_flags). It also
uses __GFP_REPEAT for the __vmalloc request which doesn't make much
sense either because vmalloc doesn't rely on costly high order
allocations.

Cc: Shaohua Li <shli@kernel.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/md/dm-ioctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
index 2adf81d81fca..dfe629a294e1 100644
--- a/drivers/md/dm-ioctl.c
+++ b/drivers/md/dm-ioctl.c
@@ -1723,7 +1723,7 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
 	if (!dmi) {
 		unsigned noio_flag;
 		noio_flag = memalloc_noio_save();
-		dmi = __vmalloc(param_kernel->data_size, GFP_NOIO | __GFP_REPEAT | __GFP_HIGH | __GFP_HIGHMEM, PAGE_KERNEL);
+		dmi = __vmalloc(param_kernel->data_size, __GFP_HIGH | __GFP_HIGHMEM, PAGE_KERNEL);
 		memalloc_noio_restore(noio_flag);
 		if (dmi)
 			*param_flags |= DM_PARAMS_VMALLOC;
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
