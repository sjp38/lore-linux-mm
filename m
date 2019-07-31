Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB1DDC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:23:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A186208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:23:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="DRp4/04Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A186208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 191498E0039; Wed, 31 Jul 2019 11:23:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11B4D8E0007; Wed, 31 Jul 2019 11:23:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFD918E0039; Wed, 31 Jul 2019 11:23:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0028E0007
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:23:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so42604852edc.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rpVydprU+qUIbG2ieS0/pcejmTH1ILSgd/PE5xIU2l8=;
        b=js5w7eKl6OsGlSiXKse9YDiaGqDt+Y82AH2eO+ByuKwduXr8BsQGgJBi5AqzTi0FJE
         7ug4knqsOPsoU7/ggtJAqN6Ght8UrElGhedi/TLg8HspKlvOgyndKv4MzSOV8LOj5OC/
         JnbFXLt2OJp0OiYWujGKxSXBbsxJuCCQIjktK+ufN8+oPxGALUVPzWOMJQyUzzMzsgCD
         Y0mLQkFAxNQRUTT6MvJOZgKUshlJ7YZ6E0muc6dbQQWNU3i1FsK8blZIdQRvySZcMgF+
         fQk+F2XDg0BZYNZXIRkBnJczvc+2dVAS13f56jN7korAbD+9rMXs4AS3rckb5tYupZx4
         eyMg==
X-Gm-Message-State: APjAAAVeBMSTncQl0CqSxOI1ujxPVpwFlYFTVg6wE5keW2ReMEGfXbE5
	0arstHiy63byW+cTYkHN0BHxqLKNmWXQAIjJmERa0fyhQMScKJ4Wymx+Kd3vrkGICG8PU+IUr3U
	e/z/lsh1bTzIdsBPP3GJzqj2X73M/ZMKxdKcEGXCaAPQ2iGQPAJMc4659/ERpjhU=
X-Received: by 2002:a17:906:499a:: with SMTP id p26mr31771441eju.308.1564586629195;
        Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
X-Received: by 2002:a17:906:499a:: with SMTP id p26mr31771362eju.308.1564586627967;
        Wed, 31 Jul 2019 08:23:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586627; cv=none;
        d=google.com; s=arc-20160816;
        b=vhqrjVfBpYj3Rz2Hh+fmOufRfoZ+Wrxies0PSrMqH95rrl+IHdYBLQw2R5XRRjGKvH
         fJeHg1Pad6vKrHWio37xqH/LxsXFyi0VQhN2NEvUU+KHgEy8QcrFMgPfRXr483nQkwkW
         VEdAV3+snVZdAupddVrZYvxMTq3s0nSJ5W6MinilT9+ywe6BqEytNlm7xEvnYEDvEMTC
         2kH0nhfGd6VAOK7Q3vbR7AX7sStrQ6HjEMMwuwgy9QTLffJJda+o9W/UzoW2VhmvYUcC
         czznlpRoSVnlzRHgO0a6NX2c1IHEeHg/6hMVC9wfGl+zxVPpENALPylNIVn+RwcXUzro
         1fpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rpVydprU+qUIbG2ieS0/pcejmTH1ILSgd/PE5xIU2l8=;
        b=MBYImTpk5MMRzt7Nljy/3aUPldtWFejqn6czHbIjO3ICNFiOTMNxbueAY5Jd3NLlOb
         E78DXQIuIs522nAtcyKevRKjHs+DrlCpjgXBDueoQFrOLY4xq3ViOnFHD5Mqtmp8rG4+
         A3K8u34uNv7kTp8VY7Q1oTi1QabwTVZxo3n+Or82OGxoCEXEOEEbOQC79WTpJ8NbUIIg
         W8SMX+ai5MMa4LM2fGil94tV3656WSGdDO4zs6A9HuQb/CrI1GhJh7p5xmhZ6qlAFNVA
         q+Mmx+FnMTFxqdh8w4HHYhNVrDv6/rcDSw/ZT+0cY72tU+OUZllQfobaNQyvHH6XEo6/
         GMHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="DRp4/04Q";
       spf=neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g11sor13547196edy.18.2019.07.31.08.23.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:23:47 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="DRp4/04Q";
       spf=neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rpVydprU+qUIbG2ieS0/pcejmTH1ILSgd/PE5xIU2l8=;
        b=DRp4/04Ql9tuwZ8HmklcrVGbpbwpqyiHWrb5OFmDW/SEC8peDq2WPBaUHFkAudB5fO
         O6QRunFSo/ysHy81uSqyDDbaDB0RbNas5DoSFJjERVndASSmEQlNkxI6m4UzvLb1lYXe
         HR9PxFKm/WpkDGRuHh7/II3kWjLslUMYjW15KfsW1uUXxZKw3qH1ykdFZqetYNR65uFr
         gcHNHUE6tyTdsEhVT4TE8EFJvr35k771sHCQxS/OJ1ZA0dTfkaCGA+sR1YMCZ/ySG35J
         zgO0k7b/GKJH49Q3m+NOFpVJ9izt7DqzZczYOnuYmoEesdA/OGp8B5vhT4m926rqes+k
         RWuQ==
X-Google-Smtp-Source: APXvYqzHNAWdNlgTeKpfoNbFrJilyAoYtl9yAfdpOnAx37mkMd2b2DlC485Nke0u/zSmR8xGQJj0mw==
X-Received: by 2002:aa7:ca45:: with SMTP id j5mr106898585edt.217.1564586627658;
        Wed, 31 Jul 2019 08:23:47 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id j12sm12429043ejd.30.2019.07.31.08.23.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:23:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 957D31048AB; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 59/59] x86/mktme: Demonstration program using the MKTME APIs
Date: Wed, 31 Jul 2019 18:08:13 +0300
Message-Id: <20190731150813.26289-60-kirill.shutemov@linux.intel.com>
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
index 000000000000..5af78617f887
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
+#define sys_encrypt_mprotect 434
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
2.21.0

