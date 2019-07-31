Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68DFFC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 218E320693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="YaTXMBHe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 218E320693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A1B28E0031; Wed, 31 Jul 2019 11:13:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67A948E002A; Wed, 31 Jul 2019 11:13:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5691A8E0031; Wed, 31 Jul 2019 11:13:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 048058E002A
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so42616638eda.9
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=giiClMAwHghspubxRJeU98UBj4kcy5uaSNNQ5yHBQr8=;
        b=ieAcn8qbfzxAraI4scSI58G3RxLYDBSQdGbauDhFUyenuxYwAsIjvRnBHPqwsl8xso
         OermEUaiSvsehFGXJdgDuDQfYgBCaVla5gqqHiJUjdkh/LCuCf7Dm7nNHwJNXEtXoKL2
         rDsDunjOh17QLxUi/TjCOMeaZw+lUWMKRJk+kF7tzqDlPfEJWW3qHPIEHfBwLiqoohVb
         LxvkDC9BWpNaeDHctRqienJ3ZZON169HhpzcDxE8YWSfGB2HYCbqADwwLXyaucskfnn3
         A2UlcVynuYn0BmIw5FKPE6k370X2lCDyVvbL4zUfxlDg8rerc3TqZ/VOURKFc0dWltMK
         2whw==
X-Gm-Message-State: APjAAAWe4ME8xahgEdlg4J9oA95Qxi+BNtyA3nArBjuUY4YzYSjSGZLm
	ddmbVTcA0KR5KCpxNhCq3KYYCeGAUzxhkCmt7x5AI9IyPIzPOCf80vFpLmstadqgbYhb5yKuIbC
	k+iA0lslTltDIYzgeGUmux2GaoUnxDGA4hy/mtELXtSiFv6nt44V8ieUpr9Qd+l8=
X-Received: by 2002:aa7:d68e:: with SMTP id d14mr107613220edr.253.1564586038604;
        Wed, 31 Jul 2019 08:13:58 -0700 (PDT)
X-Received: by 2002:aa7:d68e:: with SMTP id d14mr107613073edr.253.1564586037216;
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586037; cv=none;
        d=google.com; s=arc-20160816;
        b=ekcsyRrei/7+OtSJ56Bb7aeEkD9W+qWo5bH1wNt1iu/FY4/ARBi+uJejaflrkVCVLc
         PqaluCaewT4SSGWEYCAWuEp1NuklduI/wyMBQylztlVlD4xQWSWXLzHoqm80xp/jkM41
         mqMvdZbkA8DWG0mKgcP8PHhYKOU/sKQmhBzuydR2AUYD2mA9gbO9c3kQsy8QhRnx6LXy
         Jnw3lXkK4P+EGhCeu7QxWNBls75eTEbHLYlGAckXqQK8uIHBFm5EO7h0N8qVgXn/1HfX
         g1IQbT4RFZzQzOWQFUn3izBo9zOsvrt5Izmv6aTwi8wKooXTqoKtm/VXiK8KmAqJuVPs
         Khng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=giiClMAwHghspubxRJeU98UBj4kcy5uaSNNQ5yHBQr8=;
        b=uDZEMlvH0LsYGMjXeMl4oEnf1zWXt0UYd7w2kT5rQ3Oqjy693HzVA+sIp95BJwHt+L
         3l+8wi9kWFDUPA5BwlwiSldXtcJfDDx8h4jYMW4QQrU9iBDeNYdXqhVZZhC1Z7GgE20+
         AD5sbwV65GsPye3MdufHI0kXf0Y5jdxQe9QsaUcP/+F8gHzH7x+6TpUuBQSItZh8blXG
         DI95udcUpVoGzMvmApdGIZjbijT31C8siovh3YkQkLSoKJZsM9k6RnK9kMHio5JHh/LR
         MWsVxFnqt9wDYZvAdbY9UVUaKlQwYEQSwHc9RU+pJF4Z0zRf52p4+OL7/3Qr/NMYytAH
         vu+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=YaTXMBHe;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l33sor52320983edd.23.2019.07.31.08.13.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=YaTXMBHe;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=giiClMAwHghspubxRJeU98UBj4kcy5uaSNNQ5yHBQr8=;
        b=YaTXMBHevd+rhxg7oKsHgnNx749IFnPZBGV8uL7sZwZst8GkM7+TgJ5hOEwl+8ch77
         0SnQ660ccq3nonm+oPVfiPClF1RSRdsFcsOmiSCMAee/860JmulRtpJu6ZVUPIXxPpab
         A4HPUmoMK+oL/ZYU5z/0aKIN4ZyJj82QmP1VUkYEBl9uw4vslQvBcp1bM5ghPUhjzxVC
         giBVV/0crRxnqKUVAJjYi7W4wag0HivWwFFhHGvLdDIRmm1PDwxpL1ZVySWrGgKoEpQY
         GhlGRvNmW51GC9GcIML/xNJIoQeLdRe0qiR4tweLB/NiOTOi4OWFj5nMUqbAYuKnK/j8
         MnLQ==
X-Google-Smtp-Source: APXvYqwa7uk1eoCfkAn/mJHFtQFBKd5911qUgdeykZm3YPTTj3MkDFh75r+Wsq0y3PI0U1ZEMWspDg==
X-Received: by 2002:aa7:dd09:: with SMTP id i9mr109849959edv.193.1564586036906;
        Wed, 31 Jul 2019 08:13:56 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id t13sm17047248edd.13.2019.07.31.08.13.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 8EA5E1048AA; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 58/59] x86/mktme: Document the MKTME API for anonymous memory encryption
Date: Wed, 31 Jul 2019 18:08:12 +0300
Message-Id: <20190731150813.26289-59-kirill.shutemov@linux.intel.com>
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
 Documentation/x86/mktme/index.rst         |  1 +
 Documentation/x86/mktme/mktme_encrypt.rst | 56 +++++++++++++++++++++++
 2 files changed, 57 insertions(+)
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
index 000000000000..6dc8ae11f1cb
--- /dev/null
+++ b/Documentation/x86/mktme/mktme_encrypt.rst
@@ -0,0 +1,56 @@
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
+    The memory that is to be protected must be mapped *ANONYMOUS*.
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
2.21.0

