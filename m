Return-Path: <SRS0=rDiK=SJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC7A1C282DA
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 02:26:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7229D213A2
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 02:26:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="aJODF+9G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7229D213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B91586B0007; Sat,  6 Apr 2019 22:26:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3FDA6B0008; Sat,  6 Apr 2019 22:26:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A07B56B000C; Sat,  6 Apr 2019 22:26:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6871E6B0007
	for <linux-mm@kvack.org>; Sat,  6 Apr 2019 22:26:51 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b12so7544070pfj.5
        for <linux-mm@kvack.org>; Sat, 06 Apr 2019 19:26:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=pbFiHEf1JRX3q/KJ7+SXhCuYiieeLaagT2MKIRh7feU=;
        b=if6bKbhzVR7dEk+1nqNfPA2m/Uw0O1IILMngDkSQwmHMwLwnZp8aFusY+ZVyG9+/Ao
         TdxD/zk6T+7TDplRLVUwp+cZ5JWVpFAGwVhOlzJq0M0y1L5ZcrodCvCqeBQYCuAo5Hky
         x67Ed849KEHeawoCZYNgsKgjLNphCbXZugmf3nfF6o5zi7ZYwkhlYufmze2F6TX7XD1j
         en/zXZdFdHiRX+bvMSVYPK0iY2LAoqVR1J2Dve9JR2vJyvoINbpCf4iYg4s7fjLRSw+k
         Uf/iCw/O85VsSG53D/PbNqn/e93mHWiqMLNqFzFAMz+48i99GTK0lDFy34HM/WgHCErm
         P3zA==
X-Gm-Message-State: APjAAAUs/Et+pJThIEofQCzKsfDNOVEH16VEl7kyiLQBszZbitoqlVj+
	EkLDbuxVhhhGbVWtmJKSpnYjqz66jUfG1kHNADbyC3ulPEobVKYc0CPw6Va7rkB6zpqKCGJ6R6N
	7OyZgFDLCG+a0q2F6g2iSR/zlJsthqzlTwVYL85QxClB6tz3bkmb8XlnPXPpj1dCL8Q==
X-Received: by 2002:a65:4183:: with SMTP id a3mr21285724pgq.121.1554604010833;
        Sat, 06 Apr 2019 19:26:50 -0700 (PDT)
X-Received: by 2002:a65:4183:: with SMTP id a3mr21285690pgq.121.1554604010004;
        Sat, 06 Apr 2019 19:26:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554604010; cv=none;
        d=google.com; s=arc-20160816;
        b=qOojWwh2lCvcN4rQKXooxCwZ7wIFX+7rF/WKQO0fvd2CrXvf38GDqgo/wJy05lBKk7
         MG6MyEkTabhfTOPiUVBeLowmQC3N5SnNT8Wmpu/l3XfokIy/t87jxU8l3RzzVFurTxEe
         U3cV4CoTdXoODrpzaIyFOmvMWXGzJJrMB9CbE4ifkwPnzghOe2FPqvweQvFfjxsB8qC0
         fsf+vIJhePCr9D2+qa4vE7XQ1lTH+bMzdF1tp4K2L+2WP5xRUPsIkMrksDR5Vxz4/s60
         pA/hFKiAJU6Hhz+7f19K2HlsW5qwWhBMWoTmHj4TqHtg0GWaNwLPE1LaM0zTdSjchlF4
         tXhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=pbFiHEf1JRX3q/KJ7+SXhCuYiieeLaagT2MKIRh7feU=;
        b=OgBtt/D/iIgAe3wpjRkZxM7KYG3mvE1Z1gNUEBtAsCwS7VBFCpr/oZ8uE4rWDLBYDa
         nsdOf79XRD6x+P57tcOsiw42adWCXKrF+X9diVy0Xp3bdxEXETuNVuFIUfVGmpA9fogT
         acu9ZwmkuoSviwAGBCW5tHgoR7fWh4E/wrWrOPCwUszF0qzwga/rGTDe9czA4VOAZc9K
         subfSpxv7iFdoQ/CUaLi8GccNYTUoq5AYl4eiLfmWDNCNugPnkpmSoQhccnLgocirbuf
         E5eDXn5Cc7GDiIZ2Haqi5QgW5vefTW39pqfAuDWGKcAZR8nstWm1uo3dESnUnhgchssj
         WqDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=aJODF+9G;
       spf=pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=trong@android.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cl14sor392plb.30.2019.04.06.19.26.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Apr 2019 19:26:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=aJODF+9G;
       spf=pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=trong@android.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=pbFiHEf1JRX3q/KJ7+SXhCuYiieeLaagT2MKIRh7feU=;
        b=aJODF+9GDwNrJJA3vaeBNXIQnT08LEI7aw7UDRbuPPI79BaOZ4n+enGT8hf4x02OtZ
         G1luMZfHQgAgy60D9Wr3P/aL2B1ZC338zJdc4itOVWJQd1JP1dLypwbunA0tDe9Cj/Go
         fpvR1swPTanzB1/oOMEN9SIKfnN+HCtu7yOgS6wnp/wXF95x73FHoJWJE7f5zYEoqvkj
         0cXUXYGoScwjZ8wnT1Kco1pZsDyxceVjlwOS1X7An01ljLPBKvJQGpDfSSN9n/BZod8r
         bE8qcH1dJAgmul0kS3lWgZql8YbHBtYOiFpA9eMj7SEwXObYqVHmad9HkXKC9CSEJNF7
         5UhA==
X-Google-Smtp-Source: APXvYqww3A2dZzWPiMEkVXe7aXSilFWyt/z2WhIC6F9MpgLMGlwOH7TMwxuEo72meWiWoLGu5TQXLQ==
X-Received: by 2002:a17:902:ec0c:: with SMTP id cy12mr769plb.291.1554604009667;
        Sat, 06 Apr 2019 19:26:49 -0700 (PDT)
Received: from trong0.mtv.corp.google.com ([2620:0:1000:1601:c43f:8c1b:f6ef:3dce])
        by smtp.gmail.com with ESMTPSA id f7sm50240345pga.56.2019.04.06.19.26.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Apr 2019 19:26:48 -0700 (PDT)
From: Tri Vo <trong@android.com>
To: oberpar@linux.ibm.com,
	akpm@linux-foundation.org,
	jeyu@kernel.org
Cc: ndesaulniers@google.com,
	ghackmann@android.com,
	linux-mm@kvack.org,
	kbuild-all@01.org,
	rdunlap@infradead.org,
	lkp@intel.com,
	linux-kernel@vger.kernel.org,
	pgynther@google.com,
	willy@infradead.org,
	Tri Vo <trong@android.com>
Subject: [PATCH] module: add stub for within_module
Date: Sat,  6 Apr 2019 19:25:58 -0700
Message-Id: <20190407022558.65489-1-trong@android.com>
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Provide a stub for within_module() when CONFIG_MODULES is not set. This
is needed to build CONFIG_GCOV_KERNEL.

Fixes: 8c3d220cb6b5 ("gcov: clang support")
Suggested-by: Matthew Wilcox <willy@infradead.org>
Reported-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: kbuild test robot <lkp@intel.com>
Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
Signed-off-by: Tri Vo <trong@android.com>
---
 include/linux/module.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/module.h b/include/linux/module.h
index 5bf5dcd91009..47190ebb70bf 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -709,6 +709,11 @@ static inline bool is_module_text_address(unsigned long addr)
 	return false;
 }
 
+static inline bool within_module(unsigned long addr, const struct module *mod)
+{
+	return false;
+}
+
 /* Get/put a kernel symbol (calls should be symmetric) */
 #define symbol_get(x) ({ extern typeof(x) x __attribute__((weak)); &(x); })
 #define symbol_put(x) do { } while (0)
-- 
2.21.0.392.gf8f6787159e-goog

