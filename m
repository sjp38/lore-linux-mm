Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18BE8C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D94E9216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D94E9216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6F136B02B1; Wed,  8 May 2019 10:46:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C47B06B02B2; Wed,  8 May 2019 10:46:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0C8F6B02B3; Wed,  8 May 2019 10:46:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 718C16B02B1
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:03 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 14so12806882pgo.14
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bMhGYPvhch86dLFBTwNjwlU0ss5Zx9fxnvAxoB5kLBo=;
        b=YpD+mZNHDvFUTH+1iItCAXQh8135ZqsOldZLmktKWnvf8nNEIuYd5x7QJSiXOikTn5
         jhet9L7TfaX9cMN0DdtfKWIfu8tMhNGmIUQxe+qrn+WTVEQ8SIQiGqTfBxcOXWFv6bfb
         5dNdD1vVKQjVgk8f3kMHZrVT12LtwxRJHAZx77WiWpklQbJ2LeKHRoRCUVakbPop1ufN
         vhwlniX5LTxFdDIT5YdacVH3pio3taUllKvHlheye8uJRPbaMtQbFUE04eFE+lUJ6Aba
         eAfcxjD3h1Hu0wjEYWivl1iAbiV01j5PGcVsVJlB7gohJ5CwxgfdyUHBMPdiNtYeggds
         Ha6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUS3F5RlI+oblWTfZb/xNoIUyqyw9ClFAWo2nXQaE+vPttxg28f
	k7IiDNfTsJE1aZCBUjxa0usnmsgGNCQh8ZcqS7TFsPBBgxg36fxF2vv9RgIFI9ky0f1Ualkv81i
	gswZVmWHOyjnvg2ipNWskufKJPQK9N8rbItITgiR2eGJ7FVLoh770RUNv3T2UHTVikg==
X-Received: by 2002:a17:902:8bc3:: with SMTP id r3mr48068991plo.53.1557326763136;
        Wed, 08 May 2019 07:46:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyD/PVE1XkbbCIXsvGMTCfi/BT/6a1bLreKgZt7qGLqZ8/aKUJ0BkgOPL86XC1QdRSgWSK
X-Received: by 2002:a17:902:8bc3:: with SMTP id r3mr48060188plo.53.1557326686436;
        Wed, 08 May 2019 07:44:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326686; cv=none;
        d=google.com; s=arc-20160816;
        b=ku8xXzvlsFsDc62nehUTj7iUT7Xer/m/7n+DRR9eKx18zGfVYOVVnAqiDyU1e6pRZR
         Do45LI+vJaw6ZdZuY1PPl31S547tFq3iquTvhBzprxC+fbDW13JKCRDq3439IO+lTuWU
         lSPnlBWSm6uRUopQrGle1ENePwLDLd9tDaBatIeE6eXLwNG8r3sCow3OLKezdfQ8gyDW
         WTuoX/e+tSKaX/bGXcEGk2DrzAqlR7fN5jCxT+kPt0Sf328p6XZSGwMtxOmM8ewyQg44
         5R6o6PTdKXn9mcbmNl3SM9M4jrRpXJqiLISNqexl3tvIe0r0gVXVVluqns9JOmA8WUlE
         CbiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=bMhGYPvhch86dLFBTwNjwlU0ss5Zx9fxnvAxoB5kLBo=;
        b=Yo+Js1Yq0rKrP/ssXLfCmi4SBneT64RHuD42IEt6tcviBhsXsMApCybuuk1crtmkIw
         P/4mFmXe/ROtXL0gkccvKtG26Cvg9cqQiIy4/vS5rm2yVQ499L2VS72yKAfeyxYOMr+v
         x2zVx8wUYWdLhyS8u8zCaFOExXQAQo0mWPQ0SU2HqhqAMKqwajFSz/3qPtS0YJNLoMBa
         NMLFubzPcCk7Pbj1BbQCmENklE9I7XlkrppYrs6MNKIeX8BcQr8da/PsmmHpS/tSMRxE
         DUl19VkITln0FnEpFnUBNnqp0EMF9pK4xCr8gHgAdDXzeryJFnenfxIGifak9byhFYfq
         2MaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id s184si23372828pfs.275.2019.05.08.07.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:46 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga007.jf.intel.com with ESMTP; 08 May 2019 07:44:41 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 5EB75BC1; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
Subject: [PATCH, RFC 34/62] acpi/hmat: Determine existence of an ACPI HMAT
Date: Wed,  8 May 2019 17:43:54 +0300
Message-Id: <20190508144422.13171-35-kirill.shutemov@linux.intel.com>
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
index 75078fc9b6b3..fe3ad4ca5bb3 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -1339,4 +1339,8 @@ acpi_platform_notify(struct device *dev, enum kobject_action action)
 }
 #endif
 
+#ifdef CONFIG_X86_INTEL_MKTME
+extern bool acpi_hmat_present(void);
+#endif /* CONFIG_X86_INTEL_MKTME */
+
 #endif	/*_LINUX_ACPI_H*/
-- 
2.20.1

