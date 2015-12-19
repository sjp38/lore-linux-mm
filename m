Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f54.google.com (mail-vk0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 769636B0003
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 20:05:03 -0500 (EST)
Received: by mail-vk0-f54.google.com with SMTP id a189so74873356vkh.2
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 17:05:03 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i65si16038737vke.66.2015.12.18.17.05.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 17:05:02 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm, oom: initiallize all new zap_details fields before use
Date: Fri, 18 Dec 2015 20:04:51 -0500
Message-Id: <1450487091-7822-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>

Commit "mm, oom: introduce oom reaper" forgot to initialize the two new fields
of struct zap_details in unmap_mapping_range(). This caused using stack garbage
on the call to unmap_mapping_range_tree().

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/memory.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory.c b/mm/memory.c
index 206c8cd..0e32993 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2431,6 +2431,7 @@ void unmap_mapping_range(struct address_space *mapping,
 	details.last_index = hba + hlen - 1;
 	if (details.last_index < details.first_index)
 		details.last_index = ULONG_MAX;
+	details.check_swap_entries = details.ignore_dirty = false;
 
 
 	/* DAX uses i_mmap_lock to serialise file truncate vs page fault */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
