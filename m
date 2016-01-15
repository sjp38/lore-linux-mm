Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDA1828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 00:41:13 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id ba1so512809596obb.3
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 21:41:13 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0060.outbound.protection.outlook.com. [157.55.234.60])
        by mx.google.com with ESMTPS id f132si11297157oig.72.2016.01.14.21.41.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 21:41:12 -0800 (PST)
From: =?UTF-8?Q?Mika_Penttil=c3=a4?= <mika.penttila@nextfour.com>
Subject: [PATCH] mm: make apply_to_page_range more robust
Message-ID: <5698866F.1070802@nextfour.com>
Date: Fri, 15 Jan 2016 07:41:03 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Recent changes (4.4.0+) in module loader triggered oops on ARM. While
loading a module, size in :

apply_to_page_range(struct mm_struct *mm, unsigned long addr,   unsigned
long size, pte_fn_t fn, void *data);

can be 0 triggering the bug  BUG_ON(addr >= end);.

Fix by letting call with zero size succeed.

--Mika

Signed-off-by: mika.penttila@nextfour.com
---

diff --git a/mm/memory.c b/mm/memory.c
index c387430..c3d1a2e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1884,6 +1884,9 @@ int apply_to_page_range(struct mm_struct *mm,
unsigned long addr,
        unsigned long end = addr + size;
        int err;

+       if (!size)
+               return 0;
+
        BUG_ON(addr >= end);
        pgd = pgd_offset(mm, addr);
        do {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
