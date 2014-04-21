Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 08E5B6B0039
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 10:31:44 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so3678341eek.20
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 07:31:44 -0700 (PDT)
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
        by mx.google.com with ESMTPS id n46si10536232eeo.97.2014.04.21.07.31.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Apr 2014 07:31:43 -0700 (PDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so3684728eek.2
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 07:31:42 -0700 (PDT)
From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 1/4] ipc/shm.c: check for ulong overflows in shmat
Date: Mon, 21 Apr 2014 16:26:34 +0200
Message-Id: <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
In-Reply-To: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>

find_vma_intersection does not work as intended if addr+size overflows.
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
