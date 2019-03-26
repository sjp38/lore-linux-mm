Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0AB8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:26:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 878D6206DF
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:26:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 878D6206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FCEA6B0010; Tue, 26 Mar 2019 12:26:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AD7A6B0266; Tue, 26 Mar 2019 12:26:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14E416B0269; Tue, 26 Mar 2019 12:26:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B9DAA6B0010
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:26:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l19so5485315edr.12
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:26:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3GzvBNszJ2F9qzyq8uNQC4ioxjUcI3EqpQkesdmXCx4=;
        b=oFTmlw88tVEVp0AXhtp8LKPRHFEBYOiPGieE8FeBWSctA5EgkfokrosgpAYN4a98Cz
         PQNJNeEXYJALl+DMVJ2r2PnWuMllNZGSjQ80jNn4el5FTzbMptDjY4DjvTe3XulcZsEN
         sluwK5qY/RWuUzORSjvwIvlhP7eTMtRpckUva1NBCct1iwHJYI/qmnkeyCEo/wxbDF4F
         Fa9EWVyjBMZsya7DewxXtt+bj/3GfAGeYIxK2zoh8ebzaM/5uZsyXfOB87yEAV2Bl1cR
         92yQPJo6MVwrESIkM1IQPGIDvEow4d+5+xj0cQ0e6QxM+luFT5ONl/JvSPaqcDklSYDn
         47ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUs6tt0mNyLIRQn5jm6HEA9O6kFxeJF7EC+Fu3eOun+lj0CYcK1
	T161d5skDYPWcTcD89ztRMor+6qA/pgZK8s5Ddc4FTuVLntjE70sa0KL5Ey1jkWAtxqwun5//Hs
	xDC1t+qqxceOCEXK5Ij1TYv2Dk1VIACuXcZpULjJpHdGYeW3XpVbMA4JmfmK2/QDZYA==
X-Received: by 2002:a17:906:69c3:: with SMTP id g3mr17624695ejs.245.1553617601284;
        Tue, 26 Mar 2019 09:26:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7tj4O/CUYET8yS4t29v12MrYgwM4obIA+ryqHWKwBYKWWLY5QL3sMLD4lKQlDIhZK2GYm
X-Received: by 2002:a17:906:69c3:: with SMTP id g3mr17624648ejs.245.1553617600304;
        Tue, 26 Mar 2019 09:26:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617600; cv=none;
        d=google.com; s=arc-20160816;
        b=J+hGaQBl0VkrajC9xcuMyh43mPYYYdEo/crK1FB7Dj9XLSE7Nb9opxxdDoF8NHvQ0u
         YG8jOp3q8HKkGzr4WfaYiN+3AQKijSLqXm+QmgszvJivHCUwYQuCxBegRCoqQbRIqMIU
         SyF7YGIOTrCHEN9PUbkxfEh12EPXnZvYri0yHRimDcjhb/n0b1YPCWfZI8IMLxE1MlxV
         EpLE0CMZT7fuXPhnzoysh4ZFw1w15h5tA2pWdO9kaZG8URuuF0qpnGVdNRuJFb49rYNR
         EIWOni9VKPZkUdIa3U8p3DkCuw+OfkF/T3NPkDJfNFw0CQyanCESJjMNGdh3vJvt3NTN
         mLWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3GzvBNszJ2F9qzyq8uNQC4ioxjUcI3EqpQkesdmXCx4=;
        b=adr4XLbfe3eriR/l+haQymKubUGazfydc+sEj4k9XqvQ1wTIKAFA9gt16RASt9ji5c
         wxXwqObtbKeawSOGOwtsa+vfXSw6K5UEAL4BXKGvsVSF9u/lW9lQctwVHUuiQfOVhRUy
         5dct2/0YYO3kcd8qlBTfVJjc8FDm/ZIXKIP7vQK+R5IcETKP5gEGRtq5mtOnzei1As6F
         Py+8SxbzMqMEx6qa1ITdJo3mwv3qXE2WR/bjxtzkuzhncZ+GSkCkLYP2/AAO+wHp7yta
         crRKY29gqd9oFm+ICgLXAriQ7PlWtyoHtpMFBq1jR1bcWtwiSa+flS6tpYC/0tt0cCyJ
         PVKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c51si38240edc.56.2019.03.26.09.26.39
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:26:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 35E8015AB;
	Tue, 26 Mar 2019 09:26:39 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A661B3F614;
	Tue, 26 Mar 2019 09:26:35 -0700 (PDT)
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
Subject: [PATCH v6 01/19] arc: mm: Add p?d_large() definitions
Date: Tue, 26 Mar 2019 16:26:06 +0000
Message-Id: <20190326162624.20736-2-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190326162624.20736-1-steven.price@arm.com>
References: <20190326162624.20736-1-steven.price@arm.com>
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

