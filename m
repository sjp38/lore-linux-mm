Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id C2CA86B0005
	for <linux-mm@kvack.org>; Sun,  4 Nov 2018 17:13:14 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id h12-v6so2008807ljb.12
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 14:13:14 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id l10-v6si8931043ljj.86.2018.11.04.14.13.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 14:13:12 -0800 (PST)
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 1/2] mm: use kvzalloc for swap_info_struct allocation
Message-ID: <37b60523-d085-71e9-fef9-80b90bfcef18@virtuozzo.com>
Date: Mon, 5 Nov 2018 01:13:04 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, Aaron Lu <aaron.lu@intel.com>

commit a2468cc9bfdf ("swap: choose swap device according to numa node")
increased size of swap_info_struct up to 44 Kbytes, now it requires 4th order page.
Switch to kvzmalloc allows to avoid unexpected allocation failures.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 mm/swapfile.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 644f746e167a..8688ae65ef58 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2813,7 +2813,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 	unsigned int type;
 	int i;
 
-	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	p = kvzalloc(sizeof(*p), GFP_KERNEL);
 	if (!p)
 		return ERR_PTR(-ENOMEM);
 
@@ -2824,7 +2824,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 	}
 	if (type >= MAX_SWAPFILES) {
 		spin_unlock(&swap_lock);
-		kfree(p);
+		kvfree(p);
 		return ERR_PTR(-EPERM);
 	}
 	if (type >= nr_swapfiles) {
@@ -2838,7 +2838,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 		smp_wmb();
 		nr_swapfiles++;
 	} else {
-		kfree(p);
+		kvfree(p);
 		p = swap_info[type];
 		/*
 		 * Do not memset this entry: a racing procfs swap_next()
-- 
2.17.1
