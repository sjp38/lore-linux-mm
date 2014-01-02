Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id BF0CB6B003C
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 16:53:42 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so15008438pbb.9
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 13:53:42 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ob10si43716279pbb.37.2014.01.02.13.53.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jan 2014 13:53:41 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCHv3 04/11] dm: Use VMALLOC_TOTAL instead of VMALLCO_END - VMALLOC_START
Date: Thu,  2 Jan 2014 13:53:22 -0800
Message-Id: <1388699609-18214-5-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com
Cc: linux-kernel@vger.kernel.org, Laura Abbott <lauraa@codeaurora.org>, Neil Brown <neilb@suse.de>, linux-raid@vger.kernel.org

vmalloc already provides a macro to calculat the total vmalloc size,
VMALLOC_TOTAL. Use it.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 drivers/md/dm-bufio.c |    4 ++--
 drivers/md/dm-stats.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
index 54bdd923..cd677f2 100644
--- a/drivers/md/dm-bufio.c
+++ b/drivers/md/dm-bufio.c
@@ -1736,8 +1736,8 @@ static int __init dm_bufio_init(void)
 	 * Get the size of vmalloc space the same way as VMALLOC_TOTAL
 	 * in fs/proc/internal.h
 	 */
-	if (mem > (VMALLOC_END - VMALLOC_START) * DM_BUFIO_VMALLOC_PERCENT / 100)
-		mem = (VMALLOC_END - VMALLOC_START) * DM_BUFIO_VMALLOC_PERCENT / 100;
+	if (mem > VMALLOC_TOTAL * DM_BUFIO_VMALLOC_PERCENT / 100)
+		mem = VMALLOC_TOTAL * DM_BUFIO_VMALLOC_PERCENT / 100;
 #endif
 
 	dm_bufio_default_cache_size = mem;
diff --git a/drivers/md/dm-stats.c b/drivers/md/dm-stats.c
index 28a9012..378ffb6 100644
--- a/drivers/md/dm-stats.c
+++ b/drivers/md/dm-stats.c
@@ -80,7 +80,7 @@ static bool __check_shared_memory(size_t alloc_size)
 	if (a >> PAGE_SHIFT > totalram_pages / DM_STATS_MEMORY_FACTOR)
 		return false;
 #ifdef CONFIG_MMU
-	if (a > (VMALLOC_END - VMALLOC_START) / DM_STATS_VMALLOC_FACTOR)
+	if (a > VMALLOC_TOTAL / DM_STATS_VMALLOC_FACTOR)
 		return false;
 #endif
 	return true;
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
