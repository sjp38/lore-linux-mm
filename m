Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE626B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:06:08 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so5540030pde.20
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 02:06:06 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id sz7si10845177pab.0.2014.01.27.02.06.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Jan 2014 02:06:03 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0200EOS1E0RK70@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jan 2014 19:06:00 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 6/8] mm/swap: remove swap_lock to simplify si_swapinfo()
Date: Mon, 27 Jan 2014 18:03:04 +0800
Message-id: <000901cf1b47$60f439c0$22dcad40$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, shli@kernel.org, 'Bob Liu' <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, 'Heesub Shin' <heesub.shin@samsung.com>, mquzik@redhat.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

Consider of performance and simplicity, this patch remove swap_lock
to simplify the si_swapinfo().

Because the system info we obtain through /proc or /sys interface is
just a snapshot, we don't need a very precise freeswap and totalswap count.
Some monitor tool will get these count at per-second period, so it is good
to performance.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/swapfile.c |   15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3023172..7332c3d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2637,19 +2637,8 @@ out:
 
 void si_swapinfo(struct sysinfo *val)
 {
-	unsigned int type;
-	unsigned long nr_to_be_unused = 0;
-
-	spin_lock(&swap_lock);
-	for (type = 0; type < nr_swapfiles; type++) {
-		struct swap_info_struct *si = swap_info[type];
-
-		if ((si->flags & SWP_USED) && !(si->flags & SWP_WRITEOK))
-			nr_to_be_unused += si->inuse_pages;
-	}
-	val->freeswap = atomic_long_read(&nr_swap_pages) + nr_to_be_unused;
-	val->totalswap = total_swap_pages + nr_to_be_unused;
-	spin_unlock(&swap_lock);
+	val->freeswap = atomic_long_read(&nr_swap_pages);
+	val->totalswap = total_swap_pages;
 }
 
 /*
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
