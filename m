Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91395C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A38B20C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="GisN2VOH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A38B20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE41F8E0033; Wed, 31 Jul 2019 11:14:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6E438E0030; Wed, 31 Jul 2019 11:14:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A49ED8E0033; Wed, 31 Jul 2019 11:14:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 53A428E0030
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:14:01 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y15so42628178edu.19
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:14:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3zVMT74rDUltFrg5s5cNC7M6LQV7b9+aLo+/S3q5hiw=;
        b=BSm8BqMbV2DBNT8SUkMyfJOrg8Ckt4px/eHpxAhTH6fPn0rUM1RBFWuFToM7N2l1iY
         w8MMpapc9BfJchKU7q/i1BJ2ingHlWBzsdaXoVRrICuimSi2W0PFc0vi0CXm0dDRqDhn
         EhnntH+sA6k2fgBC+hFtATE776MsJJ9gdDUC1j+Y2WZ9rd5RgV//v0XovXizIdd/Nymu
         PV6d5N0kqIDRZMqhSw3EK18iNy8obiyWOS6XhrGomuRNy41qvlS6lfRDVK+X7nES9KbE
         /Zp14I47iZwEDvNmDPVT1iTN02mEvw992+Pq1zBtzoJ77+3Qp+bU7KWo09djmrTn6G0U
         LrvA==
X-Gm-Message-State: APjAAAXXk966F/a/iZOYmtnfY0Z93i5sLBwRRyzyzepDoE3gvk/mHcuj
	aCSa2VUre9Bw5gNsY6oD4uxXMwIASVPf5YiIoerVZ4Rrrm1FRae53XCySNVBimV3Z3Lp7s7GSoL
	2QxfTnzd91jsOyOFGDc6wA9im/gPTyqXMLpeIuNBopru4u7485uzKJT963KADeww=
X-Received: by 2002:a50:b4cb:: with SMTP id x11mr109667775edd.284.1564586040914;
        Wed, 31 Jul 2019 08:14:00 -0700 (PDT)
X-Received: by 2002:a50:b4cb:: with SMTP id x11mr109667636edd.284.1564586039565;
        Wed, 31 Jul 2019 08:13:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586039; cv=none;
        d=google.com; s=arc-20160816;
        b=xsCbz8skRRf72SqUwRQv7zwcSJw1Y6UOnLZQ5xYNwVR2RCxSzvjlGwzSLjQlFQGSBs
         Qx4jEKzwklPR0n+m8DQpopSM5TXt84cG5MCAV8cR4DDSTP5d9TSUITk1BJMwQigAsqDs
         lYVlqBHlWxtVYQLG8TGnbRO/rJVVKIPGId9DGGhu8YUu6Ys5W5E/pEQutGtyBRVy+9Ok
         4VsQ09FfIbJJiwmFnBZHHxOoNICf+byrub3MSdIg7APrnRFBYcBlSv49s6aZwDF1aZCe
         +3J4rDj6fRdE/JqBUt2/hfGdTQeKhFtLlPrZ+tesXuWmFjGfma0d+JW9JuE7RRQnFDd1
         Lt4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3zVMT74rDUltFrg5s5cNC7M6LQV7b9+aLo+/S3q5hiw=;
        b=Z7946y8HraD7O/By8+KjBVoerExkDuu5iWgrb7+KFHQhgWPXJqChx+vQT20CwFZInT
         hW2rqO88DCWCsBSt7/jJsaojIZB5WvQcd2sPNYQ4cBQqVJJYxVtqGcVxnomYlgCfCdMw
         j8lNIvvW4huq4aBdO5BkS94/V69T560bmUlqKF5hMUKN5x1VAU40GPziXu49OlNqFgCb
         DupCEzFgCCa0oSrRqYtxiqHrud5bs+6fY8xBUwmgyLB+P1COgxpwV90ScVIc1fEENVfQ
         /SdFVtZgdXHRT6iB4VTnkMb6NvhFdagVP7XSQf3Rwmp7qTMqow/ZUq77q9ZMyZRdFRSO
         QTqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=GisN2VOH;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5sor52051868edv.14.2019.07.31.08.13.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:59 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=GisN2VOH;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=3zVMT74rDUltFrg5s5cNC7M6LQV7b9+aLo+/S3q5hiw=;
        b=GisN2VOHWd3D2xd2nqgN/O4RiDCWZV8MPtYrQVY6TlWY8EHqrabeuC1r3NX9u0NUOO
         BH2o2lVkrCrb9gk1MKTOTG948p8DjJmLwuCxvSnHSCG2lQ5LlWSSW0TudDJxop3vUybS
         iS5zXgJkjFJwjSE1VsEQrLIg9PkOFtoA/PrYofcbBQsb/QBWbIN8wq9TtqNGnZW57NXu
         FygrvM5q/WyuM25UdOJmx6Q3wWqh1eJzizEsGx5+xS2vf/v8J+0H+RHMoHy2oBvIHwmm
         KlIaNODZHWgCOQ3B780DUv+UnF1kRJdgXgyEo5fMmqmMlzcNCEgAUZoRuuxXG8JEW+4G
         Cplw==
X-Google-Smtp-Source: APXvYqwlNY51UchCswKgnSs9+WfX2oW8BlZl27GF1PmsG2m8MqrdBgD47IA24LwOZbfQr2I0vImeXg==
X-Received: by 2002:a50:8b9c:: with SMTP id m28mr109889326edm.53.1564586039271;
        Wed, 31 Jul 2019 08:13:59 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id ns22sm12486254ejb.9.2019.07.31.08.13.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id DAD501045F8; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 34/59] acpi: Remove __init from acpi table parsing functions
Date: Wed, 31 Jul 2019 18:07:48 +0300
Message-Id: <20190731150813.26289-35-kirill.shutemov@linux.intel.com>
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

ACPI table parsing functions are useful after init time.

For example, the MKTME (Multi-Key Total Memory Encryption) key
service will evaluate the ACPI HMAT table when the first key
creation request occurs.  This will happen after init time.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/acpi/tables.c | 10 +++++-----
 include/linux/acpi.h  |  4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index b32327759380..9d40af7f07fb 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -33,7 +33,7 @@ static char *mps_inti_flags_trigger[] = { "dfl", "edge", "res", "level" };
 
 static struct acpi_table_desc initial_tables[ACPI_MAX_TABLES] __initdata;
 
-static int acpi_apic_instance __initdata;
+static int acpi_apic_instance;
 
 enum acpi_subtable_type {
 	ACPI_SUBTABLE_COMMON,
@@ -49,7 +49,7 @@ struct acpi_subtable_entry {
  * Disable table checksum verification for the early stage due to the size
  * limitation of the current x86 early mapping implementation.
  */
-static bool acpi_verify_table_checksum __initdata = false;
+static bool acpi_verify_table_checksum = false;
 
 void acpi_table_print_madt_entry(struct acpi_subtable_header *header)
 {
@@ -280,7 +280,7 @@ acpi_get_subtable_type(char *id)
  * On success returns sum of all matching entries for all proc handlers.
  * Otherwise, -ENODEV or -EINVAL is returned.
  */
-static int __init acpi_parse_entries_array(char *id, unsigned long table_size,
+static int acpi_parse_entries_array(char *id, unsigned long table_size,
 		struct acpi_table_header *table_header,
 		struct acpi_subtable_proc *proc, int proc_num,
 		unsigned int max_entries)
@@ -355,7 +355,7 @@ static int __init acpi_parse_entries_array(char *id, unsigned long table_size,
 	return errs ? -EINVAL : count;
 }
 
-int __init acpi_table_parse_entries_array(char *id,
+int acpi_table_parse_entries_array(char *id,
 			 unsigned long table_size,
 			 struct acpi_subtable_proc *proc, int proc_num,
 			 unsigned int max_entries)
@@ -386,7 +386,7 @@ int __init acpi_table_parse_entries_array(char *id,
 	return count;
 }
 
-int __init acpi_table_parse_entries(char *id,
+int acpi_table_parse_entries(char *id,
 			unsigned long table_size,
 			int entry_id,
 			acpi_tbl_entry_handler handler,
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 9426b9aaed86..fc1e7d4648bf 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -228,11 +228,11 @@ int acpi_numa_init (void);
 
 int acpi_table_init (void);
 int acpi_table_parse(char *id, acpi_tbl_table_handler handler);
-int __init acpi_table_parse_entries(char *id, unsigned long table_size,
+int acpi_table_parse_entries(char *id, unsigned long table_size,
 			      int entry_id,
 			      acpi_tbl_entry_handler handler,
 			      unsigned int max_entries);
-int __init acpi_table_parse_entries_array(char *id, unsigned long table_size,
+int acpi_table_parse_entries_array(char *id, unsigned long table_size,
 			      struct acpi_subtable_proc *proc, int proc_num,
 			      unsigned int max_entries);
 int acpi_table_parse_madt(enum acpi_madt_type id,
-- 
2.21.0

