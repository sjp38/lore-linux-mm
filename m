Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3471E6B6A7A
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:07:02 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id t13so5992578otk.4
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:07:02 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e17si6869937oib.145.2018.12.03.10.07.00
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:07:01 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 07/25] ACPI / APEI: Remove spurious GHES_TO_CLEAR check
Date: Mon,  3 Dec 2018 18:05:55 +0000
Message-Id: <20181203180613.228133-8-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

ghes_notify_nmi() checks ghes->flags for GHES_TO_CLEAR before going
on to __process_error(). This is pointless as ghes_read_estatus()
will always set this flag if it returns success, which was checked
earlier in the loop. Remove it.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index acf0c37e9af9..f7a0ff1c785a 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -936,9 +936,6 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 			__ghes_panic(ghes);
 		}
 
-		if (!(ghes->flags & GHES_TO_CLEAR))
-			continue;
-
 		__process_error(ghes);
 		ghes_clear_estatus(ghes, buf_paddr);
 	}
-- 
2.19.2
