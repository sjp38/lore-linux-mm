Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75D4F6B02EE
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 05:10:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g23so40705953pfj.10
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 02:10:52 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id d123si24739351pfg.142.2017.04.26.02.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 02:10:51 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id t7so13034934pgt.1
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 02:10:51 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 2/2] mm: hwpoison: call shake_page() after try_to_unmap() for mlocked page
Date: Wed, 26 Apr 2017 18:10:41 +0900
Message-Id: <1493197841-23986-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1493197841-23986-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1493197841-23986-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: xiaolong.ye@intel.com, Andrew Morton <akpm@linux-foundation.org>, Chen Gong <gong.chen@linux.intel.com>, lkp@01.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Memory error handler calls try_to_unmap() for error pages in various
states. If the error page is a mlocked page, error handling could fail
with "still referenced by 1 users" message. This is because the page
is linked to and stays in lru cache after the following call chain.

  try_to_unmap_one
    page_remove_rmap
      clear_page_mlock
        putback_lru_page
          lru_cache_add

memory_failure() calls shake_page() to hanlde the similar issue, but
current code doesn't cover because shake_page() is called only before
try_to_unmap(). So this patches adds shake_page().

Link: http://lkml.kernel.org/r/20170417055948.GM31394@yexl-desktop
Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git v4.11-rc6-mmotm-2017-04-13-14-50/mm/memory-failure.c v4.11-rc6-mmotm-2017-04-13-14-50_patched/mm/memory-failure.c
index 77cf9c3..57f07ec 100644
--- v4.11-rc6-mmotm-2017-04-13-14-50/mm/memory-failure.c
+++ v4.11-rc6-mmotm-2017-04-13-14-50_patched/mm/memory-failure.c
@@ -919,6 +919,7 @@ static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	bool unmap_success;
 	int kill = 1, forcekill;
 	struct page *hpage = *hpagep;
+	bool mlocked = PageMlocked(hpage);
 
 	/*
 	 * Here we are interested only in user-mapped pages, so skip any
@@ -983,6 +984,13 @@ static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
 		       pfn, page_mapcount(hpage));
 
 	/*
+	 * try_to_unmap() might put mlocked page in lru cache, so call
+	 * shake_page() again to ensure that it's flushed.
+	 */
+	if (mlocked)
+		shake_page(hpage, 0);
+
+	/*
 	 * Now that the dirty bit has been propagated to the
 	 * struct page and all unmaps done we can decide if
 	 * killing is needed or not.  Only kill when the page
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
