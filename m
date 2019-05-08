Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39326C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBCAE216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBCAE216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AC4D6B0294; Wed,  8 May 2019 10:44:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 395896B0299; Wed,  8 May 2019 10:44:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F072E6B029A; Wed,  8 May 2019 10:44:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B30AA6B0297
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id h12so3686968pll.20
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=018UgTJ/DlaExsBeCC+mPQWwJqpTOkW1qegnhZScuV8=;
        b=csfgWsPCDr9L2Lh3FB4zJvll+Y/NnkpoXo8OOF26d8FEXaQuSt1aztFCmxWO5fs1db
         MoOX/jktqAg5lEnuVL68kCCIP66JP1oUPo+NZqa9NEolV4fz31VCjQHuuAwjUr/9MWoS
         P/GDW37RU/T6lko4i6RuaXYutW0EG4lDRwMnkzKjIIBc4T6hX3QQSer1kEsy6tdKwcgM
         bOpDwiubBV82D03x099uXngeCMHHhK84o2OMWekHLv3JvzEnVABSu57UsQc2ttoAnkZ+
         0oocLeIR2eyfYla9viiN9kMd+cOxQOf/+0iLnxyC49T0LILPOAw/drDF6V2SScsQH8Ro
         2IFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUsx6t0BY4YsNFcr4/4CZ7igTd2Rk0VbZyGgKjkQ0+NO7M2GFs5
	GmFsFzpvXlFrRGvvNSsiTWczABRLXasY2FoWbP+ILMf9Y4Kh546Gv5i129csQtcK0AksiVrGrJ/
	B2YLcLXl9SBYUru9SdHS5CxVYcoulwaLcD6oLrW96ZU0gHLz6IFMAAMoByt94NxKs3A==
X-Received: by 2002:a63:e550:: with SMTP id z16mr47672840pgj.329.1557326690383;
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIO9juUSnQtnsd4NeyzGy1v37YGOOoiLJ7sv0YIj6RkrEJwcFv5fPookjCKnCgWZvWCjwD
X-Received: by 2002:a63:e550:: with SMTP id z16mr47672705pgj.329.1557326689098;
        Wed, 08 May 2019 07:44:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326689; cv=none;
        d=google.com; s=arc-20160816;
        b=AkmmHFbAGf8v/KhKSJFbcYdSmPZi41GjXtl8B5H8cBIBBJ7wVNtyQ6FEL3A3oPou5d
         BdRvrs4sS3o2NrROVhS28SKOyp/P3yFP0SqH9Ei3NqPChslRwTDFHV2rANANXq2uE0ok
         hUqbGEJW89KXJJRBQ3KGaxrhOQaNxa5vlcaa/qSJWnqFQDL74UdEx6JIbwflt3KRGBwY
         NZ/i/CPK90EeNBLGdvaSrzNH9LcMs7hWqv+QtKLGwoUTT8yhwh19oYYyxi8Onhjgd7F4
         pI6PscGEqr5o5M5/GJHxjNEq+o4A33xMT8LGzcvTbkyH8YpgoPNewYuBfYMA7hGSZqfD
         yj7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=018UgTJ/DlaExsBeCC+mPQWwJqpTOkW1qegnhZScuV8=;
        b=UnZEB2SNlXvRkk1z21okME1pN82FwFK1YmSB1KWZLdzCRSbWu/RYA9K+l5tNb/QVmi
         BfRDGdBFeDWcwsybqB4mglyEvs0GbQEcJT/J5PTOg4YhB+aoMcGHb0U39MIqnlkcb8K5
         1XT9ML3XH7LPPd2txuiFugsft9cNj1vxhsBpZbUK0iwSY2eMlo1gh2RaC6TQ0KjK6qNI
         diiMXnJFzJJr9dnTl6JuZTTfWC/j7iY53kwPctmlfQvAFPb0FBxNt38ImY/D2GLr/3J+
         yL2gD2Vq0g/zVwPqEkY4IizvZXWSzSFudGbghuHJuLuZ/lBkLDa5RwUKdwEeJf98Isr+
         +ZJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 184si24250871pfg.32.2019.05.08.07.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:48 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,446,1549958400"; 
   d="scan'208";a="169656563"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga002.fm.intel.com with ESMTP; 08 May 2019 07:44:44 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id B16F3D2B; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
Subject: [PATCH, RFC 40/62] keys/mktme: Program new PCONFIG targets with MKTME keys
Date: Wed,  8 May 2019 17:44:00 +0300
Message-Id: <20190508144422.13171-41-kirill.shutemov@linux.intel.com>
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

When a new PCONFIG target is added to an MKTME platform, its
key table needs to be programmed to match the key tables across
the entire platform. This type of newly added PCONFIG target
may appear during a memory hotplug event.

This key programming path will differ from the normal key
programming path in that it will only program a single PCONFIG
target, AND, it will only do that programming if allowed.

Allowed means that either user type keys are stored, or, no
user type keys are currently programmed.

So, after checking if programming is allowable, this helper
function will program the one new PCONFIG target, with all
the currently programmed keys.

This will be used in MKTME's memory notifier callback supporting
MEM_GOING_ONLINE events.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 44 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 2c975c48fe44..489dddb8c623 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -582,6 +582,50 @@ static int mktme_get_new_pconfig_target(void)
 	return new_target;
 }
 
+static int mktme_program_new_pconfig_target(int new_pkg)
+{
+	struct mktme_payload *payload;
+	int cpu, keyid, ret;
+
+	/*
+	 * Only program new target when user type keys are stored or,
+	 * no user type keys are currently programmed.
+	 */
+	if (!mktme_storekeys &&
+	    (bitmap_weight(mktme_bitmap_user_type, mktme_nr_keyids)))
+		return -EPERM;
+
+	/* Set mktme_leadcpus to only include new target */
+	cpumask_clear(mktme_leadcpus);
+	for_each_online_cpu(cpu) {
+		if (topology_physical_package_id(cpu) == new_pkg) {
+			__cpumask_set_cpu(cpu, mktme_leadcpus);
+			break;
+		}
+	}
+	/* Program the stored keys into the new key table */
+	for (keyid = 1; keyid <= mktme_nr_keyids; keyid++) {
+		/*
+		 * When a KeyID slot is not in use, the corresponding key
+		 * pointer is 0. '-1' is an intermediate state where the
+		 * key is on it's way out, but not gone yet. Program '-1's.
+		 */
+		if (mktme_map->key[keyid] == 0)
+			continue;
+
+		payload = &mktme_key_store[keyid];
+		ret = mktme_program_keyid(keyid, payload);
+		if (ret != MKTME_PROG_SUCCESS) {
+			/* Quit on first failure to program key table */
+			pr_debug("mktme: %s\n", mktme_error[ret].msg);
+			ret = -ENOKEY;
+			break;
+		}
+	}
+	mktme_update_pconfig_targets();		/* Restore mktme_leadcpus */
+	return ret;
+}
+
 static int __init init_mktme(void)
 {
 	int ret, cpuhp;
-- 
2.20.1

