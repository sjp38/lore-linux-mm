Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3DD6B0022
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 13:56:09 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id g13so5887976wrh.23
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 10:56:09 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a5si2510960wra.143.2018.02.23.10.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 10:56:08 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 147/159] mm/early_ioremap: Fix boot hang with earlyprintk=efi,keep
Date: Fri, 23 Feb 2018 19:27:35 +0100
Message-Id: <20180223170800.766416022@linuxfoundation.org>
In-Reply-To: <20180223170743.086611315@linuxfoundation.org>
References: <20180223170743.086611315@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, bp@suse.de, linux-efi@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Sasha Levin <alexander.levin@verizon.com>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dave Young <dyoung@redhat.com>


[ Upstream commit 7f6f60a1ba52538c16f26930bfbcfe193d9d746a ]

earlyprintk=efi,keep does not work any more with a warning
in mm/early_ioremap.c: WARN_ON(system_state != SYSTEM_BOOTING):
Boot just hangs because of the earlyprintk within the earlyprintk
implementation code itself.

This is caused by a new introduced middle state in:

  69a78ff226fe ("init: Introduce SYSTEM_SCHEDULING state")

early_ioremap() is fine in both SYSTEM_BOOTING and SYSTEM_SCHEDULING
states, original condition should be updated accordingly.

Signed-off-by: Dave Young <dyoung@redhat.com>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: bp@suse.de
Cc: linux-efi@vger.kernel.org
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20171209041610.GA3249@dhcp-128-65.nay.redhat.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@verizon.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 mm/early_ioremap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
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
