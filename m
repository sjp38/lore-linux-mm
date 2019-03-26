Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30E56C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2DC8206DF
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2DC8206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91A866B0270; Tue, 26 Mar 2019 12:27:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C76D6B0271; Tue, 26 Mar 2019 12:27:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B98C6B0272; Tue, 26 Mar 2019 12:27:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1706B0270
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:27:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f11so2270644edq.18
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:27:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EIMxzs3KcJ4jmgX2iikj+tJ0Q4+Nen0h2D0kdVtq1V0=;
        b=M/06xhRO7YxJLCPXVVFgNKe1G/af6PsG7KG3LJWeqMj7803+K/OpexSKlaWwLoyrvc
         HvDFybUq4idQWth0Wr+61hdiM3KUW07pyscp1eQfFOm/FhQejQKZaEqz9o8DixDLRS3i
         OfxMBby4lwovraEFVBrHAvRdfncxi16fOERyKuO2JJ18u3qQ+ezxGj+t/ap1CG5IsUVn
         yLYWvNm4J5wCDKF8R8aiC5VZx05dMU+UBhhctchEUlNvOysNYvHs6F1ejInLqm8g/27+
         91kMq6L4YmB4GFzWKCOOcbLwjzWc1HIh6/tSul+WxvOxKLUBlVEQ7dz3NL+I+gmv7Rz0
         3xKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWRliSyj5xH6QhMllRV8skQLsBlAZqZuqA7dBThV25UTakhVoMG
	JO8dzgv8CpVRSMJR+OMYNn/kKZdhfRh7bylRZMOp1T46ARJTvGNyqdVaP6VUIt/Csl//Cc59Mhw
	F+qwy+/DYxMv4HlNzqRlTX2m8twF3lEF71QP/U5xnBQHD0R/IYABRVSsGRTV46BSa0w==
X-Received: by 2002:a50:f5f1:: with SMTP id x46mr17403820edm.37.1553617620658;
        Tue, 26 Mar 2019 09:27:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqUdMk6f2di5PM3ux+X5qbaq55n24MPvYI5GNc8KVk5pQJTvFaSS2sZ0CT/TpeDg8w9WJK
X-Received: by 2002:a50:f5f1:: with SMTP id x46mr17403776edm.37.1553617619881;
        Tue, 26 Mar 2019 09:26:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617619; cv=none;
        d=google.com; s=arc-20160816;
        b=IFXiFDymSJ9RFPuJifTfQT1rR01UzEMq6S/D14OjRD9lWgX6bSckWaUvn9+XBRgPKs
         FHPq/z4M6hq7NpI9ud4vwZW7Gwlheae7+nduy5R2dnqVQnLXSB7geKCeQB2G8vNPA40P
         tUQcwxKxSExV8kC4qOII5ipGS1gw4cyjl1N2TdpTCgcETWKghQaDMGpFCQ+qttYJAdJa
         TPJal+8x6QJwWPRjVv2SbEVTQeDpelIxExPWfpCt6oOQsIkO1te1TalhTvkISOh426LK
         TMjnraG/2eCRM/yxEQTvYcbM67QqOycy0mTKAkG/QyyIvLmHDokMEPBvFzFKR1MnUvSs
         6CFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=EIMxzs3KcJ4jmgX2iikj+tJ0Q4+Nen0h2D0kdVtq1V0=;
        b=Bw/YgVsktZT1kqr79vUgi2/RJsef0AfKmKObYfVCkxBqmGvPmvz3H4gaLRXIZ9rS5j
         2TIKYXJSkHPBNSYx1G2OsfkzH+iZ3MWgxFly6IWYDcqjGoLmljJ4q+RsVIvkRNUKi5wA
         qi4CwKnu1CowbMTkMuxvBC/6A/x8xyfsAwNQV4ibCauHrKZXVzagBdDFoePRIcLfMAG8
         01ZqC0WXsbSKGEF/H6kpuXf5DZ7/y6axlihkXdz1T9Wy85F3fU3nc5qLDc+IjFkSgRaX
         ssTxOACxPNClHev25BmAHbOQ0iQbaLEm2Z/yo3a62ks8E3833nUDstolIaLaUsfi1y7H
         uYXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n17si1430043edr.198.2019.03.26.09.26.59
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:26:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E59BE1684;
	Tue, 26 Mar 2019 09:26:58 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3F3073F614;
	Tue, 26 Mar 2019 09:26:55 -0700 (PDT)
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
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux-s390@vger.kernel.org
Subject: [PATCH v6 06/19] s390: mm: Add p?d_large() definitions
Date: Tue, 26 Mar 2019 16:26:11 +0000
Message-Id: <20190326162624.20736-7-steven.price@arm.com>
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
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For s390, pud_large() and pmd_large() are already implemented as static
inline functions. Add a #define so we don't pick up the generic version
introduced in a later patch.

CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
CC: Heiko Carstens <heiko.carstens@de.ibm.com>
CC: linux-s390@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/s390/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 76dc344edb8c..3ad4c69e1f2d 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -679,6 +679,7 @@ static inline int pud_none(pud_t pud)
 	return pud_val(pud) == _REGION3_ENTRY_EMPTY;
 }
 
+#define pud_large	pud_large
 static inline int pud_large(pud_t pud)
 {
 	if ((pud_val(pud) & _REGION_ENTRY_TYPE_MASK) != _REGION_ENTRY_TYPE_R3)
@@ -696,6 +697,7 @@ static inline unsigned long pud_pfn(pud_t pud)
 	return (pud_val(pud) & origin_mask) >> PAGE_SHIFT;
 }
 
+#define pmd_large	pmd_large
 static inline int pmd_large(pmd_t pmd)
 {
 	return (pmd_val(pmd) & _SEGMENT_ENTRY_LARGE) != 0;
-- 
2.20.1

