Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 0E8376B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 08:34:48 -0400 (EDT)
Received: by yenm8 with SMTP id m8so7782631yen.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 05:34:47 -0700 (PDT)
Message-ID: <4F68795E.9030304@kernel.org>
Date: Tue, 20 Mar 2012 20:34:38 +0800
From: Shaohua Li <shli@kernel.org>
MIME-Version: 1.0
Subject: [RFC]swap: don't do discard if no discard option added
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Holger Kiehl <Holger.Kiehl@dwd.de>


Even don't add discard option, swapon will do discard, this sounds buggy,
especially when discard is slow or buggy.

Reported-by: Holger Kiehl <Holger.Kiehl@dwd.de>
Signed-off-by: Shaohua Li <shli@fusionio.com>
---
  mm/swapfile.c |    2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2012-03-20 20:11:59.222767526 +0800
+++ linux/mm/swapfile.c	2012-03-20 20:13:25.362767387 +0800
@@ -2105,7 +2105,7 @@ SYSCALL_DEFINE2(swapon, const char __use
  			p->flags |= SWP_SOLIDSTATE;
  			p->cluster_next = 1 + (random32() % p->highest_bit);
  		}
-		if (discard_swap(p) == 0 && (swap_flags & SWAP_FLAG_DISCARD))
+		if ((swap_flags & SWAP_FLAG_DISCARD) && discard_swap(p) == 0)
  			p->flags |= SWP_DISCARDABLE;
  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
