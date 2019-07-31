Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68ED1C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:24:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 217BC208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:24:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="TdeP43VI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 217BC208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 848E98E003D; Wed, 31 Jul 2019 11:23:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D2BE8E003F; Wed, 31 Jul 2019 11:23:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D7518E003D; Wed, 31 Jul 2019 11:23:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 06B4C8E003F
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:23:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a5so42624794edx.12
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:23:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Pyaxzbpsx58odlzi9CMlCU1WWA9qqTOgEqw5C9FEBVg=;
        b=g5cW1IJa1P3cDre+G4O5twYGhOFfP6Ldch8er8p/20JYtofXc7L0TSBfD0x0p3142L
         KduA8ZEWRBhjJNFDOWacXR/TDhelZxQc7Le0UoT0RfSW3nz/rzLEJgHSZ33FbW1fVp8Z
         dqmz058j25F0thA5bwvFxVTDZYSSG5p5Hgm2eSi/9ilXtj18Vm72tlv40R1EM4TxBdt7
         QnKMtxeBWEBfcJbFICsC1wTCXj2JiQuh28Hn4+0J9+VYqcBu+nPbkWmbL9u2wEePcEZi
         Gs7rs5aRLK1VyY5UgVEjSf0FygF7Ks4oU4HxT7ExVqV65u0RGzN5qGOKoooU3DTC35aE
         IitQ==
X-Gm-Message-State: APjAAAUOtWQm2JWKESeb70y3RAviCj+Ihvfp2o3gVngH3g1+4j9roRse
	CDQ62SPyUz99aBEWYUsWfMThy0wYE+q/omZH/sEF/USdZiuv/lnVMs9R4xcM17tzLAHP4ycWCXY
	a5+1vNrAKqUW2FNxwq1ySF30iL87pQceIksvatJBXF4oKEc/9+bzBujYy1I48/gk=
X-Received: by 2002:a17:906:229b:: with SMTP id p27mr93416807eja.266.1564586632597;
        Wed, 31 Jul 2019 08:23:52 -0700 (PDT)
X-Received: by 2002:a17:906:229b:: with SMTP id p27mr93416729eja.266.1564586631580;
        Wed, 31 Jul 2019 08:23:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586631; cv=none;
        d=google.com; s=arc-20160816;
        b=zpeyE8wjsmq7NJrij1+vEizr5ARs8fTaJfloQvVa6mJtJkqNgMNstnBvQPynEGegLN
         DsjJGOR1dFuMNCll9fnydmqtVkiCEwEFHi/+fGlxPOeU5YA+kvgY34xCtPq1bd8kuQrA
         36wEsnbPAhUpqSD49xnzrEFvySiQCx0yG8oKRUrQEL/NknZ1pp6I+2t2P0O/dIwAqIzA
         1JoNFbULWoFCXoSO9ceSiQuu0j43f+zOPnImOrWvMstuCWRR54dsm5XWzzG9PmKhfktP
         SReq95U6gVJa9Olg1hi5RlFLGLmeDx/cVc0SPoE6Lzd2Gk3Vi3xf53fClbaxrtufuCOx
         /mNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Pyaxzbpsx58odlzi9CMlCU1WWA9qqTOgEqw5C9FEBVg=;
        b=T3sVFa2PXdU9CvJ0/EpGFP5FWhCjbYF7R9I99O5+8TtUDKJc7r4ZY/Ky5oa5x/52M4
         FbC8+24y2Gr2sP5dL4RfDTACT5jIeuwm850Tnx2Czpz63a+Jy1swcpq4mN4f2egNRoqA
         N9D7gZ2sTPjksDUO7FTUvtZ9Mp+EzUwWZwF8ehqTXwrQl9awvSK+Wl5B0bvx6gMky8Fc
         MCLEHE5IxQiqbnOYzRX2SloSmLmbRmYSHfADFWflQXfi1/LSLOy+CisfOfm6eSdL1WS3
         5PKGYvi49wo6+UgOrHhFD1NuKWCmDEvj0SUfGh6wYU6K5736uWfEUSOXJLBrkf2K+1+L
         QqOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=TdeP43VI;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q27sor16485395eji.6.2019.07.31.08.23.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:23:51 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=TdeP43VI;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Pyaxzbpsx58odlzi9CMlCU1WWA9qqTOgEqw5C9FEBVg=;
        b=TdeP43VIsvZBSvidBd63JYHMxnbdwhhCTLKUiBkNxJ1dN5ZesnIcrufzgwhWgQyHPq
         i7R3oVQxFEJynf2mhmWeT0e02bFtLfYtRn6p0VgZ/9Cfk6L2HmVLTwyWiesqSFHcOuWI
         C7Kd8pQSESCHFSvOb3B4KDGD0ws8qGv6qEQ5VxcXS9cAH00eVayINE6xKGf1l8i8BukU
         egoKu79G/bPpu3bRP9GqYkSE1/6ni+LU5rtZqvn7BKSJqvWNGHFJFeVK/BRE5mk85JT0
         SAUKBlIR/5r0VZdnIOVvK9sEH41/fY04cVEyxQuZT0wYs85IiJA+jJz7ToKIsDLSVFEp
         FYqw==
X-Google-Smtp-Source: APXvYqwvQzZ9XL8yngupcDep2q/KvYsUDRxmOX5VsyvFeZ5aPPfxl5er8kzo/CVzwYry0AvSpyXG9Q==
X-Received: by 2002:a17:906:5409:: with SMTP id q9mr97412776ejo.209.1564586631213;
        Wed, 31 Jul 2019 08:23:51 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id u7sm12527377ejm.48.2019.07.31.08.23.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id D3EBD1045F6; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 33/59] keys/mktme: Require CAP_SYS_RESOURCE capability for MKTME keys
Date: Wed, 31 Jul 2019 18:07:47 +0300
Message-Id: <20190731150813.26289-34-kirill.shutemov@linux.intel.com>
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

The MKTME key type uses capabilities to restrict the allocation
of keys to privileged users. CAP_SYS_RESOURCE is required, but
the broader capability of CAP_SYS_ADMIN is accepted.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 1e2afcce7d85..2d90cc83e5ce 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -2,6 +2,7 @@
 
 /* Documentation/x86/mktme/ */
 
+#include <linux/cred.h>
 #include <linux/cpu.h>
 #include <linux/init.h>
 #include <linux/key.h>
@@ -371,6 +372,9 @@ int mktme_preparse_payload(struct key_preparsed_payload *prep)
 	char *options;
 	int ret;
 
+	if (!capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
+		return -EACCES;
+
 	if (datalen <= 0 || datalen > 1024 || !prep->data)
 		return -EINVAL;
 
-- 
2.21.0

