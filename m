Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 68B1F6B004D
	for <linux-mm@kvack.org>; Fri, 11 May 2012 04:00:28 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4057060pbb.14
        for <linux-mm@kvack.org>; Fri, 11 May 2012 01:00:27 -0700 (PDT)
Date: Fri, 11 May 2012 01:00:07 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: raise MemFree by reverting percpu_pagelist_fraction to
 0
Message-ID: <alpine.LSU.2.00.1205110054520.2801@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <levinsasha928@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Why is there less MemFree than there used to be?  It perturbed a test,
so I've just been bisecting linux-next, and now find the offender went
upstream yesterday.

Commit 93278814d359 "mm: fix division by 0 in percpu_pagelist_fraction()"
mistakenly initialized percpu_pagelist_fraction to the sysctl's minimum 8,
which leaves 1/8th of memory on percpu lists (on each cpu??); but most of
us expect it to be left unset at 0 (and it's not then used as a divisor).

MemTotal: 8061476kB  8061476kB  8061476kB  8061476kB  8061476kB  8061476kB
Repetitive test with percpu_pagelist_fraction 8:
MemFree:  6948420kB  6237172kB  6949696kB  6840692kB  6949048kB  6862984kB
Same test with percpu_pagelist_fraction back to 0:
MemFree:  7945000kB  7944908kB  7948568kB  7949060kB  7948796kB  7948812kB

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 3.4-rc6+/mm/page_alloc.c	2012-05-10 22:53:35.362478419 -0700
+++ linux/mm/page_alloc.c	2012-05-11 00:07:31.613657283 -0700
@@ -105,7 +105,7 @@ unsigned long totalreserve_pages __read_
  */
 unsigned long dirty_balance_reserve __read_mostly;
 
-int percpu_pagelist_fraction = 8;
+int percpu_pagelist_fraction;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
 
 #ifdef CONFIG_PM_SLEEP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
