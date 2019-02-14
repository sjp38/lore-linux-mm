Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45F68C4151A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:10:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D19F222DB
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:10:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D19F222DB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E984C8E0005; Thu, 14 Feb 2019 12:10:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D84A58E0001; Thu, 14 Feb 2019 12:10:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B88FD8E0004; Thu, 14 Feb 2019 12:10:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79F128E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:10:41 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id v82so5268419pfj.9
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:10:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=lqRqlAUixHP/maDucUSoUigQ7wiAfswfBWQi2LO7g6Q=;
        b=tHXpNQr2jZwjb/uuw6PfiTijHQcDzzpiofHFUjBvlc+BDwZP/GmhH/ST5k7Be5MyAl
         sM+ncO/vNroXUlgcoaQmt6tX4tixZsPYa/4sFXod1fEdJG+se2AZDaJ6NuyQHYZdeuhx
         GbxBnS8wm1T80WWXvfD3Mw+L2Dwi7fAxqOuOZF/Oot2TNUzREdU4wLdPWB/+637VYcmY
         MYzRV6NEdLcK0cnD0rcQUrLuOoqD2Dn8qHH6TbwDEOtvIMZuFd5bFrJ9R0N6I3b/siiA
         vfMCd7gtBaoRZCEMCzAX7WI2uqsTQdNpuBGiOBxbW4MXYkV+a/p50alj3MSijj5A6uhQ
         XYIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaqBvSXwLVGuW9lrgeFYNFkV83jfRziYrTiE0YZiBp3F28XRK2o
	5rtzaEkwnENIMlY2E5/pKytBww25A7poqpjCz3prSyMYy40teK2mj/vYvZ3Fsu54tP1O3e+18aN
	AQq2/wFguuIPlF685KoxAK+LU0V5fuQaEtkH7RRZxtI7t53LaKBOGJELWYqy1Fuj1hQ==
X-Received: by 2002:a63:a11:: with SMTP id 17mr744511pgk.310.1550164241159;
        Thu, 14 Feb 2019 09:10:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYCcHlsGGeiyYVrGXGe8NXcFY7JT9JO+l1KbmKomqkPdH4p9lUDuYG6FjuWsB7B+07ShYpq
X-Received: by 2002:a63:a11:: with SMTP id 17mr744442pgk.310.1550164240143;
        Thu, 14 Feb 2019 09:10:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164240; cv=none;
        d=google.com; s=arc-20160816;
        b=S7R+uNg3zY5itPssNPlwEBN2FL6JvqLiOJTfuwmuhtBiDbHTVsjSTtaYLwNC4sDgM5
         tYCMecgmXKdKhn7eumVoWVEk6Eu9z5dI30VIjCeGN9Y8mbJo2vNQaisDoPXrEJVBL1U+
         HJEMjwSm9pf2Qn72qMLmSKSI63juZLI9Q0Vmhy8DFCkemG+MIoDdaHxLR3gHgyXVk19L
         Y/Wvi6222eJbzD67Hl2NRgjXJq75Ouqi7/Mr2rWIMruOttiEb4SBW3k6p4o7E1yrDm74
         a296TG8DgFf/s3Fp3nEoqBrS9RBqTO5XyoNvF4+YIFqoWap6jePEeXRZ9dTtzTPPnOvB
         YIqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=lqRqlAUixHP/maDucUSoUigQ7wiAfswfBWQi2LO7g6Q=;
        b=xtRZ94Eh7s22imUSIKVjuARxtT+bo7fKkc+JtGKzE/HWC0gOvAxcE7rSN0ajFWILWJ
         ZUueVJ5meaf9hUyOQ9K75AkPClJFF6v5LIRwG3r2tKhY/SFiAcH7pb4ON+155Tywpgwh
         40+VdCTEa9ukLQyGFH5d9mq5qS45PLTcR3oD0x4EAt0bnAsDjokuYvA9dlfSszsS41ke
         l3nMqavMRdODM+gSXXjQOcTR6bq95c0G+D1Z1n3E2ahmlsKPGGtTSTt24wyBMNfzGKiE
         NxG3NGDgSk+aZdc7w0A2n1NfeAQSTZPBs+36KaO/szk1scNrG3vRmcWg14sZCBlxHmgB
         zW9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id j17si2724426pfn.271.2019.02.14.09.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:10:40 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 09:10:39 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="133613102"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 14 Feb 2019 09:10:39 -0800
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv6 02/10] acpi: Add HMAT to generic parsing tables
Date: Thu, 14 Feb 2019 10:10:09 -0700
Message-Id: <20190214171017.9362-3-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190214171017.9362-1-keith.busch@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The Heterogeneous Memory Attribute Table (HMAT) header has different
field lengths than the existing parsing uses. Add the HMAT type to the
parsing rules so it may be generically parsed.

Cc: Dan Williams <dan.j.williams@intel.com>
Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/tables.c | 9 +++++++++
 include/linux/acpi.h  | 1 +
 2 files changed, 10 insertions(+)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 967e1168becf..d9911cd55edc 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -51,6 +51,7 @@ static int acpi_apic_instance __initdata;
 
 enum acpi_subtable_type {
 	ACPI_SUBTABLE_COMMON,
+	ACPI_SUBTABLE_HMAT,
 };
 
 struct acpi_subtable_entry {
@@ -232,6 +233,8 @@ acpi_get_entry_type(struct acpi_subtable_entry *entry)
 	switch (entry->type) {
 	case ACPI_SUBTABLE_COMMON:
 		return entry->hdr->common.type;
+	case ACPI_SUBTABLE_HMAT:
+		return entry->hdr->hmat.type;
 	}
 	return 0;
 }
@@ -242,6 +245,8 @@ acpi_get_entry_length(struct acpi_subtable_entry *entry)
 	switch (entry->type) {
 	case ACPI_SUBTABLE_COMMON:
 		return entry->hdr->common.length;
+	case ACPI_SUBTABLE_HMAT:
+		return entry->hdr->hmat.length;
 	}
 	return 0;
 }
@@ -252,6 +257,8 @@ acpi_get_subtable_header_length(struct acpi_subtable_entry *entry)
 	switch (entry->type) {
 	case ACPI_SUBTABLE_COMMON:
 		return sizeof(entry->hdr->common);
+	case ACPI_SUBTABLE_HMAT:
+		return sizeof(entry->hdr->hmat);
 	}
 	return 0;
 }
@@ -259,6 +266,8 @@ acpi_get_subtable_header_length(struct acpi_subtable_entry *entry)
 static enum acpi_subtable_type __init
 acpi_get_subtable_type(char *id)
 {
+	if (strncmp(id, ACPI_SIG_HMAT, 4) == 0)
+		return ACPI_SUBTABLE_HMAT;
 	return ACPI_SUBTABLE_COMMON;
 }
 
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 7c3c4ebaded6..53f93dff171c 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -143,6 +143,7 @@ enum acpi_address_range_id {
 /* Table Handlers */
 union acpi_subtable_headers {
 	struct acpi_subtable_header common;
+	struct acpi_hmat_structure hmat;
 };
 
 typedef int (*acpi_tbl_table_handler)(struct acpi_table_header *table);
-- 
2.14.4

