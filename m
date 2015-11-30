Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id C941E6B0253
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 15:00:32 -0500 (EST)
Received: by wmec201 with SMTP id c201so173393503wme.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 12:00:32 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id uv3si68900891wjc.161.2015.11.30.12.00.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 12:00:31 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/2] proc: meminfo: estimate available memory more conservatively
Date: Mon, 30 Nov 2015 15:00:22 -0500
Message-Id: <1448913622-24198-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1448913622-24198-1-git-send-email-hannes@cmpxchg.org>
References: <1448913622-24198-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The MemAvailable item in /proc/meminfo is to give users a hint of how
much memory is allocatable without causing swapping, so it excludes
the zones' low watermarks as unavailable to userspace.

However, for a userspace allocation, kswapd will actually reclaim
until the free pages hit a combination of the high watermark and the
page allocator's lowmem protection that keeps a certain amount of DMA
and DMA32 memory from userspace as well.

Subtract the full amount we know to be unavailable to userspace from
the number of free pages when calculating MemAvailable.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/proc/meminfo.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 9155a5a..df4661a 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -57,11 +57,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	/*
 	 * Estimate the amount of memory available for userspace allocations,
 	 * without causing swapping.
-	 *
-	 * Free memory cannot be taken below the low watermark, before the
-	 * system starts swapping.
 	 */
-	available = i.freeram - wmark_low;
+	available = i.freeram - totalreserve_pages;
 
 	/*
 	 * Not all the page cache can be freed, otherwise the system will
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
