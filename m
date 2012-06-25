Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 063966B0327
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 05:55:12 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Mon, 25 Jun 2012 15:25:09 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5P9t4fL917842
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 15:25:04 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5PFPfTB020730
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:25:42 +1000
Message-ID: <1340618099.13778.39.camel@ThinkPad-T420>
Subject: [PATCH powerpc 2/2] kfree the cache name  of pgtable cache if SLUB
 is used
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Mon, 25 Jun 2012 17:54:59 +0800
In-Reply-To: <1340617984.13778.37.camel@ThinkPad-T420>
References: <1340617984.13778.37.camel@ThinkPad-T420>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>, PowerPC email list <linuxppc-dev@lists.ozlabs.org>

This patch tries to kfree the cache name of pgtables cache if SLUB is
used, as SLUB duplicates the cache name, and the original one is leaked.

This patch depends on patch 1 -- (duplicate the cache name in
saved_alias list) in this mail thread. As the pgtables cache might be
merged to other caches. In this case, the name could be safely kfreed
after calling kmem_cache_create() with patch 1.

Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
---
 arch/powerpc/mm/init_64.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 620b7ac..c9d2a7f 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -130,6 +130,9 @@ void pgtable_cache_add(unsigned shift, void
(*ctor)(void *))
 	align = max_t(unsigned long, align, minalign);
 	name = kasprintf(GFP_KERNEL, "pgtable-2^%d", shift);
 	new = kmem_cache_create(name, table_size, align, 0, ctor);
+#ifdef CONFIG_SLUB
+	kfree(name); /* SLUB duplicates the cache name */
+#endif
 	PGT_CACHE(shift) = new;
 
 	pr_debug("Allocated pgtable cache for order %d\n", shift);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
