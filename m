Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6827C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5559216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5559216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEDC96B02AB; Wed,  8 May 2019 10:44:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EAE16B02AA; Wed,  8 May 2019 10:44:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78D076B02AB; Wed,  8 May 2019 10:44:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2F06B02A7
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:55 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s22so11662538plq.1
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=72v4HftBYPH4NaCNX9vTABhQSfIMTjcr1FoRiXpK0K8=;
        b=rXQjiUNmouapF+n3IczMbmVkQ00JgGjXD8x8cqx1gWBt0gPWJTVsnKfylnXaPrg+U5
         3fJ+91jA4Amio+Q7mwPOyK+Tv4o7qqGj8DwCoinK4R7jKZtmNo8sRpAksQIChXSahcXt
         eE5pS36pWbRGfa9ZUN1oZljekUNw6Dz1GrCjpfyf+mcFYCiKJUk4MnVHqVK93i7yhBqG
         U/YxNID+1P6NawSRRpHKuzVrYb2kXU+c6XBS1NNSWm2vzK2CdWs3Cn3QfnimvyJ7K773
         yTJu9Mbt8jQXTXr5xn+0YrcApdtTgjtKASL7dKY00QKW2/hxykBC/E400yCDv4HN/ST8
         kwPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW9HsVzn/XtSLPsna9uB5/X82WJ0AVIyetxleGy922HVm0wkQ6/
	m6xoAJ6rd1hqfRHd2fgSq3eilBY1ZDfYM6qXRLMg0KsPK0oS3OmjcaojiEWjwR2V7ZpOByT78UJ
	mqkjswdHt8RrxBlMBLGZF9nXC9BS2RXH7ColCcnLvbo9/M4AjohvmBZ0lSIvjRMU1DA==
X-Received: by 2002:a63:4c54:: with SMTP id m20mr39401911pgl.316.1557326694815;
        Wed, 08 May 2019 07:44:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzU6eoteZwUYinLCAXqW5dts/ClWM/EvbpdiZ1VbG5vwLktDR9qYHjrepjBQAS2GWL+yk+j
X-Received: by 2002:a63:4c54:: with SMTP id m20mr39401796pgl.316.1557326693746;
        Wed, 08 May 2019 07:44:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326693; cv=none;
        d=google.com; s=arc-20160816;
        b=b1nI1Iy8WberKBBvsZrcZsx+uZgROGzcYvpY0UHk+grg6svJhUE0IZZGGS4cZY/JQj
         PpHvad/Y8st1aYivOnoKfpWC2FmOEUZQAfAxBfNyaZ6mitat59PVzBR2Yh5VgqjQy4wd
         P2PZTGUYeXNc/41aVfQQ/RvOir9yiaAYmYIoQHseMx9aKjwDHCiP3I7srMAixj+/6If3
         HGGvA3zR8XGrAoCaL3czT/cXkgjq/Ag0AqVdNlZb61IIiohfgu+dQ2poNHfbfzq5ompm
         z+Pj9V7BDSxmZoZeHlKeQOBmXtseGoxPFX+Zrl2yVp8YZaeXJxCcYZLkSk8Bp6m55bEQ
         uC6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=72v4HftBYPH4NaCNX9vTABhQSfIMTjcr1FoRiXpK0K8=;
        b=aIK4B2/4E75RmIIFE1ChAGlnNbCEDTOcY2GQ3zWoaIACA0EERQZqlsNlHHItcdaX+q
         E0BGzOiLlLUrMyy+Cx1XbEDdYRpPZrozC62YdUulSffxrlOPSt4pz8IfBBcWFYQ37NbL
         nH8HFnqwUwHMQmJnyD57iOEt41u+2qzIDh9NtTMI0zzwMjyp32uAUqxTQfMYPdz7BweO
         reGqh0ACX1wRYo3gNgagnnAnE+2vfCk9d8k/LZtCtZ+IBbRLAmXtPXHVx51vHH8VH8Z7
         +VryVY7AfNKFzrERnI3zWk17SDFr5B9PuhiIYMbkH5lK9iCsNZa51AurzpxxfjQ/m0je
         m0+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id q8si24066889pgf.3.2019.05.08.07.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:53 -0700 (PDT)
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
   d="scan'208";a="169656575"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga002.fm.intel.com with ESMTP; 08 May 2019 07:44:49 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 88BA31186; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
Subject: [PATCH, RFC 57/62] x86/mktme: Overview of Multi-Key Total Memory Encryption
Date: Wed,  8 May 2019 17:44:17 +0300
Message-Id: <20190508144422.13171-58-kirill.shutemov@linux.intel.com>
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

Provide an overview of MKTME on Intel Platforms.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/x86/mktme/index.rst          |  8 +++
 Documentation/x86/mktme/mktme_overview.rst | 57 ++++++++++++++++++++++
 2 files changed, 65 insertions(+)
 create mode 100644 Documentation/x86/mktme/index.rst
 create mode 100644 Documentation/x86/mktme/mktme_overview.rst

diff --git a/Documentation/x86/mktme/index.rst b/Documentation/x86/mktme/index.rst
new file mode 100644
index 000000000000..1614b52dd3e9
--- /dev/null
+++ b/Documentation/x86/mktme/index.rst
@@ -0,0 +1,8 @@
+
+=========================================
+Multi-Key Total Memory Encryption (MKTME)
+=========================================
+
+.. toctree::
+
+   mktme_overview
diff --git a/Documentation/x86/mktme/mktme_overview.rst b/Documentation/x86/mktme/mktme_overview.rst
new file mode 100644
index 000000000000..59c023965554
--- /dev/null
+++ b/Documentation/x86/mktme/mktme_overview.rst
@@ -0,0 +1,57 @@
+Overview
+=========
+Multi-Key Total Memory Encryption (MKTME)[1] is a technology that
+allows transparent memory encryption in upcoming Intel platforms.
+It uses a new instruction (PCONFIG) for key setup and selects a
+key for individual pages by repurposing physical address bits in
+the page tables.
+
+Support for MKTME is added to the existing kernel keyring subsystem
+and via a new mprotect_encrypt() system call that can be used by
+applications to encrypt anonymous memory with keys obtained from
+the keyring.
+
+This architecture supports encrypting both normal, volatile DRAM
+and persistent memory.  However, persistent memory support is
+not included in the Linux kernel implementation at this time.
+(We anticipate adding that support next.)
+
+Hardware Background
+===================
+
+MKTME is built on top of an existing single-key technology called
+TME.  TME encrypts all system memory using a single key generated
+by the CPU on every boot of the system. TME provides mitigation
+against physical attacks, such as physically removing a DIMM or
+watching memory bus traffic.
+
+MKTME enables the use of multiple encryption keys[2], allowing
+selection of the encryption key per-page using the page tables.
+Encryption keys are programmed into each memory controller and
+the same set of keys is available to all entities on the system
+with access to that memory (all cores, DMA engines, etc...).
+
+MKTME inherits many of the mitigations against hardware attacks
+from TME.  Like TME, MKTME does not mitigate vulnerable or
+malicious operating systems or virtual machine managers.  MKTME
+offers additional mitigations when compared to TME.
+
+TME and MKTME use the AES encryption algorithm in the AES-XTS
+mode.  This mode, typically used for block-based storage devices,
+takes the physical address of the data into account when
+encrypting each block.  This ensures that the effective key is
+different for each block of memory. Moving encrypted content
+across physical address results in garbage on read, mitigating
+block-relocation attacks.  This property is the reason many of
+the discussed attacks require control of a shared physical page
+to be handed from the victim to the attacker.
+
+--
+1. https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-Total-Memory-Encryption-Spec.pdf
+2. The MKTME architecture supports up to 16 bits of KeyIDs, so a
+   maximum of 65535 keys on top of the “TME key” at KeyID-0.  The
+   first implementation is expected to support 5 bits, making 63
+   keys available to applications.  However, this is not guaranteed.
+   The number of available keys could be reduced if, for instance,
+   additional physical address space is desired over additional
+   KeyIDs.
-- 
2.20.1

