Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 834C4C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34FEC216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34FEC216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1290F6B02AD; Wed,  8 May 2019 10:44:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F30016B02AA; Wed,  8 May 2019 10:44:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC0DE6B02AD; Wed,  8 May 2019 10:44:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 759626B02A9
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:55 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e69so12783560pgc.7
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AW1rtcZMENayWyGETowtPPF05jxozdNxFkdf3q0ABbw=;
        b=X2QbUpmeD+TIvbCwyS/jzdM3qAW+8XdO8ivgBzaSmE0KXxLP79ToTEtZpqArbHRtO0
         hDUxmzZkG72OTQsehfOw+dnTPv5rcg8ELEsIpnIj5y26gIQSEkaeiezv08kqPsDdZwPy
         kwarRlBjdM/lIP+NuIdItuq9aG+WB6zFguWuyYvrv5UR4deuBg9lii53wuSlFCwnNSyy
         IA/qzVTJopGhkCytCNkCoWrBvd3MYF4sOC/yebRBGAsUocnsH5Wzbd1H4YpwB6JOaC/P
         a5CAF0nYVnVDWJfx7rCvUfU/knTAwd+BxfXs8qPR57wrTaH7y68ehVnQvEPZO1jQSWsK
         3a1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXnmaQJS+kmPC/+eFJ6XJJRN5lgGxpXlGT40TznHK+AJzPiuUjr
	tPrxlJ9kD2uSHEwX/rFF7GlsKK91jhzzrldoXc/jP1VEdfMz4BqiXuYlKEz3gHK83DMjFKO1TWy
	XrIPYnpOGgo6itXFocToEzRxbMVYFMBBre2YQlLodvYYWuShn20U15y6RE8ceWU7+Iw==
X-Received: by 2002:a63:ed12:: with SMTP id d18mr48550532pgi.248.1557326695076;
        Wed, 08 May 2019 07:44:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrQ/VAEv9FduJmcMyxSmhe1g0dxmXsKkJ2rYdIRaj1hF5MTkZrcRVPc0F9aLcgWvLVbaO9
X-Received: by 2002:a63:ed12:: with SMTP id d18mr48550428pgi.248.1557326694109;
        Wed, 08 May 2019 07:44:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326694; cv=none;
        d=google.com; s=arc-20160816;
        b=klADXujkGH3U9F3kRbra8KT4WX+JLtWpuggXeHw4jIs4lR4qd/Xjfg5OasHcE3jXfa
         /+S/9VsctyZ38luAK6Zd/dBNxXLYfqmOYL12b7zuBp+uUxJaha8LLsiLrdD+wNzYzDej
         f64r/9RjCuJPV7mMiBfNfFvHmfgyJ1TpmW3U1c6GHBMOpWumtQ73AGcnLH6lkDVdRUu4
         D4QnN5MioAqtshcqHpabI7yvvGAeqI6aCtXFp8qwbye7fKZBtXOIU8fG3W5x6oEIe1n5
         YrpOw5lx3y5S3BG3S6e4QAYSFy4GfXWgMahHCKQiVxhvkFENvmWittZLqIjxni7j0n/F
         zH7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=AW1rtcZMENayWyGETowtPPF05jxozdNxFkdf3q0ABbw=;
        b=UBVNYnBTyyv41/VHP8iIz+Ipvojhz7DdDVAkvwF2h0sj5jXuYAThfOcuUK1Vi4s2WX
         wW0AaNKH1YwRd83dnTxTUjVBQ5zxuFlBk+Lf4v9pCkgHMZwTjDfsVd0otCmuChVHox6s
         IsDPI44NQ6kyyfuwxO4DAhnJiwdrmnRx4ab9osOOr6owJ+sbmS1cIlEk5Lkr7v/Kpbg9
         DwudKrOu25zGL8+//6i9ChZHD9wJ9hwJ0bgaHuakc1MkOtzZBHaPU0g50T091AhRvJvQ
         Az2gXCIlOA5NqwAXsJZVQvTCDImlAvQgi6uCKuUz/GDwoAIybYkLjNRha7k7LSOtoDAU
         Wm2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id q8si24066889pgf.3.2019.05.08.07.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:53 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,446,1549958400"; 
   d="scan'208";a="169656578"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga002.fm.intel.com with ESMTP; 08 May 2019 07:44:49 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 9448E11B3; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
Subject: [PATCH, RFC 58/62] x86/mktme: Document the MKTME provided security mitigations
Date: Wed,  8 May 2019 17:44:18 +0300
Message-Id: <20190508144422.13171-59-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alison Schofield <alison.schofield@intel.com>

Describe the security benefits of Multi-Key Total Memory
Encryption (MKTME) over Total Memory Encryption (TME) alone.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/x86/mktme/index.rst             |   1 +
 Documentation/x86/mktme/mktme_mitigations.rst | 150 ++++++++++++++++++
 2 files changed, 151 insertions(+)
 create mode 100644 Documentation/x86/mktme/mktme_mitigations.rst

diff --git a/Documentation/x86/mktme/index.rst b/Documentation/x86/mktme/index.rst
index 1614b52dd3e9..a3a29577b013 100644
--- a/Documentation/x86/mktme/index.rst
+++ b/Documentation/x86/mktme/index.rst
@@ -6,3 +6,4 @@ Multi-Key Total Memory Encryption (MKTME)
 .. toctree::
 
    mktme_overview
+   mktme_mitigations
diff --git a/Documentation/x86/mktme/mktme_mitigations.rst b/Documentation/x86/mktme/mktme_mitigations.rst
new file mode 100644
index 000000000000..90699c38750a
--- /dev/null
+++ b/Documentation/x86/mktme/mktme_mitigations.rst
@@ -0,0 +1,150 @@
+MKTME-Provided Mitigations
+==========================
+
+MKTME adds a few mitigations against attacks that are not
+mitigated when using TME alone.  The first set are mitigations
+against software attacks that are familiar today:
+
+ * Kernel Mapping Attacks: information disclosures that leverage
+   the kernel direct map are mitigated against disclosing user
+   data.
+ * Freed Data Leak Attacks: removing an encryption key from the
+   hardware mitigates future user information disclosure.
+
+The next set are attacks that depend on specialized hardware,
+such as an “evil DIMM” or a DDR interposer:
+
+ * Cross-Domain Replay Attack: data is captured from one domain
+(guest) and replayed to another at a later time.
+ * Cross-Domain Capture and Delayed Compare Attack: data is
+   captured and later analyzed to discover secrets.
+ * Key Wear-out Attack: data is captured and analyzed in order
+   to Weaken the AES encryption itself.
+
+More details on these attacks are below.
+
+Kernel Mapping Attacks
+----------------------
+Information disclosure vulnerabilities leverage the kernel direct
+map because many vulnerabilities involve manipulation of kernel
+data structures (examples: CVE-2017-7277, CVE-2017-9605).  We
+normally think of these bugs as leaking valuable *kernel* data,
+but they can leak application data when application pages are
+recycled for kernel use.
+
+With this MKTME implementation, there is a direct map created for
+each MKTME KeyID which is used whenever the kernel needs to
+access plaintext.  But, all kernel data structures are accessed
+via the direct map for KeyID-0.  Thus, memory reads which are not
+coordinated with the KeyID get garbage (for example, accessing
+KeyID-4 data with the KeyID-0 mapping).
+
+This means that if sensitive data encrypted using MKTME is leaked
+via the KeyID-0 direct map, ciphertext decrypted with the wrong
+key will be disclosed.  To disclose plaintext, an attacker must
+“pivot” to the correct direct mapping, which is non-trivial
+because there are no kernel data structures in the KeyID!=0
+direct mapping.
+
+Freed Data Leak Attack
+----------------------
+The kernel has a history of bugs around uninitialized data.
+Usually, we think of these bugs as leaking sensitive kernel data,
+but they can also be used to leak application secrets.
+
+MKTME can help mitigate the case where application secrets are
+leaked:
+
+ * App (or VM) places a secret in a page * App exits or frees
+memory to kernel allocator * Page added to allocator free list *
+Attacker reallocates page to a purpose where it can read the page
+
+Now, imagine MKTME was in use on the memory being leaked.  The
+data can only be leaked as long as the key is programmed in the
+hardware.  If the key is de-programmed, like after all pages are
+freed after a guest is shut down, any future reads will just see
+ciphertext.
+
+Basically, the key is a convenient choke-point: you can be more
+confident that data encrypted with it is inaccessible once the
+key is removed.
+
+Cross-Domain Replay Attack
+--------------------------
+MKTME mitigates cross-domain replay attacks where an attacker
+replaces an encrypted block owned by one domain with a block
+owned by another domain.  MKTME does not prevent this replacement
+from occurring, but it does mitigate plaintext from being
+disclosed if the domains use different keys.
+
+With TME, the attack could be executed by:
+ * A victim places secret in memory, at a given physical address.
+   Note: AES-XTS is what restricts the attack to being performed
+   at a single physical address instead of across different
+   physical addresses
+ * Attacker captures victim secret’s ciphertext * Later on, after
+   victim frees the physical address, attacker gains ownership 
+ * Attacker puts the ciphertext at the address and get the secret
+   plaintext
+
+But, due to the presumably different keys used by the attacker
+and the victim, the attacker can not successfully decrypt old
+ciphertext.
+
+Cross-Domain Capture and Delayed Compare Attack
+-----------------------------------------------
+This is also referred to as a kind of dictionary attack.
+
+Similarly, MKTME protects against cross-domain capture-and-compare
+attacks.  Consider the following scenario:
+ * A victim places a secret in memory, at a known physical address
+ * Attacker captures victim’s ciphertext
+ * Attacker gains control of the target physical address, perhaps
+   after the victim’s VM is shut down or its memory reclaimed.
+ * Attacker computes and writes many possible plaintexts until new
+   ciphertext matches content captured previously.
+
+Secrets which have low (plaintext) entropy are more vulnerable to
+this attack because they reduce the number of possible plaintexts
+an attacker has to compute and write.
+
+The attack will not work if attacker and victim uses different
+keys.
+
+Key Wear-out Attack
+-------------------
+Repeated use of an encryption key might be used by an attacker to
+infer information about the key or the plaintext, weakening the
+encryption.  The higher the bandwidth of the encryption engine,
+the more vulnerable the key is to wear-out.  The MKTME memory
+encryption hardware works at the speed of the memory bus, which
+has high bandwidth.
+
+Such a weakness has been demonstrated[1] on a theoretical cipher
+with similar properties as AES-XTS.
+
+An attack would take the following steps:
+ * Victim system is using TME with AES-XTS-128
+ * Attacker repeatedly captures ciphertext/plaintext pairs (can
+   be Performed with online hardware attack like an interposer).
+ * Attacker compels repeated use of the key under attack for a
+   sustained time period without a system reboot[2].
+ * Attacker discovers a cipertext collision (two plaintexts
+   translating to the same ciphertext)
+ * Attacker can induce controlled modifications to the targeted
+   plaintext by modifying the colliding ciphertext
+
+MKTME mitigates key wear-out in two ways:
+ * Keys can be rotated periodically to mitigate wear-out.  Since
+   TME keys are generated at boot, rotation of TME keys requires a
+   reboot.  In contrast, MKTME allows rotation while the system is
+   booted.  An application could implement a policy to rotate keys
+   at a frequency which is not feasible to attack.
+ * In the case that MKTME is used to encrypt two guests’ memory
+   with two different keys, an attack on one guest’s key would not
+   weaken the key used in the second guest.
+
+--
+1. http://web.cs.ucdavis.edu/~rogaway/papers/offsets.pdf
+2. This sustained time required for an attack could vary from days
+   to years depending on the attacker’s goals.
-- 
2.20.1

