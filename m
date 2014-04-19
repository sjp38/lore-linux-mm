Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id ED2526B0037
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 07:44:02 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so2335047eek.1
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 04:44:02 -0700 (PDT)
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
        by mx.google.com with ESMTPS id 45si44565672eeh.63.2014.04.19.04.44.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 04:44:01 -0700 (PDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so2320723eek.31
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 04:44:01 -0700 (PDT)
From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 3/4] ipc/shm.c: check for integer overflow during shmget.
Date: Sat, 19 Apr 2014 13:43:40 +0200
Message-Id: <1397907821-29319-4-git-send-email-manfred@colorfullife.com>
In-Reply-To: <1397907821-29319-3-git-send-email-manfred@colorfullife.com>
References: <1397907821-29319-1-git-send-email-manfred@colorfullife.com>
 <1397907821-29319-2-git-send-email-manfred@colorfullife.com>
 <1397907821-29319-3-git-send-email-manfred@colorfullife.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>

SHMMAX is the upper limit of a shared memory segment,
counted in bytes. The actual allocation is that size, rounded
up to the next full page.
Add a check that prevents the creation of segments where the
rounded up size causes an integer overflow.

Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
---
 ipc/shm.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ipc/shm.c b/ipc/shm.c
index 2dfa3d6..f000696 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -493,6 +493,9 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 	if (size < SHMMIN || size > ns->shm_ctlmax)
 		return -EINVAL;
 
+	if (numpages << PAGE_SHIFT < size)
+		return -ENOSPC;
+
 	if (ns->shm_tot + numpages < ns->shm_tot ||
 			ns->shm_tot + numpages > ns->shm_ctlall)
 		return -ENOSPC;
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
