Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F3F8C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D81F216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D81F216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E91FC6B0277; Wed,  8 May 2019 10:44:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E43ED6B0278; Wed,  8 May 2019 10:44:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0D616B0279; Wed,  8 May 2019 10:44:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6546B0277
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:46 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s19so11646772plp.6
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xvq7Qpxy3tYrBN7UYa84bMjbm+FLBqPlB9IY6Yr2j34=;
        b=ponJe43VydunEP+wx9jXqnx3L02lGSFI5Hk7HHWLAwX6H2itu3Yi1Ym7HDNOwq+RZA
         tCX6vnqADmRURFaBtBZRFzfTmxdz8MlzjoBRkURsx+KVDDl4QoruEo26jVuzngt7CaIp
         kpCJwprt7OJBYqfK+PdboKIXI+tKuoDlFztR92QwckPjsnJ8goOJQP1Z24PHevjR9Uhz
         YFz2L6aaHYs04wyOQNd8Y8gmURF1reMwth+abM+i9INGtpcFGD/6p0/GUAt4ssF0PGhe
         w2DMC0nQr1NNwIdWg1zxGahaQWXZCqs4gIt64IltPt0vWZ2p/xQ1fIiJmCzKrWB42DGZ
         hk7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWwx4fZ3/crSBaeoDuN/NSHwCQ6ywB0ksJzeVrlXNaW89j97XQS
	Mk9bFaKQuNYatmK40CvBscpXXlE93mM77HHTgpsdAwPVuvEUld/7KMbf0f0HV8F4F/IhljkxHEw
	8GaMqEe59idQQ/srlBYNJcloLdZJwslFcAZ1tCJhwOJDlCjNZAKDaOF6eC3doEEBL+w==
X-Received: by 2002:a17:902:be09:: with SMTP id r9mr47942329pls.215.1557326686149;
        Wed, 08 May 2019 07:44:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnWas7vQv5LLRJItsZhmRhYnnBO+HiUyw2YB7bvLzllJT4XS2QtVEYmErpZ3GwhdooyZl9
X-Received: by 2002:a17:902:be09:: with SMTP id r9mr47942202pls.215.1557326684825;
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326684; cv=none;
        d=google.com; s=arc-20160816;
        b=A8OioIrrpTNL6TL5Tt9di7JYKl3m0lQaAo/5DDlPjJnnL1YA9URbazP9agcIguhxZo
         2qSTbtuluK4rKQmrpDf1ZxnsxLzoRMUizHUuHASwMlNPacfb8xN0scZArV2KQO5Gqzvz
         Vly+sQ0awJHML74KekofspVRLSRlIhPBSwjSWDq3S1KjCqb4kbDWG+OuCAq1LelSrMB9
         ag+Hsce2RFNoEZslUx7xrRsGMWUkV4+xMmxpA4hQFBcsoyKhbcjeKa6R+MyPw+YNqW2W
         08iEgjc096YHolU9s8FYoJOx2A9lXhU9PHc4NayW9VS0K+SG0OKQ6irR6DHMEUcwkwKd
         QnIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=xvq7Qpxy3tYrBN7UYa84bMjbm+FLBqPlB9IY6Yr2j34=;
        b=ycBFKgAXSaZtYXqFBToo5QAAqlzIO8mXUEHE5/mUA9n1FP8PCKvhvkEsmWs4sz7dcs
         0KmhRqqRRpDoPcLsEmoW/v3D+4hXXEPZXrsldJi96CoDrSn1/6XkpNtxdAj1R3JgsiKF
         Ujdl0zfH9sPzSDmjLTtKHBibI5rh9SsXHpuIHPFZqCmHAzQYsfDEQr8TGTy7orbD0GUK
         6CnZplR6PEqZ2km6zk3o5aBAdKVLQt+wi4NNZmwBa/EDoiqjDdyG2ibp6RiJBbAGkP3w
         6ta3gvigxpiAMBHJj/FH4r6qJ4mq5dCc0fWiYE35WSGGQ2q85f1naa+GcVn/imiOvW3G
         3f9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g8si22265475plt.4.2019.05.08.07.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:44 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga005.fm.intel.com with ESMTP; 08 May 2019 07:44:39 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id EFE6EAC1; Wed,  8 May 2019 17:44:29 +0300 (EEST)
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
Subject: [PATCH, RFC 26/62] keys/mktme: Move the MKTME payload into a cache aligned structure
Date: Wed,  8 May 2019 17:43:46 +0300
Message-Id: <20190508144422.13171-27-kirill.shutemov@linux.intel.com>
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

In preparation for programming the key into the hardware, move
the key payload into a cache aligned structure. This alignment
is a requirement of the MKTME hardware.

Use the slab allocator to have this structure readily available.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 39 ++++++++++++++++++++++++++++++++++++--
 1 file changed, 37 insertions(+), 2 deletions(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 14bc4e600978..a7ca32865a1c 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -15,6 +15,7 @@
 #include "internal.h"
 
 static DEFINE_SPINLOCK(mktme_lock);
+struct kmem_cache *mktme_prog_cache;	/* Hardware programming cache */
 
 /* 1:1 Mapping between Userspace Keys (struct key) and Hardware KeyIDs */
 struct mktme_mapping {
@@ -97,6 +98,27 @@ struct mktme_payload {
 	u8		tweak_key[MKTME_AES_XTS_SIZE];
 };
 
+/* Copy the payload to the HW programming structure and program this KeyID */
+static int mktme_program_keyid(int keyid, struct mktme_payload *payload)
+{
+	struct mktme_key_program *kprog = NULL;
+	int ret;
+
+	kprog = kmem_cache_zalloc(mktme_prog_cache, GFP_ATOMIC);
+	if (!kprog)
+		return -ENOMEM;
+
+	/* Hardware programming requires cached aligned struct */
+	kprog->keyid = keyid;
+	kprog->keyid_ctrl = payload->keyid_ctrl;
+	memcpy(kprog->key_field_1, payload->data_key, MKTME_AES_XTS_SIZE);
+	memcpy(kprog->key_field_2, payload->tweak_key, MKTME_AES_XTS_SIZE);
+
+	ret = MKTME_PROG_SUCCESS;	/* Future programming call */
+	kmem_cache_free(mktme_prog_cache, kprog);
+	return ret;
+}
+
 /* Key Service Method called when a Userspace Key is garbage collected. */
 static void mktme_destroy_key(struct key *key)
 {
@@ -106,6 +128,7 @@ static void mktme_destroy_key(struct key *key)
 /* Key Service Method to create a new key. Payload is preparsed. */
 int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
 {
+	struct mktme_payload *payload = prep->payload.data[0];
 	unsigned long flags;
 	int keyid;
 
@@ -114,7 +137,14 @@ int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
 	spin_unlock_irqrestore(&mktme_lock, flags);
 	if (!keyid)
 		return -ENOKEY;
-	return 0;
+
+	if (!mktme_program_keyid(keyid, payload))
+		return MKTME_PROG_SUCCESS;
+
+	spin_lock_irqsave(&mktme_lock, flags);
+	mktme_release_keyid(keyid);
+	spin_unlock_irqrestore(&mktme_lock, flags);
+	return -ENOKEY;
 }
 
 /* Make sure arguments are correct for the TYPE of key requested */
@@ -275,10 +305,15 @@ static int __init init_mktme(void)
 	if (mktme_map_alloc())
 		return -ENOMEM;
 
+	/* Used to program the hardware key tables */
+	mktme_prog_cache = KMEM_CACHE(mktme_key_program, SLAB_PANIC);
+	if (!mktme_prog_cache)
+		goto free_map;
+
 	ret = register_key_type(&key_type_mktme);
 	if (!ret)
 		return ret;			/* SUCCESS */
-
+free_map:
 	kvfree(mktme_map);
 
 	return -ENOMEM;
-- 
2.20.1

