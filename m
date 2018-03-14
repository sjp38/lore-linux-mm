Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id BADC86B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 07:51:57 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id v4-v6so1349102plp.16
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 04:51:57 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0100.outbound.protection.outlook.com. [104.47.1.100])
        by mx.google.com with ESMTPS id c4si1742646pgu.355.2018.03.14.04.51.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Mar 2018 04:51:56 -0700 (PDT)
Subject: [PATCH] percpu: Allow to kill tasks doing pcpu_alloc() and waiting
 for pcpu_balance_workfn()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 14 Mar 2018 14:51:48 +0300
Message-ID: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tj@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In case of memory deficit and low percpu memory pages,
pcpu_balance_workfn() takes pcpu_alloc_mutex for a long
time (as it makes memory allocations itself and waits
for memory reclaim). If tasks doing pcpu_alloc() are
choosen by OOM killer, they can't exit, because they
are waiting for the mutex.

The patch makes pcpu_alloc() to care about killing signal
and use mutex_lock_killable(), when it's allowed by GFP
flags. This guarantees, a task does not miss SIGKILL
from OOM killer.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/percpu.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 50e7fdf84055..212b4988926c 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1369,8 +1369,12 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 		return NULL;
 	}
 
-	if (!is_atomic)
-		mutex_lock(&pcpu_alloc_mutex);
+	if (!is_atomic) {
+		if (gfp & __GFP_NOFAIL)
+			mutex_lock(&pcpu_alloc_mutex);
+		else if (mutex_lock_killable(&pcpu_alloc_mutex))
+			return NULL;
+	}
 
 	spin_lock_irqsave(&pcpu_lock, flags);
 
