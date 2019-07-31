Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3406C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB9072186A
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="F6Gayf2v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB9072186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93E798E000E; Wed, 31 Jul 2019 11:08:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CB538E0001; Wed, 31 Jul 2019 11:08:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71A558E000E; Wed, 31 Jul 2019 11:08:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7AF8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so42606372eda.9
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mtVfWkAA6f5+WVvylDNJC/YjX6VpSH295mUWXLakGJs=;
        b=tJXekoIaVfF6TK7vP9X6oUZYeZEwDwhqYo9WhIdZ++PbGi5njH8p39fK4vkLaJC1+p
         CMig0Xe7E3U2Mi+bwjg8+KmMJ0WXGP3MkkVYECEiLvNfNG4mhofG9vFUrpX3Z1B+ViqX
         CrfiwVE4EF8H9k6R68GTtVMuEsB/VUj/O9BwFC8lvHCH0CMrgA7ZzNkhIS8AjvjhNs6b
         U72ILXXfomB1J94hzXH6MduKcVpx0OjAMDG5fJTO0V9cAjjyGURQJUSRi+iKvU9vFxBV
         hhy39rfB8GgZ5s6cxRqYBe1326GLZVvLxV28HoRaaEgOcUrcs64X0ywlA46Sza38iZyV
         BJ5Q==
X-Gm-Message-State: APjAAAWx5TxvO/RpsMaTcQCrIYC/QPYjgnP7KGOld5HmSCvOuThp8VUs
	ywpiN3MphIZEnbZRTpn+09Dnj/cLv2oUWGhFNlWv6tdHUq/dd0L078lehwXQ7e6mq1q406tv/pT
	p49l7meEubRKnCQD4DzqbdHSRYsjOfA4+IQlIhINBy+M77CrtlSIqk72HCXlAFX0=
X-Received: by 2002:a17:906:454d:: with SMTP id s13mr96252790ejq.255.1564585702699;
        Wed, 31 Jul 2019 08:08:22 -0700 (PDT)
X-Received: by 2002:a17:906:454d:: with SMTP id s13mr96252670ejq.255.1564585701374;
        Wed, 31 Jul 2019 08:08:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585701; cv=none;
        d=google.com; s=arc-20160816;
        b=EdZ7tTP6db6M184usHiwne1ktkHszZQFBdRJceK0uL6Zr3LZTl7R42FSDfoLsM6zyk
         6rZmp+GYNSWHQhvH/ZTzYDfurqdUC0xgISalKR6m8ejzy/8U7p/dn4FFbGDL5rqAhilA
         diNLy8BblaDBSbP2CTT5h3xuzBuKcRBfvlM3sQaDkLLssh0WrHDpgV+MTyq0zz3KsAAL
         wGBaZxjx6wLZQI51JAJt1z9RlGAOQVrVpfUXi2onW0XObTetp/YVG7AbgwflNBeYWJc8
         xhgL7/jTHOUi5qCVOi0k6xSxTv3xyF3UOfPvzKEwxXEBBCYp39pKUW6v+jdVBuqxDdyF
         P5Ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=mtVfWkAA6f5+WVvylDNJC/YjX6VpSH295mUWXLakGJs=;
        b=X46kL6vRjI1Azy+UrTIfSsiSoAJQ6/i+u2bOqcj0gKFKTBHanTwJnbKw9iz1KPeAM6
         wdSTth9xOfs+kVjNYOcjUUyqANyHi1RuEMCfu8lYQfeGQc5jQbtsmvc9STFG0cmO5z4o
         TvIT2Yq4rCLwJNduWIEiUCHhBBS1lpe5qW6gKImJMxl1aLC5BrSXsEirywh9iMMIGSrJ
         x5GNNE/iRmune/QGCZ8kpNFrkCuvNmDHXeKdTkRMnI0rj9Y+ob8wY8UMqb/85sERFS54
         gT/3e98fq6aQZFeae9WQZVNksCBW//ckmiPzcd3d7UKkpMEkO10lLEUZkUj7VF9Ku2gR
         OSKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=F6Gayf2v;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p21sor21711136ejj.15.2019.07.31.08.08.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:21 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=F6Gayf2v;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=mtVfWkAA6f5+WVvylDNJC/YjX6VpSH295mUWXLakGJs=;
        b=F6Gayf2vpoXGYJV1uYsSi1oz9m/Dzpd5ss3IOuggi2htSc6htYXpy88IVTNHrSo5Kq
         hWpzEyAGHC2mXZ2wjIjArOS3WPtQuYHcn8nT+/O5W6T39U8KBhjxYitFwEIaU42F/UUZ
         MNDJaDmYDJ2rhvFYveEcpSA76sB3cuT4BXBPtSCQ2kN740Cc3sAloiWNwrNa1DM5fuLc
         QNavgnJR+irD1X17yEJ886mr2816CG2BFT/M05u0Cg9IRy9uHdqMz7DhseDkDzn7Vz3t
         VhUu8iRxDz4AskPYJARFdivUJOn42HuHlC1NNjkGej7JPSPdAEioY0xwz3pfTdTU9bkn
         rRzQ==
X-Google-Smtp-Source: APXvYqxpbVO0IZEgbCImRCWNwH0wevZHXyUPfYVpywOy9u0W0e5mFEX3kiMgbftkDicJ8087eYkuCA==
X-Received: by 2002:a17:906:7f16:: with SMTP id d22mr95105774ejr.17.1564585700959;
        Wed, 31 Jul 2019 08:08:20 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id d7sm16505352edr.39.2019.07.31.08.08.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 1E8B210131E; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 07/59] x86/mm: Mask out KeyID bits from page table entry pfn
Date: Wed, 31 Jul 2019 18:07:21 +0300
Message-Id: <20190731150813.26289-8-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

MKTME claims several upper bits of the physical address in a page table
entry to encode KeyID. It effectively shrinks number of bits for
physical address. We should exclude KeyID bits from physical addresses.

For instance, if CPU enumerates 52 physical address bits and number of
bits claimed for KeyID is 6, bits 51:46 must not be threated as part
physical address.

This patch adjusts __PHYSICAL_MASK during MKTME enumeration.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/cpu/intel.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index 8d6d92ebeb54..f03eee666761 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -616,6 +616,29 @@ static void detect_tme(struct cpuinfo_x86 *c)
 		mktme_status = MKTME_ENABLED;
 	}
 
+#ifdef CONFIG_X86_INTEL_MKTME
+	if (mktme_status == MKTME_ENABLED && nr_keyids) {
+		/*
+		 * Mask out bits claimed from KeyID from physical address mask.
+		 *
+		 * For instance, if a CPU enumerates 52 physical address bits
+		 * and number of bits claimed for KeyID is 6, bits 51:46 of
+		 * physical address is unusable.
+		 */
+		phys_addr_t keyid_mask;
+
+		keyid_mask = GENMASK_ULL(c->x86_phys_bits - 1, c->x86_phys_bits - keyid_bits);
+		physical_mask &= ~keyid_mask;
+	} else {
+		/*
+		 * Reset __PHYSICAL_MASK.
+		 * Maybe needed if there's inconsistent configuation
+		 * between CPUs.
+		 */
+		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
+	}
+#endif
+
 	/*
 	 * KeyID bits effectively lower the number of physical address
 	 * bits.  Update cpuinfo_x86::x86_phys_bits accordingly.
-- 
2.21.0

