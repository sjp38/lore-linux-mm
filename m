Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1250F6B004A
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 22:03:16 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p5D23D1A026886
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 19:03:13 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by hpaq13.eem.corp.google.com with ESMTP id p5D23BwN030723
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 19:03:12 -0700
Received: by pzk2 with SMTP id 2so2190608pzk.37
        for <linux-mm@kvack.org>; Sun, 12 Jun 2011 19:03:11 -0700 (PDT)
Date: Sun, 12 Jun 2011 19:03:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] slub: fix kernel BUG at mm/slub.c:1950!
Message-ID: <alpine.LSU.2.00.1106121842250.31463@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

3.0-rc won't boot with SLUB on my PowerPC G5: kernel BUG at mm/slub.c:1950!
Bisected to 1759415e630e "slub: Remove CONFIG_CMPXCHG_LOCAL ifdeffery".

After giving myself a medal for finding the BUG on line 1950 of mm/slub.c
(it's actually the
	VM_BUG_ON((unsigned long)(&pcp1) % (2 * sizeof(pcp1)));
on line 268 of the morass that is include/linux/percpu.h)
I tried the following alignment patch and found it to work.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/slub_def.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 3.0-rc2/include/linux/slub_def.h	2011-05-29 18:42:37.077880848 -0700
+++ linux/include/linux/slub_def.h	2011-06-12 17:17:51.000000000 -0700
@@ -43,7 +43,7 @@ struct kmem_cache_cpu {
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
-};
+} __attribute__((aligned(2 * sizeof(long))));
 
 struct kmem_cache_node {
 	spinlock_t list_lock;	/* Protect partial list and nr_partial */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
