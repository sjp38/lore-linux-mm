Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kB4Ddbtg118686
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:39:40 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB4DdZkF2179310
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:39:35 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB4DdYnH005777
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:39:35 GMT
Date: Mon, 4 Dec 2006 14:39:34 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH/RFC 3/5] make rodata section read-only again
Message-ID: <20061204133934.GE9209@osiris.boeblingen.de.ibm.com>
References: <20061204133132.GB9209@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061204133132.GB9209@osiris.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Make sure the rodata section is read only again.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/mm/init.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+)

Index: linux-2.6.19-rc6-mm2/arch/s390/mm/init.c
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/mm/init.c
+++ linux-2.6.19-rc6-mm2/arch/s390/mm/init.c
@@ -84,6 +84,26 @@ void show_mem(void)
         printk("%d pages swap cached\n",cached);
 }
 
+static __init void setup_ro_region(void)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+	pte_t new_pte;
+	unsigned long address, end;
+
+	address = ((unsigned long)&__start_rodata) & PAGE_MASK;
+	end = PFN_ALIGN((unsigned long)&__end_rodata);
+
+	for (; address < end; address += PAGE_SIZE) {
+		pgd = pgd_offset_k(address);
+		pmd = pmd_offset(pgd, address);
+		pte = pte_offset_kernel(pmd, address);
+		new_pte = mk_pte_phys(address, __pgprot(_PAGE_RO));
+		set_pte(pte, new_pte);
+	}
+}
+
 extern unsigned long __initdata zholes_size[];
 extern void vmem_map_init(void);
 /*
@@ -110,6 +130,7 @@ void __init paging_init(void)
 		pmd_clear((pmd_t *)(pg_dir + i));
 #endif
 	vmem_map_init();
+	setup_ro_region();
 
 	S390_lowcore.kernel_asce = pgdir_k;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
