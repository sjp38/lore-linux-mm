Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3006B0007
	for <linux-mm@kvack.org>; Sun,  4 Nov 2018 17:13:17 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id p19so895273lfg.5
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 14:13:17 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id q22si30629394lfj.86.2018.11.04.14.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 14:13:15 -0800 (PST)
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 2/2] mm: avoid unnecessary swap_info_struct allocation
Message-ID: <a24bf353-8715-2bee-d0fa-96ca06c5b69f@virtuozzo.com>
Date: Mon, 5 Nov 2018 01:13:12 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, Aaron Lu <aaron.lu@intel.com>

Currently newly allocated swap_info_struct can be quickly freed.
This patch avoid uneccessary high-order page allocation and helps
to decrease the memory pressure.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 mm/swapfile.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8688ae65ef58..53ec2f0cdf26 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2809,14 +2809,17 @@ late_initcall(max_swapfiles_check);
 
 static struct swap_info_struct *alloc_swap_info(void)
 {
-	struct swap_info_struct *p;
+	struct swap_info_struct *p = NULL;
 	unsigned int type;
 	int i;
+	bool force_alloc = false;
 
-	p = kvzalloc(sizeof(*p), GFP_KERNEL);
-	if (!p)
-		return ERR_PTR(-ENOMEM);
-
+retry:
+	if (force_alloc) {
+		p = kvzalloc(sizeof(*p), GFP_KERNEL);
+		if (!p)
+			return ERR_PTR(-ENOMEM);
+	}
 	spin_lock(&swap_lock);
 	for (type = 0; type < nr_swapfiles; type++) {
 		if (!(swap_info[type]->flags & SWP_USED))
@@ -2828,6 +2831,11 @@ static struct swap_info_struct *alloc_swap_info(void)
 		return ERR_PTR(-EPERM);
 	}
 	if (type >= nr_swapfiles) {
+		if (!force_alloc) {
+			force_alloc = true;
+			spin_unlock(&swap_lock);
+			goto retry;
+		}
 		p->type = type;
 		swap_info[type] = p;
 		/*
-- 
2.17.1
