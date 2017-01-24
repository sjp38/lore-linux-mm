Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF16B6B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 06:27:25 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v77so25896443wmv.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 03:27:25 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id a69si17934426wme.110.2017.01.24.03.27.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 03:27:24 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 3677E98D60
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 11:27:24 +0000 (UTC)
Date: Tue, 24 Jan 2017 11:27:23 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, page_alloc: Split buffered_rmqueue -fix
Message-ID: <20170124112723.mshmgwq2ihxku2um@techsingularity.net>
References: <20170123153906.3122-1-mgorman@techsingularity.net>
 <20170123153906.3122-2-mgorman@techsingularity.net>
 <8808c88d-3404-a3b5-b395-06936bbaa2ed@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <8808c88d-3404-a3b5-b395-06936bbaa2ed@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>

Vlastimil Babka pointed out that a failed per-cpu refill on a kernel with
CONFIG_DEBUG_VM may blow up on a VM_BUG_ON_PAGE. This patch is a fix
to the mmotm patch mm-page_alloc-split-buffered_rmqueue.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c075831c3a1a..5a04636ccc05 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2697,7 +2697,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 	local_irq_restore(flags);
 
 out:
-	VM_BUG_ON_PAGE(bad_range(zone, page), page);
+	VM_BUG_ON_PAGE(page && bad_range(zone, page), page);
 	return page;
 
 failed:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
