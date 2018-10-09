Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 828106B0007
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 14:48:19 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id v132-v6so1517660ywb.15
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 11:48:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e142-v6sor9951265yba.7.2018.10.09.11.48.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 11:48:17 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/4] mm: workingset: use cheaper __inc_lruvec_state in irqsafe node reclaim
Date: Tue,  9 Oct 2018 14:47:31 -0400
Message-Id: <20181009184732.762-3-hannes@cmpxchg.org>
In-Reply-To: <20181009184732.762-1-hannes@cmpxchg.org>
References: <20181009184732.762-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

No need to use the preemption-safe lruvec state function inside the
reclaim region that has irqs disabled.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/workingset.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index e5c70bc94077..f564aaa6b71d 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -493,7 +493,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	 * shadow entries we were tracking ...
 	 */
 	xas_store(&xas, NULL);
-	inc_lruvec_page_state(virt_to_page(node), WORKINGSET_NODERECLAIM);
+	__inc_lruvec_page_state(virt_to_page(node), WORKINGSET_NODERECLAIM);
 
 out_invalid:
 	xa_unlock_irq(&mapping->i_pages);
-- 
2.19.0
