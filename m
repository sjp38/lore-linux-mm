Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 61D066B0254
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 00:17:08 -0500 (EST)
Received: by mail-oi0-f47.google.com with SMTP id p187so189981310oia.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 21:17:08 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0078.outbound.protection.outlook.com. [104.47.1.78])
        by mx.google.com with ESMTPS id h188si2816530oia.5.2016.01.19.21.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Jan 2016 21:17:07 -0800 (PST)
From: =?UTF-8?Q?Mika_Penttil=c3=a4?= <mika.penttila@nextfour.com>
Subject: [PATCH v2] mm: make apply_to_page_range more robust
Message-ID: <569F184D.8020602@nextfour.com>
Date: Wed, 20 Jan 2016 07:17:01 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

Recent changes (4.4.0+) in module loader triggered oops on ARM. 
    
can be 0 triggering the bug  BUG_ON(addr >= end);.

The call path is SyS_init_module()->set_memory_xx()->apply_to_page_range(),
and apply_to_page_range gets zero length resulting in triggering :
   
  BUG_ON(addr >= end)

This is a consequence of changes in module section handling (Rusty CC:ed).
This may be triggable only with certain modules and/or gcc versions. 

Plus, I think the spirit of the BUG_ON is to catch overflows,
not to bug on zero length legitimate callers. So whatever the
reason for this triggering, some day we have another caller with
zero length. 

Fix by letting call with zero size succeed. 

v2: add more explanation

Signed-off-by: Mika PenttilA? mika.penttila@nextfour.com
Reviewed-by: Pekka Enberg <penberg@kernel.org>
---

diff --git a/mm/memory.c b/mm/memory.c
index c387430..c3d1a2e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1884,6 +1884,9 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
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
