Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61329C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1989C21855
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="BRLtr4tg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1989C21855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B89998E0018; Wed, 31 Jul 2019 11:08:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC6828E0019; Wed, 31 Jul 2019 11:08:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93C918E0018; Wed, 31 Jul 2019 11:08:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3AADA8E0019
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:31 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id j10so30806610wre.18
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2C449KSjT4bbSwYYn5oh0t+GvJgUUHqBrjpFSTJaVMM=;
        b=gfhQVD5HH58EwZsHgcPLepi0YYl8hGVoRFXDJM2/cBXd6/GKIjsd0/2PvoBpQ4dxRM
         OzR5gmhRoSif/R2vURAF4v9gSNxc0F/DgaPD5VmspugR1NHtoR3IjQ19KiLScrUNwi8l
         i9qgCZUnodpfV4Fd3cexlsHTf0jy6GETaecK0l3NkRe/zyQdHGmRFQhWr07S6dDUP8yA
         xX9ASPYTbD8VjhuFztaE/byA+p8c+cm/Oq55mbFWbX4JcZAmVlXdlB1lmWBQin+10Vlg
         k1miXB+XlOOQ2tv1YE1H5S5GHfkoOIXNq6gOLSJirciHWB4v7tArie/wIjOk1ejpQbed
         wTjQ==
X-Gm-Message-State: APjAAAXNJ6wKYcp2wxb5HVoSeXm/1RFIaktsl1N6zHkiC+13q4aJrcf9
	LChqTn0ssnt0lWGjzAI5tv+YNh+VDT2KTd65uVhldNTK29UkTFOIW+FxaSKVp9to5x2kNZ6DRGZ
	9eMSVMYObaB5At8HPgb5mGvq/9CmYZnYsCHI9drSKWSWtS/lGfaaZBKnq2RXUKE0=
X-Received: by 2002:a1c:a514:: with SMTP id o20mr114609088wme.149.1564585710794;
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
X-Received: by 2002:a1c:a514:: with SMTP id o20mr114609005wme.149.1564585709583;
        Wed, 31 Jul 2019 08:08:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585709; cv=none;
        d=google.com; s=arc-20160816;
        b=mAAOyG9UtJBhAHYSal2FAsI6DjYfp8eyGIFeAAi5YkSOApgdtK+1V5TphqWflPJ74f
         vbG21reJAyaNQqu2ucNr/moRRnkSrF4MaNFRQYOWD6NsvbKgO2o0oAED1bqq+RU7FkCv
         dG4b0TpFgvgh4TBt6LFe5WY94TqFeVrjPSuDljhwJ86Ene3HnznpvqCHJp3MVwZBtwLH
         fq8LXZ+MHT4ztd9RKfK1SkPHhFx2KcFSaoCO0lyoWqeC6ul5bovSQHToeNFes2iqvoP9
         hTlbYI7w5ejp0fZ5dMfLhE3eVfaZtYdSwidLaDT1erkkVT09g2x8GQsGJDXJV+W3A4Ou
         EFLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=2C449KSjT4bbSwYYn5oh0t+GvJgUUHqBrjpFSTJaVMM=;
        b=mHrC9te0E7IHYs8tBHO3B4fMXtKAJFRnW02jQiYyPbTanCVt6wWnuR6K8YqKDtNguc
         YI75VdY48TeWqqU2T9DbHI7DDtPhICoXH9uHfm10SfmdhCRQKY9F2xuGVvkgOtlmF8ed
         Wc7NBkVoeOHBdsr0iT5ii8e2jGb09NIBRCcptMZVsAoEhW5pMkZ228gHlVuRd0gnVEPJ
         u0rI/e0j15BBPC5W6/Z95DUl+riS6VhWOie+1LRXOyT/cafh1JdOpqddnOWE4sOQaiIS
         GDqo+6MusdI7+lOP/7ORzQtVzhq8dI5grbguFhOiEPN9ZyXBCzUzoO/JcaEHnkKD9Gh6
         aBlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=BRLtr4tg;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l33sor52306997edd.23.2019.07.31.08.08.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:29 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=BRLtr4tg;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=2C449KSjT4bbSwYYn5oh0t+GvJgUUHqBrjpFSTJaVMM=;
        b=BRLtr4tgYn50QM+JIDHN/iYJHDA/eYrOUmJYvQptXTzwrBNdmFzt8zjJULLektK/VA
         AL/NZPGusMjazLlBev7xe67PdKIfQ1ifpZNsX3n6tVVOa4ud/9OwxtjEEiXleT0dww34
         btnUPhOQ9ej+n+IZzfuH/c2u7wLSynBdGbkIYgwm/zx9aTR7AirSR8kauZtQI1eG36ut
         GrY5WSOyefYNkH38KCUyy7rpU+qfA4Tow+UQHZI/00wFfW7zf53dLyFQhYvsbF2QDkKz
         HwKhJkV1eHDK+DsnsDoJNeFWLsnZIxfo/PjZHwoQIcsO8/FwvmZXcMuwGCHQNeY7A0V3
         GE2Q==
X-Google-Smtp-Source: APXvYqxMBwDpewyfIfpy++jLBpP8UloTaXPGrZ8I/eqCpEpkmrEfDx2SZR3u/YrZv24UsUCPRBrhkw==
X-Received: by 2002:a05:6402:28e:: with SMTP id l14mr42072938edv.11.1564585709289;
        Wed, 31 Jul 2019 08:08:29 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id jt17sm12600191ejb.90.2019.07.31.08.08.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 8E3561030BE; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 23/59] x86/pconfig: Set an activated algorithm in all MKTME commands
Date: Wed, 31 Jul 2019 18:07:37 +0300
Message-Id: <20190731150813.26289-24-kirill.shutemov@linux.intel.com>
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

The Intel MKTME architecture specification requires an activated
encryption algorithm for all command types.

For commands that actually perform encryption, SET_KEY_DIRECT and
SET_KEY_RANDOM, the user specifies the algorithm when requesting the
key through the MKTME Key Service.

For CLEAR_KEY and NO_ENCRYPT commands, do not require the user to
specify an algorithm. Define a default algorithm, that is 'any
activated algorithm' to cover those two special cases.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/intel_pconfig.h | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/intel_pconfig.h b/arch/x86/include/asm/intel_pconfig.h
index 3cb002b1d0f9..4f27b0c532ee 100644
--- a/arch/x86/include/asm/intel_pconfig.h
+++ b/arch/x86/include/asm/intel_pconfig.h
@@ -21,14 +21,20 @@ enum pconfig_leaf {
 
 /* Defines and structure for MKTME_KEY_PROGRAM of PCONFIG instruction */
 
+/* mktme_key_program::keyid_ctrl ENC_ALG, bits [23:8] */
+#define MKTME_AES_XTS_128	(1 << 8)
+#define MKTME_ANY_ACTIVATED_ALG	(1 << __ffs(mktme_algs) << 8)
+
 /* mktme_key_program::keyid_ctrl COMMAND, bits [7:0] */
 #define MKTME_KEYID_SET_KEY_DIRECT	0
 #define MKTME_KEYID_SET_KEY_RANDOM	1
-#define MKTME_KEYID_CLEAR_KEY		2
-#define MKTME_KEYID_NO_ENCRYPT		3
 
-/* mktme_key_program::keyid_ctrl ENC_ALG, bits [23:8] */
-#define MKTME_AES_XTS_128	(1 << 8)
+/*
+ * CLEAR_KEY and NO_ENCRYPT require the COMMAND in bits [7:0]
+ * and any activated encryption algorithm, ENC_ALG, in bits [23:8]
+ */
+#define MKTME_KEYID_CLEAR_KEY  (2 | MKTME_ANY_ACTIVATED_ALG)
+#define MKTME_KEYID_NO_ENCRYPT (3 | MKTME_ANY_ACTIVATED_ALG)
 
 /* Return codes from the PCONFIG MKTME_KEY_PROGRAM */
 #define MKTME_PROG_SUCCESS	0
-- 
2.21.0

