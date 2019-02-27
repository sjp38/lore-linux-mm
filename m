Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D420C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C814920842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C814920842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7392C8E000A; Wed, 27 Feb 2019 12:06:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C46C8E0001; Wed, 27 Feb 2019 12:06:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58A3C8E000A; Wed, 27 Feb 2019 12:06:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 035E68E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:06:53 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d31so7237084eda.1
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:06:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=J233IL1FGhNVHQPbZ8NtivYHyMkhcYW8XDURBlgnssI=;
        b=HA6NQxbV40DL3acKYOREcdy/7Ri+IwVFSortUIilRFHmIhAWX2y2CDxtoijWKT7QY1
         kzBLNCm1rJAFT3Zx2oVBK4eI6hgM9gw2jodj5ERrWB6zy5oyF7WdaQqE/ibYLo+FG4f/
         ZOErldVbuKWzKNteP7/xT4tCjF2X5btKJe8sxCY9CByu0qJ+lUKOLA5Jv3YcHxpiob7A
         OO/PCRq1F+igC4XDqBYyrf6xtddvcj1oIXUJLRgCAabq5ioNTUdStfcGioIGiGWdErKT
         UAQsDCupTbm72YvuXJCLzC7n0k7RA1IAMmHPqb1Tr4aebN8zUqkRkF3dAHjnsxau+sL7
         8aiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubF4Lo12smgNBJSRupL1aAGgduKKX0Y+lvD0wv9tDiylHRLOV+g
	mOsUlEvhsSIbfVtHkJtQ4njXk4nMH/ZJuAJnQQ0NbCtCoPSxmyRbf222BZKrk+EVbyGxpES3WfA
	uKPEZuwQGE8IOhVJ6fsrRRFG6qY2QgMrqB4Alf7cvuGi2VZ53dWq2CXxxZFh0XMFDnw==
X-Received: by 2002:a17:906:a4c4:: with SMTP id cc4mr2290381ejb.198.1551287212521;
        Wed, 27 Feb 2019 09:06:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZPep9jA/zJRaodqpOQ2CvPONoGIwZMUcIgWykg/qU1eKw4sxNnNqoY+LAjFODK2FHexBTK
X-Received: by 2002:a17:906:a4c4:: with SMTP id cc4mr2290328ejb.198.1551287211590;
        Wed, 27 Feb 2019 09:06:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287211; cv=none;
        d=google.com; s=arc-20160816;
        b=J9JaoC7t8/FVbkP9q8oA2gi++UzQhpFB46fj4G7XtzVCWg9qGbiy3n5LPVHaiFCL7C
         QBAdAavi1Xa12n4FudV3kenf2/jFbRjMA9JN9kBJV6JHrKQxmCbqedjfEHsHpQJntJMu
         3jBsEqrvppQL99kXPmz1qGZ5txEpiME81UQom5Jt2hNVnWDrneSCcucC+aHATLXtzrFO
         GiHhmyR4yiZ2hrlQ3LVcbP/h1pZJ/Q6KIWcBijl2QKkuoyvYVulE1xIVQMcOKhEZfMoI
         rgPwxm5NaCS96sirgvJkJfvxXoG0KMOYXOAa+VA03g7Yp0zgL9NsnZIF59uBcktZjqV5
         iSDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=J233IL1FGhNVHQPbZ8NtivYHyMkhcYW8XDURBlgnssI=;
        b=jiOsr4OQigizbIjWga+WJRyCN1QKJ+vDcM9U0zVbR+I2hjdjpZ58gq96mlzUOZJuct
         bbG9DW8TYbw1N2Gt0ILIoaHFscf2PBbxjD1U8nstSEdneYJ4UvHopcGxs88dF66zbHaV
         Py4ekD2yOr2/dA6CDmGD+wRnxYUEJT0MauUTp2Q/WmshbBVmS7aklthUZUddwLfxCM4j
         JVPwkBhetLtFgdmhpev66GEdEjtZeNayl7nOMh4/SDKLoeP4dpemrlFra9aaPU2Q6N2t
         6xp68zM4Pz0drcUZP7KNps946zh7pHT7bgb/Y9l7JXpQIrS8otCTiax1tQN74ZGdAVoL
         uNzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j21si800791ejx.273.2019.02.27.09.06.51
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:06:51 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AE821A78;
	Wed, 27 Feb 2019 09:06:50 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4FE223F738;
	Wed, 27 Feb 2019 09:06:47 -0800 (PST)
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
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Guo Ren <guoren@kernel.org>
Subject: [PATCH v3 06/34] csky: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:40 +0000
Message-Id: <20190227170608.27963-7-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
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
p?d_large() functions/macros.

For csky, we don't support large pages, so add a stub returning 0.

CC: Guo Ren <guoren@kernel.org>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/csky/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/csky/include/asm/pgtable.h b/arch/csky/include/asm/pgtable.h
index edfcbb25fd9f..4ffdb6bfbede 100644
--- a/arch/csky/include/asm/pgtable.h
+++ b/arch/csky/include/asm/pgtable.h
@@ -158,6 +158,8 @@ static inline int pmd_present(pmd_t pmd)
 	return (pmd_val(pmd) != __pa(invalid_pte_table));
 }
 
+#define pmd_large(pmd)	(0)
+
 static inline void pmd_clear(pmd_t *p)
 {
 	pmd_val(*p) = (__pa(invalid_pte_table));
-- 
2.20.1

