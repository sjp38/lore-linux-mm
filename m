Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CE26C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:50:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1078B2133D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:50:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1078B2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9F5E8E0007; Wed, 27 Feb 2019 17:50:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C54B78E0001; Wed, 27 Feb 2019 17:50:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC8468E0007; Wed, 27 Feb 2019 17:50:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6B68E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 17:50:31 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id t1so13496836plo.20
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 14:50:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=nQuXJ7LNYRRxRkGtcByfgDjWm6trYb32V1csoO7OD/Q=;
        b=Vwc+Hte3VEziqKSTW4ij0/1j5HiP0C/2uI8+epD8rJ44uFaDjmjrEnGVxXyK8nrSfZ
         /TFWV1iz8awU4yI+n/DF/IJmSTE9FeR4MDPzjdGGhStcU3ByTjBgBTaE3kmcWcDFE6EB
         Rqk7XgKx0I8yYMoiIXgaXvRNQLDDylEY9PAuv57nhpdVd7QaHXuEyP5XDAwxL2FQ1MMQ
         9qxdgOJKRTM0fMdd63sovE1odFc5U4Bkyrn54qHGq7JfXpCRlh1vPzHgfdUDnIBRfjSo
         bFhKcaPzLKm991mMpNQKacyYz+WdAu5yzlNyqH+eqvgEJbohOfPTwnAIN+Avee2fm1vy
         nIhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZ/v5MLu9fWtQUhZODY2+53/u2V/Ol2z7hz9eT+ZYwK8HYOa08L
	9Z5Rg4EuVGW6mOX1qd2cEUltCTliWVGFsyqo2AGNyjqeSOHTX5ya5HRf6dAZKiFccrybBJca7hy
	A6hWdpuXKBIrJShw6e1cvT+W+xzjPhAJK5yuU33lPcYqazBZ4mNanXPLbJ6jUj9r5zA==
X-Received: by 2002:a62:b248:: with SMTP id x69mr4114190pfe.256.1551307831040;
        Wed, 27 Feb 2019 14:50:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaffC2Ar0aA7SbsAgBHwXiVeLRRQqnmuk5wiSDsEzcPdvGyIr4XWDzNVlZaVEbb5je0f0NG
X-Received: by 2002:a62:b248:: with SMTP id x69mr4114135pfe.256.1551307830131;
        Wed, 27 Feb 2019 14:50:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551307830; cv=none;
        d=google.com; s=arc-20160816;
        b=nSKjyDvb+BEcscLhQfJk5jt4ayJzoE2EM5KCdKtmpAA1kglKpfy1yN9Hm82P81Ngum
         +8hm/trg5vLgviCOQ/aazEndBC9eD2ENyJ6zXGHp3V6fu3rV8PCrBLU+PchSeojRx7Il
         ZQZ8fE17C9lUPOtZQYfidfffUG8QWQC87mkL3u+IJw4MFY84XiSjh2qk7HQA0sBej4Dq
         9PXGvFAzMCBAV8jzPsOru04KtHAbA6+1t63UkVThbMbh2GuL4FaSm47dQJOIEQgylKqq
         E8S/VpJ2RQ7O3EV0dAxAuq1ZCqLq/9Nd0POsJA7Rm/HdILEwPbPoycAT5I2xpwXMMMee
         4I2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=nQuXJ7LNYRRxRkGtcByfgDjWm6trYb32V1csoO7OD/Q=;
        b=NcGouC6gRGr3fgAgHOxECliDKSgzqUaFkqj/hxpyTvIjrrbBEArT7rtVcJJBOuN1RX
         7ZAZDGWRRoNhjv0Pcah3q54DPqzjWLn/RLz7PveZVrMcYAmoAUyav+n1bdVDOzOOXLrR
         A/7BDiv9wiltpgE5L5Z7xaO8Klg1kJu9C6yyaHtQ5l5h16YTxOHXlHtfL4yErdJ3si5v
         ifz8JdSHt9wmnFziw0ykG99/5oGmOilfv/rDooInq1pQwYxny1iFfWFOCdSgrNk/DJbW
         KT3WVn2+RpS1+hiW3iwLAM+SmEjk5UWq3u8OXjZotsAMw71dDtBLiVeHO+7q7cdTa64X
         8aSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z20si10836901pgf.324.2019.02.27.14.50.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 14:50:30 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Feb 2019 14:50:29 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,420,1544515200"; 
   d="scan'208";a="121349389"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga008.jf.intel.com with ESMTP; 27 Feb 2019 14:50:28 -0800
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
Subject: [PATCHv7 02/10] acpi: Add HMAT to generic parsing tables
Date: Wed, 27 Feb 2019 15:50:30 -0700
Message-Id: <20190227225038.20438-3-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190227225038.20438-1-keith.busch@intel.com>
References: <20190227225038.20438-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000007, version=1.2.4
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
index 7553774a22b7..3d0da38f94c6 100644
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
index 9494d42bf507..7c7515b0767e 100644
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

