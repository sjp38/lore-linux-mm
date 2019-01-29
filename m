Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B49BC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3856620844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3856620844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA9F18E0018; Tue, 29 Jan 2019 13:50:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5E7D8E0015; Tue, 29 Jan 2019 13:50:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD3D48E0018; Tue, 29 Jan 2019 13:50:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 682CA8E0015
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:42 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so8314183edz.15
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WYxvlKVfAa6t/tNZfSF0UteJyG2GjojemqgH68lA8Pg=;
        b=SHqvSRV7pePnHY/ESayS6lbzy59eds5OrGCaVkDNtqnT8f7GM6Zcze/VGDGAZ7NHK7
         xeGZHaNrj3roX6f95JIwwK6OEMJdwBDYddlV0v4sDCjke96xLDMMf5YgE1t/Z/bmrbRt
         jypKhvdfSUCiugr2Vu9j3KnVmpiV03+eq3GDyubIf2XgqF4LmFRqq877uDrHBDXvfNNE
         3TuNhklvme8uMakY7+no0e+uqz80oHBHOyQOb/ROKcv+ziqUL5lmKBPFNvx7TEequC6S
         IyuitJ2dQXAPX2hu1Y5wLv8wpTcoiAttP3E8JQS3CVz3MRFjxNxUOIMmT8YL1I7yXZqV
         Di8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukffIE7vPINPyvbqVTL2hWvDPcVG0IuN3yTiTCeqRvDTLNMrl0SY
	c8UPi5yKQvkOrV8hzSKM2oRivRmbBPuT71PqxhMrWFESgSw9PAl5iglnSBYylmy1K58ZbF2Jnrj
	5AoyZbuMRiQ3J61vT/1EY+y7+YyIWGqAkqL5Bdd8BsWV5gMxhD18am0/C6qzC1mnxKw==
X-Received: by 2002:a50:8bb5:: with SMTP id m50mr26055827edm.211.1548787841916;
        Tue, 29 Jan 2019 10:50:41 -0800 (PST)
X-Google-Smtp-Source: ALg8bN78iubkW52z6ZRzrhkUlJe+7fGrtPeVkemVmbIUf57+53oBsEfRBu83wDl8BZi+1KH1kpXc
X-Received: by 2002:a50:8bb5:: with SMTP id m50mr26055777edm.211.1548787840950;
        Tue, 29 Jan 2019 10:50:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787840; cv=none;
        d=google.com; s=arc-20160816;
        b=u5V59hJBWUsGjdzwTMY7ZEuWrWYpj/Gdnf6/7RFml/vKRQuhJb9kVo0ZRLncU1BKF9
         Xd131XWb/iNe+qMWmBJdFhhOGQWoVOg0hmdRwGKuvnoZFPxyJkhNEe/Z4xSwe9Z+KQjj
         IzEX/qBDFzKrh4D/71xaGISe1GR1BlzZqNNinoaWl+V/IP83KHvX5UBl4FKyEj6EoU0F
         YMFttkfNtRF1Y9t+ps8/lBgMa1RxqqB9MBK9U/HniQxbeeDJcnTxvv+Wv+DQiFdg2XsD
         b2X1GBLvPuPz5bK/iWiSnVAszdNTwdEE1DOi3zi1bp9RWlEmNftyNu5s3jH1EEi/ri7e
         Zz7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=WYxvlKVfAa6t/tNZfSF0UteJyG2GjojemqgH68lA8Pg=;
        b=oiHGgNNWGYvh7cSj90lgrMRZhj+oKKEHzXzsSyPNQvGK1BR840qUYI9gw8x8tT1eQR
         kExLHXYnMJUVN77LtKDx/XztEUYEc7CYZ542/G6HCrj/4iQ3Q28Dgolgb4/TE97u+6Cs
         ONHZsRx9IixjPgttj2XQZdUFHvdAwHQdeH0crLaTKqn+y/qP5fYVYgXwioaAAktHSdtR
         UbZkbdHh7lU3sqyUbp1ZsnPfem6PnuKALOBWS4PxrquluxfpCO89VVRLUOF62utvTl2q
         9ejEvqK8Zdzq4zUgtxPItPtosux9iAMff0fun6seUG5D6CAjPuxdnBHN3fNu/0lwj8iw
         NGMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v4si3967773edy.314.2019.01.29.10.50.40
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:40 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1B90315AB;
	Tue, 29 Jan 2019 10:50:40 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6E72A3F557;
	Tue, 29 Jan 2019 10:50:37 -0800 (PST)
From: James Morse <james.morse@arm.com>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	Borislav Petkov <bp@alien8.de>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>,
	james.morse@arm.com
Subject: [PATCH v8 21/26] ACPI / APEI: Use separate fixmap pages for arm64 NMI-like notifications
Date: Tue, 29 Jan 2019 18:48:57 +0000
Message-Id: <20190129184902.102850-22-james.morse@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190129184902.102850-1-james.morse@arm.com>
References: <20190129184902.102850-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now that ghes notification helpers provide the fixmap slots and
take the lock themselves, multiple NMI-like notifications can
be used on arm64.

These should be named after their notification method as they can't
all be called 'NMI'. x86's NOTIFY_NMI already is, change the SEA
fixmap entry to be called FIX_APEI_GHES_SEA.

Future patches can add support for FIX_APEI_GHES_SEI and
FIX_APEI_GHES_SDEI_{NORMAL,CRITICAL}.

Because all of ghes.c builds on both architectures, provide a
constant for each fixmap entry that the architecture will never
use.

Signed-off-by: James Morse <james.morse@arm.com>

---
Changes since v7:
 * Removed v6's #ifdefs, these aren't needed now that SEA/NMI can't be
   turned off on their respective architectures.

Changes since v6:
 * Added #ifdef definitions of each missing fixmap entry.

Changes since v3:
 * idx/lock are now in a separate struct.
 * Add to the comment above ghes_fixmap_lock_irq so that it makes more
   sense in isolation.
---
 arch/arm64/include/asm/fixmap.h | 2 +-
 drivers/acpi/apei/ghes.c        | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/fixmap.h b/arch/arm64/include/asm/fixmap.h
index ec1e6d6fa14c..966dd4bb23f2 100644
--- a/arch/arm64/include/asm/fixmap.h
+++ b/arch/arm64/include/asm/fixmap.h
@@ -55,7 +55,7 @@ enum fixed_addresses {
 #ifdef CONFIG_ACPI_APEI_GHES
 	/* Used for GHES mapping from assorted contexts */
 	FIX_APEI_GHES_IRQ,
-	FIX_APEI_GHES_NMI,
+	FIX_APEI_GHES_SEA,
 #endif /* CONFIG_ACPI_APEI_GHES */
 
 #ifdef CONFIG_UNMAP_KERNEL_AT_EL0
diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 957c1559ebf5..e6f0d176b245 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -958,7 +958,7 @@ int ghes_notify_sea(void)
 	int rv;
 
 	raw_spin_lock(&ghes_notify_lock_sea);
-	rv = ghes_in_nmi_spool_from_list(&ghes_sea, FIX_APEI_GHES_NMI);
+	rv = ghes_in_nmi_spool_from_list(&ghes_sea, FIX_APEI_GHES_SEA);
 	raw_spin_unlock(&ghes_notify_lock_sea);
 
 	return rv;
-- 
2.20.1

