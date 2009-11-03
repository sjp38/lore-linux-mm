Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4D73E6B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 17:19:48 -0500 (EST)
Date: Tue, 3 Nov 2009 22:19:43 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH mmotm] fix to swap_info-include-first_swap_extent-fix.patch
In-Reply-To: <Pine.LNX.4.64.0911021222010.32400@sister.anvils>
Message-ID: <Pine.LNX.4.64.0911032215290.29276@sister.anvils>
References: <1257155103-9189-1-git-send-email-jirislaby@gmail.com>
 <Pine.LNX.4.64.0911021222010.32400@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Sorry, just noticed what the diff contexts don't show: Jiri's patch
is initializing p->first_swap_extent.list at a point before p has
been decided - we may kfree that newly allocated p and go on to
reuse an existing free entry for p.

Now, the patch is not actually wrong: an existing free entry will have
a good empty first_swap_extent.list; but it looks suspicious, it seems
strange to initialize a field in something we're about to kfree, and
I'd rather we put that initialization back to where it was in 2.6.32.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/swapfile.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm/mm/swapfile.c	2009-11-03 18:05:36.000000000 +0000
+++ linux/mm/swapfile.c	2009-11-03 18:08:26.000000000 +0000
@@ -1768,7 +1768,6 @@ SYSCALL_DEFINE2(swapon, const char __use
 		kfree(p);
 		goto out;
 	}
-	INIT_LIST_HEAD(&p->first_swap_extent.list);
 	if (type >= nr_swapfiles) {
 		p->type = type;
 		swap_info[type] = p;
@@ -1787,6 +1786,7 @@ SYSCALL_DEFINE2(swapon, const char __use
 		 * would be relying on p->type to remain valid.
 		 */
 	}
+	INIT_LIST_HEAD(&p->first_swap_extent.list);
 	p->flags = SWP_USED;
 	p->next = -1;
 	spin_unlock(&swap_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
