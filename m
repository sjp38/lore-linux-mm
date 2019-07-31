Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A1BBC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:23:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1D1C2171F
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:23:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="NRoJL3bi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1D1C2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A79E8E0007; Wed, 31 Jul 2019 11:23:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90AD88E003A; Wed, 31 Jul 2019 11:23:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D3528E0007; Wed, 31 Jul 2019 11:23:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2579C8E003A
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:23:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l14so42650465edw.20
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:23:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=a18UOZt3FCDvDMvgP9zldJLt6lTKwFfHbu73YInWFn4=;
        b=pep7ReqfdJvJ5apIpitAW/dw8zCYtGK5A6R7rzHc6krBOuK/eGwcvX1KQZa5GFOQUj
         fBTyakhtO48YZptOb+LgSwh+FVcLlulGV7IUrNjMaaYJ5PG29E5cFf6GgeV5rulYeHlJ
         cCRcjADc1P0hgh1vPJST+xsv7L4xFzk+a4jUxrUAfC/qKQ3bPJQngrlvDyQWAvpmog+w
         fKHxU8VA7RI2iJEMgRHttPyfYMnz2FiqFWt6tZcQ55lgDbyIWpRZUIizdB6rtcmANdsx
         c4jtDaQXX8g7sNEOtJGVrsqKuPXMRk9xQMjRxM5lQObXE9n7vMzkYKElCiWndy5H0tFc
         wOTA==
X-Gm-Message-State: APjAAAWgGBOFDPTpCdHLvHoRvQ5g5Z/F3VXZO/Sx5Pjnd7gvsLBvJ2+X
	TDmzv9jPLMcJoj1OGZ/WFUiNOcoEgG2dCfCRUUGM4RxaT/1cmFqmvKOgYX07nfY0NpNL1f9uQ6O
	w6Y3PNMw99rBf6LkLwVCpSgBpN9GoUiohNFsNiXxgYJUfbTtNli+qpTgPKccJNAw=
X-Received: by 2002:a17:906:7e4b:: with SMTP id z11mr96941081ejr.214.1564586629693;
        Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
X-Received: by 2002:a17:906:7e4b:: with SMTP id z11mr96940988ejr.214.1564586628305;
        Wed, 31 Jul 2019 08:23:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586628; cv=none;
        d=google.com; s=arc-20160816;
        b=uUUDKOCKGXKGLpiNJpIkGfUYTXJ1zR0d/p4ug5uHtcrfqMI6IGdp/kD8iY10mbRNlU
         EDcQpEqGZ2lZpk/9ycZpj9pqbBJCLMbLAKEC7+XZZj8qmwtQB7Uttlc53Y1asp3r6aEK
         QUmF4P9RuetRlSWlRAZ/Jio7J9wx69/E+cMZ4cE+sTXf2fAXEQMRYsTDuZjPj3A8l0lW
         KmU0vhhdqfrQMrCjXyp0ehmHV/mR74ocAHuvqb4OPct9eClMniBr/2J7sYBMj/wmvod1
         4TB+AjzmbnswbVjJeCrNx+mv8TxENDOUr0CIHnzLL3btP4FCUkQi+yOL7Y8h1gqDX8g/
         1xWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=a18UOZt3FCDvDMvgP9zldJLt6lTKwFfHbu73YInWFn4=;
        b=S1G8tSAAaDMWe2CNIR9PLJHbT/n/H7zGFUyQzgMfB1cIJC4+WGA7U+LXEE8lXdVspD
         8RDCNKZ4SQ5Bu/BWA3+Bbvkk4cFyXDQyGvtuqs+edo/BApF+OGDCP3wY4HpZ7uNVHgd0
         B9XHrXg2bcvmDQvVcXF9yTrg7ALL5y+Ym1NhmApOB22wn7VPtc6pH0zl3Q1kD8Yg5zHn
         8cOgF1ni1Lp9DkBU93FmjQsadX+2BXzdKe+7K6u9KljFeDcVnj2BfkXtMjRUz5F+1ptv
         0sWAfyF8fa8Dz4Wr0I24s7R/h4z640igg6DMh1edqE9+0EALJiaoxk2vnEVBb2ARCtHm
         pk4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=NRoJL3bi;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h14sor52333488ede.5.2019.07.31.08.23.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:23:48 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=NRoJL3bi;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=a18UOZt3FCDvDMvgP9zldJLt6lTKwFfHbu73YInWFn4=;
        b=NRoJL3bi5X5MHI+UHT7B1S62Fze3JOWhyFVaj3bzy32xghKUPsGgZO7GdGj/I+MGwQ
         IcszjXoHkHLCYl9E9+S0TVZkBMexB6yUan+V+lOdKu1ZTL//k329IuqiUOHsMZt8zobx
         DpyOBiRYKgBlkPN70qU0UyV4A9sw+9NOai6RD5k+KXVTchojnkBQ/9wvCG9xsOR3lQJH
         25Orq3JTmZBnhwFdJDSLbIjUUACw24Q/2V5Z/1iDJXDUwr6CPtjVVjX8EN+dRQ/iWt3F
         ajr2K45loyNYVlzJu2bXoVrUmjOiINR3+Zakf9U0MEFo74tWWpXOujPELeLbtPwG7Bf+
         4HTA==
X-Google-Smtp-Source: APXvYqz4eqsH2iJwU1tjXfKb0+/bNd+u2NkjVb8FXDZ8ZsSkbsVxoPTi6IlMDOoUIFCjKkMNnj7bMA==
X-Received: by 2002:a50:b87c:: with SMTP id k57mr105890483ede.226.1564586627977;
        Wed, 31 Jul 2019 08:23:47 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id f24sm17482856edf.30.2019.07.31.08.23.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:23:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 953461030BF; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 24/59] keys/mktme: Introduce a Kernel Key Service for MKTME
Date: Wed, 31 Jul 2019 18:07:38 +0300
Message-Id: <20190731150813.26289-25-kirill.shutemov@linux.intel.com>
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

MKTME (Multi-Key Total Memory Encryption) is a technology that allows
transparent memory encryption in upcoming Intel platforms. MKTME will
support multiple encryption domains, each having their own key.

The MKTME key service will manage the hardware encryption keys. It
will map Userspace Keys to Hardware KeyIDs and program the hardware
with the user requested encryption options.

Here the mapping structure is introduced, as well as the key service
initialization and registration.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/Makefile     |  1 +
 security/keys/mktme_keys.c | 60 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 61 insertions(+)
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
index 000000000000..d262e0f348e4
--- /dev/null
+++ b/security/keys/mktme_keys.c
@@ -0,0 +1,60 @@
+// SPDX-License-Identifier: GPL-3.0
+
+/* Documentation/x86/mktme/ */
+
+#include <linux/init.h>
+#include <linux/key.h>
+#include <linux/key-type.h>
+#include <linux/mm.h>
+#include <keys/user-type.h>
+
+#include "internal.h"
+
+static unsigned int mktme_available_keyids;  /* Free Hardware KeyIDs */
+
+enum mktme_keyid_state {
+	KEYID_AVAILABLE,	/* Available to be assigned */
+	KEYID_ASSIGNED,		/* Assigned to a userspace key */
+	KEYID_REF_KILLED,	/* Userspace key has been destroyed */
+	KEYID_REF_RELEASED,	/* Last reference is released */
+};
+
+/* 1:1 Mapping between Userspace Keys (struct key) and Hardware KeyIDs */
+struct mktme_mapping {
+	struct key		*key;
+	enum mktme_keyid_state	state;
+};
+
+static struct mktme_mapping *mktme_map;
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
+	if (mktme_nr_keyids() < 1)
+		return 0;
+
+	mktme_available_keyids = mktme_nr_keyids();
+
+	/* Mapping of Userspace Keys to Hardware KeyIDs */
+	mktme_map = kvzalloc((sizeof(*mktme_map) * (mktme_nr_keyids() + 1)),
+			     GFP_KERNEL);
+	if (!mktme_map)
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
2.21.0

