Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4683BC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:23:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AD27217D4
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:23:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="0D+e9OKI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AD27217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6F918E003C; Wed, 31 Jul 2019 11:23:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A8968E003D; Wed, 31 Jul 2019 11:23:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EA428E003C; Wed, 31 Jul 2019 11:23:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1190A8E003B
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:23:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f3so42592560edx.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:23:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fyWNol/pClGETI/+3Fy8S0o8APly1L7wYaUOInJ7cro=;
        b=Mr/GWQdR11/SISd1xnmKxBpvnu5H+u4844PUQ0TU2C9mGtkVT+PG7kY6Ow9hf4aEQ4
         0OgQiyu+kNge8cOy8ZkUMqC1DX3llQo2R8ajWwGDIWKgBJSJ0t9F8NZzn1X9iHabaO+Q
         mfNehv13UVJUEO0JtXvDhVUj/8nfgMmLvkRedJohBUZFO0KnymI0UfT7jHeVunWeXAfH
         EoMnnvnwc+4Ls7a27LXiIGPEBcLZCV8EWPP2MDDS6+t9YFQiU6bngajPLo+zJKmOLt2U
         AhAE+/lKCP5C8MYnNowvSU+YiOGo93TKYb9gviIPVdGPH5a2/EV8yQC4mY6IXksEuVOu
         ClmA==
X-Gm-Message-State: APjAAAWl2CrD5kejNo/kWTAS1nz1ylYNZIpiTACkTKwGjDrcpkbJPFHa
	l/ptGa2PgKF3GpuyvrZaj02dYQSjqIL8OgpeJJsJvZ57SD+qtHZLBIGcm3t874k6YdoY3ueCGZk
	umKZ4KR0Y1sEh9DfkOkEWz+NkBxb02RmqsVsFUuVLY0JWOm61UjcU+lyqZK6W2OM=
X-Received: by 2002:a17:906:81cb:: with SMTP id e11mr93820237ejx.37.1564586630593;
        Wed, 31 Jul 2019 08:23:50 -0700 (PDT)
X-Received: by 2002:a17:906:81cb:: with SMTP id e11mr93820158ejx.37.1564586629365;
        Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586629; cv=none;
        d=google.com; s=arc-20160816;
        b=QJcZ5r25CRPgyh9FCmmmudfliszrZhoX2zz5+53jyjD7waXWgGdWi5N6MB/2TtRZm7
         9O3Uwoj/gAuS/3GtosSUjKXmiocs6mF2r1pmj92Fl1t1t52m4UZea4A33/TBmBEcmOE4
         SoGuiBSObauk331AXyhb5nGv3vISydHLXufenuMtqo62tph2KycxuPkHEjQa31cN/gm7
         HV8glQU735UxWM7kKC1FZQSp/hSghFgeIhN6xNZ1TFXxFlak6SCMCcgWd6Y18OQVq0a4
         hQbuYTnB9J7aZxgw4C33QQdUkgYlqlml4WvcvCQiz1G4y8MZ5c9Mm0Wf1IbTcwhB2ZIl
         RrTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=fyWNol/pClGETI/+3Fy8S0o8APly1L7wYaUOInJ7cro=;
        b=wb4L+CiuplBqIw0v7ecdPCzMMmK8D8ODKNeUMYYeKQ3a0pTXDtsEkjp/lUgmjadP1f
         HROt7ulLswCot98W5w615UAJxWBmSUgjZdOeUuv9tX04XldA0+i0uPfB+MJXOHclhbuP
         YYMLLfW1CTnJikBMZnMwmIl/2ofZUBPjLyGUwuG3MDLiKYxVSRCYYetAGVug4G54OWnw
         Hdgp0KA+JMPwo6rLzA4Z9BnAMv1ffIo0yNBfykPRWRG7SGLYGy3JRKk7gf/F4gDojvvE
         oH21g2p9ryQ/EvXlByJVM2vBE4IyEWVTxlVuvpOA6A83HOLIBAiQojd4xanLIgjz7iqG
         +OTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=0D+e9OKI;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b56sor52198994edb.9.2019.07.31.08.23.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=0D+e9OKI;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=fyWNol/pClGETI/+3Fy8S0o8APly1L7wYaUOInJ7cro=;
        b=0D+e9OKImyb4sTdS3DaGli2ESSvrhwMepoaeber6sOi6xNQeOXqjqOnb/1KIv5eA0x
         eNNtaJSwMUTdya3x65wpEduqQWVFqNJxowmsYurkJg6idVmOJAgynHTMtURvl6pRH+lp
         /AXQs/PGw3QMUYeGMcitYEalW7K8jjmrvIDBQFxHoyvKOlQjQp1wt8RvB40She7x5nMN
         Km17y2HW/2HnGsAkyXDWsXdzi+suKv/3bNL7rEATTZ6hOD/1GmoI3RxM+fG1oxMgjoTb
         i0NcERRrgjS3qiNo560qZowGrKNWVHk2bwOr/TVDT1ncGB5cnkrBEBAJUPDEPQtBhvsJ
         S6vA==
X-Google-Smtp-Source: APXvYqwsOKPemvbbrapjzGTexE0e+E42HWLS7Zg61PJSi6P6DFE4jdPIWGYYycTh80vcUaFlClexVw==
X-Received: by 2002:a50:b388:: with SMTP id s8mr106143247edd.15.1564586629069;
        Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id f24sm16699742edt.82.2019.07.31.08.23.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:23:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id E1BE61045F9; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 35/59] acpi/hmat: Determine existence of an ACPI HMAT
Date: Wed, 31 Jul 2019 18:07:49 +0300
Message-Id: <20190731150813.26289-36-kirill.shutemov@linux.intel.com>
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

From: Alison Schofield <alison.schofield@intel.com>

Platforms that need to confirm the presence of an HMAT table
can use this function that simply reports the HMATs existence.

This is added in support of the Multi-Key Total Memory Encryption
(MKTME), a feature on future Intel platforms. These platforms will
need to confirm an HMAT is present at init time.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/acpi/hmat/hmat.c | 13 +++++++++++++
 include/linux/acpi.h     |  4 ++++
 2 files changed, 17 insertions(+)

diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index 96b7d39a97c6..38e3341f569f 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -664,3 +664,16 @@ static __init int hmat_init(void)
 	return 0;
 }
 subsys_initcall(hmat_init);
+
+bool acpi_hmat_present(void)
+{
+	struct acpi_table_header *tbl;
+	acpi_status status;
+
+	status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
+	if (ACPI_FAILURE(status))
+		return false;
+
+	acpi_put_table(tbl);
+	return true;
+}
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index fc1e7d4648bf..d27f4d17dfb3 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -1335,4 +1335,8 @@ acpi_platform_notify(struct device *dev, enum kobject_action action)
 }
 #endif
 
+#ifdef CONFIG_X86_INTEL_MKTME
+extern bool acpi_hmat_present(void);
+#endif /* CONFIG_X86_INTEL_MKTME */
+
 #endif	/*_LINUX_ACPI_H*/
-- 
2.21.0

