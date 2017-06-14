Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5F16B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:11:59 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id v184so6478213itc.15
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:11:59 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0087.outbound.protection.outlook.com. [104.47.32.87])
        by mx.google.com with ESMTPS id x75si883403itb.48.2017.06.14.12.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 12:11:58 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH tip/sched/core] mm/early_ioremap: Adjust early_ioremap
 system_state check
Date: Wed, 14 Jun 2017 14:11:52 -0500
Message-ID: <20170614191152.28089.65392.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@suse.de>, Ingo Molnar <mingo@kernel.org>

A recent change added a new system_state value, SYSTEM_SCHEDULING, which
exposed a warning issued by early_ioreamp() when the system_state was not
SYSTEM_BOOTING. Since early_ioremap() can be called when the system_state
is SYSTEM_SCHEDULING, the check to issue the warning is changed from
system_state != SYSTEM_BOOTING to system_state >= SYSTEM_RUNNING.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 mm/early_ioremap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
index 6d5717b..57540de 100644
--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
@@ -103,7 +103,7 @@ static int __init check_early_ioremap_leak(void)
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
