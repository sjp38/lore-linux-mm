Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id A91BF6B6A7D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:07:13 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id 32so5926014ots.15
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:07:13 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c127si6302024oib.58.2018.12.03.10.07.12
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:07:12 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue consumed the records
Date: Mon,  3 Dec 2018 18:05:58 +0000
Message-Id: <20181203180613.228133-11-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

ACPI has a GHESv2 which is used on hardware reduced platforms to
explicitly acknowledge that the memory for CPER records has been
consumed. This lets an external agent know it can re-use this
memory for something else.

Previously notify_nmi and the estatus queue didn't do this as
they were never used on hardware reduced platforms. Once we move
notify_sea over to use the estatus queue, it may become necessary.

Add the call. This is safe for use in NMI context as the
read_ack_register is pre-mapped by ghes_new() before the
ghes can be added to an RCU list, and then found by the
notification handler.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 366dbdd41ef3..15d94373ba72 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -926,6 +926,10 @@ static int _in_nmi_notify_one(struct ghes *ghes)
 	__process_error(ghes);
 	ghes_clear_estatus(ghes, buf_paddr);
 
+	if (is_hest_type_generic_v2(ghes) && ghes_ack_error(ghes->generic_v2))
+		pr_warn_ratelimited(FW_WARN GHES_PFX
+				    "Failed to ack error status block!\n");
+
 	return 0;
 }
 
-- 
2.19.2
