Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 023CC6B7453
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 07:30:11 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n39so20202128qtn.18
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 04:30:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d7si4379030qtj.266.2018.12.05.04.30.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 04:30:10 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 4/7] riscv/vdso: don't clear PG_reserved
Date: Wed,  5 Dec 2018 13:28:48 +0100
Message-Id: <20181205122851.5891-5-david@redhat.com>
In-Reply-To: <20181205122851.5891-1-david@redhat.com>
References: <20181205122851.5891-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, David Hildenbrand <david@redhat.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Tobias Klauser <tklauser@distanz.ch>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>

The VDSO is part of the kernel image and therefore the struct pages are
marked as reserved during boot.

As we install a special mapping, the actual struct pages will never be
exposed to MM via the page tables. We can therefore leave the pages
marked as reserved.

Cc: Palmer Dabbelt <palmer@sifive.com>
Cc: Albert Ou <aou@eecs.berkeley.edu>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/riscv/kernel/vdso.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/riscv/kernel/vdso.c b/arch/riscv/kernel/vdso.c
index 582cb153eb24..0cd044122234 100644
--- a/arch/riscv/kernel/vdso.c
+++ b/arch/riscv/kernel/vdso.c
@@ -54,7 +54,6 @@ static int __init vdso_init(void)
 		struct page *pg;
 
 		pg = virt_to_page(vdso_start + (i << PAGE_SHIFT));
-		ClearPageReserved(pg);
 		vdso_pagelist[i] = pg;
 	}
 	vdso_pagelist[i] = virt_to_page(vdso_data);
-- 
2.17.2
