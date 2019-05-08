Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D70FC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2B7E216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2B7E216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FB0C6B0274; Wed,  8 May 2019 10:44:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 654496B0276; Wed,  8 May 2019 10:44:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 457626B0278; Wed,  8 May 2019 10:44:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1F26B0274
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:46 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x5so12774108pfi.5
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W6m17Hrz7mMXRuCnuzuaf5je4qoyo8lsRAEw+Mb4/RY=;
        b=T0+FdC3grnmVGqlXPxeha+U1u4Rnj9F9HBCzPrW4ORUylWfMXIoD5/mB13gYPX4H4J
         kW5U/HKsoEw8CnkbpTOla4Fru/VHsgaIzduNXDDWsEM2hj/UrnnmxCCQOldxHmMhK+Pv
         j0ZIk6JkPWv6cv1z61ERYhyBe06sCDFhxFry3JpPanmhollX+eC4l451pLkGFjX16pW/
         x3HFhDOsCpV9/0mlx71uAJZCLQTKe8ZoyRD1XVhw5K6KPQuA8VAQ+K4GQmY2ltNFDp36
         x/nBiJuwCg04bNu9fUMuSmlXgoda2vTd3VJ7kwP/tbi9czkMt5N9nrrU/xCvhPkr1dNd
         lliA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWiHdZezENoHiJ9RSZJn7cvrutWX12NDOi6n7c1T9iX+WhM3uBJ
	vrjA6tK+fmSsLKs9yoWO1F1Ld4Jw+iEov6k7fMzoAaE9+g0qpSSTlFxzBaOrcRqKM4Z5Qu9r5hV
	Ued1lfeEy9aI90O0rCXo4qWuQGWS9LTacgevtDAhdeF1GiAsEm35Zm7SIIlSgde/t3g==
X-Received: by 2002:a17:902:5ac8:: with SMTP id g8mr16475265plm.154.1557326685693;
        Wed, 08 May 2019 07:44:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4LP429x9KQVXRobkucxd2vmd6VRyGlv1g99pH3N1xLhUr6JUE1BhRdkQQtWhrF2zgFJzM
X-Received: by 2002:a17:902:5ac8:: with SMTP id g8mr16475139plm.154.1557326684418;
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326684; cv=none;
        d=google.com; s=arc-20160816;
        b=DVOL3uFxB4j1e4uUKk4tUtISYSPUwhT8mELDMlk6j8RhpVDon2XtvhFAhKB/RwqyY1
         M1UY2LgiddLk1yUj70PTQOZpIQj5x7ZAlLlRH1OJWckDoWgdSfNx6V57wSEYzr08QUyp
         AIBnH+6JwF1dMjhZkNM6uJs5MpDxOgQ+nVcp4wVzg+FifCrkEmdEeSePdtK6XqhwNQeU
         gzKveygxY0uGoyEBPaSJAs2X6bJucOCGE186ILu8MVDNBimbDB5nOIyajows0vprUJQO
         UGRPumNMHDDSMWnmXduuBv7nFKfQ++6ST+45w1+icnaAXMyeI4FTOrSnBjhvboXcQW9T
         +72Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=W6m17Hrz7mMXRuCnuzuaf5je4qoyo8lsRAEw+Mb4/RY=;
        b=o1IntS4GdIz2DE6Mlpnhw/0+osJXlhDu/k3BvaWu2Sl70fj+klNMX59YZjVzVtVCL1
         hWHKmGgHW4D17yEivjRihKO+HcHxEwtG8X88K50ei1bQLQWlRv+CB+1cFl2+a8/gcOJv
         Cei53K2bHhmaEPOOqp+g0+d541Mh/ZeLUqgtXkmn6hAEKqLVMjEChO1mf2aBf+eNb0o7
         hovWHTsFp9PJx0g1Z77JouiNL64XTjTmt1EKLfPAqbfPUXlw01sEz1JNLC0bS+CjdN4n
         9iXY1RJaGvZSZfQpw08ar6KwwpRqB0CVNMlItYHoYI6EC+nXqAK40wLgC1nJo4hHYWyC
         VgnA==
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
   d="scan'208";a="169656541"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga002.fm.intel.com with ESMTP; 08 May 2019 07:44:40 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id E5276ABE; Wed,  8 May 2019 17:44:29 +0300 (EEST)
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
Subject: [PATCH, RFC 25/62] keys/mktme: Instantiate and destroy MKTME keys
Date: Wed,  8 May 2019 17:43:45 +0300
Message-Id: <20190508144422.13171-26-kirill.shutemov@linux.intel.com>
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

Instantiating and destroying are two Kernel Key Service methods
that are invoked by the kernel key service when a key is added
(add_key, request_key) or removed (invalidate, revoke, timeout).

During instantiation, MKTME needs to allocate an available hardware
KeyID and map it to the Userspace Key.

During destroy, MKTME wil returned the hardware KeyID to the pool of
available keys.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 92a047caa829..14bc4e600978 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -14,6 +14,8 @@
 
 #include "internal.h"
 
+static DEFINE_SPINLOCK(mktme_lock);
+
 /* 1:1 Mapping between Userspace Keys (struct key) and Hardware KeyIDs */
 struct mktme_mapping {
 	unsigned int	mapped_keyids;
@@ -95,6 +97,26 @@ struct mktme_payload {
 	u8		tweak_key[MKTME_AES_XTS_SIZE];
 };
 
+/* Key Service Method called when a Userspace Key is garbage collected. */
+static void mktme_destroy_key(struct key *key)
+{
+	mktme_release_keyid(mktme_keyid_from_key(key));
+}
+
+/* Key Service Method to create a new key. Payload is preparsed. */
+int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
+{
+	unsigned long flags;
+	int keyid;
+
+	spin_lock_irqsave(&mktme_lock, flags);
+	keyid = mktme_reserve_keyid(key);
+	spin_unlock_irqrestore(&mktme_lock, flags);
+	if (!keyid)
+		return -ENOKEY;
+	return 0;
+}
+
 /* Make sure arguments are correct for the TYPE of key requested */
 static int mktme_check_options(struct mktme_payload *payload,
 			       unsigned long token_mask, enum mktme_type type)
@@ -236,7 +258,9 @@ struct key_type key_type_mktme = {
 	.name		= "mktme",
 	.preparse	= mktme_preparse_payload,
 	.free_preparse	= mktme_free_preparsed_payload,
+	.instantiate	= mktme_instantiate_key,
 	.describe	= user_describe,
+	.destroy	= mktme_destroy_key,
 };
 
 static int __init init_mktme(void)
-- 
2.20.1

