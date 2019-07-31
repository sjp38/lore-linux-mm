Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD29FC32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9769B20C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="kM1i0F40"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9769B20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 423468E000D; Wed, 31 Jul 2019 11:08:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 375588E0014; Wed, 31 Jul 2019 11:08:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E474E8E000D; Wed, 31 Jul 2019 11:08:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8CDFB8E0011
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so42576189edc.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=D3iLJ7KF8Vm9odDmu+BTFZ/KOQRQtwHyPsHUVXUW2iI=;
        b=bPxJ3U+RjGWbx3hoopWb/KLcpAQQ0tRKdy6hpLxq7F7r516f20R11rd6IjwBTnw9QS
         OnLjN14+791kLSMajISl7llTA3jqUoqnKZ/6CF8xcA8Tv9V4xHKqcFrMqF4XCLqNUk2D
         0aKI6JrxvUvsD/L2kIxKrJFliKygbxF6ITqjjUBQVR/LZ1f5bUmzEd/HR7FFBVYVw6GE
         LRIXDIF5vKG2oXWCeLl2aCkG+RBnWqneRgZQYsnXYZAj5BhRvByQIzWCMd0uKx1b8myY
         lJmfDEWIObudy+kDnX7SVZXPgVg/zMWmm2Y9kH8yWqF+KWdKtPQDhMSoojfMo741BX12
         MSLA==
X-Gm-Message-State: APjAAAVOlaumTMWCCvfns8D53LhaGZFT6CAyzykhmvmnnbhwG0KUf93I
	vR21bwHwdnGzGB5C5eT9myfGGuY/Jl9eghRu/2gnn5Z5lP3u4eF6A457NgAKB+UnPevS1saPHkS
	HA5y+5km/qDvf9TQlvFVQUzkguJ7TExvWJorf/7R/wKA8yPmwAx27dNIxGmMfVfM=
X-Received: by 2002:a50:f781:: with SMTP id h1mr110193205edn.240.1564585707151;
        Wed, 31 Jul 2019 08:08:27 -0700 (PDT)
X-Received: by 2002:a50:f781:: with SMTP id h1mr110193074edn.240.1564585705957;
        Wed, 31 Jul 2019 08:08:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585705; cv=none;
        d=google.com; s=arc-20160816;
        b=v03vnfy/TrSWs+S2tfUoyn8IhLlVI8Z1St2wuJQ6mRmVQ4FN7mxfSNyvMi1Mc78edl
         vuyWavr3thHezxcYaO+UFGtbtzzEjrl0OzMI4si9Ro4+PgWI5GwPAznqkYWLD+Z+tIQu
         tVaFbZNjhtDSKRzRwo9Z0SWGN75iCHwDyA/CSUoqiJwodo2F/pjRODnB26EhsFKXNHNu
         FVVf6AkmaTefFV4Het+d85SRbL1kH6F33TqstBs2kmaIMxTvFBrplaOcERKglvDbpARi
         W7ekJjhHx1kh9W7RMAfK55/uYQgkcdA/n4J1ZtASdxnnPxXjs7G3uk+d00hIg25vdqhZ
         ZIyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=D3iLJ7KF8Vm9odDmu+BTFZ/KOQRQtwHyPsHUVXUW2iI=;
        b=z60W6zwRW1JaHCdWLHVd+TN1CsE/w3ITXX3vN51wAVmnEd2uUv8TH3PUlixvtpY2Nu
         idy9pkwm//Yaw0M6qqs6yzZQIYiDKQ8gvB+q2UMahU4qIz6UfiV5lndNhXbMQ237Yth0
         P1cL+VAVwynkYI795pJ5EStZUfpeD/iiJaalZ56PDB9Rhctt7/wL4SLaZVQYMbDWYW84
         TQmTx5exaPk3UtZRWOSAX1ID6QrLIQ9ND8EsrsFRkJlPDg9FcquF0gWJIPrwD3F43cFg
         m7/boCL2AUFYThcQliRMlnW22tvVbe6McBKsUI43vrJqvQNd/ELG+BBX9tHUKclwzZ2s
         M12w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=kM1i0F40;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bq17sor22167287ejb.55.2019.07.31.08.08.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:25 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=kM1i0F40;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=D3iLJ7KF8Vm9odDmu+BTFZ/KOQRQtwHyPsHUVXUW2iI=;
        b=kM1i0F40FYXfEMcdQiR9VUZLV2aBUr0DIlco9iB3hlWgYlqGoH3YhFqThyiuG3GlhU
         MICJOrT8oqR+53hRqgv3cF8csRqL1xVpyX6tD/ZJaUBHXHN9slodEDUAQFc2ndeYmsWR
         WW3A0qapPQ7CP1xULEMwz3e4zS5z/Rmun6q/0nEmdJiaXIJHY6yN81AnytapRernvBrE
         raTbz2gJS/FTTNoeLLnIs+MXpv+7iucyiiIu1zFPo09iRbaEfSGAfhH+M11KFAhMEC6e
         NwTMUxuK0IGQ7DtfynJRVOV/piQIKxKjIlGe+MhgETY+7kSa+fXty72q0sWznKXB/EmX
         L2Jw==
X-Google-Smtp-Source: APXvYqzHXFkffBxAenDjJHEoVzdmjQiN5+u8mCxxAUf8k5rkMpqzlIwg7G5dir5Kcyl0q83T3wGkPw==
X-Received: by 2002:a17:906:1496:: with SMTP id x22mr96005472ejc.191.1564585705643;
        Wed, 31 Jul 2019 08:08:25 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id u7sm12521820ejm.48.2019.07.31.08.08.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:22 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 3A8CF101322; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 11/59] x86/mm: Detect MKTME early
Date: Wed, 31 Jul 2019 18:07:25 +0300
Message-Id: <20190731150813.26289-12-kirill.shutemov@linux.intel.com>
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

We need to know the number of KeyIDs before page_ext is initialized.
We are going to use page_ext to store KeyID and it would be handly to
avoid page_ext allocation if there's no MKMTE in the system.

page_ext initialization happens before full CPU initizliation is complete.
Move detect_tme() call to early_init_intel().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/cpu/intel.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index 991bdcb2a55a..4c2d70287eb4 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -187,6 +187,8 @@ static bool bad_spectre_microcode(struct cpuinfo_x86 *c)
 	return false;
 }
 
+static void detect_tme(struct cpuinfo_x86 *c);
+
 static void early_init_intel(struct cpuinfo_x86 *c)
 {
 	u64 misc_enable;
@@ -338,6 +340,9 @@ static void early_init_intel(struct cpuinfo_x86 *c)
 	 */
 	if (detect_extended_topology_early(c) < 0)
 		detect_ht_early(c);
+
+	if (cpu_has(c, X86_FEATURE_TME))
+		detect_tme(c);
 }
 
 #ifdef CONFIG_X86_32
@@ -793,9 +798,6 @@ static void init_intel(struct cpuinfo_x86 *c)
 	if (cpu_has(c, X86_FEATURE_VMX))
 		detect_vmx_virtcap(c);
 
-	if (cpu_has(c, X86_FEATURE_TME))
-		detect_tme(c);
-
 	init_intel_misc_features(c);
 }
 
-- 
2.21.0

