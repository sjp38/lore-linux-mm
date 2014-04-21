Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 90D5E6B003A
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 10:31:46 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id c41so3686617eek.36
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 07:31:46 -0700 (PDT)
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
        by mx.google.com with ESMTPS id u5si54783852een.113.2014.04.21.07.31.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Apr 2014 07:31:45 -0700 (PDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so3666768eek.16
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 07:31:44 -0700 (PDT)
From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 2/4] ipc/shm.c: check for overflows of shm_tot
Date: Mon, 21 Apr 2014 16:26:35 +0200
Message-Id: <1398090397-2397-3-git-send-email-manfred@colorfullife.com>
In-Reply-To: <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
 <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>

shm_tot counts the total number of pages used by shm segments.

If SHMALL is ULONG_MAX (or nearly ULONG_MAX), then the number
can overflow.  Subsequent calls to shmctl(,SHM_INFO,) would return
wrong values for shm_tot.

The patch adds a detection for overflows.

Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
---
 ipc/shm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 382e2fb..2dfa3d6 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -493,7 +493,8 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 	if (size < SHMMIN || size > ns->shm_ctlmax)
 		return -EINVAL;
 
-	if (ns->shm_tot + numpages > ns->shm_ctlall)
+	if (ns->shm_tot + numpages < ns->shm_tot ||
+			ns->shm_tot + numpages > ns->shm_ctlall)
 		return -ENOSPC;
 
 	shp = ipc_rcu_alloc(sizeof(*shp));
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
