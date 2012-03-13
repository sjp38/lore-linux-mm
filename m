Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id CA9F36B004D
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 01:36:57 -0400 (EDT)
Received: by vcqp1 with SMTP id p1so22547vcq.2
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 22:36:56 -0700 (PDT)
From: Avery Pennarun <apenwarr@gmail.com>
Subject: [PATCH 2/5] mm: bootmem: it's okay to reserve_bootmem an invalid address.
Date: Tue, 13 Mar 2012 01:36:38 -0400
Message-Id: <1331617001-20906-3-git-send-email-apenwarr@gmail.com>
In-Reply-To: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Avery Pennarun <apenwarr@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Yinghai LU <yinghai@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

...but only if you provide BOOTMEM_EXCLUSIVE, which should guarantee that
you're actually checking the return value.  In that case, just return an
error code if the memory you tried to get is invalid.  This lets callers
safely probe around for a valid memory range.

If you don't use BOOTMEM_EXCLUSIVE and the memory address is invalid, just
crash as before, since the caller is probably not bothering to check the
return value.

Signed-off-by: Avery Pennarun <apenwarr@gmail.com>
---
 mm/bootmem.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 7a9f505..d397dae 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -351,7 +351,10 @@ static int __init mark_bootmem(unsigned long start, unsigned long end,
 			return 0;
 		pos = bdata->node_low_pfn;
 	}
-	BUG();
+	/* people who don't use BOOTMEM_EXCLUSIVE don't check the return
+	 * value, so BUG() if it goes wrong. */
+	BUG_ON(!(reserve && (flags & BOOTMEM_EXCLUSIVE));
+	return -ENOENT;
 }
 
 /**
@@ -421,7 +424,7 @@ int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 }
 
 /**
- * reserve_bootmem - mark a page range as usable
+ * reserve_bootmem - mark a page range as reserved
  * @addr: starting address of the range
  * @size: size of the range in bytes
  * @flags: reservation flags (see linux/bootmem.h)
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
