Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 469286B0033
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 22:34:40 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id u128so62945oib.8
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 19:34:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j5si1712400oif.26.2017.12.01.19.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 19:34:39 -0800 (PST)
Date: Sat, 2 Dec 2017 11:34:30 +0800
From: Dave Young <dyoung@redhat.com>
Subject: [PATCH] fix system_state checking in early_ioremap
Message-ID: <20171202033430.GA2619@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, bp@suse.de, mingo@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-efi@vger.kernel.org

Since below commit earlyprintk=efi,keep does not work any more with a warning
in mm/early_ioremap.c: WARN_ON(system_state >= SYSTEM_RUNNING):
commit 69a78ff226fe ("init: Introduce SYSTEM_SCHEDULING state")

Reason is the the original assumption is SYSTEM_BOOTING equal to
system_state < SYSTEM_RUNNING. But with commit 69a78ff226fe it is not true
any more. Change the WARN_ON to check system_state >= SYSTEM_RUNNING instead.

Signed-off-by: Dave Young <dyoung@redhat.com>
---
 mm/early_ioremap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-x86.orig/mm/early_ioremap.c
+++ linux-x86/mm/early_ioremap.c
@@ -111,7 +111,7 @@ __early_ioremap(resource_size_t phys_add
 	enum fixed_addresses idx;
 	int i, slot;
 
-	WARN_ON(system_state != SYSTEM_BOOTING);
+	WARN_ON(system_state >= SYSTEM_RUNNING);
 
 	slot = -1;
 	for (i = 0; i < FIX_BTMAPS_SLOTS; i++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
