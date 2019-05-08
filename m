Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86E86C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 476CC21019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 476CC21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E3C16B02BE; Wed,  8 May 2019 10:46:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B8806B02BF; Wed,  8 May 2019 10:46:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 233E16B02C0; Wed,  8 May 2019 10:46:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E0F7A6B02BE
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:18 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a90so11630904plc.7
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sFNXeoj5VSTs2wgVxlm7rC7QOxoLc6G2loYXKuB7a6o=;
        b=UGq2WBAlEbLmevJ4vGcIjUSSi3daouHaiU/WXzScWz5SXgaDrG/D03r9vxX+PSICuR
         CVMlln3Twl/TRGkMfPFBLqMTSFEXIJcPYnEujApAAzpsoSVrp4FFkG8BQF3NJjM/s6gT
         IDaaZgi/wLczVkaX1ywgm6OnzWRmgDBpsVLrxGVZaendiOAxYg6sZgq9jq7gvBrWrIW3
         11W4I4DXRhWGCquGOYcIzZsCywvvPjCeR4exb3eZBKasyvxe2lwwsUgwpd0U0g68lFtR
         lveeLJTaHfUHRDCMTIu7Oys7NlpUK6e2J15o05mOLlw4B7gaLHFx2/Rsw6Jz1iuChB02
         eplw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXV2FsNJrhzBxd1CO3pIak7wpMFg/GEUe9h6oEzztbjoMHEdMWm
	2/VYiyDA7hOz2YlzkEwfcPU2ig70TaB7Di6Dr8X5fITyzSbzGgyexciZI7vxte7+oEsIzzPDpkV
	jDiN927CbGk2kWunpqPcTURvBsAYWY+QujkHgAMxT5gvkarsszJLXa2smLT6p/GXJSA==
X-Received: by 2002:a63:231c:: with SMTP id j28mr47519921pgj.430.1557326778578;
        Wed, 08 May 2019 07:46:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwD8Q7N9zcTJCxIEIJ1GlfMp2DJjAE73wIme02iqXopfeMOQxdB1Aw7FuYFZJDQgPLE6r8E
X-Received: by 2002:a63:231c:: with SMTP id j28mr47509589pgj.430.1557326690426;
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326690; cv=none;
        d=google.com; s=arc-20160816;
        b=FuZtNcsxXJz06lxpW8oHSy6EOS7Erepe+al3znMgGh1zKOVR3n9zhBLN7v+xqH3rHP
         kANpXRxuA4dC/GHD6k5wGERwDcr9KVxURhuOLqs26Q6Sly7FuDiiBg9gaNuxPMXdk1Ft
         IJZmV7zfoIWDfhq80/Fa8ddIRDfQOl5liSCCpbIFPwD9fcfxexnlSGHlXnmz8DwczKKS
         ttCKPUqIyQAuAfhClfEu/q8wlC75+w8Vk4x1cpmxXHL2fEFrkLmc5HD7RXLBrAyMXrTs
         w7dxwrzbWo9XLZYk9xI1Hu68rCCDU0LvGYn55iM68NPjbKxoTWc/1LW+LbAlQgqeP7ye
         8tzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=sFNXeoj5VSTs2wgVxlm7rC7QOxoLc6G2loYXKuB7a6o=;
        b=PzYgfsGlU9nVCQkWVPWHFhJgeg00Wsq62y9fkpYR4zS5SFKRugQQ8rSlx9gO//tr5w
         dbVeaIjXgL+yjmMFpWoPQe5hqjUVptBOOFtX9FX8lVKvo1/gv+tB14TY+PBiSNsEVNDX
         ghiKbbGOiPyYDtuLTWsvn21hwnqC/Dflxra5E7I7X6XWG42O85VTkFiSsD5YB2Za6rVl
         Ucom4ky4zs1WBtwlx6av7M2glUKaNjpnhCipjCDZNk8cbQpIiRLvmgZneu2cZNuWk20K
         vFuhPBs5PTy7ntRc2J+YLB9bQI3gJIioyk7rLNzW8Pgv612cMReUK16Ns91WXBbff8JC
         IX7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d11si23177393pgj.84.2019.05.08.07.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:50 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga006.fm.intel.com with ESMTP; 08 May 2019 07:44:43 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 78815BD3; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
Subject: [PATCH, RFC 36/62] acpi/hmat: Evaluate topology presented in ACPI HMAT for MKTME
Date: Wed,  8 May 2019 17:43:56 +0300
Message-Id: <20190508144422.13171-37-kirill.shutemov@linux.intel.com>
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
index fe3ad4ca5bb3..82b270dfb785 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -1341,6 +1341,7 @@ acpi_platform_notify(struct device *dev, enum kobject_action action)
 
 #ifdef CONFIG_X86_INTEL_MKTME
 extern bool acpi_hmat_present(void);
+extern bool mktme_hmat_evaluate(void);
 #endif /* CONFIG_X86_INTEL_MKTME */
 
 #endif	/*_LINUX_ACPI_H*/
-- 
2.20.1

