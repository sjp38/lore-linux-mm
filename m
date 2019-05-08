Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3937C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6540521734
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6540521734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E44276B0298; Wed,  8 May 2019 10:44:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCCB66B029C; Wed,  8 May 2019 10:44:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C47546B0299; Wed,  8 May 2019 10:44:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE096B0294
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:50 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id x5so11673677pll.2
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dqpuT+9O5x3PWBM5fykV5GjRYUg/5N+OL/uQud0+8W0=;
        b=QL9uz1RNlt6N/td+o4bVva0hRulTt8nTnBYAlUfSqzqYal4ZOysAF6WS7RNjWQPIX7
         QPUqP33MC7xXWd0UzXvxlKCQ4UgGoVEW1OxHLy6p/f/cmCD2Hp0LngqhSEiHk1odPe/C
         WE7rizJtRBPlk9jGvdVM8RIaBF+XVk79xnk1GL/vA8yGMZ4foVUCZjPzWyJcm/FFE6GJ
         19N6Vt+jEQgqm6w3NW+2tZMt+8b4TctC0Yq2w9EOa/ONWxcYN74LL0qYQavXK8fqRNwI
         EhcLlrBQi0CVc+E9zxM/hLk4lveVXhLO4jRxdDtrzyhXLKHFrZ3GwoaL3ds5xjn7pagb
         5OfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX/PAHjt6I447S0klQuSBmnhbgTgHN8Z6ne4PVoNjnb15iZZi78
	uJ+R78B4Cn8gkjoVuBRLqJPPGkWMnfjMXWRtRNsu6a8W/AIeNrso5aQvz1ZwCaCgiqXN70TCbnl
	wVqPlTih7UQU/dC23fjdDUqy+IcmGIuTHlvMbG8yxXrQXJNYEEM3IBnaP08XzMy5HUQ==
X-Received: by 2002:aa7:8453:: with SMTP id r19mr49297083pfn.44.1557326690207;
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjrfcJdRf/lo4bmSwi1gynLMKwX56dwUgLbUukBuqSM4Rw+3QNUu8TUPgvS2D9NLj5+/BO
X-Received: by 2002:aa7:8453:: with SMTP id r19mr49296941pfn.44.1557326688877;
        Wed, 08 May 2019 07:44:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326688; cv=none;
        d=google.com; s=arc-20160816;
        b=PcvJUUnrDKOdOAU+I+U4P5O9RSTkyHZjFImaJnI7g4c3nMZbvAoZAZJxiIBkN2a2Mb
         t34IFNqFSwBW/SeOOxQewmHLlDn2FmBV29X4UYrvuPoT7vPyRy28oSITxHyy6SeHPiDO
         OpMJVyokUPj6gWrFpR8tMwKW2TTKu7Eg5AWtliLWoGCgyg/izV9lV44tqKatSo7OlnzC
         +eYai/VM0r2d2OOpc0GVRwtnRf8nDI3pXfD4ti/fXDV0vOsSp1XSRWDA2f7uTf7iMM2G
         uBYnV1QcETra9RWWAGmUmorLM90JPToSxrnf5QxjPHqN52S8kFgmxp7PHTmarKTbwkbT
         w5ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=dqpuT+9O5x3PWBM5fykV5GjRYUg/5N+OL/uQud0+8W0=;
        b=JKmV8vKTiVpR+fqSu5zEPLGMmc2LsJgZVajua9eURSjkDsbiY0/6fwfI2I9jJcewcx
         hje8v0dXZka23X5RTVzuEq86MvAsKRiadKqRgGvHslauB4bU5C+iMqKqU3Lg4hqhc8J9
         QEw4ujDP+C4Jj/6EcrqO5fZ2xi6761PqkIRcwTDME2oYgZFFe8CDl/gaqWSua1+rKIwY
         2ywNv8NA3NFSgmFxvk7o1jnxNBjhox2DcuXPbMd+/FUABZA8zW1mZwR4p//ssKqAYo64
         d+sVvM/yEPNc8kxLALsIufXooHyodc2YnQo99DiDfEFFwzTPHsNyZ0FJlDl6s3XeJzfh
         DAeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 184si24250871pfg.32.2019.05.08.07.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:48 -0700 (PDT)
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
   d="scan'208";a="169656560"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga002.fm.intel.com with ESMTP; 08 May 2019 07:44:44 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 8506EBF5; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
Subject: [PATCH, RFC 37/62] keys/mktme: Do not allow key creation in unsafe topologies
Date: Wed,  8 May 2019 17:43:57 +0300
Message-Id: <20190508144422.13171-38-kirill.shutemov@linux.intel.com>
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

MKTME feature depends upon at least one online CPU capable of
programming each memory controller in the platform.

An unsafe topology for MKTME is a memory only package or a package
with no online CPUs. Key creation with unsafe topologies will fail
with EINVAL and a warning will be logged one time.
For example:
	[ ] MKTME: no online CPU in proximity domain
	[ ] MKTME: topology does not support key creation

These are recoverable errors. CPUs may be brought online that are
capable of programming a previously unprogrammable memory controller,
or an unprogrammable memory controller may be removed from the
platform.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 39 ++++++++++++++++++++++++++++++--------
 1 file changed, 31 insertions(+), 8 deletions(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index f5fc6cccc81b..734e1d28eb24 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -26,6 +26,7 @@ cpumask_var_t mktme_leadcpus;		/* One lead CPU per pconfig target */
 static bool mktme_storekeys;		/* True if key payloads may be stored */
 unsigned long *mktme_bitmap_user_type;	/* Shows presence of user type keys */
 struct mktme_payload *mktme_key_store;	/* Payload storage if allowed */
+bool mktme_allow_keys;			/* True when topology supports keys */
 
 /* 1:1 Mapping between Userspace Keys (struct key) and Hardware KeyIDs */
 struct mktme_mapping {
@@ -278,33 +279,55 @@ static void mktme_destroy_key(struct key *key)
 	percpu_ref_kill(&encrypt_count[keyid]);
 }
 
+static void mktme_update_pconfig_targets(void);
 /* Key Service Method to create a new key. Payload is preparsed. */
 int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
 {
 	struct mktme_payload *payload = prep->payload.data[0];
 	unsigned long flags;
+	int ret = -ENOKEY;
 	int keyid;
 
 	spin_lock_irqsave(&mktme_lock, flags);
+
+	/* Topology supports key creation */
+	if (mktme_allow_keys)
+		goto get_key;
+
+	/* Topology unknown, check it. */
+	if (!mktme_hmat_evaluate()) {
+		ret = -EINVAL;
+		goto out_unlock;
+	}
+
+	/* Keys are now allowed. Update the programming targets. */
+	mktme_update_pconfig_targets();
+	mktme_allow_keys = true;
+
+get_key:
 	keyid = mktme_reserve_keyid(key);
 	spin_unlock_irqrestore(&mktme_lock, flags);
 	if (!keyid)
-		return -ENOKEY;
+		goto out;
 
 	if (percpu_ref_init(&encrypt_count[keyid], mktme_percpu_ref_release,
 			    0, GFP_KERNEL))
-		goto err_out;
+		goto out_free_key;
 
-	if (!mktme_program_keyid(keyid, payload)) {
-		mktme_store_payload(keyid, payload);
-		return MKTME_PROG_SUCCESS;
-	}
+	ret = mktme_program_keyid(keyid, payload);
+	if (ret == MKTME_PROG_SUCCESS)
+		goto out;
+
+	/* Key programming failed */
 	percpu_ref_exit(&encrypt_count[keyid]);
-err_out:
+
+out_free_key:
 	spin_lock_irqsave(&mktme_lock, flags);
 	mktme_release_keyid(keyid);
+out_unlock:
 	spin_unlock_irqrestore(&mktme_lock, flags);
-	return -ENOKEY;
+out:
+	return ret;
 }
 
 /* Make sure arguments are correct for the TYPE of key requested */
-- 
2.20.1

