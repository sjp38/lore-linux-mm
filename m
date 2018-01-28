Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 93C866B000C
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 17:30:40 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a9so4532521pff.0
        for <linux-mm@kvack.org>; Sun, 28 Jan 2018 14:30:40 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0092.outbound.protection.outlook.com. [104.47.37.92])
        by mx.google.com with ESMTPS id 4-v6si7815462plc.812.2018.01.28.14.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 28 Jan 2018 14:30:39 -0800 (PST)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: [PATCH AUTOSEL for 3.18 22/25] mm/early_ioremap: Fix boot hang with
 earlyprintk=efi,keep
Date: Sun, 28 Jan 2018 22:29:59 +0000
Message-ID: <20180128222931.7781-22-alexander.levin@microsoft.com>
References: <20180128222931.7781-1-alexander.levin@microsoft.com>
In-Reply-To: <20180128222931.7781-1-alexander.levin@microsoft.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>
Cc: Dave Young <dyoung@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, "bp@suse.de" <bp@suse.de>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo
 Molnar <mingo@kernel.org>, Sasha Levin <Alexander.Levin@microsoft.com>

From: Dave Young <dyoung@redhat.com>

[ Upstream commit 7f6f60a1ba52538c16f26930bfbcfe193d9d746a ]

earlyprintk=3Defi,keep does not work any more with a warning
in mm/early_ioremap.c: WARN_ON(system_state !=3D SYSTEM_BOOTING):
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
Link: http://lkml.kernel.org/r/20171209041610.GA3249@dhcp-128-65.nay.redhat=
.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
---
 mm/early_ioremap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
index e10ccd299d66..5edcf1b37fa6 100644
--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
@@ -102,7 +102,7 @@ __early_ioremap(resource_size_t phys_addr, unsigned lon=
g size, pgprot_t prot)
 	enum fixed_addresses idx;
 	int i, slot;
=20
-	WARN_ON(system_state !=3D SYSTEM_BOOTING);
+	WARN_ON(system_state >=3D SYSTEM_RUNNING);
=20
 	slot =3D -1;
 	for (i =3D 0; i < FIX_BTMAPS_SLOTS; i++) {
--=20
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
