Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34003C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E447D216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E447D216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A78966B027B; Wed,  8 May 2019 10:44:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C9286B027F; Wed,  8 May 2019 10:44:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45AA26B027C; Wed,  8 May 2019 10:44:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F187B6B027C
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:47 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a17so12769955pff.6
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nxgctlSwkuGLHPGiqehWnGCrtge4VEN6ON3Go+SCJw4=;
        b=ZHx3B1MPVs6OvBV7G4+udvcC9tSoW+jjrqFZbYNxxdzYqreRr1UckP9IudeCK6oRZa
         zICLeiy0N5XkKxEGdSvnhCGY+RK+oeYHZ++usbInig3SCyHblanZjQE3Yo1z2Q5JMr82
         EbJimbfWoxAh+lLMPKaMGiGPLXCnDoPVbnDryFpwpob7d6oyAQ3lZPJNNjExkztJ/VqO
         Uw7gIcqsV+TacbtGffjsCB7PziZq130Zuso+s9nKEq0Uxde8G8msuKJknOdsaAOIDl8V
         53+8bg3xWwHPG+3B/5A5wNAgeUw26t95Kl1/LSMHEt0V1QyH0H2eCKfUPgfW7OnZkkxx
         1jnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVCqGPhnOnFWu8hTaqXw9UeFrFSOUoh2I+9zGLEBkrShpKnglkQ
	dH6Y3Seyt8NnKWXkwCGqAr0yRP8e8P/8QAUIKyfsLcMgfq22Gg2sinrpArQf1Aui9JdMbq7/w33
	qed1aev1eXqu+v8FggLPZi4Aq3W6n9TmHBJRsGXqqDCXduHdIEPc2Nqdzr8PPWmlmMg==
X-Received: by 2002:a62:69c2:: with SMTP id e185mr49001193pfc.119.1557326687637;
        Wed, 08 May 2019 07:44:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzByFr+Ed0brEv7i1/DSZk8GmzBnA7p1kR7WfFlX1juJunA6VirECYxLVdsY2EuW0iswaaS
X-Received: by 2002:a62:69c2:: with SMTP id e185mr49001070pfc.119.1557326686352;
        Wed, 08 May 2019 07:44:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326686; cv=none;
        d=google.com; s=arc-20160816;
        b=Uza0k61Y3ofiCe8bJ6G3lAJN/htTuex3F7At5UzynchNH4iHSwPBDrb1I2qZwSNscV
         LqZ5NhyQnpDr5CF/gOYwMvjc9wDLs5xv62VATcUyq+Gg8wA2+kkPtzmU3Vdb8MvEaz3u
         T0Z7F6jPIWpqYFHFE/IRMC3EFJsnKDg/D1JzkuaHD8hf/G5BYCqPOk6uhClNRy8EWWmi
         fRIGLEiNYnzQzOJYAEwwuK6C4AEWgfBubbizU8XIw4Ph+87hGuB1+zH8cBPdQbT8gv5r
         SVfsY28dR0CXqMq+933Ot/8VGxRmwTXBLRCWy75jl96692OF/klHtsTNvHbA7f54sGnh
         QpzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=nxgctlSwkuGLHPGiqehWnGCrtge4VEN6ON3Go+SCJw4=;
        b=woZ8Ed+yYba5NdFye/4mt17U36b8dxuG8Jq5ChVOu78B7rV7wZtkYxoezD7C7/RhXA
         egdsQBU62RyK7CTfTI2i9FWDx2rBfhi9FHLJBBgmzkXLThu+5vN4APhvQVxGrUHc3S3T
         dmGBHwJg1IXKg5Z/ZaFDgsuvv4286VX6qiJOo01azmtfByo2/IZR3yOFuMl2D02H4oPq
         Jp8efYAF/1aDAmoW2Z5XFa+bQ9U0uKBtrOZaC47IhC3rROdncqEQZ/MME9triU6hkBeC
         4oZT6pgPl8b/BUKt7//rMmgmODYm0m2goGx6HvVpW5CMINPhdvdKQPyljle5bmzamylv
         dkPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d3si22507173pfc.278.2019.05.08.07.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:45 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga001.jf.intel.com with ESMTP; 08 May 2019 07:44:40 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 297B6B2F; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
Subject: [PATCH, RFC 30/62] keys/mktme: Set up a percpu_ref_count for MKTME keys
Date: Wed,  8 May 2019 17:43:50 +0300
Message-Id: <20190508144422.13171-31-kirill.shutemov@linux.intel.com>
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

The MKTME key service needs to keep usage counts on the encryption
keys in order to know when it is safe to free a key for reuse.

percpu_ref_count applies well here because the key service will
take the initial reference and typically hold that reference while
the intermediary references are get/put. The intermediaries in this
case are the encrypted VMA's.

Align the percpu_ref_init and percpu_ref_kill with the key service
instantiate and destroy methods respectively.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 40 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 39 insertions(+), 1 deletion(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index f70533b1a7fd..496b5c1b7461 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -8,6 +8,7 @@
 #include <linux/key-type.h>
 #include <linux/mm.h>
 #include <linux/parser.h>
+#include <linux/percpu-refcount.h>
 #include <linux/random.h>
 #include <linux/string.h>
 #include <asm/intel_pconfig.h>
@@ -80,6 +81,26 @@ int mktme_keyid_from_key(struct key *key)
 	return 0;
 }
 
+struct percpu_ref *encrypt_count;
+void mktme_percpu_ref_release(struct percpu_ref *ref)
+{
+	unsigned long flags;
+	int keyid;
+
+	for (keyid = 1; keyid <= mktme_nr_keyids; keyid++) {
+		if (&encrypt_count[keyid] == ref)
+			break;
+	}
+	if (&encrypt_count[keyid] != ref) {
+		pr_debug("%s: invalid ref counter\n", __func__);
+		return;
+	}
+	percpu_ref_exit(ref);
+	spin_lock_irqsave(&mktme_map_lock, flags);
+	mktme_release_keyid(keyid);
+	spin_unlock_irqrestore(&mktme_map_lock, flags);
+}
+
 enum mktme_opt_id {
 	OPT_ERROR,
 	OPT_TYPE,
@@ -225,7 +246,10 @@ static int mktme_program_keyid(int keyid, struct mktme_payload *payload)
 /* Key Service Method called when a Userspace Key is garbage collected. */
 static void mktme_destroy_key(struct key *key)
 {
-	mktme_release_keyid(mktme_keyid_from_key(key));
+	int keyid = mktme_keyid_from_key(key);
+
+	mktme_map->key[keyid] = (void *)-1;
+	percpu_ref_kill(&encrypt_count[keyid]);
 }
 
 /* Key Service Method to create a new key. Payload is preparsed. */
@@ -241,9 +265,15 @@ int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
 	if (!keyid)
 		return -ENOKEY;
 
+	if (percpu_ref_init(&encrypt_count[keyid], mktme_percpu_ref_release,
+			    0, GFP_KERNEL))
+		goto err_out;
+
 	if (!mktme_program_keyid(keyid, payload))
 		return MKTME_PROG_SUCCESS;
 
+	percpu_ref_exit(&encrypt_count[keyid]);
+err_out:
 	spin_lock_irqsave(&mktme_lock, flags);
 	mktme_release_keyid(keyid);
 	spin_unlock_irqrestore(&mktme_lock, flags);
@@ -447,10 +477,18 @@ static int __init init_mktme(void)
 	/* Initialize first programming targets */
 	mktme_update_pconfig_targets();
 
+	/* Reference counters to protect in use KeyIDs */
+	encrypt_count = kvcalloc(mktme_nr_keyids + 1, sizeof(encrypt_count[0]),
+				 GFP_KERNEL);
+	if (!encrypt_count)
+		goto free_targets;
+
 	ret = register_key_type(&key_type_mktme);
 	if (!ret)
 		return ret;			/* SUCCESS */
 
+	kvfree(encrypt_count);
+free_targets:
 	free_cpumask_var(mktme_leadcpus);
 	bitmap_free(mktme_target_map);
 free_cache:
-- 
2.20.1

