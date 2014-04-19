Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id C2C226B0035
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 07:43:59 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so2342837eei.0
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 04:43:59 -0700 (PDT)
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
        by mx.google.com with ESMTPS id d5si44505867eei.298.2014.04.19.04.43.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 04:43:58 -0700 (PDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so2345517eek.10
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 04:43:58 -0700 (PDT)
From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 1/4] ipc/shm.c: check for ulong overflows in shmat
Date: Sat, 19 Apr 2014 13:43:38 +0200
Message-Id: <1397907821-29319-2-git-send-email-manfred@colorfullife.com>
In-Reply-To: <1397907821-29319-1-git-send-email-manfred@colorfullife.com>
References: <1397907821-29319-1-git-send-email-manfred@colorfullife.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>

find_vma_intersection does not work properly if addr+size overflows.
The patch adds a manual check before the call to find_vma_intersection.

Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
---
 ipc/shm.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ipc/shm.c b/ipc/shm.c
index 7645961..382e2fb 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1160,6 +1160,9 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	down_write(&current->mm->mmap_sem);
 	if (addr && !(shmflg & SHM_REMAP)) {
 		err = -EINVAL;
+		if (addr + size < addr)
+			goto invalid;
+
 		if (find_vma_intersection(current->mm, addr, addr + size))
 			goto invalid;
 		/*
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
