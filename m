Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF927C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A797A20C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="a8D1IY8W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A797A20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98AA18E002B; Wed, 31 Jul 2019 11:13:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 826EB8E0022; Wed, 31 Jul 2019 11:13:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 653F08E002A; Wed, 31 Jul 2019 11:13:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0974D8E0028
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:56 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so42614673eds.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=igF6rwOO/MpHXaPOW5M5V10Q4NOXV533wOmvObyjS78=;
        b=ap0bpH16W1dO8NEZ9FM5k+cGsXowar0RW7tLOoj4p9RgAqyCvcPByA371lGwll/ePt
         lTO1oNdfMbZJUok2qasSUKJn588FZijpOt/QCaVeNYVItavVSg7VBC6wiUXOYJKYRn55
         IXf9CWVbaGaAgbmoNIqHFGHvVmqUzkkLPW65WsPub7l4sU9NqzCQQ8dtxBJAUgWsOOqX
         rqKlNogHQCys363ib1+kPOn1nvEgP98QYbT6RMX3kYpymq0x2QEw/V6kDxykAj6zp8UE
         1aodEzTvNYN9Z8vB3NJHwr+x/tmLM1xGMiRi6yKV6JsfP567coJKIckeGCEGsrTup64v
         M5fg==
X-Gm-Message-State: APjAAAU/+WDmXHiFfEoBNtG5OzOeYaot00vpn9vpP7JGPzdA+eKxTYXL
	sr37tORYRIH41J2N0ytCuViaiioeyq3pZIDRlP/JWqS836d9nv5JtfET3ikg9VVS9ZaZ61I7KyI
	vF+dtx2KUS95M6nRHegXiZFNKKS8SWQ8lFvolzOZDqt+6VfvMLCY3nV+ZW5YfafI=
X-Received: by 2002:aa7:df8b:: with SMTP id b11mr5269479edy.6.1564586035568;
        Wed, 31 Jul 2019 08:13:55 -0700 (PDT)
X-Received: by 2002:aa7:df8b:: with SMTP id b11mr5269340edy.6.1564586034071;
        Wed, 31 Jul 2019 08:13:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586034; cv=none;
        d=google.com; s=arc-20160816;
        b=dTNvIrAq6inAQl68w2HuSaDayfSXbrWJS9L8mkzQkR3UWP4R6P1MSE48gX3CLlU7xv
         nXEwc2nhjkBaPG+j/+X/Md9uc6nv6eAxeUvomwPuD5liy3T5zUA8/k8n8m7ezV2Dv7rV
         TpXkL1THJaPKXVtrtowkjNMcupSY4TD7Wo8vDyuWTMpTjAwTwB+ihVJn/yfCqIeTWb9c
         M6VWBLsS2wmaMBAS4+ZSRnRCM7qFwDkPQE8Wn6Ku/icGON3IG383y+QOhTrc0fFTNJtb
         v/8aRHVP5pHldnUJ+BkhV4KyhFRREmElVAzWoUdRiamvsuKa1InmaYzOKIyrQitxvP5X
         AUFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=igF6rwOO/MpHXaPOW5M5V10Q4NOXV533wOmvObyjS78=;
        b=OjwA4urPhqIPfYmoVUT12YeVVBPkcxqJaSRY6SLjrYpqREwHdNRyz9qVys+7KyHK+C
         QTBSWniHuPiR7nV1WKJ1C/bfG06k3P8WQksJVjC8ykJg4Zqp0yuco+Sdwtm4TdAY+53t
         QsjxnIYnVfxNGOHT5aaJE0N6E0clZcI3Zt507UCB1q5apMFuom/6tZ9zhHOaQwzKF59W
         NVZZhB0eskfEThUKQA8fLeegPKODFljAWfaDYm2Bll8Yalnd67PhFXJaBul2803mVtUF
         lXK+RTRLV7GlOR2p2cTNlv87NDSj0Aq6H+q/9Unc0g2p0EynpBQuR5TkUskl9inVJJsQ
         jYhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=a8D1IY8W;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id pj9sor22571555ejb.22.2019.07.31.08.13.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:54 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=a8D1IY8W;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=igF6rwOO/MpHXaPOW5M5V10Q4NOXV533wOmvObyjS78=;
        b=a8D1IY8WQS/+pFXxx/c79xwSarq0iBdwCWmWCulUgzml4ker2LJSZneHrbBGRc9GCv
         H11X9TMhet9vbmINgjsTxzpQhGw8LclboXWyHT3C8sP81/lKyUEJb80FNr1Z3YxssR1s
         IN4FXExlSdSk1vWQd4N5Kkg511vrNfyls4pDcgm+WDjrht72CCqQslx6rnLT6w1nFhR7
         qav+PNWqOr+wWtQ7MgYg1Knk12t/pP9iRkjhwnvEbWBJH7+WHTJWnfHK0vZdejGeflRe
         +np9WYVRO4AAyNwU58oVH7WDmV4bh3Re5u+csPI0Y37Za/tH7uxoXCEETZ2CG6GG8fvP
         xGJg==
X-Google-Smtp-Source: APXvYqwV5kCyMozU4z2zmBu0uFZ9eCcpeUARTXuEcmuWXOI+wPOLh76dszK/1zlrOgtlJNxL8DEMmg==
X-Received: by 2002:a17:906:784:: with SMTP id l4mr80515472ejc.19.1564586033595;
        Wed, 31 Jul 2019 08:13:53 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id c16sm17311766edc.58.2019.07.31.08.13.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:51 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 79BFF1048A7; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 55/59] x86/mktme: Document the MKTME provided security mitigations
Date: Wed, 31 Jul 2019 18:08:09 +0300
Message-Id: <20190731150813.26289-56-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
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
 Documentation/x86/mktme/mktme_mitigations.rst | 151 ++++++++++++++++++
 2 files changed, 152 insertions(+)
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
index 000000000000..c593784851fb
--- /dev/null
+++ b/Documentation/x86/mktme/mktme_mitigations.rst
@@ -0,0 +1,151 @@
+MKTME-Provided Mitigations
+==========================
+:Author: Dave Hansen <dave.hansen@intel.com>
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
2.21.0

