Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 6A8426B0037
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 10:52:56 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 2/2] mm: remove_memory: Fix end_pfn setting
Date: Fri,  8 Mar 2013 08:41:41 -0700
Message-Id: <1362757301-18550-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1362757301-18550-1-git-send-email-toshi.kani@hp.com>
References: <1362757301-18550-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, Toshi Kani <toshi.kani@hp.com>

remove_memory() calls walk_memory_range() with [start_pfn, end_pfn),
where end_pfn is exclusive in this range.  Therefore, end_pfn needs
to be set to the next page of the end address.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 mm/memory_hotplug.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ae7bcba..3e2ab7b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1801,7 +1801,7 @@ int __ref remove_memory(int nid, u64 start, u64 size)
 	int retry = 1;
 
 	start_pfn = PFN_DOWN(start);
-	end_pfn = start_pfn + PFN_DOWN(size);
+	end_pfn = PFN_UP(start + size - 1);
 
 	/*
 	 * When CONFIG_MEMCG is on, one memory block may be used by other

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
