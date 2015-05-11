Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id ECD326B0072
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:52:57 -0400 (EDT)
Received: by wgiu9 with SMTP id u9so132650794wgi.3
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:52:57 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id fn5si402573wib.71.2015.05.11.08.52.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 08:52:51 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:52:50 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id EF2DE1B0805F
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:53:31 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BFqlLQ3211546
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:52:47 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BFqjPm014792
	for <linux-mm@kvack.org>; Mon, 11 May 2015 09:52:46 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH v1 05/15] mips: kmap_coherent relies on disabled preemption
Date: Mon, 11 May 2015 17:52:10 +0200
Message-Id: <1431359540-32227-6-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org, dahi@linux.vnet.ibm.com

k(un)map_coherent relies on pagefault_disable() to also disable
preemption.

Let's make this explicit, to prepare for pagefault_disable() not
touching preemption anymore.

This patch is based on a patch by Yang Shi on the -rt tree:
"k{un}map_coherent are just called when cpu_has_dc_aliases == 1 with VIPT
cache. However, actually, the most modern MIPS processors have PIPT dcache
without dcache alias issue. In such case, k{un}map_atomic will be called
with preempt enabled."

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 arch/mips/mm/init.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index faa5c98..198a314 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -90,6 +90,7 @@ static void *__kmap_pgprot(struct page *page, unsigned long addr, pgprot_t prot)
 
 	BUG_ON(Page_dcache_dirty(page));
 
+	preempt_disable();
 	pagefault_disable();
 	idx = (addr >> PAGE_SHIFT) & (FIX_N_COLOURS - 1);
 	idx += in_interrupt() ? FIX_N_COLOURS : 0;
@@ -152,6 +153,7 @@ void kunmap_coherent(void)
 	write_c0_entryhi(old_ctx);
 	local_irq_restore(flags);
 	pagefault_enable();
+	preempt_enable();
 }
 
 void copy_user_highpage(struct page *to, struct page *from,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
