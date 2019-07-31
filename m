Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C759C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D909A208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="UeQPYBDU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D909A208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B8A68E0019; Wed, 31 Jul 2019 11:08:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 768F68E001A; Wed, 31 Jul 2019 11:08:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 593B98E0019; Wed, 31 Jul 2019 11:08:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 035F98E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so42624210ede.0
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=p3ZdWpQd4xgv1kA6jDtn8atrxpLedHc/tVwU2ev+R3g=;
        b=soN3ffNhMTMz6O0h551B6GwS2dh5Jda89JvQlDL4tpf5Ye/dbHCXwiFxKeNGADvSdp
         7IT6fYNubKDhJ57WcUE/AijxUEnMf8gvnrR68uTVQ/Z+EloITGkCRx5zWTZQIyjAAsNR
         DXNq1Y+7Cl/JgFErXCQp6el3KpnA0bMkvIsXdVSoOpgmwG3bmnEVZWN77Zq0etvS8hrh
         bV44Q+17Ul0Dan/oR/g1gdXrH4IrLNjuYlNHOTxrkMXNsOEnUK6lBsk7yvb8otsyk19+
         Alo44DfdCR6AKQCzx28d/jwZfGmfPDkN+QFgOmfiBj59DyfDaiYvbFhzRs8TK9ldEGrl
         Eumg==
X-Gm-Message-State: APjAAAU5TuzBSFCIO+5B8zLJ48TTLaGNRL+Z7EeuV0rtaEvJcnDbh36P
	DgPN+ZB7hmgRguEYKASk4/Arb2r0UfwyZlbLcu6nbVM18hGd39a8I0ws9lA5zTVGf3GLHpfgtwp
	ZB0aJV8OzQS73sfCHoPLwC0AY39+VzMRu8rl5rzY3NTEMgJArV3rPpDU0YlGqCGc=
X-Received: by 2002:a17:906:4e92:: with SMTP id v18mr98197439eju.57.1564585711550;
        Wed, 31 Jul 2019 08:08:31 -0700 (PDT)
X-Received: by 2002:a17:906:4e92:: with SMTP id v18mr98197297eju.57.1564585710074;
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585710; cv=none;
        d=google.com; s=arc-20160816;
        b=VA8n5kUIIToN3rJa17LmOxbmEMJNuwFsLSJHF1B123nYCtNNeswAKmxMzXUyElIzl6
         G0lDtvg0HLwuPRxgyklXLtsOgjsXuICwIAeXDtc2zvN/5nrmmJj2mfbXgX3NPYyJnost
         PUkmxbnIscG2bN0LVLg51R15MU1yfZHnNHSBKsIaDi8XSNtTZE3IzEPUiUqR9bkURwMC
         1Tq91LraLrr8468uNtJN998hiqyTXlGkWNS+L8V83uliJ9pjG/h+86MtiYfNSq3jICNh
         1kHpyVrkgpLE/WOxcTLnWQ75pRWovknzICxXAp6Gb+Pacq27g0tT9tTe48CzGJSdLh0M
         Qzgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=p3ZdWpQd4xgv1kA6jDtn8atrxpLedHc/tVwU2ev+R3g=;
        b=GZRA0+cX7EUU4r01tIOiR3gnpvLl60vdsmrq1gOLnr5ZVtjH5nsvBNcHYiPCuAMKVa
         fj+rqYGyOOmFOaeLUNoKCroOPw19AccDyCZroDCT5AlNdqrKezd2FaPWmU5eIFVTjv5b
         N8aZoG03W1Hsg7LTfm6IVfwex+DOZa+0kuwf7YlJL/QifpXokqgHyNi78G2xGEcPT4hH
         oad6rA3s7OnY+Gw4ydfe+b08RDAbJNNK1vBciS0plshaHpM6uB4I9tTSrHmsqal3X25F
         SN4XmV2jNXW4LnaCOvqsiKxbcTao9cmbBgbGW6Eax2DtB3EiebHkQwe4KyLsfSSwEFCc
         eZvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=UeQPYBDU;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g6sor52316454edf.15.2019.07.31.08.08.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=UeQPYBDU;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=p3ZdWpQd4xgv1kA6jDtn8atrxpLedHc/tVwU2ev+R3g=;
        b=UeQPYBDUV35JfXNrT+d/+kITJnfTYOBQ1jtvX2JvqFbwVh/IeIZ2iI0ZXO91FPn9Ce
         GW/w3MO7sHLXXgtgE2TaPrzyGuhNw243bGm6o/iGuQwYW66FhRrCIaqTdHAHoNMlPwIJ
         eWN5hgS1key/lsY2Gpyw1STp4427doI388pSYFCLVQEjOIiGXT+TkZloJYN6tjzrbOyJ
         vcQMkjiEs7M6OXH8+Lpe0TAD2Ou/D+uu+KPrBcug6Q74tQXQEJs+TqHWk3omP9QV64d8
         7zAhZGz4EvgStlF3Md21t/Dhxvi9IqnlZrJdrf/4i/NIcNvgXhFuAzIO3cs7qe9OAhQP
         jyqw==
X-Google-Smtp-Source: APXvYqwkQSn37lZ2YK2K4kR+zMFHwX+ELvbrlQTI82djGKjlx/y1EvYEwBEFV4qd/VWbyn8Xl7msnw==
X-Received: by 2002:a50:a943:: with SMTP id m3mr105292611edc.190.1564585709728;
        Wed, 31 Jul 2019 08:08:29 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id y11sm12444539ejb.54.2019.07.31.08.08.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 9EFEC1030C0; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 25/59] keys/mktme: Preparse the MKTME key payload
Date: Wed, 31 Jul 2019 18:07:39 +0300
Message-Id: <20190731150813.26289-26-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
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
 include/keys/mktme-type.h  |  31 +++++++++
 security/keys/mktme_keys.c | 134 +++++++++++++++++++++++++++++++++++++
 2 files changed, 165 insertions(+)
 create mode 100644 include/keys/mktme-type.h

diff --git a/include/keys/mktme-type.h b/include/keys/mktme-type.h
new file mode 100644
index 000000000000..9dad92f17179
--- /dev/null
+++ b/include/keys/mktme-type.h
@@ -0,0 +1,31 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+/* Key service for Multi-KEY Total Memory Encryption */
+
+#ifndef _KEYS_MKTME_TYPE_H
+#define _KEYS_MKTME_TYPE_H
+
+#include <linux/key.h>
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
+	MKTME_TYPE_CPU,
+	MKTME_TYPE_NO_ENCRYPT,
+};
+
+const char *const mktme_type_names[] = {
+	[MKTME_TYPE_CPU]	= "cpu",
+	[MKTME_TYPE_NO_ENCRYPT]	= "no-encrypt",
+};
+
+extern struct key_type key_type_mktme;
+
+#endif /* _KEYS_MKTME_TYPE_H */
diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index d262e0f348e4..fe119a155235 100644
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
@@ -27,8 +31,138 @@ struct mktme_mapping {
 
 static struct mktme_mapping *mktme_map;
 
+enum mktme_opt_id {
+	OPT_ERROR,
+	OPT_TYPE,
+	OPT_ALGORITHM,
+};
+
+static const match_table_t mktme_token = {
+	{OPT_TYPE, "type=%s"},
+	{OPT_ALGORITHM, "algorithm=%s"},
+	{OPT_ERROR, NULL}
+};
+
+/* Make sure arguments are correct for the TYPE of key requested */
+static int mktme_check_options(u32 *payload, unsigned long token_mask,
+			       enum mktme_type type, enum mktme_alg alg)
+{
+	if (!token_mask)
+		return -EINVAL;
+
+	switch (type) {
+	case MKTME_TYPE_CPU:
+		if (test_bit(OPT_ALGORITHM, &token_mask))
+			*payload |= (1 << alg) << 8;
+		else
+			return -EINVAL;
+
+		*payload |= MKTME_KEYID_SET_KEY_RANDOM;
+		break;
+
+	case MKTME_TYPE_NO_ENCRYPT:
+		*payload |= MKTME_KEYID_NO_ENCRYPT;
+		break;
+
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/* Parse the options and store the key programming data in the payload. */
+static int mktme_get_options(char *options, u32 *payload)
+{
+	enum mktme_alg alg = MKTME_ALG_AES_XTS_128;
+	enum mktme_type type = MKTME_TYPE_ERROR;
+	substring_t args[MAX_OPT_ARGS];
+	unsigned long token_mask = 0;
+	char *p = options;
+	int token;
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
+		case OPT_TYPE:
+			type = match_string(mktme_type_names,
+					    ARRAY_SIZE(mktme_type_names),
+					    args[0].from);
+			if (type < 0)
+				return -EINVAL;
+			break;
+
+		case OPT_ALGORITHM:
+			/* Algorithm must be generally supported */
+			alg = match_string(mktme_alg_names,
+					   ARRAY_SIZE(mktme_alg_names),
+					   args[0].from);
+			if (alg < 0)
+				return -EINVAL;
+
+			/* Algorithm must be activated on this platform */
+			if (!(mktme_algs & (1 << alg)))
+				return -EINVAL;
+			break;
+
+		default:
+			return -EINVAL;
+		}
+	}
+	return mktme_check_options(payload, token_mask, type, alg);
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
+	size_t datalen = prep->datalen;
+	u32 *mktme_payload;
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
2.21.0

