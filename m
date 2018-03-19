Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A85A6B0022
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 11:32:18 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w14-v6so2895415plp.13
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 08:32:18 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30112.outbound.protection.outlook.com. [40.107.3.112])
        by mx.google.com with ESMTPS id g11si153133pgf.5.2018.03.19.08.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 19 Mar 2018 08:32:17 -0700 (PDT)
Subject: [PATCH v2] mm: Allow to kill tasks doing pcpu_alloc() and waiting for
 pcpu_balance_workfn()
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
 <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
 <20180319151447.GL2943022@devbig577.frc2.facebook.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <4e8ca27a-9c92-8f1e-fb72-88758a266cb6@virtuozzo.com>
Date: Mon, 19 Mar 2018 18:32:10 +0300
MIME-Version: 1.0
In-Reply-To: <20180319151447.GL2943022@devbig577.frc2.facebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Kirill Tkhai <ktkhai@virtuozzo.com>

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
v2: Added explaining comment
 mm/percpu.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 50e7fdf84055..605e3228baa6 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1369,8 +1369,17 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 		return NULL;
 	}
 
-	if (!is_atomic)
-		mutex_lock(&pcpu_alloc_mutex);
+	if (!is_atomic) {
+		/*
+		 * pcpu_balance_workfn() allocates memory under this mutex,
+		 * and it may wait for memory reclaim. Allow current task
+		 * to become OOM victim, in case of memory pressure.
+		 */
+		if (gfp & __GFP_NOFAIL)
+			mutex_lock(&pcpu_alloc_mutex);
+		else if (mutex_lock_killable(&pcpu_alloc_mutex))
+			return NULL;
+	}
 
 	spin_lock_irqsave(&pcpu_lock, flags);
 
