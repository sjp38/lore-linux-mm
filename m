Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id E96B66B0007
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 06:17:08 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id c24-v6so2554811lja.1
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 03:17:08 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id d202si20033283lfe.126.2018.11.05.03.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 03:17:07 -0800 (PST)
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v2] mm: use kvzalloc for swap_info_struct allocation
References: <20181105061016.GA4502@intel.com>
Message-ID: <fc23172d-3c75-21e2-d551-8b1808cbe593@virtuozzo.com>
Date: Mon, 5 Nov 2018 14:17:01 +0300
MIME-Version: 1.0
In-Reply-To: <20181105061016.GA4502@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, Aaron Lu <aaron.lu@intel.com>

commit a2468cc9bfdf ("swap: choose swap device according to numa node")
changed 'avail_lists' field of 'struct swap_info_struct' to an array.
In popular linux distros it increased size of swap_info_struct up to
40 Kbytes and now swap_info_struct allocation requires order-4 page.
Switch to kvzmalloc allows to avoid unexpected allocation failures.

Acked-by: Aaron Lu <aaron.lu@intel.com>
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
