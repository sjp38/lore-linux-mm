Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03DEAC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB3D9217D7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB3D9217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDF3A6B02D5; Wed,  8 May 2019 10:46:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E68186B02D7; Wed,  8 May 2019 10:46:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D56C06B02D8; Wed,  8 May 2019 10:46:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A07F66B02D5
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:52 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id h12so3690244pll.20
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Kj3xFje8z8MAF13PrAdu5omi33lo97QkSLPU9hFx5qo=;
        b=cQdZWSbs7NsrPzlBrBebQhcAsj2CgM83Zbvo61MrAAkkomgAG2mzI+eikAfqYrkugD
         iKXzCp74vI4KjvaR63RKQqSCk2u/ornho/pT2vv8rEVglhe2KfsuJpgUgQ6fBqRBtUlQ
         3hyQaWujTrHKIvIaHC3UKosGJ4cYJX7qt8gajhOZRP/aDYlvOX+TFax3NBlIxei1+VSb
         8r7gFgIRHo+QocilFoKg6cRsz9KN11RAWjVksrxk/gOrYmoX8JxcXBpFJ5RnLg8Cr2dh
         QHSjJoeRUIW1kAkiIHE7TMNuIou+V9BX220UzQPYQQtEuJ7Is1wM4Nju9Z7dmaMjoafR
         DNng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU8Frw7kfmGJojn7qb30EXZtkKm3X25H2Ul8NUwveNOCY5Zm6cC
	g+FXBFDzcXgMWTBAWHzJfMRx8cwAi5KT+nBoDQLHOTk9tUP0f2FKxr1aJewsheVgeCR8NOqtDJm
	G9bhIOk8KAu6uSR2xyZNwCM990ub2LqSXF09BMLeBsdsA7R9AceRHO196PRjzyeis9Q==
X-Received: by 2002:a63:950d:: with SMTP id p13mr15743359pgd.269.1557326812316;
        Wed, 08 May 2019 07:46:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyD6V3NIm4Ssdw+Q50sny7x5M1VJx0vkuYQwBycZ+d80FAZ50vBi8J80jsL679nTEd2LkxX
X-Received: by 2002:a63:950d:: with SMTP id p13mr15728791pgd.269.1557326684674;
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326684; cv=none;
        d=google.com; s=arc-20160816;
        b=c0Ivv3E88L+K4y81ZmTCI5+SUxSW2UwFD2Fy6UczFQ25Gl5r3vZh1GiYfhl5KeSev/
         aERNWGSlIiqtIwMjui62Hq/abyWgXPLPt3HDYCi8dSK+lyWNLjpvpvsTnlWg1/snsKVC
         HhEEkNBBplg7Udj9UXdlLuSNQdy6bbKzi9rkaXMlyNiI5gfZcZyBTMqoLsdufgjKeBCK
         2EwfJRFwHPn/qgjYRIuVjS16wQTATkUsGZ5LkU/n6UdJP/tvMP+4gejJVqQ6i4tRp+cJ
         7GHYrhHgHg0/bsX0Lj0crhBoPF4uC+g1IzCO5gIKJxg3ODX8s5A+n9NTIpPN/AKXcYY5
         skSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Kj3xFje8z8MAF13PrAdu5omi33lo97QkSLPU9hFx5qo=;
        b=QRwu2SE9WvFgJvCAqu0tTNntT4k/a9wBf3gzMC1ZfgpoGj27QvtJPcc/wshHKYBEVD
         QedQsNWT4rl0HaKSgSsX4AeCBXDpeReJW/SmSRCUn3bS0tR5gIjsl2xyYEWeGFmnPgDG
         7BE3jHnLplQZvH6k9XMCF56OBzUsf9d69PTu3A+cq65Ty3Q6ildBN+SrHWAuXRIXIu8P
         gGxsq1oZ53sah1abK7NoOYTQY7QFwuyWCzSv6XDu5llVOOSMDzb0f7iVhXHA6cTKlOLZ
         xgGOADfXeTTwvnd7+0cSch4Nyb2gv7u2T208i3N34szGGqIuApopuUon92SfpO045h+i
         3TSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f6si24524459plf.90.2019.05.08.07.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:44 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,446,1549958400"; 
   d="scan'208";a="169656544"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga002.fm.intel.com with ESMTP; 08 May 2019 07:44:40 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id C4835A64; Wed,  8 May 2019 17:44:29 +0300 (EEST)
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
Subject: [PATCH, RFC 22/62] x86/pconfig: Set a valid encryption algorithm for all MKTME commands
Date: Wed,  8 May 2019 17:43:42 +0300
Message-Id: <20190508144422.13171-23-kirill.shutemov@linux.intel.com>
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

The Intel MKTME architecture specification requires a valid encryption
algorithm for all command types.

For commands that actually perform encryption, SET_KEY_DIRECT and
SET_KEY_RANDOM, the user specifies the algorithm when requesting the
key through the MKTME Key Service.

For CLEAR_KEY and NO_ENCRYPT commands, a valid encryption algorithm is
also required by the MKTME hardware. However, it does not make sense to
ask userspace to specify one. Define the CLEAR_KEY and NO_ENCRYPT type
commands to always include a valid encryption algorithm.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/intel_pconfig.h | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/intel_pconfig.h b/arch/x86/include/asm/intel_pconfig.h
index 3cb002b1d0f9..15705699a14e 100644
--- a/arch/x86/include/asm/intel_pconfig.h
+++ b/arch/x86/include/asm/intel_pconfig.h
@@ -21,14 +21,20 @@ enum pconfig_leaf {
 
 /* Defines and structure for MKTME_KEY_PROGRAM of PCONFIG instruction */
 
+/* mktme_key_program::keyid_ctrl ENC_ALG, bits [23:8] */
+#define MKTME_AES_XTS_128	(1 << 8)
+#define MKTME_ANY_VALID_ALG	(1 << 8)
+
 /* mktme_key_program::keyid_ctrl COMMAND, bits [7:0] */
 #define MKTME_KEYID_SET_KEY_DIRECT	0
 #define MKTME_KEYID_SET_KEY_RANDOM	1
-#define MKTME_KEYID_CLEAR_KEY		2
-#define MKTME_KEYID_NO_ENCRYPT		3
 
-/* mktme_key_program::keyid_ctrl ENC_ALG, bits [23:8] */
-#define MKTME_AES_XTS_128	(1 << 8)
+/*
+ * CLEAR_KEY and NO_ENCRYPT require the COMMAND in bits [7:0]
+ * and any valid encryption algorithm, ENC_ALG, in bits [23:8]
+ */
+#define MKTME_KEYID_CLEAR_KEY  (2 | MKTME_ANY_VALID_ALG)
+#define MKTME_KEYID_NO_ENCRYPT (3 | MKTME_ANY_VALID_ALG)
 
 /* Return codes from the PCONFIG MKTME_KEY_PROGRAM */
 #define MKTME_PROG_SUCCESS	0
-- 
2.20.1

