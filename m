Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id F29636B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 23:51:40 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t18so13122869oih.11
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 20:51:40 -0700 (PDT)
Received: from mail-it0-x230.google.com (mail-it0-x230.google.com. [2607:f8b0:4001:c0b::230])
        by mx.google.com with ESMTPS id t8si5613006oig.288.2017.08.14.20.51.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 20:51:40 -0700 (PDT)
Received: by mail-it0-x230.google.com with SMTP id m34so678183iti.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 20:51:40 -0700 (PDT)
Date: Mon, 14 Aug 2017 21:51:38 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v5 02/10] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20170815035138.qylh4mhpqom5g6qx@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-3-tycho@docker.com>
 <910adbb5-c5d7-3091-1c92-996f73dd6221@redhat.com>
 <20170815034718.o6fej2gqkmypxtl2@smitten>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170815034718.o6fej2gqkmypxtl2@smitten>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On Mon, Aug 14, 2017 at 09:47:18PM -0600, Tycho Andersen wrote:
> I'll do that for the next version

Actually looking closer, I think we just need to mirror the
debug_pagealloc_enabled() checks in set_kpte() from
split_large_page(),

diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
index a1344f27406c..c962bd7f34cc 100644
--- a/arch/x86/mm/xpfo.c
+++ b/arch/x86/mm/xpfo.c
@@ -54,9 +54,11 @@ inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
 
 		do_split = try_preserve_large_page(pte, (unsigned long)kaddr, &cpa);
 		if (do_split) {
-			spin_lock(&cpa_lock);
+			if (!debug_pagealloc_enabled())
+				spin_lock(&cpa_lock);
 			BUG_ON(split_large_page(&cpa, pte, (unsigned long)kaddr));
-			spin_unlock(&cpa_lock);
+			if (!debug_pagealloc_enabled())
+				spin_unlock(&cpa_lock);
 		}
 
 		break;


Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
