Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66B8BC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23BD7216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23BD7216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 796636B0279; Wed,  8 May 2019 10:44:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F2656B027B; Wed,  8 May 2019 10:44:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C0FE6B027D; Wed,  8 May 2019 10:44:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B30D36B027B
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:47 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e20so12786773pgm.16
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=N2jLN5QWnTSH1XUYhZ/otarDGjastGUX2NwaocN9qk8=;
        b=hjU4N15FkiS+1qsPcyQvWXSPq+eAbeaVZ5Y23PtU5u5JQLmb3a4p3LxGdx1xl2Ef2r
         xmNjKl2fHaIyhBJUh1EHsUBttIxfX5Nivm6PA2KvBoSnrln6WCTo3MwDuP29d10i2Ivv
         w6oQZeYrZgk9osAe2dmEpiBy5XyYaY76q/kLAJ2Iu/Avr7TYgvtoCvlw7xg96KZwkhE9
         bIpkq3gU0wmjpvBsySw5QZ+x411H4S/+w6HDWuGB1GHl4aMRUgWBK0XjOZI/zfoTXSfi
         jTV2TLjC8WGk6WUIogJPN3mdgvwfhfkhrD6J9Gg/o/mI7xv5n5EetuorAq4MPNOCqxyw
         sc3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVS5NoWbtYe6raqMTM5/qA5Zcdgx13aIisWD8P1PLNBqyCsL2jC
	m6wTfFhZwFxkvcF1v5TKYaQWLqi41tTm2t267wJXookD225tu8YWhLAgw7lghEZUrFLdHk71A8p
	42RIeXjSRly3FC1B3+dy2Vu6OclSqPD7+GBV3CosCmhFB92hVsav/Ahl5ovXeTZUfKw==
X-Received: by 2002:a62:7a8f:: with SMTP id v137mr35046640pfc.243.1557326687371;
        Wed, 08 May 2019 07:44:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9KUkuKoUPUZGFTxS9ghF/dWdmesu5z9GO3b7oVCYDqNxdKJBnLbV9+Xal1cvygkA3aEeh
X-Received: by 2002:a62:7a8f:: with SMTP id v137mr35046486pfc.243.1557326685832;
        Wed, 08 May 2019 07:44:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326685; cv=none;
        d=google.com; s=arc-20160816;
        b=gGptEKwXf+v1uG+oqWH/HVJvbEMPWfK0l3WqsSlFyVTUDn0e9hAEIdmkR2Kj3ZR6Mm
         I4/Z0AxIGk8ni+LvSHfHeZjSYEN6iC3CGDOjlEwV/KdMylthSJ+hZzt6CcP+FKbKCbCn
         LufAzG/xVshqpQ5IFYvGP/7WMYld7sXCYVnqSMbfA0Y22D+Rmaa73p55K5O/gixr40qb
         q4trqtnQDDr3IVElSmnX/ErTvTrdxJ3GV5t4E8+30eQpsIsIjSR06ulzLJowTgMWp9F3
         KMTR3+FZd8bk/CxxCL79462i/bhXWuXz33Sk1Bl2sdGgNyD27RenSgEeWJ5eIimdmPH9
         LMIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=N2jLN5QWnTSH1XUYhZ/otarDGjastGUX2NwaocN9qk8=;
        b=N40M5XHpqfVYlNrTIpxiyQBgWP30PWrlEX+XDIX8V2tYXXpcvE+l1MMFhHd2ZsDe6d
         7JLZZhijk8yQVtW69docljXV4Lql+YJLsbuv07EBnHXyrtj+CvUqayxoIZF4DhgW5qoo
         U0gJeKJt4PFb/0jVJpEYlyQkAZhqLV7VG+9vZcCa0jpEkhnn+hZVCJkyvgMDG9L/sqWk
         RIxGo2lKSlhZF56mpsHG1Gerr+BW96SL88bHOglOhQg9n6B069OXiwBnyG+sKW2mCbBJ
         7P7fdh3z8eC1gFCNNJT7MI1gZ9hmZD6C8j5vC4nQ4qHdBQhVVLIFeH9sjpTDdewx1TWa
         IbOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 184si24250871pfg.32.2019.05.08.07.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:45 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga002.jf.intel.com with ESMTP; 08 May 2019 07:44:40 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id DA53DAA9; Wed,  8 May 2019 17:44:29 +0300 (EEST)
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
Subject: [PATCH, RFC 24/62] keys/mktme: Preparse the MKTME key payload
Date: Wed,  8 May 2019 17:43:44 +0300
Message-Id: <20190508144422.13171-25-kirill.shutemov@linux.intel.com>
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

It is a requirement of the Kernel Keys subsystem to provide a
preparse method that validates payloads before key instantiate
methods are called.

Verify that userspace provides valid MKTME options and prepare
the payload for use at key instantiate time.

Create a method to free the preparsed payload. The Kernel Key
subsystem will that to clean up after the key is instantiated.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/keys/mktme-type.h  |  39 +++++++++
 security/keys/mktme_keys.c | 165 +++++++++++++++++++++++++++++++++++++
 2 files changed, 204 insertions(+)
 create mode 100644 include/keys/mktme-type.h

diff --git a/include/keys/mktme-type.h b/include/keys/mktme-type.h
new file mode 100644
index 000000000000..032905b288b4
--- /dev/null
+++ b/include/keys/mktme-type.h
@@ -0,0 +1,39 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+/* Key service for Multi-KEY Total Memory Encryption */
+
+#ifndef _KEYS_MKTME_TYPE_H
+#define _KEYS_MKTME_TYPE_H
+
+#include <linux/key.h>
+
+/*
+ * The AES-XTS 128 encryption algorithm requires 128 bits for each
+ * user supplied data key and tweak key.
+ */
+#define MKTME_AES_XTS_SIZE	16	/* 16 bytes, 128 bits */
+
+enum mktme_alg {
+	MKTME_ALG_AES_XTS_128,
+};
+
+const char *const mktme_alg_names[] = {
+	[MKTME_ALG_AES_XTS_128]	= "aes-xts-128",
+};
+
+enum mktme_type {
+	MKTME_TYPE_ERROR = -1,
+	MKTME_TYPE_USER,
+	MKTME_TYPE_CPU,
+	MKTME_TYPE_NO_ENCRYPT,
+};
+
+const char *const mktme_type_names[] = {
+	[MKTME_TYPE_USER]	= "user",
+	[MKTME_TYPE_CPU]	= "cpu",
+	[MKTME_TYPE_NO_ENCRYPT]	= "no-encrypt",
+};
+
+extern struct key_type key_type_mktme;
+
+#endif /* _KEYS_MKTME_TYPE_H */
diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index b5e8289f041b..92a047caa829 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -6,6 +6,10 @@
 #include <linux/key.h>
 #include <linux/key-type.h>
 #include <linux/mm.h>
+#include <linux/parser.h>
+#include <linux/string.h>
+#include <asm/intel_pconfig.h>
+#include <keys/mktme-type.h>
 #include <keys/user-type.h>
 
 #include "internal.h"
@@ -69,8 +73,169 @@ int mktme_keyid_from_key(struct key *key)
 	return 0;
 }
 
+enum mktme_opt_id {
+	OPT_ERROR,
+	OPT_TYPE,
+	OPT_KEY,
+	OPT_TWEAK,
+	OPT_ALGORITHM,
+};
+
+static const match_table_t mktme_token = {
+	{OPT_TYPE, "type=%s"},
+	{OPT_KEY, "key=%s"},
+	{OPT_TWEAK, "tweak=%s"},
+	{OPT_ALGORITHM, "algorithm=%s"},
+	{OPT_ERROR, NULL}
+};
+
+struct mktme_payload {
+	u32		keyid_ctrl;	/* Command & Encryption Algorithm */
+	u8		data_key[MKTME_AES_XTS_SIZE];
+	u8		tweak_key[MKTME_AES_XTS_SIZE];
+};
+
+/* Make sure arguments are correct for the TYPE of key requested */
+static int mktme_check_options(struct mktme_payload *payload,
+			       unsigned long token_mask, enum mktme_type type)
+{
+	if (!token_mask)
+		return -EINVAL;
+
+	switch (type) {
+	case MKTME_TYPE_USER:
+		if (test_bit(OPT_ALGORITHM, &token_mask))
+			payload->keyid_ctrl |= MKTME_AES_XTS_128;
+		else
+			return -EINVAL;
+
+		if ((test_bit(OPT_KEY, &token_mask)) &&
+		    (test_bit(OPT_TWEAK, &token_mask)))
+			payload->keyid_ctrl |= MKTME_KEYID_SET_KEY_DIRECT;
+		else
+			return -EINVAL;
+		break;
+
+	case MKTME_TYPE_CPU:
+		if (test_bit(OPT_ALGORITHM, &token_mask))
+			payload->keyid_ctrl |= MKTME_AES_XTS_128;
+		else
+			return -EINVAL;
+
+		payload->keyid_ctrl |= MKTME_KEYID_SET_KEY_RANDOM;
+		break;
+
+	case MKTME_TYPE_NO_ENCRYPT:
+		payload->keyid_ctrl |= MKTME_KEYID_NO_ENCRYPT;
+		break;
+
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/* Parse the options and store the key programming data in the payload. */
+static int mktme_get_options(char *options, struct mktme_payload *payload)
+{
+	enum mktme_type type = MKTME_TYPE_ERROR;
+	substring_t args[MAX_OPT_ARGS];
+	unsigned long token_mask = 0;
+	char *p = options;
+	int ret, token;
+
+	while ((p = strsep(&options, " \t"))) {
+		if (*p == '\0' || *p == ' ' || *p == '\t')
+			continue;
+		token = match_token(p, mktme_token, args);
+		if (token == OPT_ERROR)
+			return -EINVAL;
+		if (test_and_set_bit(token, &token_mask))
+			return -EINVAL;
+
+		switch (token) {
+		case OPT_KEY:
+			ret = hex2bin(payload->data_key, args[0].from,
+				      MKTME_AES_XTS_SIZE);
+			if (ret < 0)
+				return -EINVAL;
+			break;
+
+		case OPT_TWEAK:
+			ret = hex2bin(payload->tweak_key, args[0].from,
+				      MKTME_AES_XTS_SIZE);
+			if (ret < 0)
+				return -EINVAL;
+			break;
+
+		case OPT_TYPE:
+			type = match_string(mktme_type_names,
+					    ARRAY_SIZE(mktme_type_names),
+					    args[0].from);
+			if (type < 0)
+				return -EINVAL;
+			break;
+
+		case OPT_ALGORITHM:
+			ret = match_string(mktme_alg_names,
+					   ARRAY_SIZE(mktme_alg_names),
+					   args[0].from);
+			if (ret < 0)
+				return -EINVAL;
+			break;
+
+		default:
+			return -EINVAL;
+		}
+	}
+	return mktme_check_options(payload, token_mask, type);
+}
+
+void mktme_free_preparsed_payload(struct key_preparsed_payload *prep)
+{
+	kzfree(prep->payload.data[0]);
+}
+
+/*
+ * Key Service Method to preparse a payload before a key is created.
+ * Check permissions and the options. Load the proposed key field
+ * data into the payload for use by the instantiate method.
+ */
+int mktme_preparse_payload(struct key_preparsed_payload *prep)
+{
+	struct mktme_payload *mktme_payload;
+	size_t datalen = prep->datalen;
+	char *options;
+	int ret;
+
+	if (datalen <= 0 || datalen > 1024 || !prep->data)
+		return -EINVAL;
+
+	options = kmemdup_nul(prep->data, datalen, GFP_KERNEL);
+	if (!options)
+		return -ENOMEM;
+
+	mktme_payload = kzalloc(sizeof(*mktme_payload), GFP_KERNEL);
+	if (!mktme_payload) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	ret = mktme_get_options(options, mktme_payload);
+	if (ret < 0) {
+		kzfree(mktme_payload);
+		goto out;
+	}
+	prep->quotalen = sizeof(mktme_payload);
+	prep->payload.data[0] = mktme_payload;
+out:
+	kzfree(options);
+	return ret;
+}
+
 struct key_type key_type_mktme = {
 	.name		= "mktme",
+	.preparse	= mktme_preparse_payload,
+	.free_preparse	= mktme_free_preparsed_payload,
 	.describe	= user_describe,
 };
 
-- 
2.20.1

