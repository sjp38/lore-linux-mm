Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78C6FC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45301216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45301216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D4C56B02AA; Wed,  8 May 2019 10:44:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AC006B02AC; Wed,  8 May 2019 10:44:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19CA56B02AE; Wed,  8 May 2019 10:44:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D51006B02AA
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:56 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 14so12804865pgo.14
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0Q0yXtZW5uGIkggk/JKR2b6AmJ5y5De3E5tHqrEiJuk=;
        b=n1wxyoN/V4OARiw2x4Wdaaivf1AAYZnmFhXopNXu6LiKHOoqjqW6GmBOlK8DfUvee2
         EuGcJvapznX+m622SliCqsMRVMbICXg0e/IXF3AJuGYAsfja+TD4n8W9L3gZCePpLTQe
         9c5FL/0OMygXNj5nRzO3WBJ+kI3lXCZs4mdndzOvGW+2/MmrIWqoLnfZVmQVjBTpHBnu
         lKHwuozk9rkqNrD7YKMBdF3wgtA5C+xXuxRTjcn+irP6zbdUe4SXYfQONzHRg/N9XtRH
         cJ+5099U6rQUuq4g56uV36pTf0+pflfdXS6gEiQL/Zf2DuRtItyGxNZsm716yh/19scD
         BtvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXLfwHfnO658ocZr0CNItJ87ewVdg1wX1CmeektQTBAIy8OaTwB
	5f+d2t3bk5oHr+zUmsX/s13a2UfAQQLVjpmYLeBVz6RGA1vq8cfB6pjriEBO3+7rlRPQWxUrqOy
	k9YBESggAcjFi36J34SnmXHIK1qAXiBq06nmDGGKUkzQlZcdiVDQ1A/+3IA5TP2Ga1w==
X-Received: by 2002:a63:4621:: with SMTP id t33mr44541403pga.246.1557326696511;
        Wed, 08 May 2019 07:44:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIDkgBOrYtoDrQiRYnqj3u4WG0jXfFIsWKf/lvncoY9kziqooct/HZ7chOIUWDDybZJTsp
X-Received: by 2002:a63:4621:: with SMTP id t33mr44541259pga.246.1557326695210;
        Wed, 08 May 2019 07:44:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326695; cv=none;
        d=google.com; s=arc-20160816;
        b=fHdPTUfHdAFY4e8GWiKfVftqBd97dp1tvJMdxezlm5UZ/ZUBgTuFoYQs4EJw8FhRJe
         RpDp/Bh80SnSFjWDRyBPcufE5RFqa4UwV8xcz5FD8kftBgZTvGcWXSYHWMwNWCvYVX4M
         aFQ/Y1xLd0lBNfVbT8nMab2WeaUq9IisrGJo7/FIe+79HI/gVapfZWUZNSPPMFDXITkF
         8fDkiBScLWSrhytcIhk6J3Fi5cmnI+fQDZswqatyluyxMLTIKVNtePdtJuX+lNDep+3/
         1pFJ7pyHMsaKDH2qGn28b2LhDpXvC8DHBLbK0n17o6pYWEas2fcnCPkgiWirEZMPZH7D
         EAVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0Q0yXtZW5uGIkggk/JKR2b6AmJ5y5De3E5tHqrEiJuk=;
        b=CpR7f3z9xuyN/VrRGsKo82DFhqNoRbWPVX+VzvMO1FEniWVEE1tkaTSYlWHwdyppV9
         4AxBKhjKrzNF4bhSFHb6Ca5uZtA5qFLGhSj2MprZGfwznfsb1OjnCg7MkW9qg+pxef72
         J9ieZWd9bfDABZ5TVENJ9WL6bAevrL6IFXaoSX/+KpB324Pl9RizHTI+v/EGVdSeNGRJ
         fTSfhCVhvXaDDkh+JmcORb3RFiSaEj4cOqJmDNiSJ2I/u/KU9xj89v28E+5ispgxp9iQ
         Tgx+gPP6QREYTONdxkmFgYdh7u3AHzozvvlwnUCpagejrm16VSXGYbOEMbJohhYQOZGT
         mtlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t16si6593003plm.65.2019.05.08.07.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:54 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga006.jf.intel.com with ESMTP; 08 May 2019 07:44:49 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id BCB7F11CF; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
Subject: [PATCH, RFC 61/62] x86/mktme: Document the MKTME API for anonymous memory encryption
Date: Wed,  8 May 2019 17:44:21 +0300
Message-Id: <20190508144422.13171-62-kirill.shutemov@linux.intel.com>
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
 Documentation/x86/mktme/index.rst         |  1 +
 Documentation/x86/mktme/mktme_encrypt.rst | 57 +++++++++++++++++++++++
 2 files changed, 58 insertions(+)
 create mode 100644 Documentation/x86/mktme/mktme_encrypt.rst

diff --git a/Documentation/x86/mktme/index.rst b/Documentation/x86/mktme/index.rst
index 8cf2b7d62091..ca3c76adc596 100644
--- a/Documentation/x86/mktme/index.rst
+++ b/Documentation/x86/mktme/index.rst
@@ -9,3 +9,4 @@ Multi-Key Total Memory Encryption (MKTME)
    mktme_mitigations
    mktme_configuration
    mktme_keys
+   mktme_encrypt
diff --git a/Documentation/x86/mktme/mktme_encrypt.rst b/Documentation/x86/mktme/mktme_encrypt.rst
new file mode 100644
index 000000000000..5cdffabc610f
--- /dev/null
+++ b/Documentation/x86/mktme/mktme_encrypt.rst
@@ -0,0 +1,57 @@
+MKTME API: system call encrypt_mprotect()
+=========================================
+
+Synopsis
+--------
+int encrypt_mprotect(void \*addr, size_t len, int prot, key_serial_t serial);
+
+Where *key_serial_t serial* is the serial number of a key allocated
+using the MKTME Key Service.
+
+Description
+-----------
+    encrypt_mprotect() encrypts the memory pages containing any part
+    of the address range in the interval specified by addr and len.
+
+    encrypt_mprotect() supports the legacy mprotect() behavior plus
+    the enabling of memory encryption. That means that in addition
+    to encrypting the memory, the protection flags will be updated
+    as requested in the call.
+
+    The *addr* and *len* must be aligned to a page boundary.
+
+    The caller must have *KEY_NEED_VIEW* permission on the key.
+
+    The range of memory that is to be protected must be mapped as
+    *ANONYMOUS*.
+
+Errors
+------
+    In addition to the Errors returned from legacy mprotect()
+    encrypt_mprotect will return:
+
+    ENOKEY *serial* parameter does not represent a valid key.
+
+    EINVAL *len* parameter is not page aligned.
+
+    EACCES Caller does not have *KEY_NEED_VIEW* permission on the key.
+
+EXAMPLE
+--------
+  Allocate an MKTME Key::
+        serial = add_key("mktme", "name", "type=cpu algorithm=aes-xts-128" @u
+
+  Map ANONYMOUS memory::
+        ptr = mmap(NULL, size, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+
+  Protect memory::
+        ret = syscall(SYS_encrypt_mprotect, ptr, size, PROT_READ|PROT_WRITE,
+                      serial);
+
+  Use the encrypted memory
+
+  Free memory::
+        ret = munmap(ptr, size);
+
+  Free the key resource::
+        ret = keyctl(KEYCTL_INVALIDATE, serial);
-- 
2.20.1

