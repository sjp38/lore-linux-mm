Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3847C10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:50:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E02D20828
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:50:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E02D20828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DD138E0005; Wed,  6 Mar 2019 10:50:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 163338E0002; Wed,  6 Mar 2019 10:50:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02A6C8E0005; Wed,  6 Mar 2019 10:50:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A15F28E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:50:52 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f2so6455863edm.18
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:50:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3GzvBNszJ2F9qzyq8uNQC4ioxjUcI3EqpQkesdmXCx4=;
        b=bB851xJ1+m2w22NkSVyX5FgghjYTjVedZadvQ3/k8dJP89m0iZ94Gq2ID1QQvk3A/0
         aCT2LTCpVoUsJe++CXPYTSz9uAa3Xi62tBh3z0JFsuLhsBHmvtAlH8OQjAGn3zyItfa8
         pS5CTT1+0EIuy7SCE4x5sMCKkKfoSjxDRCBt+5pQW2mUc0TU+Zev/DLDcsfCXlJiFbUo
         pab+2Xd7QoEmEFsHHJacMUfpt4tHavfVVI7/KPcRjbdewvX9qAIoPTNu+nr5qL4roDVZ
         0y11LLQxWWjxQUuNML0x8TLPgj48qi9iVsaFGUpo18g20126ia0wpG6Fep0iqyrTWlDm
         /0Rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWt+U6xfCXwWQWZWai4qOPLos0egefY1PCwyJxSG1LPvaE5ELJt
	dfqagKnuGTJEAj4ujC8Zpd1VU7vFXqQV/esmkvAqLyLtJBqdDvn8xwJYe9RWhAUGjWks2Pn0t1/
	/62QGFF+mUqDx5HkeCBTaqxoP/ylLKA4m/y9l6G+lECk8CurbUtw7rnME/6DZG5qTsw==
X-Received: by 2002:a17:906:4ad9:: with SMTP id u25mr4446041ejt.176.1551887451885;
        Wed, 06 Mar 2019 07:50:51 -0800 (PST)
X-Google-Smtp-Source: APXvYqwMrt/S98k2uu5Pkn3ONiffGcOLV5uNWTtC580591jiYl2ufV9sa0boHE6SS1jSdy2uarer
X-Received: by 2002:a17:906:4ad9:: with SMTP id u25mr4445968ejt.176.1551887450577;
        Wed, 06 Mar 2019 07:50:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887450; cv=none;
        d=google.com; s=arc-20160816;
        b=xu/5GkBeEacBk9l6fSwt4s6vWTDUa58PRW0KslCic6m2Q6WQFJQA1SKJVk/GTcAUuk
         Jrw6G4bAaKBHUQvvLPd+kmN6aTCLhPtd5aH7S4GKFLziNc2AsuJbOV/OKjuxr15qMonC
         M0zJMdPWmFvUynqNqWzMnEjWIeEV2AT7FnA7QPNsuY5uhwFIeDmbz36Kte7HV366dKR1
         eOxvZHI27ZVGMN0EOMzStVDsix5CUAlBQEvnLhs4MEkGaIqQ81yQDi42gzZLbGtD78sX
         dI8csGB+Tasb2/BrdljHTEDoFPNNbvqO3uRwviwr96TEQofPh/Pm3FCdsBgh7yjmemYV
         AdCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3GzvBNszJ2F9qzyq8uNQC4ioxjUcI3EqpQkesdmXCx4=;
        b=jhaG1+7nNm5hJyc+6aad36+bVWUzfkBJGkiUhSt1N+abN9MCvECY1DxShmjOJcsC6l
         oD0rHz/iB5SiN7Vhqr5tR44/1dinQ1HiVtUjQiy3ziW34qL/YQPO9fOnZBT9kK7stNG2
         kzU6p/TXUt8K2tgyuAI+tJaQ68S1aj9i59FISyh7+cFwrAoppCYQi6d95svswjvlBf7E
         ljJvZGONGaJLWoK3+F1YBTV97qoIebhF4Sp0iqxDt/979lNAlaVFFegUSeAEoIuqFXL8
         nbBIKOPafkJpbPj7TWZUtyfqeeFR1F8uTotEjlMT2D/Vd0f1aUR26MIQHI+hdp/VKgzS
         gOZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p21si184204eda.281.2019.03.06.07.50.50
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:50:50 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8FBC91596;
	Wed,  6 Mar 2019 07:50:49 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0E1EB3F703;
	Wed,  6 Mar 2019 07:50:45 -0800 (PST)
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
	Vineet Gupta <vgupta@synopsys.com>,
	linux-snps-arc@lists.infradead.org
Subject: [PATCH v4 01/19] arc: mm: Add p?d_large() definitions
Date: Wed,  6 Mar 2019 15:50:13 +0000
Message-Id: <20190306155031.4291-2-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190306155031.4291-1-steven.price@arm.com>
References: <20190306155031.4291-1-steven.price@arm.com>
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

For arc, we only have two levels, so only pmd_large() is needed.

CC: Vineet Gupta <vgupta@synopsys.com>
CC: linux-snps-arc@lists.infradead.org
Signed-off-by: Steven Price <steven.price@arm.com>
Acked-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/pgtable.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index cf4be70d5892..0edd27bc7018 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -277,6 +277,7 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)
 #define pmd_none(x)			(!pmd_val(x))
 #define	pmd_bad(x)			((pmd_val(x) & ~PAGE_MASK))
 #define pmd_present(x)			(pmd_val(x))
+#define pmd_large(x)			(pmd_val(pmd) & _PAGE_HW_SZ)
 #define pmd_clear(xp)			do { pmd_val(*(xp)) = 0; } while (0)
 
 #define pte_page(pte)		pfn_to_page(pte_pfn(pte))
-- 
2.20.1

