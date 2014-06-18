Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 486836B0082
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 02:37:51 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so402446pad.37
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 23:37:51 -0700 (PDT)
Received: from fgwmail.fujitsu.co.jp (fgwmail.fujitsu.co.jp. [164.71.1.133])
        by mx.google.com with ESMTPS id ez7si1063833pab.241.2014.06.17.23.37.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 23:37:50 -0700 (PDT)
Received: from kw-mxoi2.gw.nic.fujitsu.com (unknown [10.0.237.143])
	by fgwmail.fujitsu.co.jp (Postfix) with ESMTP id 55B883EE0C8
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 15:37:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.nic.fujitsu.com [10.0.50.93])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 62869AC04F0
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 15:37:48 +0900 (JST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C3621DB8038
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 15:37:48 +0900 (JST)
Message-ID: <53A1339E.2000000@jp.fujitsu.com>
Date: Wed, 18 Jun 2014 15:37:18 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] x86,mem-hotplug: pass sync_global_pgds() a correct argument
 in remove_pagetable()
References: <53A132E2.9000605@jp.fujitsu.com>
In-Reply-To: <53A132E2.9000605@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: tangchen@cn.fujitsu.com, toshi.kani@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, guz.fnst@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com

remove_pagetable() gets start argument and passes the argument to
sync_global_pgds(). In this case, the argument must not be modified.
If the argument is modified and passed to sync_global_pgds(),
sync_global_pgds() does not correctly synchronize PGD to PGD entries
of all processes MM since synchronized range of memory [start, end]
is wrong.

Unfortunately the start argument is modified in remove_pagetable().
So this patch fixes the issue.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/x86/mm/init_64.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index df1a992..a5b245d 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -975,19 +975,20 @@ static void __meminit
 remove_pagetable(unsigned long start, unsigned long end, bool direct)
 {
 	unsigned long next;
+	unsigned long addr;
 	pgd_t *pgd;
 	pud_t *pud;
 	bool pgd_changed = false;

-	for (; start < end; start = next) {
-		next = pgd_addr_end(start, end);
+	for (addr = start; addr < end; addr = next) {
+		next = pgd_addr_end(addr, end);

-		pgd = pgd_offset_k(start);
+		pgd = pgd_offset_k(addr);
 		if (!pgd_present(*pgd))
 			continue;

 		pud = (pud_t *)pgd_page_vaddr(*pgd);
-		remove_pud_table(pud, start, next, direct);
+		remove_pud_table(pud, addr, next, direct);
 		if (free_pud_table(pud, pgd))
 			pgd_changed = true;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
