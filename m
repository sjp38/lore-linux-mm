Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 9393B6B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 01:36:57 -0400 (EDT)
Received: by vcqp1 with SMTP id p1so22546vcq.2
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 22:36:56 -0700 (PDT)
From: Avery Pennarun <apenwarr@gmail.com>
Subject: [PATCH 3/5] mm: nobootmem: implement reserve_bootmem() in terms of memblock.
Date: Tue, 13 Mar 2012 01:36:39 -0400
Message-Id: <1331617001-20906-4-git-send-email-apenwarr@gmail.com>
In-Reply-To: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Avery Pennarun <apenwarr@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Yinghai LU <yinghai@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

There was an implementation for it in mm/bootmem.c, but it was left out of
nobootmem.c, and we can easily write a memblock implementation.  That way
code (eg.  printk) that wants to reserve memory early on can just always
call bootmem on all platforms.

Signed-off-by: Avery Pennarun <apenwarr@gmail.com>
---
 mm/nobootmem.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 24f0fc1..2c269da 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -193,6 +193,29 @@ void __init free_bootmem(unsigned long addr, unsigned long size)
 	memblock_free(addr, size);
 }
 
+/**
+ * reserve_bootmem - mark a page range as reserved
+ * @addr: starting address of the range
+ * @size: size of the range in bytes
+ * @flags: reservation flags (see linux/bootmem.h)
+ *
+ * Partial pages will be reserved.
+ *
+ * The range must be contiguous but may span node boundaries.
+ */
+int __init reserve_bootmem(unsigned long addr, unsigned long size,
+			    int flags)
+{
+	if (flags & BOOTMEM_EXCLUSIVE) {
+		phys_addr_t m = memblock_find_in_range(addr, addr + size,
+					size, PAGE_SIZE);
+		if (m != addr)
+			return -EBUSY;
+	}
+	memblock_reserve(addr, size);
+	return 0;
+}
+
 static void * __init ___alloc_bootmem_nopanic(unsigned long size,
 					unsigned long align,
 					unsigned long goal,
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
