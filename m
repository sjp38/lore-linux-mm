Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F774C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3EBE216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3EBE216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34E656B02A6; Wed,  8 May 2019 10:44:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 125A46B02A7; Wed,  8 May 2019 10:44:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E00796B02AC; Wed,  8 May 2019 10:44:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8756B02A7
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:55 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a141so12783476pfa.13
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zPmtLVMnvlVnxE7UxQaP7LRcAClmbAOM+DFTsaab/Sk=;
        b=dyaejQRy7XQWK8zQLWLQzr+i+3Acm4GhUsMLNWOXmHAyaGlCIkl27uYZjjy/tAD4md
         3PDPCik90CQFg/zGaukPf6iOQw3KOvynJO+CThJFr8eNueDGlL3khKbszRUu5+cEOCRw
         oWQs2vOIkCTU6EUGyysVV3NHr2lvFm3H4TF0ygIjvMQNq/nVy725BEMXPaLUcRZ66+64
         Lo0a5jYTM4pCxY8WEC4ERbyzGkedXlsIR35exhCqVzKqBtQZwxL407G91kP1Cz1jQRsI
         yFOp3W4RfjMgpsQ5ni9VHcAyx4mQUcOxKPAikFigOawofuIfGoWlLQYarLDTL1z/q+il
         20wA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVWSx2pWC0GHhMS68VNdcT+8iAoVE76jTcfra4CrU7kRcFU0mM3
	KIty0r6HGZrwL3SiWXJY46IGmcZ1IWUIdk0Dy/zT+VJdJ0jpjm20UwfqspqyutrfKxfsyFju/ky
	XawIvnISdJ+bBJEJQZFS5JfKPN2h3qoX29PrEFmjW1RBhHCcwIkKqbhqwGpYshRbi2A==
X-Received: by 2002:a17:902:76c5:: with SMTP id j5mr48381466plt.337.1557326695162;
        Wed, 08 May 2019 07:44:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXaJmC+Yn+BEu9bBqsHAo1GxOxEnUSpCGJh1SuV28KPPmffXBAXxE/vgEWExLDBxalBsK+
X-Received: by 2002:a17:902:76c5:: with SMTP id j5mr48381374plt.337.1557326694291;
        Wed, 08 May 2019 07:44:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326694; cv=none;
        d=google.com; s=arc-20160816;
        b=VzejrkfZv3Y4wyBSoKl/M5rVQajhn/rjdM3qQDhxsmxY5ke0M8pbtc8TJgerbTcJx8
         YHO/8XGxQU/Pl/zHvtm+fi2o/uaHGJbwtLek0llOWEedtGqMcfojirWHS4upgtNs1QMO
         aNOM6AQb+LbuK1TBr/kranQFFOcwEzB5Lz8NhOmaUcaFc0Hfieu0TkzbgaDMCygAaNhh
         umyxjabPzJuoeUYmnkqFm3uJ+h5jysW9ICUkNAuDQ8nlRs5LjxoTaCL14Ti1eLHN62f8
         r4IhapJIPeu/ZgQNTnlv9iAKf2KVc94lRjfRQjNyeNokIr3Pmj3cMK24K0MBkVBB98gj
         mmhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=zPmtLVMnvlVnxE7UxQaP7LRcAClmbAOM+DFTsaab/Sk=;
        b=vpgU2IXUy/tGmailh6DIoaN11s1ykny1vyh9r2eB0Fqm+Q1n5KB11UHPwWazbMn0F/
         Mxey22l68G82QJyw0G5b3RfUfYwke/nn4eZeKO+DKf5QLo+SQvuV/4xAwRXvGNleB3KR
         txCKw10p8uZgPi2bgssE5LXleWfans9z6VJffUmNFWXmmA0TvyCYVo1d5RXAvcdhQGKR
         PZebmIyvxe2ArUjVTHk2ggR7CVAs/NaPZh1fkrzbFvdtQNTno4Pvm1neN9v998e7Ok65
         sWZmjxQm4wAYHoavJMTCnl7b7OTk5L2+9N2BmyRT6pjDm35t8aVL3bIcsBCmhVzlMrqR
         9hfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id h128si4938pgc.499.2019.05.08.07.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:53 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by FMSMGA003.fm.intel.com with ESMTP; 08 May 2019 07:44:49 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id AF33E11CE; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
Subject: [PATCH, RFC 60/62] x86/mktme: Document the MKTME Key Service API
Date: Wed,  8 May 2019 17:44:20 +0300
Message-Id: <20190508144422.13171-61-kirill.shutemov@linux.intel.com>
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
 Documentation/x86/mktme/mktme_keys.rst | 96 ++++++++++++++++++++++++++
 2 files changed, 97 insertions(+)
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
index 000000000000..161871dee0dc
--- /dev/null
+++ b/Documentation/x86/mktme/mktme_keys.rst
@@ -0,0 +1,96 @@
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
+        *user*	User will supply the encryption key data. Use this
+                type to directly program a hardware encryption key.
+
+        *cpu*	User requests a CPU generated encryption key.
+                The CPU generates and assigns an ephemeral key.
+
+        *no-encrypt*
+                 User requests that hardware does not encrypt
+                 memory when this key is in use.
+
+    algorithm=
+        When type=user or type=cpu the algorithm field must be
+        *aes-xts-128*
+
+        When type=clear or type=no-encrypt the algorithm field
+        must not be present in the payload.
+
+    key=
+        When type=user the user must supply a 128 bit encryption
+        key as exactly 32 ASCII hexadecimal characters.
+
+	When type=cpu the user may optionally supply 128 bits of
+        entropy for the CPU generated encryption key in this field.
+        It must be exactly 32 ASCII hexadecimal characters.
+
+	When type=no-encrypt this key field must not be present
+        in the payload.
+
+    tweak=
+	When type=user the user must supply a 128 bit tweak key
+        as exactly 32 ASCII hexadecimal characters.
+
+	When type=cpu the user may optionally supply 128 bits of
+        entropy for the CPU generated tweak key in this field.
+        It must be exactly 32 ASCII hexadecimal characters.
+
+        When type=no-encrypt the tweak field must not be present
+        in the payload.
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
+    Add a 'user' type key::
+
+        char \*options_USER = "type=user
+                               algorithm=aes-xts-128
+                               key=12345678912345671234567891234567
+                               tweak=12345678912345671234567891234567";
+
+        key = add_key("mktme", "name", options_USER, strlen(options_USER),
+                      KEY_SPEC_THREAD_KEYRING);
+
+    Add a 'cpu' type key::
+
+        char \*options_USER = "type=cpu algorithm=aes-xts-128";
+
+        key = add_key("mktme", "name", options_CPU, strlen(options_CPU),
+                      KEY_SPEC_THREAD_KEYRING);
+
+    Add a "no-encrypt' type key::
+
+	key = add_key("mktme", "name", "no-encrypt", strlen(options_CPU),
+		      KEY_SPEC_THREAD_KEYRING);
-- 
2.20.1

