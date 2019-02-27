Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E280C00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9C6621852
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9C6621852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 982578E0004; Wed, 27 Feb 2019 12:07:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 908538E0001; Wed, 27 Feb 2019 12:07:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D3938E0004; Wed, 27 Feb 2019 12:07:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 238898E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:40 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id k32so7092902edc.23
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=J3FIuviiMVREZMZELIXYHVD1g1qTn0XuyTtmAQTk6Hc=;
        b=iUxIoUBL+0Mtg1puNn2720yX6IQ3pRIik6MsRhrN7Xh0gXza1ZFWpzhAnh/ftWvu7s
         IRrbQ/a6Q3+tRXbXZhDhnqOhH1t92r2mhYnoyv6NPZLSwHbQmrJGxHnid9clSUtY0L2U
         cVXl+mY5EH3MvHv5DVHMoaPufBOUsNJlSse8grhPaAWT1LAr2wycPGhRf5O0RccoqQyt
         7+llO9nYcYDOW1NWEXDkI+ac294v0eAANa9nuIgJuW14o7ZvuyFnRZzMQKSS42YRK11w
         KD6f5dE9yPU6fpzooBp0Iep3PQ5rK8t98K5M0ugurQMB2LTN/+BavGP1L3QbErcaMmd5
         oVzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuatidrH7jDYYEf7DJ+An+W7RIL1q9ppOfePNXLD2itVhKmeVSc+
	fnQJq1tb6vHIQPCnKBfwYUBGDbRrAHZdaau0ep8JS6RtfNMuqHKcmDtL46sL4rwSb/IpGiOjsit
	/zdC1LiUiV11IPUPqRw6Bu84YXT/EnCHg9Uba/4F2ltl/BKmTMWQtJFmpmXUXET2BfQ==
X-Received: by 2002:a17:906:b209:: with SMTP id p9mr2290797ejz.39.1551287259660;
        Wed, 27 Feb 2019 09:07:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaIIKev7LhwaCA6eM431xXFcYkmoy3pMqL8q6sXUIXSykO2qsOkNejMku2fGcc6502TIXG2
X-Received: by 2002:a17:906:b209:: with SMTP id p9mr2290733ejz.39.1551287258693;
        Wed, 27 Feb 2019 09:07:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287258; cv=none;
        d=google.com; s=arc-20160816;
        b=S7v01RTAeXmCniY/dmwFJV8FmLdAZ9hkrisSy/yrzJHZwe4EIQCTSnHJSPGX3tgBbD
         QkKwHvHlliNzg8wiB9vnK8gpt1UP2wTj4YhlFj+XdSu+boIw9ZFqNwZ9GtmtAN0kWw/r
         y6yqRtgdAo3zLhdHXFxJ5ZvfJOeK1HBpttoGv9KmwYXc33Z6UQf2Pu0vg4nKPdkVo6YN
         4NxFNRkquD/mReecSUdQ3gSQKGRIgHSSgnRDPYMLtSAmxtpnzWYLZE3RQJuc5al1oQxf
         g7LBRBcLhnSq1YQ1cQycMmKLEbA64fO8OM3do2IyfNj2TgHADzrnDVQUOUUxVjAvG5XZ
         BwTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=J3FIuviiMVREZMZELIXYHVD1g1qTn0XuyTtmAQTk6Hc=;
        b=KVWv0U4+CD+7imAnbSuJ684lS+5Gnrk6PO/t55k+cDm5Wok5Tu8H9pzkPTH1lt5KZf
         iDcb76Igf1NMOObm8zmmK5mQybx1t1BblqPmcfWshoPme9gVxVmrsWtJFNen90uwTQAc
         Cv6YLxqQ7A2IEyHNF9+veAmEWk7mfBNGCfx+g/WT/Vk7dOmni5bSVVFuCo6pzAFmYfAh
         LcldbFbA/KIJiuwSMWXgTBm5EhlJWJQcgJk5NlI8gDDI82MdVbB6GZ+8v3oG898VVRfZ
         j4uU832+OFoLo8EjWcLI0RlPV0/6eeBAFB9TfhXDtgnrFVplZyng7rD/USY0U2KqqDml
         U2ig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a17si4440098ejy.247.2019.02.27.09.07.38
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:38 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AE15D1684;
	Wed, 27 Feb 2019 09:07:37 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 056103F738;
	Wed, 27 Feb 2019 09:07:33 -0800 (PST)
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
Subject: [PATCH v3 18/34] s390: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:52 +0000
Message-Id: <20190227170608.27963-19-steven.price@arm.com>
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

For s390, we don't support large pages, so add a stub returning 0.

CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
CC: Heiko Carstens <heiko.carstens@de.ibm.com>
CC: linux-s390@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/s390/include/asm/pgtable.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 063732414dfb..9617f1fb69b4 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -605,6 +605,11 @@ static inline int pgd_present(pgd_t pgd)
 	return (pgd_val(pgd) & _REGION_ENTRY_ORIGIN) != 0UL;
 }
 
+static inline int pgd_large(pgd_t pgd)
+{
+	return 0;
+}
+
 static inline int pgd_none(pgd_t pgd)
 {
 	if (pgd_folded(pgd))
@@ -645,6 +650,11 @@ static inline int p4d_present(p4d_t p4d)
 	return (p4d_val(p4d) & _REGION_ENTRY_ORIGIN) != 0UL;
 }
 
+static inline int p4d_large(p4d_t p4d)
+{
+	return 0;
+}
+
 static inline int p4d_none(p4d_t p4d)
 {
 	if (p4d_folded(p4d))
-- 
2.20.1

