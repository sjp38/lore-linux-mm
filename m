Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7909FC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EAB820693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="K8GSlHVy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EAB820693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3E338E0030; Wed, 31 Jul 2019 11:14:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A71808E0036; Wed, 31 Jul 2019 11:14:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84D938E0035; Wed, 31 Jul 2019 11:14:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3319E8E0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:14:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c31so42657164ede.5
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:14:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0SvRw1bdF/wj1/uPaALpB1mJItIzSwaE2+8pgarmj/0=;
        b=XTM2o66kjbKeKoFbTuxtbrCDdNTydLDSSktlOqiCkroUjVX8Ikkt6R03pUod862zpi
         0EN/XJSmygvA3w3XpkUyaTyP+Z7f8o6Bw3OVPDwfQtB8+kj8328EaYBXyA43xXkldE2X
         1vjSribnQhRo7U/urNYfGYV93Olp1aqq70GWA5BYHm4uR4nqGFmhCG5nGzGttSf7y6jq
         xEtEbsOcjQ9UYkkezzzjmsqapUyrYP4KRJywSznxhFKngsgz2PQKIkKPSqAm7PQjjJrs
         fBrPilhMDGpE/auOEXeDhbf95dx9VXrC7Umar28BKC+/zSYoSjIJ5cVmVw74kKaIzU9w
         0gcw==
X-Gm-Message-State: APjAAAVoEIu3LkOP3YlChT/pMhdEecMNDFtB91Y0usReuNo/795TT0HK
	WSCkHQcSPrUGoXZp6FG3e6Kk/gwhd7hW3TGp0TdTC1hpyjJDWAzo1QWT3psMeSLB81MJw5x/yTM
	RZLkVLDzh068WdBNmQm9h8iIPwpbb0mu+ystQ0WKefLBO7/sjOuSiAclhZhpZ1bw=
X-Received: by 2002:a50:9263:: with SMTP id j32mr106969576eda.121.1564586041786;
        Wed, 31 Jul 2019 08:14:01 -0700 (PDT)
X-Received: by 2002:a50:9263:: with SMTP id j32mr106969445eda.121.1564586040430;
        Wed, 31 Jul 2019 08:14:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586040; cv=none;
        d=google.com; s=arc-20160816;
        b=p3KNYuHxm78EelTTgYw9fHMjoC1TLnEWXCHrVGVPurNBRqCIF36D5uVIhFF/IERHTs
         uo8FNJldy1e/dBOdtKWo4/Tbkgm83KJ/Q12fkKaYuk4yV3dYhgbfKMRwm24uUsb+e6Hk
         qUjlnhfvKK3YeUGb5EP8ps+gEGDMzl1/WQVt4xEPZF8ON0TaRcQfHDPhJK8yX8PWdn21
         UzQ3cJt/fY6m0P/28JDiIQAyOeINhqnQk3lBfqs3ixvg2kudctZtngJjrEQGyYni15/d
         7A/l3GIDKA4OnmVrOTTLTKpqq8w1PAY6IblUk3k3vcg2qSUrPe1XRrqNeuxCY53KF2RS
         Sm1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0SvRw1bdF/wj1/uPaALpB1mJItIzSwaE2+8pgarmj/0=;
        b=qasuvPRuaZqPBr766PK6JzcjgQjAEq0udpWIpPuPlXUUeOYtwmceUhiBuiK7dQclsm
         wOUpsaGyPvd1b9aMbHzAuXhEcU8K+JHLLxojmVnTMImHCJ4hBP3mmjPGacHetLYOHGkw
         xkEA0Pjh5lmMaWE+Gm64nvGwLEDn2hQLsUX93mUSBUotLZ/Fjmwn8KMEVlMD1nuiv13b
         717XUaorAWAjeCg1eR1njavUXmYiK07cAzoMyenSvhVgwxxH6p13FfkcwCrOqnqRKcA9
         KlnPIjKNERYGu1+88FtDZuhM2dXXbQGwPA/VcqLlBgZOBiWZcaeZloNeid0ncg4QGAk4
         PnHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=K8GSlHVy;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x8sor22155844eju.28.2019.07.31.08.14.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:14:00 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=K8GSlHVy;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=0SvRw1bdF/wj1/uPaALpB1mJItIzSwaE2+8pgarmj/0=;
        b=K8GSlHVyaCoX6eoUymMD8WNd8fo5NWDf75jpRiOk+1zSA+MpR6EfH2u4sq/cei0nEX
         o80zJP8en7QDpE5vzs8O5n4LrgF22geCbTMxZs9xW/Bw6G07hLfzIVGyGKyQoxIOnZBD
         YFtORfTsEPttMMQotUKNiwrIP4HCJfUjTSf2by1YSPzvrtnfC1aL0Dv/WEnFMeyqvoSY
         1yZ+xCdOLBGgiLW+bKu/YcS0pacqJtrPn8i6k/jyqe3Rz1jF3T9VOENF63nv+EydMMBy
         h8eN884I5s73CM7fbg8Lu/9/FG0L4WKxt0gSlNtUkWxzIvuA+TNSCpjkFO+PNMv3SZs9
         BR7A==
X-Google-Smtp-Source: APXvYqwDDDPlNwfBHKIOlIbyqYdy0UrYvh8zFar3DZnhvZm8R0JCleo52KdoWAHk4ZEHWuudYw10ag==
X-Received: by 2002:a17:906:e11a:: with SMTP id gj26mr95741299ejb.95.1564586040068;
        Wed, 31 Jul 2019 08:14:00 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id qq13sm12564390ejb.27.2019.07.31.08.13.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id EF8F91045FB; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 37/59] acpi/hmat: Evaluate topology presented in ACPI HMAT for MKTME
Date: Wed, 31 Jul 2019 18:07:51 +0300
Message-Id: <20190731150813.26289-38-kirill.shutemov@linux.intel.com>
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

MKTME, Multi-Key Total Memory Encryption, is a feature on Intel
platforms. The ACPI HMAT table can be used to verify that the
platform topology is safe for the usage of MKTME.

The kernel must be capable of programming every memory controller
on the platform. This means that there must be a CPU online, in
the same proximity domain of each memory controller.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/acpi/hmat/hmat.c | 54 ++++++++++++++++++++++++++++++++++++++++
 include/linux/acpi.h     |  1 +
 2 files changed, 55 insertions(+)

diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index 38e3341f569f..936a403c0694 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -677,3 +677,57 @@ bool acpi_hmat_present(void)
 	acpi_put_table(tbl);
 	return true;
 }
+
+static int mktme_parse_proximity_domains(union acpi_subtable_headers *header,
+					 const unsigned long end)
+{
+	struct acpi_hmat_proximity_domain *mar = (void *)header;
+	struct acpi_hmat_structure *hdr = (void *)header;
+
+	const struct cpumask *tmp_mask;
+
+	if (!hdr || hdr->type != ACPI_HMAT_TYPE_PROXIMITY)
+		return -EINVAL;
+
+	if (mar->header.length != sizeof(*mar)) {
+		pr_warn("MKTME: invalid header length in HMAT\n");
+		return -1;
+	}
+	/*
+	 * Require a valid processor proximity domain.
+	 * This will catch memory only physical packages with
+	 * no processor capable of programming the key table.
+	 */
+	if (!(mar->flags & ACPI_HMAT_PROCESSOR_PD_VALID)) {
+		pr_warn("MKTME: no valid processor proximity domain\n");
+		return -1;
+	}
+	/* Require an online CPU in the processor proximity domain. */
+	tmp_mask = cpumask_of_node(pxm_to_node(mar->processor_PD));
+	if (!cpumask_intersects(tmp_mask, cpu_online_mask)) {
+		pr_warn("MKTME: no online CPU in proximity domain\n");
+		return -1;
+	}
+	return 0;
+}
+
+/* Returns true if topology is safe for MKTME key creation */
+bool mktme_hmat_evaluate(void)
+{
+	struct acpi_table_header *tbl;
+	bool ret = true;
+	acpi_status status;
+
+	status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
+	if (ACPI_FAILURE(status))
+		return -EINVAL;
+
+	if (acpi_table_parse_entries(ACPI_SIG_HMAT,
+				     sizeof(struct acpi_table_hmat),
+				     ACPI_HMAT_TYPE_PROXIMITY,
+				     mktme_parse_proximity_domains, 0) < 0) {
+		ret = false;
+	}
+	acpi_put_table(tbl);
+	return ret;
+}
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index d27f4d17dfb3..8854ae942e37 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -1337,6 +1337,7 @@ acpi_platform_notify(struct device *dev, enum kobject_action action)
 
 #ifdef CONFIG_X86_INTEL_MKTME
 extern bool acpi_hmat_present(void);
+extern bool mktme_hmat_evaluate(void);
 #endif /* CONFIG_X86_INTEL_MKTME */
 
 #endif	/*_LINUX_ACPI_H*/
-- 
2.21.0

