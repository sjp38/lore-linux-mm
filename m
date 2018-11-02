Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB1126B0008
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 08:00:19 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id be11-v6so1445402plb.2
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 05:00:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 60-v6sor22747702plb.63.2018.11.02.05.00.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Nov 2018 05:00:18 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [PATCH] mm/hotplug: Optimize clear_hwpoisoned_pages
Date: Fri,  2 Nov 2018 23:00:01 +1100
Message-Id: <20181102120001.4526-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>

In hot remove, we try to clear poisoned pages, but
a small optimization to check if num_poisoned_pages
is 0 helps remove the iteration through nr_pages.

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 mm/sparse.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index 33307fc05c4d..16219c7ddb5f 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -724,6 +724,16 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 	if (!memmap)
 		return;
 
+	/*
+	 * A further optimization is to have per section
+	 * ref counted num_poisoned_pages, but that is going
+	 * to need more space per memmap, for now just do
+	 * a quick global check, this should speed up this
+	 * routine in the absence of bad pages.
+	 */
+	if (atomic_long_read(&num_poisoned_pages) == 0)
+		return;
+
 	for (i = 0; i < nr_pages; i++) {
 		if (PageHWPoison(&memmap[i])) {
 			atomic_long_sub(1, &num_poisoned_pages);
-- 
2.17.1
