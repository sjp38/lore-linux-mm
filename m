Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D056C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D7E721019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D7E721019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A72396B02BF; Wed,  8 May 2019 10:46:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A23686B02C0; Wed,  8 May 2019 10:46:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 875816B02C2; Wed,  8 May 2019 10:46:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE426B02C0
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:19 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g6so11610834plp.18
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=r4np14USnRYf0pSmuynNxiGvJ92FnJxR9tAT5ohZpVY=;
        b=ks4wZ5ugiklkdg/S5KoGs4a4qLKI03L1WSssKFd2ozz2h3Hzc65nI7TXb1sO8VvMy9
         IURAjFfLk4EMruvBeo4s3HBkcWBHIWP5vrWqfwPEuKuNoAxg/4MSG9L/Nk8epq1NjPcO
         tRtOL/QGngxAK4qRLd6kW98qx6ITDmI9HSfK5d4e9EfJxoUPnDybapmvLIwqfTcdTduF
         Adl4N9QWRwi1kvQONLgk4N0qmmw0RNu3UdF9Ago32/jyOTFyTcWnvfNzuGHnBiTImxlf
         0PJd/UZaUzgoDja7uRoWLOvkmSLG0k+1nBIxcxRCPvrzMgx9BfMjcJ1VEGIb+GZRg8XI
         oXlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXSZIR5mBq9cIbMaWdtv/lMow8ZOoKAzfDU7cYofeB1RpCEAfZu
	81z+D1eFAr4YZM3K8BN74qFl9bb/3N6JdMi7nIJ1yfZ8MvpgblSu5OWZkQZefBWBiLCkIJmKjbW
	8R8m9wxPhKe4WvNgS/ko8PsfMc7L3u3hh/SYhUiHDSQgusoz8UugNVOqgWkKIjJXwTg==
X-Received: by 2002:a17:902:b581:: with SMTP id a1mr12748754pls.206.1557326778962;
        Wed, 08 May 2019 07:46:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDOFDOrn50+l9dpBZA9MZ+fFA0nn7BnIh5dqYU2EBf8RlT9jBvHehQYR/e0afmEOqXB+7i
X-Received: by 2002:a17:902:b581:: with SMTP id a1mr12738094pls.206.1557326684562;
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326684; cv=none;
        d=google.com; s=arc-20160816;
        b=XskDc8jtBqSnw7nVBbtC2t3wywqVFrgAPZUWhEe3lnH7HgCjWg8F5meHoN3UzqMgdE
         XryW64B3MyGQxARLZ8PEi2hM/B5bNi49cS6Ixy1A6SwgjbFYL8vHork32lciUuQR2HUO
         kiNo4YxEXmW2zV2DvAhX2Y1qbYp3TIOr1PeDfe2gyzkzrL0/diDTJ1RcIgtD8+koKBAf
         89YarXSatQWu+JtIm+pOjQaEct3Uf01bqlXF40W7WOt9C+waWP0+YCnjxc9uKy93eFFV
         jSZJlRvhz8hKvJRvSVLT+5O1RM/p9F/3V1QWIoMgAdpnVkeFlK33DSwd3tTh5sEFckTl
         R79g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=r4np14USnRYf0pSmuynNxiGvJ92FnJxR9tAT5ohZpVY=;
        b=VLRvexZzYUiIEI1Brr5wgQy0QwfLNY+jP9Hh9ke7lu6Prmn6R6/m/woWVJfsY03Ozy
         NeLyDOfxoYeAGddZYVFqJxCbgDgViq5ztmkurMT3g0QNuuBX8sgWt+sALL+x/9lfHei9
         mctYKwmhDw1eektfdsG8eliXp+uANlrSro3zRN/xB2lhteKYWZHde7O2pDwtk8IJmGWM
         M+xbfNChG21jEu1wHxPcGIzyt9FZzRDtpz6qOPG7akdJIw67ah0eYCGPVNJ16WTzvMsS
         YdJr8F8CPsolpKc4E71ECfD2J9RskNdgVUrmTxcPPaJEWytUqlHJok0aruxYY8DnxovT
         cWbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 90si19482350plb.86.2019.05.08.07.44.44
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
  by fmsmga005.fm.intel.com with ESMTP; 08 May 2019 07:44:40 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 06098AD9; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
Subject: [PATCH, RFC 27/62] keys/mktme: Strengthen the entropy of CPU generated MKTME keys
Date: Wed,  8 May 2019 17:43:47 +0300
Message-Id: <20190508144422.13171-28-kirill.shutemov@linux.intel.com>
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

If users request CPU generated keys, mix additional entropy bits
from the kernel into the key programming fields used by the
hardware. This additional entropy may compensate for weak user
supplied, or CPU generated, entropy.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index a7ca32865a1c..9fdf482ea3e6 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -7,6 +7,7 @@
 #include <linux/key-type.h>
 #include <linux/mm.h>
 #include <linux/parser.h>
+#include <linux/random.h>
 #include <linux/string.h>
 #include <asm/intel_pconfig.h>
 #include <keys/mktme-type.h>
@@ -102,7 +103,8 @@ struct mktme_payload {
 static int mktme_program_keyid(int keyid, struct mktme_payload *payload)
 {
 	struct mktme_key_program *kprog = NULL;
-	int ret;
+	u8 kern_entropy[MKTME_AES_XTS_SIZE];
+	int ret, i;
 
 	kprog = kmem_cache_zalloc(mktme_prog_cache, GFP_ATOMIC);
 	if (!kprog)
@@ -114,6 +116,14 @@ static int mktme_program_keyid(int keyid, struct mktme_payload *payload)
 	memcpy(kprog->key_field_1, payload->data_key, MKTME_AES_XTS_SIZE);
 	memcpy(kprog->key_field_2, payload->tweak_key, MKTME_AES_XTS_SIZE);
 
+	/* Strengthen the entropy fields for CPU generated keys */
+	if ((payload->keyid_ctrl & 0xff) == MKTME_KEYID_SET_KEY_RANDOM) {
+		get_random_bytes(&kern_entropy, sizeof(kern_entropy));
+		for (i = 0; i < (MKTME_AES_XTS_SIZE); i++) {
+			kprog->key_field_1[i] ^= kern_entropy[i];
+			kprog->key_field_2[i] ^= kern_entropy[i];
+		}
+	}
 	ret = MKTME_PROG_SUCCESS;	/* Future programming call */
 	kmem_cache_free(mktme_prog_cache, kprog);
 	return ret;
-- 
2.20.1

