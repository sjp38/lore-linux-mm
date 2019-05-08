Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06E36C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C73EC205ED
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C73EC205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 542906B0003; Wed,  8 May 2019 10:44:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F3F86B0005; Wed,  8 May 2019 10:44:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E2B86B0007; Wed,  8 May 2019 10:44:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 043356B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:36 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x5so11673304pll.2
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TCzL5NUW6PZPJubSx6ptHjsKfaI6lzp6k1fXbK9hDAA=;
        b=E4zaHzphJnWUFgrhLXlD7E5/1fTdiw6d1D8aAXdAjlcKwCAeiBATDOjlou2QCQ/aAG
         HE4FurlQQ5QHg5Xex3eUApm2NOYZ2qtHUY2/h5G/t8wfVpteT4tK4v6UtsrdlvczV4W1
         dC5fhynyKfPMqVR4FW2FWwNbb75AMRBCe8enoAK4XjCnOKy5aDTBGw476951PoN2mbyK
         UZbRBeAwbVSLClcqLypfSmXHrQ9AkIebqCeTZ28v0tXfbIaFnsy3b/7SODkn2jWCwPMm
         ul2/b7DqARKl5q1ICf8J6kOCtT0RjjYk8akqO53+9ecVS4iReCkTvJvHTRFivAO7BLg5
         XMrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUXLCgaG4y13LKzsGSjVfUG3vPeynzyVcgrmx4KtitIpP90+LDI
	IlqjYR7FcYBpguisiBC2BumPyH3L01OGGRq0aYcBCSIyfSbfGCqY3DEc6uneH6d/SmNcsdLre+h
	m8zdjEJZn0VOEPFeRZ3D/PoCvxq649rrVzh4jU/cgWzlrm86h6Pk367AjDYJeeFHUOw==
X-Received: by 2002:aa7:8d81:: with SMTP id i1mr49144532pfr.127.1557326675662;
        Wed, 08 May 2019 07:44:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzc29sqrZkB2s6XTIv3IzMR1fos3Xo3p6HigBax9sP8R6iCQeeRAQtkDJaePKwUKHjlr0YU
X-Received: by 2002:aa7:8d81:: with SMTP id i1mr49144447pfr.127.1557326674865;
        Wed, 08 May 2019 07:44:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326674; cv=none;
        d=google.com; s=arc-20160816;
        b=ppGi6IvfcSraB1kT6Tn1jJH0Zg5Pb3qziZy6In0+Qsls64WHL5ztRc/MLuLsYIAS7z
         3//PqESt37jn/PQ4p19i52B+SilbH3sPW2tnSvA+Vbgw9VSF+EIvptLsBGnzjPleHenb
         QxKzvO4CeYYDljNpN/wf8bgiJzps6VA6+xnGjHfGAeTTARmpvKEOraS3urD9O+kprFUJ
         S3/ejOBxZdo/1B0n0NfBxruvZduU45IF0xikqs+nAG6B4xYFNUuOy2TeF+3n3cINyq7p
         QfTyDJAY1B28wNPvd6ndkWb2Jf6LDcws+zk/80dFWs9zabPxp5WDZN2zVR/UsWmUdcZq
         Oq1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=TCzL5NUW6PZPJubSx6ptHjsKfaI6lzp6k1fXbK9hDAA=;
        b=h5oRWp7p+xjyZtGyjOXbqMxDmb5PY01Lf7vpVSGEvh5ByEr3FkSPAUFzFe2I2NerH+
         hykD6Kqda/5F1F+eYBbaYAS8ypfaxiLBJJRRMHm3XQfP6KNQ4olSr87rtLazLqA9t0Hz
         g4moB7ZrRKgfSzYDSUp026wqVXGXtCc+hc3eddTOzm42703q5Ub1rpcFNGo+QFyafKvU
         nl4OI+XhkX9r60UFHF3TQepQW9XCvzb99MAOoqfAj5Zo3Cm1iCxwtgiRSb796HQnlPNF
         02K65VqCaGFs0aP92RxtPMAMRBxDYh6b9RLTYoVBzT57GChPdkFMPCZdvdrj3jV0RMxc
         8luQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 192si726287pgb.488.2019.05.08.07.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:34 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga002.jf.intel.com with ESMTP; 08 May 2019 07:44:29 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id A94D92DA; Wed,  8 May 2019 17:44:28 +0300 (EEST)
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
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 03/62] mm/ksm: Do not merge pages with different KeyIDs
Date: Wed,  8 May 2019 17:43:23 +0300
Message-Id: <20190508144422.13171-4-kirill.shutemov@linux.intel.com>
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

KeyID indicates what key to use to encrypt and decrypt page's content.
Depending on the implementation a cipher text may be tied to physical
address of the page. It means that pages with an identical plain text
would appear different if KSM would look at a cipher text. It effectively
disables KSM for encrypted pages.

In addition, some implementations may not allow to read cipher text at all.

KSM compares plain text instead (transparently to KSM code).

But we still need to make sure that pages with identical plain text will
not be merged together if they are encrypted with different keys.

To make it work kernel only allows merging pages with the same KeyID.
The approach guarantees that the merged page can be read by all users.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |  7 +++++++
 mm/ksm.c           | 17 +++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 13c40c43ce00..07c36f4673f6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1606,6 +1606,13 @@ static inline int vma_keyid(struct vm_area_struct *vma)
 }
 #endif
 
+#ifndef page_keyid
+static inline int page_keyid(struct page *page)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_SHMEM
 /*
  * The vma_is_shmem is not inline because it is used only by slow
diff --git a/mm/ksm.c b/mm/ksm.c
index fc64874dc6f4..91bce4799c45 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1227,6 +1227,23 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 	if (!PageAnon(page))
 		goto out;
 
+	/*
+	 * KeyID indicates what key to use to encrypt and decrypt page's
+	 * content.
+	 *
+	 * KSM compares plain text instead (transparently to KSM code).
+	 *
+	 * But we still need to make sure that pages with identical plain
+	 * text will not be merged together if they are encrypted with
+	 * different keys.
+	 *
+	 * To make it work kernel only allows merging pages with the same KeyID.
+	 * The approach guarantees that the merged page can be read by all
+	 * users.
+	 */
+	if (kpage && page_keyid(page) != page_keyid(kpage))
+		goto out;
+
 	/*
 	 * We need the page lock to read a stable PageSwapCache in
 	 * write_protect_page().  We use trylock_page() instead of
-- 
2.20.1

