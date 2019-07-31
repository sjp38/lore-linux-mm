Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11D75C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE3AE20693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="vHCm2eeu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE3AE20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87C5E8E002F; Wed, 31 Jul 2019 11:13:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84E608E002A; Wed, 31 Jul 2019 11:13:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73F878E002F; Wed, 31 Jul 2019 11:13:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 249B98E002A
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f3so42574641edx.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WTAAjTsK3+3w7eSPHsyJf/zyVQM+N+66EXtK8GvqGh0=;
        b=gvG+y23g7/zJLiXoE7DV96v9fI+xH8UjoofHxyQ2nIzVSyiiSCMTR24wNjfiqe/2dH
         mo3kNc59qjNzv+ELlBtjH4tkFJcdOJvf3C20DaIWuivpmgDo0ZBejJ+OOGwrJVvJ+id/
         r1H/XmBv4pkP4g19LYrJq5k3urkZ9xGLOSbZlaPJeSK69k2FmzsIumkJl6o9jm8BsE1c
         0qXKCqSH6m67oqq8QDFRyjznglLjYAMnul7N0KiwtJYgZCYP5eY/DkRKHZb0NUwWyz1j
         VhWdaii9jIl+3X3wQZMSvK7HCIhllgutmYomWkfFlarqljuD7VIHZFG8dyssZvoC1ldY
         LTHQ==
X-Gm-Message-State: APjAAAVvuCR2dkaGeazKLvouosuZqUdwk8fx2ONBYd/OHpboQp8rkxXf
	1aKnO3hxUwq7KiTmWnG/zhuSV5WkcLeORdDPWFSagjIlcYsmh2/chvleXTYBU3RPKuAA/NI6iJj
	YPv65qIwXo/pj6awFwaEhu+9KMB9wQhkqnZ7OZdhKX5SItFTqt5ULLQ4cz5ioi04=
X-Received: by 2002:a50:eb8f:: with SMTP id y15mr108162446edr.31.1564586037723;
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
X-Received: by 2002:a50:eb8f:: with SMTP id y15mr108162319edr.31.1564586036451;
        Wed, 31 Jul 2019 08:13:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586036; cv=none;
        d=google.com; s=arc-20160816;
        b=ngoiukpe8mz6uf7yTxSvGrTH5DUZEvPhiwotcb2k9ldYF3XUY5A+gmoWGj9qWXMfMx
         +oOSgvK2vX8GTSvUwhwkjxN38HEne73MVhFuXeMJk7Ds9w5mCWoMeH8U+Mr0WuOJ20FY
         5ORPi80PbNmRU0vOiDRZKqTSYCgNdN+kgowggEmHCQ3CvB+D5PoH8N7Tz9tCqK0jcAqg
         t1t25FPc79ENnIhBXz7GvaSv3VFGpXoOZIHgyzZy7Xk2gsMKzo7Pm6MPvh9QrjZetcvg
         ULvx9tW+EkyONJcQV98rc25P6Kw0QHu2Fy9T/1F1tkil8pegM36YimWVplYBFlLE6xF8
         Ry2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WTAAjTsK3+3w7eSPHsyJf/zyVQM+N+66EXtK8GvqGh0=;
        b=Wiv0ear+7Y6hzN8WoDXR2FrNCJoI2vi1mBCQ6HTDZO6gChESNPYm1xEGj2fWUzmk+m
         Aw7+ykd/Y89YkTYOdzAyOk5+vbLk/hPtWvnt0QAOQISj+dic0O1+VICyG3Yogk/vJfb0
         NMY6ieS/IJHdxz7Yj5F6ZGN26K+8NdHK3Vl1uTtG1uKkJeqI2FKIK6Q1nfDOdyBnucAQ
         VCowNzaXsn9w5H1Nna4cAiPo+oPPd2nUDiMdAICbqIVytHoBMsSijbh91aon5ikTs+Ku
         DgDMQqaUKquL59bLembqq1IADg+4Td9rlk7o3m6te0ZKHdisvF/TYbgkF9F71h0kjtuy
         NoNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=vHCm2eeu;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l22sor52318095eda.1.2019.07.31.08.13.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:56 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=vHCm2eeu;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=WTAAjTsK3+3w7eSPHsyJf/zyVQM+N+66EXtK8GvqGh0=;
        b=vHCm2eeuCUQs2yHSeXWs6297E3LD/DJ3yKHjxnQ3uS38oTOhZMWNOL2t2b8qyqezCd
         TSyHJ2nZIkIp+xozfa1fMkbPHgLyD07pzVHXY1r0RJbOqJQjIa59zY+kzkFpFK+i6bAm
         u2IRsUZJ7qr8muyrOi/vvs1sPIHYD5F+Sz93KlJmSVBGUVMoNkaJnWL0flwcUWdk1Rd+
         pJLhMUZ1mXkr512XbgaOmHVFaepWq9DNGGdxUvxD97xw+4EXINwjigBZSkDbyOrFGk9v
         coI9yYfL7DOZadkWb+EyLWXGslgUVJIufSy67o3yRyMY9W/s+uFsbxg0YK6+eu5onsz9
         Qs2g==
X-Google-Smtp-Source: APXvYqyDF7Ax4wPwm75VtJQs6n6Sw+upz55I60UXt6jJNg1T+Xcry5rWrrwsNPjn0mCM+yzapDyh9Q==
X-Received: by 2002:a50:9153:: with SMTP id f19mr109455097eda.70.1564586035945;
        Wed, 31 Jul 2019 08:13:55 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id q56sm17022134eda.28.2019.07.31.08.13.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 87A6F1048A9; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 57/59] x86/mktme: Document the MKTME Key Service API
Date: Wed, 31 Jul 2019 18:08:11 +0300
Message-Id: <20190731150813.26289-58-kirill.shutemov@linux.intel.com>
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
 Documentation/x86/mktme/mktme_keys.rst | 61 ++++++++++++++++++++++++++
 2 files changed, 62 insertions(+)
 create mode 100644 Documentation/x86/mktme/mktme_keys.rst

diff --git a/Documentation/x86/mktme/index.rst b/Documentation/x86/mktme/index.rst
index 0f021cc4a2db..8cf2b7d62091 100644
--- a/Documentation/x86/mktme/index.rst
+++ b/Documentation/x86/mktme/index.rst
@@ -8,3 +8,4 @@ Multi-Key Total Memory Encryption (MKTME)
    mktme_overview
    mktme_mitigations
    mktme_configuration
+   mktme_keys
diff --git a/Documentation/x86/mktme/mktme_keys.rst b/Documentation/x86/mktme/mktme_keys.rst
new file mode 100644
index 000000000000..5d9125eb7950
--- /dev/null
+++ b/Documentation/x86/mktme/mktme_keys.rst
@@ -0,0 +1,61 @@
+MKTME Key Service API
+=====================
+MKTME is a new key service type added to the Linux Kernel Key Service.
+
+The MKTME Key Service type is available when CONFIG_X86_INTEL_MKTME is
+turned on in Intel platforms that support the MKTME feature.
+
+The MKTME Key Service type manages the allocation of hardware encryption
+keys. Users can request an MKTME type key and then use that key to
+encrypt memory with the encrypt_mprotect() system call.
+
+Usage
+-----
+    When using the Kernel Key Service to request an *mktme* key,
+    specify the *payload* as follows:
+
+    type=
+        *cpu*	User requests a CPU generated encryption key.
+                The CPU generates and assigns an ephemeral key.
+
+        *no-encrypt*
+                 User requests that hardware does not encrypt
+                 memory when this key is in use.
+
+    algorithm=
+        When type=cpu the algorithm field must be *aes-xts-128*
+        *aes-xts-128* is the only supported encryption algorithm
+
+        When type=no-encrypt the algorithm field must not be
+        present in the payload.
+
+ERRORS
+------
+    In addition to the Errors returned from the Kernel Key Service,
+    add_key(2) or keyctl(1) commands, the MKTME Key Service type may
+    return the following errors:
+
+    EINVAL for any payload specification that does not match the
+           MKTME type payload as defined above.
+
+    EACCES for access denied. The MKTME key type uses capabilities
+           to restrict the allocation of keys to privileged users.
+           CAP_SYS_RESOURCE is required, but it will accept the
+           broader capability of CAP_SYS_ADMIN. See capabilities(7).
+
+    ENOKEY if a hardware key cannot be allocated. Additional error
+           messages will describe the hardware programming errors.
+
+EXAMPLES
+--------
+    Add a 'cpu' type key::
+
+        char \*options_CPU = "type=cpu algorithm=aes-xts-128";
+
+        key = add_key("mktme", "name", options_CPU, strlen(options_CPU),
+                      KEY_SPEC_THREAD_KEYRING);
+
+    Add a "no-encrypt' type key::
+
+	key = add_key("mktme", "name", "no-encrypt", strlen(options_CPU),
+		      KEY_SPEC_THREAD_KEYRING);
-- 
2.21.0

