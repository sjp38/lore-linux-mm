Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD8DEC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 17:16:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C45E21EF2
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 17:16:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="qUcsAiEO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C45E21EF2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B3C36B000C; Wed,  7 Aug 2019 13:16:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03F596B000D; Wed,  7 Aug 2019 13:16:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFB266B000E; Wed,  7 Aug 2019 13:16:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A8F646B000C
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 13:16:21 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id o6so53129667plk.23
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 10:16:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RUBxnyz640QfvTz6lz/Tqs2pyOPmGqnxC24rkQCQqR8=;
        b=AgY8CBuf9bDZvSv4sly5qKzhKBKvnCtXmRQucWMO2JHYbJ5z+rPIkKYbq4pBDGVh/z
         LXqjINuheHzT85ipMQg9l6jDQmCziuFkQfrNXou5Yy9Xck8r41Zo37oTemJixt3RgyTg
         qviTMhJtM88V2obWvp+OpGD1+0BFeRYkOnTbIKiUy4YdbRsk+d6PAvgkueVZ1TUGUWXe
         J/Eto2pDNFPrfNzlujciEl7yhsrlyahXCNgl6FsWNFLt+OyTtTyC+Ud/Q4jJQYIvKbf1
         WEjcSgysyqyQIVuIji7KQ/FCMwtVsoY7BnE6UsLtR8ZVZCXVJYZbn54vha09jhvi108Y
         NUhw==
X-Gm-Message-State: APjAAAW39mwG6KvgWLKS8UKjyMgeNQJoOjchShMxl1Dun3V3OubScIlG
	nPDFmRkVog4udEbr8hIzCUkjc1nvnJX8g002BJUwIDZLlJ+W3AHNIYFVqRp/e1ElwQBOhI/bUqA
	nrl90IqFIqIsdS10cMYdhOMN5vM+q5gUTdgXCkkNoFInaEi+1KUTx/jr60URTtSopeA==
X-Received: by 2002:a65:5a8c:: with SMTP id c12mr8424688pgt.73.1565198181250;
        Wed, 07 Aug 2019 10:16:21 -0700 (PDT)
X-Received: by 2002:a65:5a8c:: with SMTP id c12mr8424628pgt.73.1565198180393;
        Wed, 07 Aug 2019 10:16:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565198180; cv=none;
        d=google.com; s=arc-20160816;
        b=BYBHOiY5lf2vZqyhlL2xSMCngnb+kW8xz3DZ2UJNzHSgS7LV3iW/nlt26t8A8sMGIk
         kDq4JveIzG/iaViXyCM+kw6DKhvCGQsJNl9Kb1PDDXn381oOPz0CRj0T4nZdPTmCJMLg
         AXFWJyiulKK2GIoAoY7KJcTF0adMVDEQ+64wLiG52Vm7fyjZjla7qB1M7f3jdFDlXNsB
         0o1nbkh10NSq/Tv9Ix2F8NBZVBkIGGSnEe7y+e6wNyKs5ypdFRqtN+nlaXMoj95/yRm6
         C4cgZi0gZAwMNMwI3k0U4SUvrYdmWbCKb0BMbXWFIguenEtd6LXilj51iVAZnDUJ6l5B
         K8Jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=RUBxnyz640QfvTz6lz/Tqs2pyOPmGqnxC24rkQCQqR8=;
        b=EIFt9w2LJUbmtK1iNgzkVPL3opNQxb3SD1ffZaFAqkD6iYCK5IK26WK17nSQvcm/ZI
         ltJEvQs5jxAE5sab/5dBDWkIMyIkbm/bIP+dFaiuve/yHMY8E5fwdpeeueIOnAi6uxhA
         DR/FXOX+0nX+1Owhq4NAMXu6UENSmVODMombBHn88bpYg9MpWd5oq1ij+18K/5WncOLB
         xaxNa7B8Q/kKprfTDCNlZ+Vn3azbJx5+HxzknAzmmnIfnnMkhiPOu7Qqp6FlTb0Ujsjo
         F36zCeOtTWeTvQT0grIdwO70oNOuQJGirSo07iua4sq25S8LQvAwLsRD8LKu0/WltQco
         XQcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=qUcsAiEO;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a63sor2067191pla.38.2019.08.07.10.16.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 10:16:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=qUcsAiEO;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=RUBxnyz640QfvTz6lz/Tqs2pyOPmGqnxC24rkQCQqR8=;
        b=qUcsAiEOKB0kyiDTK9YasOF7A4ofZDbfv+p8AIH2GkVHqwEwA1IA/h3IzTFeMkODCy
         rbSy4s5NCnbvnUouu7MfVETepWhtmKX5MsEvPzADXzvQqfRMT3AznSoRGnX5bZHxlply
         d1709s86c+06D6w3zpjya8G4jJGHYnl8N2mVk=
X-Google-Smtp-Source: APXvYqyljthmaedQMd1J+PXKwGtyBWQtdiL8Gz9KlrlERrf+UnJhUAJEITHMkjgMGR3wYbFETkajsg==
X-Received: by 2002:a17:902:b497:: with SMTP id y23mr9265019plr.68.1565198179959;
        Wed, 07 Aug 2019 10:16:19 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id a1sm62692130pgh.61.2019.08.07.10.16.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 10:16:19 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>,
	Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>,
	dancol@google.com,
	fmayer@google.com,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>,
	joelaf@google.com,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	kernel-team@android.com,
	linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	minchan@kernel.org,
	namhyung@google.com,
	paulmck@linux.ibm.com,
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>,
	tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Will Deacon <will@kernel.org>
Subject: [PATCH v5 4/6] [RFC] arm64: Add support for idle bit in swap PTE
Date: Wed,  7 Aug 2019 13:15:57 -0400
Message-Id: <20190807171559.182301-4-joel@joelfernandes.org>
X-Mailer: git-send-email 2.22.0.770.g0f2c4a37fd-goog
In-Reply-To: <20190807171559.182301-1-joel@joelfernandes.org>
References: <20190807171559.182301-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This bit will be used by idle page tracking code to correctly identify
if a page that was swapped out was idle before it got swapped out.
Without this PTE bit, we lose information about if a page is idle or not
since the page frame gets unmapped.

In this patch we reuse PTE_DEVMAP bit since idle page tracking only
works on user pages in the LRU. Device pages should not consitute those
so it should be unused and safe to use.

Cc: Robin Murphy <robin.murphy@arm.com>
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 arch/arm64/Kconfig                    |  1 +
 arch/arm64/include/asm/pgtable-prot.h |  1 +
 arch/arm64/include/asm/pgtable.h      | 15 +++++++++++++++
 3 files changed, 17 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 3adcec05b1f6..9d1412c693d7 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -128,6 +128,7 @@ config ARM64
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
 	select HAVE_ARCH_PREL32_RELOCATIONS
+	select HAVE_ARCH_PTE_SWP_PGIDLE
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_STACKLEAK
 	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
diff --git a/arch/arm64/include/asm/pgtable-prot.h b/arch/arm64/include/asm/pgtable-prot.h
index 92d2e9f28f28..917b15c5d63a 100644
--- a/arch/arm64/include/asm/pgtable-prot.h
+++ b/arch/arm64/include/asm/pgtable-prot.h
@@ -18,6 +18,7 @@
 #define PTE_SPECIAL		(_AT(pteval_t, 1) << 56)
 #define PTE_DEVMAP		(_AT(pteval_t, 1) << 57)
 #define PTE_PROT_NONE		(_AT(pteval_t, 1) << 58) /* only when !PTE_VALID */
+#define PTE_SWP_PGIDLE		PTE_DEVMAP		 /* for idle page tracking during swapout */
 
 #ifndef __ASSEMBLY__
 
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 3f5461f7b560..558f5ebd81ba 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -212,6 +212,21 @@ static inline pte_t pte_mkdevmap(pte_t pte)
 	return set_pte_bit(pte, __pgprot(PTE_DEVMAP));
 }
 
+static inline int pte_swp_page_idle(pte_t pte)
+{
+	return 0;
+}
+
+static inline pte_t pte_swp_mkpage_idle(pte_t pte)
+{
+	return set_pte_bit(pte, __pgprot(PTE_SWP_PGIDLE));
+}
+
+static inline pte_t pte_swp_clear_page_idle(pte_t pte)
+{
+	return clear_pte_bit(pte, __pgprot(PTE_SWP_PGIDLE));
+}
+
 static inline void set_pte(pte_t *ptep, pte_t pte)
 {
 	WRITE_ONCE(*ptep, pte);
-- 
2.22.0.770.g0f2c4a37fd-goog

