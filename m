Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C54F6B02AA
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 15:43:41 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l124so94544493wml.4
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 12:43:41 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id la2si38249058wjb.67.2016.11.01.12.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 12:43:40 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id p190so17851174wmp.1
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 12:43:40 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH] drm/via: use get_user_pages_unlocked()
Date: Tue,  1 Nov 2016 19:43:37 +0000
Message-Id: <20161101194337.24015-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Michal Hocko <mhocko@kernel.org>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, Lorenzo Stoakes <lstoakes@gmail.com>

Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 drivers/gpu/drm/via/via_dmablit.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 1a3ad76..98aae98 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -238,13 +238,9 @@ via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
 	vsg->pages = vzalloc(sizeof(struct page *) * vsg->num_pages);
 	if (NULL == vsg->pages)
 		return -ENOMEM;
-	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages((unsigned long)xfer->mem_addr,
-			     vsg->num_pages,
-			     (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0,
-			     vsg->pages, NULL);
-
-	up_read(&current->mm->mmap_sem);
+	ret = get_user_pages_unlocked((unsigned long)xfer->mem_addr,
+			vsg->num_pages, vsg->pages,
+			(vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0);
 	if (ret != vsg->num_pages) {
 		if (ret < 0)
 			return ret;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
