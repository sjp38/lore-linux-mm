Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14380C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDA47216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDA47216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDDFA6B02C3; Wed,  8 May 2019 10:46:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8F9C6B02C4; Wed,  8 May 2019 10:46:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C93EF6B02C5; Wed,  8 May 2019 10:46:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 880086B02C3
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 33so12763026pgv.17
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oOVtF7P9+CwpY068vQsyDP170eNCHboFWW4/MZfPk2k=;
        b=DDkUJ7SNxQieQ4qy0s9Wu3TXBCeAxFeOfMM+8L7AJ5XRutvJM3omJ9fNW36hkd8sD/
         JHVrYBUxlf1fhvGhh83j6pYcRBKm5/RvYZo4n5YfBf+24cauTE/6n0jg9IOoH6bQxPg5
         4HJh2UQey6DO/ubFuXbdmpYm/7G/Q0Kb5zHp5jGrkiM2K0A0PlS8z/8YQevuBj8+DeuN
         I+djqZn0C//eAkQBGpWzoUcRvNi6oj8HdXdmeoF74nF3sR+QTUUPCAJpUVrjxehawGSW
         EP9bmME6SXoNOWK5fU88A81litJCJbRexo72C298WpCaxKSwyii++P+N2FI9Mp7F86+O
         v6mg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWrPyDwvr3zGX44SEPN3uXx8swM/CQFxWkEUUffrWf4Ny51BxSJ
	9R8dK4KOgaKUmnBh/ZcEuexmPLTzKegRCxqen6lk+VIs+XyAxO0TGXZDSPifoNDGst9HAkmSKD2
	E02N1cNeE44FlhXz2Vt8CamaQ/1YvL7FYL8Z9QL37OOcmqaW2SQe6prGhCjPAEDcNhA==
X-Received: by 2002:a17:902:8507:: with SMTP id bj7mr26466567plb.214.1557326782220;
        Wed, 08 May 2019 07:46:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuHyLDJFsPdBKYUsSizIznaUsnKNlFjRADN0qJ1UWU5NcZs8kYOlip11qYO/oIB09V+9eh
X-Received: by 2002:a17:902:8507:: with SMTP id bj7mr26456281plb.214.1557326694298;
        Wed, 08 May 2019 07:44:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326694; cv=none;
        d=google.com; s=arc-20160816;
        b=eGFBNyWOqpgdobXFY0dx4y3kPuZh/ycPnBKpTLzaHHM/S8BJ6lSoMrQPfDjj3thW2l
         x3rBmAxr0MYo555Gi4JWxu7lNjiW95mkF8As36shiXCnRSvTOZ7c4TdZSZ4+o4ZF+UWx
         WLLipuvyC/N9NmgMrp+8OlFTzB4c+tZUcsCR8pJ+RFTNIABGK4vvka/SZBb6NlE9YTjE
         nmYTSo5jBtw29mRW4vjC3N2IlTRaFJ9kDecK9SQpKYy6XJ5pGkq7tqeGjkJKvO7U9O21
         qmD/h2Uf/pX7vBprlK1w1Z8e6cXXCQnjN7jIQKlPcNnjmp+mlprtHOgQS5RhuC7uMf5U
         ePTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=oOVtF7P9+CwpY068vQsyDP170eNCHboFWW4/MZfPk2k=;
        b=KcJ4u1/SarZK07SZwELahqw5O2k8E1FtD1gBI2rn26T3yil6L5OeS+GpmlC4+u4xCw
         piBEwxrZwlnD2SlNLu0GlHS2U7mry+FHoIltVr2+jgULsVD8XsDTx9cVQDyboO3f7/cJ
         /GYAjlFAMbSQdNR+xPOMs74LK3Y6LlYV9PLtNvQPLpvwanvW7jQlNjefbwclPTdWd8oc
         MAiiN0T5NsEbGbuvoxifTrH7YQeukZeAdcqrxYLbjSnYOBpHkD+c2s6wSgO3KtZ1WpTa
         s8Ck6TXWMa/+N/uAKO0OmLCRowPktaBUH2PV55bhrWsJm3MjJamJ/lAqtCdPsyzCD01C
         6Zcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t16si6593003plm.65.2019.05.08.07.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:54 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga005.fm.intel.com with ESMTP; 08 May 2019 07:44:49 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id CA21811F7; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
Subject: [PATCH, RFC 62/62] x86/mktme: Demonstration program using the MKTME APIs
Date: Wed,  8 May 2019 17:44:22 +0300
Message-Id: <20190508144422.13171-63-kirill.shutemov@linux.intel.com>
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

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/x86/mktme/index.rst      |  1 +
 Documentation/x86/mktme/mktme_demo.rst | 53 ++++++++++++++++++++++++++
 2 files changed, 54 insertions(+)
 create mode 100644 Documentation/x86/mktme/mktme_demo.rst

diff --git a/Documentation/x86/mktme/index.rst b/Documentation/x86/mktme/index.rst
index ca3c76adc596..3af322d13225 100644
--- a/Documentation/x86/mktme/index.rst
+++ b/Documentation/x86/mktme/index.rst
@@ -10,3 +10,4 @@ Multi-Key Total Memory Encryption (MKTME)
    mktme_configuration
    mktme_keys
    mktme_encrypt
+   mktme_demo
diff --git a/Documentation/x86/mktme/mktme_demo.rst b/Documentation/x86/mktme/mktme_demo.rst
new file mode 100644
index 000000000000..49377ad648e7
--- /dev/null
+++ b/Documentation/x86/mktme/mktme_demo.rst
@@ -0,0 +1,53 @@
+Demonstration Program using MKTME API's
+=======================================
+
+/* Compile with the keyutils library: cc -o mdemo mdemo.c -lkeyutils */
+
+#include <sys/mman.h>
+#include <sys/syscall.h>
+#include <sys/types.h>
+#include <keyutils.h>
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+
+#define PAGE_SIZE sysconf(_SC_PAGE_SIZE)
+#define sys_encrypt_mprotect 428
+
+void main(void)
+{
+	char *options_CPU = "algorithm=aes-xts-128 type=cpu";
+	long size = PAGE_SIZE;
+        key_serial_t key;
+	void *ptra;
+	int ret;
+
+        /* Allocate an MKTME Key */
+	key = add_key("mktme", "testkey", options_CPU, strlen(options_CPU),
+                      KEY_SPEC_THREAD_KEYRING);
+
+	if (key == -1) {
+		printf("addkey FAILED\n");
+		return;
+	}
+        /* Map a page of ANONYMOUS memory */
+	ptra = mmap(NULL, size, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+	if (!ptra) {
+		printf("failed to mmap");
+		goto inval_key;
+	}
+        /* Encrypt that page of memory with the MKTME Key */
+	ret = syscall(sys_encrypt_mprotect, ptra, size, PROT_NONE, key);
+	if (ret)
+		printf("mprotect error [%d]\n", ret);
+
+        /* Enjoy that page of encrypted memory */
+
+        /* Free the memory */
+	ret = munmap(ptra, size);
+
+inval_key:
+        /* Free the Key */
+	if (keyctl(KEYCTL_INVALIDATE, key) == -1)
+		printf("invalidate failed on key [%d]\n", key);
+}
-- 
2.20.1

