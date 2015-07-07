Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9EBE86B0259
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 11:11:14 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so142012084qkh.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 08:11:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c72si2310233qkh.34.2015.07.07.08.11.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 08:11:13 -0700 (PDT)
Date: Tue, 7 Jul 2015 11:11:11 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH 4/7] dm: use kvmalloc
In-Reply-To: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.02.1507071110410.23387@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <msnitzer@redhat.com>
Cc: "Alasdair G. Kergon" <agk@redhat.com>, Edward Thornber <thornber@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Vivek Goyal <vgoyal@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com

Use the function kvmalloc to allocate ioctl parameters.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 drivers/md/dm-ioctl.c         |   26 +++++---------------------
 drivers/md/dm-table.c         |   37 +++++++++++++++++++++++++++++++++++++
 include/linux/device-mapper.h |    2 ++
 3 files changed, 44 insertions(+), 21 deletions(-)

Index: linux-4.1/drivers/md/dm-ioctl.c
===================================================================
--- linux-4.1.orig/drivers/md/dm-ioctl.c	2015-07-02 19:21:15.000000000 +0200
+++ linux-4.1/drivers/md/dm-ioctl.c	2015-07-02 19:21:21.000000000 +0200
@@ -1676,12 +1676,8 @@ static void free_params(struct dm_ioctl 
 	if (param_flags & DM_WIPE_BUFFER)
 		memset(param, 0, param_size);
 
-	if (param_flags & DM_PARAMS_ALLOC) {
-		if (is_vmalloc_addr(param))
-			vfree(param);
-		else
-			kfree(param);
-	}
+	if (param_flags & DM_PARAMS_ALLOC)
+		kvfree(param);
 }
 
 static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kernel,
@@ -1712,21 +1708,7 @@ static int copy_params(struct dm_ioctl _
 	 * Try to avoid low memory issues when a device is suspended.
 	 * Use kmalloc() rather than vmalloc() when we can.
 	 */
-	dmi = NULL;
-	if (param_kernel->data_size <= KMALLOC_MAX_SIZE) {
-		dmi = kmalloc(param_kernel->data_size, GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN);
-		if (dmi)
-			*param_flags |= DM_PARAMS_ALLOC;
-	}
-
-	if (!dmi) {
-		unsigned noio_flag;
-		noio_flag = memalloc_noio_save();
-		dmi = __vmalloc(param_kernel->data_size, GFP_NOIO | __GFP_REPEAT | __GFP_HIGH | __GFP_HIGHMEM, PAGE_KERNEL);
-		memalloc_noio_restore(noio_flag);
-		if (dmi)
-			*param_flags |= DM_PARAMS_ALLOC;
-	}
+	dmi = kvmalloc(param_kernel->data_size, GFP_NOIO);
 
 	if (!dmi) {
 		if (secure_data && clear_user(user, param_kernel->data_size))
@@ -1734,6 +1716,8 @@ static int copy_params(struct dm_ioctl _
 		return -ENOMEM;
 	}
 
+	*param_flags |= DM_PARAMS_ALLOC;
+
 	if (copy_from_user(dmi, user, param_kernel->data_size))
 		goto bad;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
