Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77A3FC76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 483FB2190F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 483FB2190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8C368E0003; Mon, 22 Jul 2019 11:42:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3D758E0001; Mon, 22 Jul 2019 11:42:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2D158E0003; Mon, 22 Jul 2019 11:42:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 715608E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:42:32 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c31so26564550ede.5
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:42:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eKl9NY7OTKmyYuPsGrRoNPFWZw8MxP6jB3gNXjnh+E8=;
        b=TOlh0hG0tBxU3zVorXHJts22EvQVNYFBl64hjueooFr6rY8XBz7s5GnZMsSxR6wYhv
         0BXn/d9ZSKIWshVQY7q+hSPCTIQhFfOdWU7PveTJs7nlHDpMxvqGy/FyzjmgjUQJ7iSs
         BvjXNSdesASPWn/I8CHewDJck1dQSuJOWDvWniqSunJH0zylJVCUc5pMhLuefNoyq0Eg
         gJ76EnrKPvl+Lueo5pfPWn9PUZXnUa97DWPR8XPQTk9ozUZGiA21eW9fs7sIu0RjeFjQ
         kkMrPmSlEBOWugIbnkS/LGu3Z1Huq5K/eYx13iYnm1Xvp7ATZQIi69oXmQn86RB7Og63
         S1cQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVKGNYBriW23dNcz+kr9g2iwKV2ctu91d0uf7sqgrwY8REu87BR
	gAz7gUh143g3h24qpnFwN4cbzfTiJGvfwbKmQi1zGU9yJ+602lI5Xm13anWISmvwHtqjICQhEIH
	lM4ZBTuwgnDll07d5Q8VLjzrP/wl8d0Ow9ceFPTd3oKnMzZiDZlBAY3w3kT6BMvhiPg==
X-Received: by 2002:a17:906:8409:: with SMTP id n9mr52844686ejx.128.1563810151937;
        Mon, 22 Jul 2019 08:42:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLCY+EucFZEk9/V7y4rQ1tMKDNy0wMXHR5vhwZ81pHvZ3Se3XePfF0OXLQdQ15iQCtJZCD
X-Received: by 2002:a17:906:8409:: with SMTP id n9mr52844638ejx.128.1563810151194;
        Mon, 22 Jul 2019 08:42:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810151; cv=none;
        d=google.com; s=arc-20160816;
        b=GLCtykaiE0ZKkTpeMA7umHbuDKu3HdeON+UaTJs+crEsyNKOAnkQBrBWHqbnIdfj9k
         1VRLTl6YoBd0iZWK1krbj5Zxgo3HupuwoAjhQT65v6IkCNzUIaHUq+h3I6WAivKvYnSo
         rTsB0/s9Q8IV3Go3ovUWF8Fo3NuY0V5SscZmwoh54jGU1rBye9NHBV8JGMgP4dudbCTN
         h6lrvf7kaqY31PaY/d2MF+EHG/F6OrMNye/FRC5dd65f53AkIh47kQR0aE3ozhWekcmL
         GUO+w3L7q8SgGEweWEvFf11JL7uCVB1+QOVT425PHcJWDUyBpIlVOEd2W05Uf3d9F60Z
         a2ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=eKl9NY7OTKmyYuPsGrRoNPFWZw8MxP6jB3gNXjnh+E8=;
        b=NmOM5PO//VrJM/ay+aEsBleudx7OQ1IOBdq/Kzx5S7mBLjPMOJOzPBHOu2sBoiHr8b
         3D/27pyJ8AGFfRshOPEWv6f4W7yw1NOlv4DLLJ5d3J87TUH9NrUqTIkasaybs43uO7w7
         nMsBra69YWPj3+wcRyShmwjDYyWBAm0Sn7SWlOKC4otFCRdxYXUbBX+lBUs/8jK+ROPK
         EPyRsVSY5jhzJre6BrmyfEjhiJpz8tZgZoxyGk0hsyXUrZ6ykofupRyE6On3eP9efalU
         WdxaDQZlcbocO0xcI+3DcBR2Xmz5reTcgqhFKPI/RijPdseGHCkbPjH2VIcxuSk2bgY+
         3lUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 39si5131235edq.151.2019.07.22.08.42.30
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:42:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6DB1B1596;
	Mon, 22 Jul 2019 08:42:29 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BCA9A3F694;
	Mon, 22 Jul 2019 08:42:26 -0700 (PDT)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will@kernel.org>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Russell King <linux@armlinux.org.uk>
Subject: [PATCH v9 02/21] arm: mm: Add p?d_leaf() definitions
Date: Mon, 22 Jul 2019 16:41:51 +0100
Message-Id: <20190722154210.42799-3-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information is provided by the
p?d_leaf() functions/macros.

For arm pmd_large() already exists and does what we want. So simply
provide the generic pmd_leaf() name.

CC: Russell King <linux@armlinux.org.uk>
CC: linux-arm-kernel@lists.infradead.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm/include/asm/pgtable-2level.h | 1 +
 arch/arm/include/asm/pgtable-3level.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/arm/include/asm/pgtable-2level.h b/arch/arm/include/asm/pgtable-2level.h
index 51beec41d48c..0d3ea35c97fe 100644
--- a/arch/arm/include/asm/pgtable-2level.h
+++ b/arch/arm/include/asm/pgtable-2level.h
@@ -189,6 +189,7 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
 }
 
 #define pmd_large(pmd)		(pmd_val(pmd) & 2)
+#define pmd_leaf(pmd)		(pmd_val(pmd) & 2)
 #define pmd_bad(pmd)		(pmd_val(pmd) & 2)
 #define pmd_present(pmd)	(pmd_val(pmd))
 
diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index 5b18295021a0..ad55ab068dbf 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -134,6 +134,7 @@
 #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
 						 PMD_TYPE_SECT)
 #define pmd_large(pmd)		pmd_sect(pmd)
+#define pmd_leaf(pmd)		pmd_sect(pmd)
 
 #define pud_clear(pudp)			\
 	do {				\
-- 
2.20.1

