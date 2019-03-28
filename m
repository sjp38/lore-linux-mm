Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EC6BC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37B21206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37B21206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD2DA6B0007; Thu, 28 Mar 2019 11:22:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D579C6B000A; Thu, 28 Mar 2019 11:22:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C149F6B0007; Thu, 28 Mar 2019 11:22:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B44B6B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k8so5121616edl.22
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BRz1fLaVHJrWps04LeU/9kcyNHUo1yfdaodtNUtdXHA=;
        b=qkQ70/10pcQtzdeMWfXA+/WZmGyfOS6RJzDXdmAHyBtipmqaTR7xRbm4h4mgYoxtql
         qXWj7MrKOR5dnsy1ynfnrpIdIiBjhNFAYC6V2hRfk96/sFa+8xg5Agla/BFho/0dJTkQ
         gxO7DTufIpKLVkN2oPMPUUWaYRm4aM3LEyz3UQk0mJ5/+7mK8WyhJz2vWw0y1tex1423
         piU+gq479JTinZ8MLpnpsGeLH4umeC+1XR/nPVdsTkOoL4PByAAsEuYFYhGO2LkiOOcu
         hvLFVbJM4SYxHC5Y3uKD8JsnlC68TXiB2ihpHp/m1atFh4DJL5lKha9LArA/A99z06Rs
         R3YQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAV8iWd3hW/reZQcbjE+SsIeJu6si/6/Hbzw35O+i+w8D3E2gGPw
	zxVkfU1U+95f7RNtp/l+TzGF9CiutZ3gRBAkYYRqUJ9mAA+t7nhlpjNhuB5M3EUhWFzpl0olU5J
	8Ngmbf7RsUI9KyYHquDweQYHr/gKMWzK5tB78k9Ir1vDR6ekq7sB6SDTDzQhdOylzeQ==
X-Received: by 2002:a17:906:a889:: with SMTP id ha9mr20952623ejb.171.1553786522932;
        Thu, 28 Mar 2019 08:22:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycHXnXGE4WCIE6Kv05Ce1+RyDGhngKSWs/GgGuCqiROkCIp55FtV+8lgrG8/KTLA9T7JNA
X-Received: by 2002:a17:906:a889:: with SMTP id ha9mr20952574ejb.171.1553786521900;
        Thu, 28 Mar 2019 08:22:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786521; cv=none;
        d=google.com; s=arc-20160816;
        b=zWg+EQrK3toiOVAZLXBOR+JYS1qZ7LAkJgbZW9ZQgNKKDuqBz1ZmqjD78aMh9jCAKG
         Y0H+Eoxi9nCwMyNwyDbI7ViW+1Q6dBLlj1tfGXW98rBH924WUb9EbArUD4VwgiugOOgy
         4Oi5NHQP6rE6Z9kWyXYYTrrv5E/0YqgkikKMCH412E1lMbWSQ42WZA914tWo4FZPRPkZ
         Ibob1/WOlU4cO8frkKDU/o05UOGAydWWMSRIwOTKCi3MJD3PoxRhjymEgFbUUfYiAtDq
         XNW2uKnlZnH/V6LM+FUFyEqtXrQZ/TATgF2l/2eNliXCJJmtrqQtbhW3srh3M93PZv6p
         HljA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BRz1fLaVHJrWps04LeU/9kcyNHUo1yfdaodtNUtdXHA=;
        b=yyrH5ydPkHtWVBpMeHk13fvkLGRUl3BfJ2CtBBKhrrJNVoSddtpolih++lvgbAYFUu
         o4DO3LHW4kmqSbPrlBdUspZiaF2cNU4N6QGQ4pEUieefZd7B48Xc1E2rceFeQtUJenXI
         1fh9KNWZcYbT2ISqzq7pdckLYzUvJxT5VoJuOqF9EI/8cIAEehT1bvFSWNrqxV8tX1Rg
         488Hmb5CjTrOyZFWSoWHu0Bi3IcgoZlHsmBU9pTxKnEwsW2jX15KlBrjgzB0HT3xacR1
         J4o7Bu6LSka6pCKC9acEecgd1u0Sdh2taQt75sL+U9JLyz9jCtp6KF3bJukUJQs5Suy1
         LC1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x11si1745928edh.253.2019.03.28.08.22.01
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DFAE0165C;
	Thu, 28 Mar 2019 08:22:00 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 99DC33F557;
	Thu, 28 Mar 2019 08:21:57 -0700 (PDT)
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
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v7 02/20] arm64: mm: Add p?d_large() definitions
Date: Thu, 28 Mar 2019 15:20:46 +0000
Message-Id: <20190328152104.23106-3-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328152104.23106-1-steven.price@arm.com>
References: <20190328152104.23106-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information will be provided by the
p?d_large() functions/macros.

For arm64, we already have p?d_sect() macros which we can reuse for
p?d_large().

CC: Catalin Marinas <catalin.marinas@arm.com>
CC: Will Deacon <will.deacon@arm.com>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm64/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index de70c1eabf33..6eef345dbaf4 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 				 PMD_TYPE_TABLE)
 #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
 				 PMD_TYPE_SECT)
+#define pmd_large(pmd)		pmd_sect(pmd)
 
 #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
 #define pud_sect(pud)		(0)
@@ -511,6 +512,7 @@ static inline phys_addr_t pmd_page_paddr(pmd_t pmd)
 #define pud_none(pud)		(!pud_val(pud))
 #define pud_bad(pud)		(!(pud_val(pud) & PUD_TABLE_BIT))
 #define pud_present(pud)	pte_present(pud_pte(pud))
+#define pud_large(pud)		pud_sect(pud)
 #define pud_valid(pud)		pte_valid(pud_pte(pud))
 
 static inline void set_pud(pud_t *pudp, pud_t pud)
-- 
2.20.1

