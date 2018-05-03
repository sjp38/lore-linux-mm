Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2162C6B0011
	for <linux-mm@kvack.org>; Thu,  3 May 2018 16:47:30 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id n2-v6so12711932pgs.2
        for <linux-mm@kvack.org>; Thu, 03 May 2018 13:47:30 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id r13-v6si2419295pgq.675.2018.05.03.13.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 13:47:28 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 1/2] Revert "ipc/shm: Fix shmat mmap nil-page protection"
Date: Thu,  3 May 2018 13:32:42 -0700
Message-Id: <20180503203243.15045-2-dave@stgolabs.net>
In-Reply-To: <20180503203243.15045-1-dave@stgolabs.net>
References: <20180503203243.15045-1-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aarcange@redhat.com
Cc: joe.lawrence@redhat.com, gareth.evans@contextis.co.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave@stgolabs.net, stable@kernel.org, Davidlohr Bueso <dbueso@suse.de>

95e91b831f87 (ipc/shm: Fix shmat mmap nil-page protection) worked on
the idea that we should not be mapping as root addr=0 and MAP_FIXED.
However, it was reported that this scenario is in fact valid, thus
making the patch both bogus and breaks userspace as well. For example
X11's libint10.so relies on shmat(1, SHM_RND) for lowmem initialization[1].

[1] https://cgit.freedesktop.org/xorg/xserver/tree/hw/xfree86/os-support/linux/int10/linux.c#n347

Reported-by: Joe Lawrence <joe.lawrence@redhat.com>
Reported-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 ipc/shm.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 0075990338f4..b81d53c8f459 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1371,13 +1371,8 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 
 	if (addr) {
 		if (addr & (shmlba - 1)) {
-			/*
-			 * Round down to the nearest multiple of shmlba.
-			 * For sane do_mmap_pgoff() parameters, avoid
-			 * round downs that trigger nil-page and MAP_FIXED.
-			 */
-			if ((shmflg & SHM_RND) && addr >= shmlba)
-				addr &= ~(shmlba - 1);
+			if (shmflg & SHM_RND)
+				addr &= ~(shmlba - 1);  /* round down */
 			else
 #ifndef __ARCH_FORCE_SHMLBA
 				if (addr & ~PAGE_MASK)
-- 
2.13.6
