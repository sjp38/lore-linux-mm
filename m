Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id CCBA19C000C
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:15 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so953476pdi.19
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:15 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 11/26] sep: Convert sep_lock_user_pages() to get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:27:52 +0200
Message-Id: <1380724087-13927-12-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mark Allyn <mark.a.allyn@intel.com>, Jayant Mangalampalli <jayant.mangalampalli@intel.com>

CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: Mark Allyn <mark.a.allyn@intel.com>
CC: Jayant Mangalampalli <jayant.mangalampalli@intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/staging/sep/sep_main.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/sep/sep_main.c b/drivers/staging/sep/sep_main.c
index 6a98a208bbf2..11f5b2117457 100644
--- a/drivers/staging/sep/sep_main.c
+++ b/drivers/staging/sep/sep_main.c
@@ -1263,13 +1263,8 @@ static int sep_lock_user_pages(struct sep_device *sep,
 	}
 
 	/* Convert the application virtual address into a set of physical */
-	down_read(&current->mm->mmap_sem);
-	result = get_user_pages(current, current->mm, app_virt_addr,
-		num_pages,
-		((in_out_flag == SEP_DRIVER_IN_FLAG) ? 0 : 1),
-		0, page_array, NULL);
-
-	up_read(&current->mm->mmap_sem);
+	result = get_user_pages_fast(app_virt_addr, num_pages,
+		((in_out_flag == SEP_DRIVER_IN_FLAG) ? 0 : 1), page_array);
 
 	/* Check the number of pages locked - if not all then exit with error */
 	if (result != num_pages) {
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
