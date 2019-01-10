Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE7B8E0008
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:10:49 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id x67so8649005pfk.16
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:10:49 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 31si7655786plz.263.2019.01.10.13.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 13:10:48 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [RFC PATCH v7 15/16] xpfo, mm: Fix hang when booting with "xpfotlbflush"
Date: Thu, 10 Jan 2019 14:09:47 -0700
Message-Id: <c65c84a5e0a3df290d2b65dc36867bbedf51cb97.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Kernel hangs when booted up with "xpfotlbflush" option. This is caused
by xpfo_kunmap() fliushing TLB while holding xpfo lock starving other
tasks waiting for the lock. This patch moves tlb flush outside of the
code holding xpfo lock.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 mm/xpfo.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/xpfo.c b/mm/xpfo.c
index 85079377c91d..79ffdba6af69 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -148,6 +148,8 @@ EXPORT_SYMBOL(xpfo_kmap);
 
 void xpfo_kunmap(void *kaddr, struct page *page)
 {
+	bool flush_tlb = false;
+
 	if (!static_branch_unlikely(&xpfo_inited))
 		return;
 
@@ -168,10 +170,13 @@ void xpfo_kunmap(void *kaddr, struct page *page)
 		if (atomic_read(&page->xpfo_mapcount) == 0) {
 			SetPageXpfoUnmapped(page);
 			set_kpte(kaddr, page, __pgprot(0));
-			xpfo_cond_flush_kernel_tlb(page, 0);
+			flush_tlb = true;
 		}
 		spin_unlock(&page->xpfo_lock);
 	}
+
+	if (flush_tlb)
+		xpfo_cond_flush_kernel_tlb(page, 0);
 }
 EXPORT_SYMBOL(xpfo_kunmap);
 
-- 
2.17.1
