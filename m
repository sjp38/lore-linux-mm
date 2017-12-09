Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 219DD6B027E
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 23:16:27 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id y124so5780071oie.0
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 20:16:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j50si3214937otc.212.2017.12.08.20.16.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 20:16:26 -0800 (PST)
Date: Sat, 9 Dec 2017 12:16:10 +0800
From: Dave Young <dyoung@redhat.com>
Subject: [PATCH resend] fix boot hang with earlyprintk=efi,keep
Message-ID: <20171209041610.GA3249@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, bp@suse.de, mingo@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-efi@vger.kernel.org

earlyprintk=efi,keep does not work any more with a warning
in mm/early_ioremap.c: WARN_ON(system_state != SYSTEM_BOOTING):
Boot just hangs because of the earlyprintk within earlyprintk
implementation code.

This is caused by a new introduced middle state in below commit:
commit 69a78ff226fe ("init: Introduce SYSTEM_SCHEDULING state")
early_ioremap is fine in both SYSTEM_BOOTING and SYSTEM_SCHEDULING
states, original condition should be updated accordingly.

Signed-off-by: Dave Young <dyoung@redhat.com>
---
v1->v2: update patch log correct some typos
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
