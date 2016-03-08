Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B25646B0254
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 20:47:37 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id 129so1112495pfw.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 17:47:37 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id ah10si832181pad.118.2016.03.07.17.47.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 17:47:37 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id x188so125744pfb.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 17:47:36 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] tools/vm/page-types.c: remove memset() in walk_pfn()
Date: Tue,  8 Mar 2016 10:47:32 +0900
Message-Id: <1457401652-9226-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

I found that page-types is very slow and my testing shows many timeout errors.
Here's an example with a simple program allocating 1000 thps.

  $ time ./page-types -p $(pgrep -f test_alloc)
  ...
  real    0m17.201s
  user    0m16.889s
  sys     0m0.312s

  $ time ./page-types.patched -p $(pgrep -f test_alloc)
  ...
  real    0m0.182s
  user    0m0.046s
  sys     0m0.135s

Most of time is spent in memset(), which isn't necessary because we check
that the return of kpagecgroup_read() is equal to pages and uninitialized
memory is never used. So we can drop this memset().

Fixes: 954e95584579 ("tools/vm/page-types.c: add memory cgroup dumping and filtering")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 tools/vm/page-types.c | 2 --
 1 file changed, 2 deletions(-)

diff --git v4.5-rc5-mmotm-2016-02-24-16-18/tools/vm/page-types.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/tools/vm/page-types.c
index dab61c3..c192baf 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/tools/vm/page-types.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/tools/vm/page-types.c
@@ -633,8 +633,6 @@ static void walk_pfn(unsigned long voffset,
 	unsigned long pages;
 	unsigned long i;
 
-	memset(cgi, 0, sizeof cgi);
-
 	while (count) {
 		batch = min_t(unsigned long, count, KPAGEFLAGS_BATCH);
 		pages = kpageflags_read(buf, index, batch);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
