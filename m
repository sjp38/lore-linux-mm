Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8073C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A58C0216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A58C0216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 961686B0293; Wed,  8 May 2019 10:44:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9133F6B0294; Wed,  8 May 2019 10:44:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 829316B0295; Wed,  8 May 2019 10:44:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45D956B0293
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:49 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d21so12791190pfr.3
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YUiV7ciEmu1VpZKDN9yq95Yz4mn5jz12GvAwo9oqPZY=;
        b=aad57X9zsG4C0iBrc0QkUol02Fju8R72EQvA32qkHLde9FpSMZg2CosAWeRyHCPUkk
         CxMRROo5yph7f4m9nOv9oxW3gTc+bZIsogCjDRoA0l2/WG7d7kCXwhc/ZoDfmyGLcZcI
         pHsF4rwRp+i4WmPdxFOAP5V5YubhqdkBy9OMAQLe11N5W01FI4yFUZGVr0p1DByrFJDD
         N17O0Btr3Ez1V28Jxa9z+hsuAW+fjmXE3WOTYMqu4rLxAsAq9FRC/AYssQ1yo6XBuNp5
         fjTxRAJj8FqYV5mxwjQlMU5g4BZw4EbMG0EVo7mvJNCUTt1RerycUkdcSyTkGTpJBTwA
         CY/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWfFr6cByronew0qHhNEDY5QiSemwXdrdjdbFRuFAtXuRzCOAxO
	TnmVJ0vU30151u5U5h4pV9xmZi9nbWsu8YSV3e4pPAuhk4jPN3Cp49ZNCuqSsZZZQq1ZxZFinys
	QYo5N0lLOFaeEiynbCX7GF0MWXnJz1njAUvoFqQcKVeG5WgTVNnZO2rQxxizhvZn2OA==
X-Received: by 2002:a65:4302:: with SMTP id j2mr46930832pgq.291.1557326688948;
        Wed, 08 May 2019 07:44:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6WYBbUaY24YHR8LOIMoGIAXX8OaS/h1LRNNmUCSD9VpYTAqTRO3PmT9jPmKAA8EMJ3Yl3
X-Received: by 2002:a65:4302:: with SMTP id j2mr46930712pgq.291.1557326687771;
        Wed, 08 May 2019 07:44:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326687; cv=none;
        d=google.com; s=arc-20160816;
        b=IkiI42OIerkZT423M0k46QGSg7hDTDqjB7z4VD+EfUFnq2Wmtop7xJZv09K/hdnwIL
         ytkRjNxcDUQq8LDSAulhvcRWhJDu+yJzUObSczGI/xmcINPrw9hR7B+oswA+JU/2pH0+
         JKxLSCs29Bh7O6QxTouBWhs26gcvwWn3DdkOArYSnMY3e6t9IkY1v9Aqsn4Do/yQwZDs
         +9ZAlq5QvGCxVFeqtN0s9lMR8MgaI27/JBDHqiMxfkdA2i3FVtcWak9TZIo9lh1kO9hE
         TMzolYEJ8/+MjVG3Ae97BpBHlL3nl1jgoceeNtaE4gcDtGqpObO8EgZdz5VymmJA3o+m
         oK2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=YUiV7ciEmu1VpZKDN9yq95Yz4mn5jz12GvAwo9oqPZY=;
        b=fmzG31o2/PiBqNIJ62FyX4Z5oUEhk7CLc74swv7A/fB/GbiPFp1urK+J565O3Ki7qX
         fH+LpFg+gQtgjBLGZUv4iECqQ671/B0Ob626ZA/Tu1+vh8mAvgZvoYEtqYTKRXRw+Luz
         kE2HBNVmV4HgbrMc56cNB05jM1H2FtTAYgkDb/SkE9GYr7LAm0mwqQssClfT3vbPkqvT
         cOIDc8FBg57GNFHIO5mhXfhtIzVoCATtrZhXF8uoCtw3acrRZNCVoywVkCT6Je1QXwKr
         Mn8XCAuCqOV/OB1LFdNzBOdDM4zeZ10wH/vko5pUg3AuQocwrNm2qoHoD6tWokOKjeca
         SWgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id s184si23372828pfs.275.2019.05.08.07.44.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:47 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga001.fm.intel.com with ESMTP; 08 May 2019 07:44:43 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 6B821BD1; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
Subject: [PATCH, RFC 35/62] keys/mktme: Require ACPI HMAT to register the MKTME Key Service
Date: Wed,  8 May 2019 17:43:55 +0300
Message-Id: <20190508144422.13171-36-kirill.shutemov@linux.intel.com>
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

The ACPI HMAT will be used by the MKTME key service to identify
topologies that support the safe programming of encryption keys.
Those decisions will happen at key creation time and during
hotplug events.

To enable this, we at least need to have the ACPI HMAT present
at init time. If it's not present, do not register the type.

If the HMAT is not present, failure looks like this:
[ ] MKTME: Registration failed. ACPI HMAT not present.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index bcd68850048f..f5fc6cccc81b 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -2,6 +2,7 @@
 
 /* Documentation/x86/mktme_keys.rst */
 
+#include <linux/acpi.h>
 #include <linux/cred.h>
 #include <linux/cpu.h>
 #include <linux/init.h>
@@ -490,6 +491,12 @@ static int __init init_mktme(void)
 	if (mktme_nr_keyids < 1)
 		return 0;
 
+	/* Require an ACPI HMAT to identify MKTME safe topologies */
+	if (!acpi_hmat_present()) {
+		pr_warn("MKTME: Registration failed. ACPI HMAT not present.\n");
+		return -EINVAL;
+	}
+
 	/* Mapping of Userspace Keys to Hardware KeyIDs */
 	if (mktme_map_alloc())
 		return -ENOMEM;
-- 
2.20.1

