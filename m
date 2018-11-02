Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id C8E366B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 11:31:54 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id t74-v6so1071427wmt.0
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 08:31:54 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.74])
        by mx.google.com with ESMTPS id e8-v6si7805250wrw.379.2018.11.02.08.31.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 08:31:53 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: fix uninitialized variable warnings
Date: Fri,  2 Nov 2018 16:31:06 +0100
Message-Id: <20181102153138.1399758-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
Cc: Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, Wang Long <wanglong19@meituan.com>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In a rare randconfig build, I got a warning about possibly uninitialized
variables:

mm/page-writeback.c: In function 'balance_dirty_pages':
mm/page-writeback.c:1623:16: error: 'writeback' may be used uninitialized in this function [-Werror=maybe-uninitialized]
    mdtc->dirty += writeback;
                ^~
mm/page-writeback.c:1624:4: error: 'filepages' may be used uninitialized in this function [-Werror=maybe-uninitialized]
    mdtc_calc_avail(mdtc, filepages, headroom);
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mm/page-writeback.c:1624:4: error: 'headroom' may be used uninitialized in this function [-Werror=maybe-uninitialized]

The compiler evidently fails to notice that the usage is in dead code
after 'mdtc' is set to NULL when CONFIG_CGROUP_WRITEBACK is disabled.
Adding an IS_ENABLED() check makes this clear to the compiler.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/page-writeback.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 3f690bae6b78..f02535b7731a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1611,7 +1611,7 @@ static void balance_dirty_pages(struct bdi_writeback *wb,
 			bg_thresh = gdtc->bg_thresh;
 		}
 
-		if (mdtc) {
+		if (IS_ENABLED(CONFIG_CGROUP_WRITEBACK) && mdtc) {
 			unsigned long filepages, headroom, writeback;
 
 			/*
@@ -1944,7 +1944,7 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 	    wb_calc_thresh(gdtc->wb, gdtc->bg_thresh))
 		return true;
 
-	if (mdtc) {
+	if (IS_ENABLED(CONFIG_CGROUP_WRITEBACK) && mdtc) {
 		unsigned long filepages, headroom, writeback;
 
 		mem_cgroup_wb_stats(wb, &filepages, &headroom, &mdtc->dirty,
-- 
2.18.0
