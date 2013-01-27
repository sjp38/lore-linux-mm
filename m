Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 445646B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 16:47:01 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so1140385pad.40
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 13:47:00 -0800 (PST)
Date: Sun, 27 Jan 2013 13:47:01 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH next/mmotm] swap: add per-partition lock for swapfile fix
In-Reply-To: <20130127141253.GA27019@kernel.org>
Message-ID: <alpine.LNX.2.00.1301271341030.16981@eggly.anvils>
References: <5101FFF5.6030503@oracle.com> <20130125042512.GA32017@kernel.org> <alpine.LNX.2.00.1301261754530.7300@eggly.anvils> <20130127141253.GA27019@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Shaohua Li <shli@fusionio.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I had all cpus spinning in swap_info_get(), for the lock on an area
being swapped off: probably because get_swap_page() forgot to unlock.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/swapfile.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

--- mmotm.orig/mm/swapfile.c	2013-01-23 17:55:39.132447115 -0800
+++ mmotm/mm/swapfile.c	2013-01-27 10:41:45.000000000 -0800
@@ -470,10 +470,9 @@ swp_entry_t get_swap_page(void)
 		spin_unlock(&swap_lock);
 		/* This is called for allocating swap entry for cache */
 		offset = scan_swap_map(si, SWAP_HAS_CACHE);
-		if (offset) {
-			spin_unlock(&si->lock);
+		spin_unlock(&si->lock);
+		if (offset)
 			return swp_entry(type, offset);
-		}
 		spin_lock(&swap_lock);
 		next = swap_list.next;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
