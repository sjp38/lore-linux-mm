Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5826B6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:24:48 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k200so38964868lfg.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:24:48 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id f20si30485606wme.7.2016.04.27.05.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 05:24:47 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id A91051C1581
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:24:46 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/4] mm, page_alloc: inline the fast path of the zonelist iterator -fix
Date: Wed, 27 Apr 2016 13:24:43 +0100
Message-Id: <1461759885-17163-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1461759885-17163-1-git-send-email-mgorman@techsingularity.net>
References: <1461759885-17163-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Vlastimil Babka pointed out that the nodes allowed by a cpuset are not
reread if the nodemask changes during an allocation. This potentially
allows an unnecessary page allocation failure. Moving the retry_cpuset
label is insufficient but rereading the nodemask before retrying addresses
the problem.

This is a fix to the mmotm patch
mm-page_alloc-inline-the-fast-path-of-the-zonelist-iterator.patch .

Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d8383750bd43..45a36e98b9cb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3855,6 +3855,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	 */
 	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie))) {
 		alloc_mask = gfp_mask;
+		ac.nodemask = &cpuset_current_mems_allowed;
 		goto retry_cpuset;
 	}
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
