Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BBE5C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AABE216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AABE216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 541F26B02B8; Wed,  8 May 2019 10:46:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51BD36B02BA; Wed,  8 May 2019 10:46:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E6306B02BB; Wed,  8 May 2019 10:46:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED6726B02B8
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:14 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t1so12766972pfa.10
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SWcujcOdjJ4n7cFeyFQDmfheevccd9AmduaPEsJQk94=;
        b=nB2RrcYcllDG6uEF9bBTv7ffhCBQigT1w46MIm3LqLIT4w/6lSfyyXeHPGvmO7eVze
         hiPsbMgGYhuhjU+9CCx06I53J2/N6gMUYykf5sD6PprSItsOIIDwrlysaXwzikaCiOEE
         14hnG5pUtQZwm4VUiCqC31xdFRFGEXx55EQQdrQZTue3WxVyrWvpiTgKvZVAo/WOFWTn
         uyu/uY7Mncp1KTqjnTCShOJbPEz27g/Xsu31mFNcADZzvfEV6TwsxMiTnIqDbVyK8Qq7
         YGyrq0aayl80NDIJuMa4ysqbGSBN7OIsbUlvgpoj+vG6To7V3P9ViWdPr2/71/WeM+y4
         L0rA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUhbfZ7IuTM/4ESxTlkpCF5SR92Uj77kVG/Sxgbv48N7x27Ew48
	tNAVUZ3RizbOpqpLJ/jXXTgZKz+vqvOpS98/1UdlB6GLHwNqeiBjMhW3F5lO+touIQ+o5Dl3C5/
	JWEuAPHeCA22wZKRKGnO/hxVR5ui06XFv89YVkfrmSkZE07JhQtrd5b73+CF53eW5yQ==
X-Received: by 2002:a62:d244:: with SMTP id c65mr48978738pfg.173.1557326774629;
        Wed, 08 May 2019 07:46:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUrb/LH30TxSBw6+bYVvZEYgsglB2JC4qm9O5sihWnZZ9byCF/FFss9+HwAebcVwtJ8lqY
X-Received: by 2002:a62:d244:: with SMTP id c65mr48968261pfg.173.1557326686337;
        Wed, 08 May 2019 07:44:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326686; cv=none;
        d=google.com; s=arc-20160816;
        b=sJoJm/K2w3bJ2I1Iw+d+xdINrvGH01O8jqmoVz9bSjinqNKUQbqipvd2g9PbUkyApr
         cEmxwGzB07TMIU6zCW3rpFVNm4Ik2gtmulsCY4zeLzngsm+jL6ocd7rpfdeerUCRXM8B
         FHHtuYPlkOF8rTeioBHg26vpsg59d7b14bc1U/Z2X2p1WMCdsi0k7jBYy3Obe7YnssMT
         zGjAqSUqYoheH3fVtWbLacysmAKJQbF5ERhWMm51rsHjmW/W2/NskZUj/CXJRGuQ8X5s
         X+xk7peR2CVrIxxmEezJKuv/H+0NSCFItr9LPUBGOEIDZhi9o23Hzn5jIeDnDwTyG3ka
         G/PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=SWcujcOdjJ4n7cFeyFQDmfheevccd9AmduaPEsJQk94=;
        b=GBfzGpfc82Qt2FIfQyCZUBUC3Jg03IUW7/Fx4R1fDH3zjq+JT5Ck3MP1fnszST6lbK
         VoeayH8eeLc5p1y5QhoQZYcd32qlxHI3CAnyUzf03ESoak0Syy4tD5PpzA7PhSrSjHnU
         ay+2tnpRKS/1oS5xDzjtovfwBlPbSqc2fuhJrEgk2kqsjTv3z8orOfkYdFP7eqX3lzsW
         fbbG6exW/2bhX9IA8Gjqvu2qNc8hLzbp1YqfxKo57jTGRdw+FfnrLN2GJzpVGTzsPez3
         3hLWd9LpY4H945iTOoi5ehavk7MhExYqy93om4cvuLWI/r9LIgyGqMZPKtpLbS8t47/a
         lblQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 184si24250871pfg.32.2019.05.08.07.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:46 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga005.jf.intel.com with ESMTP; 08 May 2019 07:44:41 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 51199B86; Wed,  8 May 2019 17:44:30 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
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
Subject: [PATCH, RFC 33/62] acpi: Remove __init from acpi table parsing functions
Date: Wed,  8 May 2019 17:43:53 +0300
Message-Id: <20190508144422.13171-34-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alison Schofield <alison.schofield@intel.com>

ACPI table parsing functions are useful outside of init time.

For example, the MKTME (Multi-Key Total Memory Encryption) key
service will evaluate the ACPI HMAT table when the first key
creation request occurs.  This will happen after init time.

Additionally, the table parsing functions can be used when
_HMA objects are evaluated at runtime. The _HMA object provides
a completely new HMAT, overriding the existing table. The table
parsing functions will come in handy for those events.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/acpi/tables.c | 10 +++++-----
 include/linux/acpi.h  |  4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 3d0da38f94c6..35646b0fa7eb 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -47,7 +47,7 @@ static char *mps_inti_flags_trigger[] = { "dfl", "edge", "res", "level" };
 
 static struct acpi_table_desc initial_tables[ACPI_MAX_TABLES] __initdata;
 
-static int acpi_apic_instance __initdata;
+static int acpi_apic_instance;
 
 enum acpi_subtable_type {
 	ACPI_SUBTABLE_COMMON,
@@ -63,7 +63,7 @@ struct acpi_subtable_entry {
  * Disable table checksum verification for the early stage due to the size
  * limitation of the current x86 early mapping implementation.
  */
-static bool acpi_verify_table_checksum __initdata = false;
+static bool acpi_verify_table_checksum = false;
 
 void acpi_table_print_madt_entry(struct acpi_subtable_header *header)
 {
@@ -294,7 +294,7 @@ acpi_get_subtable_type(char *id)
  * On success returns sum of all matching entries for all proc handlers.
  * Otherwise, -ENODEV or -EINVAL is returned.
  */
-static int __init
+static int
 acpi_parse_entries_array(char *id, unsigned long table_size,
 		struct acpi_table_header *table_header,
 		struct acpi_subtable_proc *proc, int proc_num,
@@ -370,7 +370,7 @@ acpi_parse_entries_array(char *id, unsigned long table_size,
 	return errs ? -EINVAL : count;
 }
 
-int __init
+int
 acpi_table_parse_entries_array(char *id,
 			 unsigned long table_size,
 			 struct acpi_subtable_proc *proc, int proc_num,
@@ -402,7 +402,7 @@ acpi_table_parse_entries_array(char *id,
 	return count;
 }
 
-int __init
+int
 acpi_table_parse_entries(char *id,
 			unsigned long table_size,
 			int entry_id,
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 7c7515b0767e..75078fc9b6b3 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -240,11 +240,11 @@ int acpi_numa_init (void);
 
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
2.20.1

