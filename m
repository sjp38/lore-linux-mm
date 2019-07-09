Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10BCEC73C53
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 18:55:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9C1B20665
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 18:55:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9C1B20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F5128E0055; Tue,  9 Jul 2019 14:55:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A4158E0032; Tue,  9 Jul 2019 14:55:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3946F8E0055; Tue,  9 Jul 2019 14:55:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id E35708E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 14:55:36 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id b67so1432487wmd.0
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 11:55:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=5xqV2Lb5KecX8IhtaHyJbfxJMgfFlWDd0B4Flce/i8Q=;
        b=VXo7RakBWgS4k3TMZ04Mw7L1D2MV21hvN8ulIg2x2h2q6ABep27ByjeRyQTRotLcbU
         r95o0AbY3vwX31SIDzWQBG093D7P3S+5u5wCDHdSlxRQZT9ojS6xkBH6IbyNJ/OVnpnx
         Qeo46U4KNXt3znXijznzj8DQp/T1U2rOY5QOApYxTb77NUwsKU6PeXSQ53uUhyTnWpXx
         TJm+JJQSpDvoL2mpEoPyvPuKQXf8xin8yHCTCq+yisrGi1Dmq1OwO0o1enQ8Odfp88Ao
         4/hwbUfdRPkaRVut5NgwbOVibyg/PJMrSXTGti9fKVHsw6A122+7lILN07WuI6marLGR
         LIWQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.17.10 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAW80cKZLF9YsHUoVPR+QN/28UnUiGTV0QdEerPm9IIu+dNbP72d
	QM7TElj0y4kDeOcCzDPVvBuMwBIhlfFq3CFoffwKVP6DxKb6doZD7fF7DM1INMqU2ySJeP5alKo
	8VgC0FC60Yizv7PwZsHC7oGvJWs+XTLUJXvbB5FicuXz9zumbkvkhDWDv3FoFJ+Y=
X-Received: by 2002:adf:f544:: with SMTP id j4mr26810612wrp.150.1562698536456;
        Tue, 09 Jul 2019 11:55:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCXyRUSJ3t4yJ4kIvyXcgOleoXfB6nUw9Kw33R25A57qH2523c9QpqPvMpGwtTMwahSQBP
X-Received: by 2002:adf:f544:: with SMTP id j4mr26810577wrp.150.1562698535662;
        Tue, 09 Jul 2019 11:55:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562698535; cv=none;
        d=google.com; s=arc-20160816;
        b=yqi0RxicuBMCSfmLATKJKdJhFxdODO0SRDyjg0K5vcde7P4548TW6ksgeobXfwgDEk
         yQOEvlLWgDcmYPqJrkGBFpBmh4cNLHHOUaqDLWUNvdtJUoZw1TN0+v6dPlWJkJbE8dlg
         m4wv9SZxIxpMYUzImuHPLZ5BnN8W0J9lj43aswy/Rn8TUUgWwmYN6lVAFMTmgbF4gcd0
         gQ4aibuy0qQ92b8uflCjCsIHFsYWTscD7+Q6mB9OGSsXFlm+idZXs4J3RbyBM87NVZgQ
         E17tAS2ZfzyW6ta7178pv8jNMK7xmcvjKVcrJPEbCDl8/qtrgpyEg4srjcYmT/OSZdxx
         1kGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=5xqV2Lb5KecX8IhtaHyJbfxJMgfFlWDd0B4Flce/i8Q=;
        b=M92qNTr5rbt2cJD6rM8bcnXnxo5NXaBJmwwB2oFNDI3GP0eEBE6IXjgI1kocsPdWW4
         asP3dvYrsLDMv5AgIGPfci07xr+T8TAZgxjaU9gFjBssGfIXapH8/8Io4hQt/ch0N7cz
         y4upAGqB64pB4QvXLykis+DETxS7tQAAbUZSQbFceKGixSSJSI4Dyo6djYPbswThvtNh
         3nA9rpz2M6sKNY5oHQPzVrhte1Jacl2Vr23702d7KqghbhYwufW2V5uNfD7WdyqVeh8p
         9vRWdzacH0nmSRkMl6/EPw8AXyetSW7rcCD/Q1pb9MnBSkStS4UF2pX6yBVqapnzZdr3
         JCKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.17.10 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id z2si2954296wma.41.2019.07.09.11.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 11:55:35 -0700 (PDT)
Received-SPF: neutral (google.com: 212.227.17.10 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=212.227.17.10;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.17.10 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from threadripper.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue108 [212.227.15.145]) with ESMTPA (Nemesis) id
 1MV6Bs-1ht4UM2gFi-00SAJu; Tue, 09 Jul 2019 20:55:32 +0200
From: Arnd Bergmann <arnd@arndb.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lecopzer Chen <lecopzer.chen@mediatek.com>,
	Mark-PK Tsai <Mark-PK.Tsai@mediatek.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/sparse.c: mark sparse_buffer_free as __meminit
Date: Tue,  9 Jul 2019 20:55:07 +0200
Message-Id: <20190709185528.3251709-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:dVuJ+e4kut2pBGD0f44Tc4g9wI+Sx6SMYC65vDceSfeBL8Yrh+N
 QNGHbxDD8YGcxeGUylFBPh2+1bqSGZD7fY2xzD4DuBrL6v+lkqQlguvHdgwjCswrVGx0YTH
 Ei8xRNQutUg89MivWr34gzxK4A0qtbmc/bwPqX+Ro6d0AKd1DALUkvtQnCKRHpDo8N4C/cH
 PXTpKClIVFlzJz6klNUKQ==
X-UI-Out-Filterresults: notjunk:1;V03:K0:m6/WP9gsIM8=://qaXXPJjdjdLwFXs/UQEw
 +imM3iOlc931kOkt2KJoAkJMtnNtcB+ECAqcccp5LqSZ3ZDoYw7uVgg/aT3s3kBDKyU4CZ91+
 2Vv8UpHhZZoJXqrINVUJ8Du1cwhPcS4ZsnJ21M5qOYaKY1jkttUcJCkKERpJq1IpUCifqgOze
 mKvXl0BLByMoOsx0q3wapfs4860AqLAaqyz48b9NGKVcne1njGvfLfitEQC5RzGOLwJG9Xe1Z
 F6/zmu4tTBuXiw90z5Ux0bs1+KAkSfgqXDaupSq7BAbQnLVdlXaHNkL9VK/eb4B2ezZ/34NeV
 MiiefBC8t4cjbufi6ryt5N3y2yroSgI2eWwz2FcrpGYb4lsJd5WYCo6AbNqdXnPC+OVUyB6Wc
 MLYwE0vTk91UACyfh2+tle7bfjU3ClroCy9kGhBi+mjWKm1jc58gmuMlR+Jaqwu8TewKdLmQv
 XNl8NaGgSEcGsFWzlV8BcB7MIn7u/tIs0jQ8nDWHyxygclcwEk/Yd4D6V692Om8veoGdlx1gu
 TzYzg9SKzJhRwiPUDRI3k+WyNZWezRG/2qvOpIMDFTUQRLD0ffbTGoTCsNpFnOgp6wVdO5/EA
 lZrmXTsVfpFEaMWIvX8u+xilTzIr8Lr9SdU273CuvBlAMW1Rz5tIwmVLSdqw+JaR3QdVcXSIq
 LBIa5aiZKVRYszZlP3mu3UyXhpUxO3LxicJ+8O6JszIV2dLW1Guy37mq6jWmxne7b4rfIoisw
 2m3oWKIhTpFb0cn56zAlG3ImsCaDSmHu1cS8Dg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Calling an __init function from a __meminit function is not allowed:

WARNING: vmlinux.o(.meminit.text+0x30ff): Section mismatch in reference from the function sparse_buffer_alloc() to the function .init.text:sparse_buffer_free()
The function __meminit sparse_buffer_alloc() references
a function __init sparse_buffer_free().
If sparse_buffer_free is only used by sparse_buffer_alloc then
annotate sparse_buffer_free with a matching annotation.

Downgrade the annotation to __meminit for both, as they may be
used in the hotplug case.

Fixes: mmotm ("mm/sparse.c: fix memory leak of sparsemap_buf in aliged memory")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/sparse.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 3267c4001c6d..4801d45bd66e 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -470,7 +470,7 @@ struct page __init *__populate_section_memmap(unsigned long pfn,
 static void *sparsemap_buf __meminitdata;
 static void *sparsemap_buf_end __meminitdata;
 
-static inline void __init sparse_buffer_free(unsigned long size)
+static inline void __meminit sparse_buffer_free(unsigned long size)
 {
 	WARN_ON(!sparsemap_buf || size == 0);
 	memblock_free_early(__pa(sparsemap_buf), size);
-- 
2.20.0

