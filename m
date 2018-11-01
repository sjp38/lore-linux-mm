Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id B9A2A6B0006
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 13:37:56 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id h69so2620565lfg.10
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 10:37:56 -0700 (PDT)
Received: from forwardcorp1j.cmail.yandex.net (forwardcorp1j.cmail.yandex.net. [5.255.227.105])
        by mx.google.com with ESMTPS id i140-v6si26316206lfg.118.2018.11.01.10.37.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 10:37:54 -0700 (PDT)
Subject: [PATCH RFC] mm: do not start node_reclaim for page order > MAX_ORDER
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 01 Nov 2018 20:37:52 +0300
Message-ID: <154109387197.925352.10499549042420271600.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org

Page allocator has check in __alloc_pages_slowpath() but nowdays
there is earlier entry point into reclimer without such check:
get_page_from_freelist() -> node_reclaim().

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/vmscan.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 62ac0c488624..52f672420f0b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -4117,6 +4117,12 @@ int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
 {
 	int ret;
 
+	/*
+	 * Do not scan if allocation will never succeed.
+	 */
+	if (order >= MAX_ORDER)
+		return NODE_RECLAIM_NOSCAN;
+
 	/*
 	 * Node reclaim reclaims unmapped file backed pages and
 	 * slab pages if we are over the defined limits.
