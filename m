Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4471C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A48EB21019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A48EB21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D05E6B02D4; Wed,  8 May 2019 10:46:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 281766B02D5; Wed,  8 May 2019 10:46:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 171346B02D6; Wed,  8 May 2019 10:46:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D20C36B02D4
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:51 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so1895582plt.11
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hzud1pZzk11Z4MTkeEFL/myfLNNdwcv2ATalXrKplz0=;
        b=NZouNb+/u70pVfPsulTKH9DsW41U5VnUxKv8E7vRXVDe8rvUR7D4HsY1cRiBMpAm8L
         nDtuXajuLxpt7ciI4jKj/ijYFSr6O37YO5dmn+hUDXysj5/q/3UJhDEN+NRbsTBhhM0v
         H9BsllujzuemuzCRoDuhIQeu8XeMA0Fl7X8l+a9U670LtUsgtI7E4DdEQXR95O6UK4wO
         R5FlAgaZwQox43yJZnK0Fx0Bkb4secbcrU/m0w6kWdXyi6xpGiTVyxttwmxqBw1HBdl9
         NYAwDuD7phItJP7p8uYRZPtdYj5nizKa8L0Brk4v3TqRPMzzKNgk4vQDoAK/IOaUrXi3
         ssDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVuRQS547IS94IPsP9TjZEW/GUo7jeeiqa6aOYH5e+APPcOqNG+
	GLxWkDxzSgHxOwDSIPkGzLTLJFXJvtqfaN6ZfrG1FKaes064ns8cwj40dvBVQWjyvq6tT1u4393
	iDa6X1qKv30hBra4J3uOSp9OF6FE0nBKQDkNqPMBmyiyTiqtUszMYD2mQfTCA1Pl/qQ==
X-Received: by 2002:aa7:92c4:: with SMTP id k4mr50765624pfa.183.1557326811530;
        Wed, 08 May 2019 07:46:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKokrle53rtes2wnQvjFwXjoOQTJzHN6Tbc96TREyo2ZIfCJ7ydQ+9NUZRJ0P/gFwjEaA6
X-Received: by 2002:aa7:92c4:: with SMTP id k4mr50749903pfa.183.1557326684054;
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326684; cv=none;
        d=google.com; s=arc-20160816;
        b=UFgDeWI2T3NBBEu9hsDohH5gIY+ThVy0Ge6KlbvIPQX41zDeh0xYJ0t6CRnsbhe5ah
         IOoDpk5jx8WC/FjlZ+unnBD1cPx8nE89VH08oLq8nUu+Yxt65G1PoE1cbRdLv+qrVSuS
         DqbaA6zckvg4+6ep1CCY4s10SJ92dbmoMnnFv/z5Njguhq+Ti1kDvutE4aS9LLazhJI5
         sBNAirCWPc/mcWeVrc+eh3FoM6Vez6T6KT9ks9iOdD5UiEmifn5ArnP9XK23l10d4Iq1
         LphNMKC/Wy0eEB/rX8DsvIpe/Y50jasR4xAo4nRddnjAMIZ30wvDcLqMX6qvBpa/kHhZ
         /lmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=hzud1pZzk11Z4MTkeEFL/myfLNNdwcv2ATalXrKplz0=;
        b=WohleZ8uW6H6QJk7kRyfkT2U3wTZ3fEtEx7sBw+BKWFAf02+NLfU+2AjYP/ldGi3wY
         te7tJJYkcOyaBNKIxyOnDTmwMre41fV5FV3x7v4DdKAO2/aX2Kr2dE9hq+OPohiMmAlA
         eIHPas5QGQYDbf6Y5p3f0bu5hO4DawmZSKm6F4NcPWvcekTyJmkNQcrbBlkGkBkmTgnI
         00YbdS4rZK9netMTatjHszQSAbGlgiNbVtaNOxf2Jwe673qdmm+gEcdGjBEP7W1nzAIj
         cLXP4EId8tJwQIva3EnXebSOSZ7U7m9jCeZr4so5p6gjVFHXfSe1ngF/QkOkDQd+VGdg
         SCXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f6si24524459plf.90.2019.05.08.07.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,446,1549958400"; 
   d="scan'208";a="169656539"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga002.fm.intel.com with ESMTP; 08 May 2019 07:44:39 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id AF1AFA17; Wed,  8 May 2019 17:44:29 +0300 (EEST)
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
Subject: [PATCH, RFC 20/62] mm/page_ext: Export lookup_page_ext() symbol
Date: Wed,  8 May 2019 17:43:40 +0300
Message-Id: <20190508144422.13171-21-kirill.shutemov@linux.intel.com>
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

page_keyid() is inline funcation that uses lookup_page_ext(). KVM is
going to use page_keyid() and since KVM can be built as a module
lookup_page_ext() has to be exported.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/page_ext.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 1af8b82087f2..91e4e87f6e41 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -142,6 +142,7 @@ struct page_ext *lookup_page_ext(const struct page *page)
 					MAX_ORDER_NR_PAGES);
 	return get_entry(base, index);
 }
+EXPORT_SYMBOL_GPL(lookup_page_ext);
 
 static int __init alloc_node_page_ext(int nid)
 {
@@ -212,6 +213,7 @@ struct page_ext *lookup_page_ext(const struct page *page)
 		return NULL;
 	return get_entry(section->page_ext, pfn);
 }
+EXPORT_SYMBOL_GPL(lookup_page_ext);
 
 static void *__meminit alloc_page_ext(size_t size, int nid)
 {
-- 
2.20.1

