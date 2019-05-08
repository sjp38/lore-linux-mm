Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37045C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EABE4216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EABE4216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47FC56B02B2; Wed,  8 May 2019 10:46:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 431D16B02B4; Wed,  8 May 2019 10:46:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F77E6B02B5; Wed,  8 May 2019 10:46:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E701A6B02B2
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:04 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o1so12798278pgv.15
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LCcp+NaHSkyxYVzCq9AR5JBhCaNxEkGTOS5HXRjuHDo=;
        b=LPEsTKcIUXHl0rF2Hl2IhdO5Wu/tFOdEX1v8G/1hQIDlr7RRcU2SF/PEPqM3X35qsS
         tXMyXWMdnke9JmtKZ6NZlAuilFt7Gv8qKH6xwWOob3DMMURTbXDTcqkTDX0hONwVRwId
         eq+ZgVtpc7wQKiEAuJ747KE/+lYF4/Tp1KQyk0bikJXc/G+g1kvUyUydlg3ggja4aHbs
         7Jgtp3P8+ABX4dZM7XaJ6oEsuKiCRye+lqS1vg0w7NtLRj7PI5LYQ3u64JDZh54xUIfO
         mtRU5nIAk0U/9xZ+Ur6CKEUTENDBt66AHWet00+1AGViQivsTTq3mQlmz9NpCK64Kqa3
         /7DQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUcMAR0TGpJY+mNQ0MW2jU27CVpoiAYFeZSlgd/8c7zejcTJfjI
	iTzWIaLcADKBXU0SVRIPA3pzRRNUAWU1OUTMxeKVWpxoahRoijZ/yoIng0zoPDT4XF11q640pxZ
	Sn2TIjy6kpJp1IznD7m1KSlQigYmxys9POKTe2BMJBdREIrr7rlXi/nhuohRMlyPUMw==
X-Received: by 2002:a63:309:: with SMTP id 9mr26246793pgd.49.1557326764537;
        Wed, 08 May 2019 07:46:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwU88KlhYmdT1IBJ9WlCz9a7YAauc6jNWNm4kvBq1ByU57KkwfA0H7MD6TI9OAwkLjkX0aQ
X-Received: by 2002:a63:309:: with SMTP id 9mr26237618pgd.49.1557326686078;
        Wed, 08 May 2019 07:44:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326686; cv=none;
        d=google.com; s=arc-20160816;
        b=HdmBoTBYJm4hk8dzD35fJcE9MZZcrRwxMhMKsUeM9G0SgPGHvQOd5CtvU/YsVlv/XZ
         /HKkuNlYoix67ZLCsNPPPD70RNqKQyiAUHaw0RJAz65sSGen382BZFM70QdSrK2vkJB3
         olLhaKqmf3o3p87WNdnEcbCo8zlpCppe5UCbFeXPD1lgh1PhcGYomJPuw0LCitd54N5z
         6WqXq2Oo5N2QmFYu4qm1li073bz9f2SMcrgHmpbuZsQjz4ylv4w5UGxko9KJcU+ZxzYh
         SD7fdaRVfO3aD9nrf3XK9a3Ir0R3n1ebfqwscx8Bn4iBlEwtxkE8pwd0bxBKh/fkMl2G
         70EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LCcp+NaHSkyxYVzCq9AR5JBhCaNxEkGTOS5HXRjuHDo=;
        b=zbSlDPoRfnET4YD5uRBmRzmqtxhg2WgInizUi+yiM3mVKz2SvgKIU5oTjzVEe42ngS
         /AbcHA2+4g5UbwpC+AAKJvx/8v4VjcK5hR3t6zUbg18RfUEX20IvOJ7bniN8NniIROc3
         fK8pxbaM0cP4iqrFBOojDzpcM/aWDpMkctuDQCoeiGyNX2I7ZkI8cCgl5d+lmb34C7P7
         51mytxJJOBGYpxW7vRf7JQrYyaOc/JWBJ8+AiUk+sjp9W5NChHhIvmvoLbelmAo/8aXV
         /SPA/+apvG9iTqmqgLUOUD0ZQCh9UwoI5vplzHHbLU6yhzulqR6Gmx65IXI75RaR0WdV
         e6Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id s184si23372828pfs.275.2019.05.08.07.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:45 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga007.jf.intel.com with ESMTP; 08 May 2019 07:44:40 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id CED38A79; Wed,  8 May 2019 17:44:29 +0300 (EEST)
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
Subject: [PATCH, RFC 23/62] keys/mktme: Introduce a Kernel Key Service for MKTME
Date: Wed,  8 May 2019 17:43:43 +0300
Message-Id: <20190508144422.13171-24-kirill.shutemov@linux.intel.com>
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

MKTME (Multi-Key Total Memory Encryption) is a technology that allows
transparent memory encryption in upcoming Intel platforms. MKTME will
support multiple encryption domains, each having their own key.

The MKTME key service will manage the hardware encryption keys. It
will map Userspace Keys to Hardware KeyIDs and program the hardware
with the user requested encryption options.

Here the mapping structure and associated helpers are introduced,
as well as the key service initialization and registration.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/Makefile     |  1 +
 security/keys/mktme_keys.c | 98 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 99 insertions(+)
 create mode 100644 security/keys/mktme_keys.c

diff --git a/security/keys/Makefile b/security/keys/Makefile
index 9cef54064f60..28799be801a9 100644
--- a/security/keys/Makefile
+++ b/security/keys/Makefile
@@ -30,3 +30,4 @@ obj-$(CONFIG_ASYMMETRIC_KEY_TYPE) += keyctl_pkey.o
 obj-$(CONFIG_BIG_KEYS) += big_key.o
 obj-$(CONFIG_TRUSTED_KEYS) += trusted.o
 obj-$(CONFIG_ENCRYPTED_KEYS) += encrypted-keys/
+obj-$(CONFIG_X86_INTEL_MKTME) += mktme_keys.o
diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
new file mode 100644
index 000000000000..b5e8289f041b
--- /dev/null
+++ b/security/keys/mktme_keys.c
@@ -0,0 +1,98 @@
+// SPDX-License-Identifier: GPL-3.0
+
+/* Documentation/x86/mktme_keys.rst */
+
+#include <linux/init.h>
+#include <linux/key.h>
+#include <linux/key-type.h>
+#include <linux/mm.h>
+#include <keys/user-type.h>
+
+#include "internal.h"
+
+/* 1:1 Mapping between Userspace Keys (struct key) and Hardware KeyIDs */
+struct mktme_mapping {
+	unsigned int	mapped_keyids;
+	struct key	*key[];
+};
+
+struct mktme_mapping *mktme_map;
+
+static inline long mktme_map_size(void)
+{
+	long size = 0;
+
+	size += sizeof(*mktme_map);
+	size += sizeof(mktme_map->key[0]) * (mktme_nr_keyids + 1);
+	return size;
+}
+
+int mktme_map_alloc(void)
+{
+	mktme_map = kvzalloc(mktme_map_size(), GFP_KERNEL);
+	if (!mktme_map)
+		return -ENOMEM;
+	return 0;
+}
+
+int mktme_reserve_keyid(struct key *key)
+{
+	int i;
+
+	if (mktme_map->mapped_keyids == mktme_nr_keyids)
+		return 0;
+
+	for (i = 1; i <= mktme_nr_keyids; i++) {
+		if (mktme_map->key[i] == 0) {
+			mktme_map->key[i] = key;
+			mktme_map->mapped_keyids++;
+			return i;
+		}
+	}
+	return 0;
+}
+
+void mktme_release_keyid(int keyid)
+{
+	mktme_map->key[keyid] = 0;
+	mktme_map->mapped_keyids--;
+}
+
+int mktme_keyid_from_key(struct key *key)
+{
+	int i;
+
+	for (i = 1; i <= mktme_nr_keyids; i++) {
+		if (mktme_map->key[i] == key)
+			return i;
+	}
+	return 0;
+}
+
+struct key_type key_type_mktme = {
+	.name		= "mktme",
+	.describe	= user_describe,
+};
+
+static int __init init_mktme(void)
+{
+	int ret;
+
+	/* Verify keys are present */
+	if (mktme_nr_keyids < 1)
+		return 0;
+
+	/* Mapping of Userspace Keys to Hardware KeyIDs */
+	if (mktme_map_alloc())
+		return -ENOMEM;
+
+	ret = register_key_type(&key_type_mktme);
+	if (!ret)
+		return ret;			/* SUCCESS */
+
+	kvfree(mktme_map);
+
+	return -ENOMEM;
+}
+
+late_initcall(init_mktme);
-- 
2.20.1

