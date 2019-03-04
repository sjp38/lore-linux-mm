Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51DEAC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 20:00:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1984C20830
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 20:00:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1984C20830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDAF08E0003; Mon,  4 Mar 2019 15:00:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8A7D8E0001; Mon,  4 Mar 2019 15:00:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A55138E0003; Mon,  4 Mar 2019 15:00:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC9B8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 15:00:40 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id f4so4227823wrj.11
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 12:00:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=ZfakE/CbS8xrs43Lrg/OoZsO+6PpNSqmllDKU14czno=;
        b=b8cfyn2EK2S8kDiVLaxEb+ODDkWQovuKRRVIYIZwA3QPrOud1rM/jC73E4alzHWrlX
         NqCd7rk8DYcS5DrmPK3/3shZ/20b6bGbQVsBaEntiF0VcLvtuVdKofTgvvKBDwS4PjMs
         bWA8+eXxN24hIUasy8dzuZhydAqwHMgk3BLk4FeR24hLnoQxcvEclvuvexnZXyz/BYFZ
         v6y4SD2vf4XLaekL4Cl0+9XlWN7NoLU0V2u2lpvMPocRZ7DaObmbxZnrpXwm1w0MDAkG
         eWqkuAUrgV6cn5BczTybywnKpIbWy8t+eGoiCuqSBAfCY2GlM7sdqTHQDFUywbSFXWoz
         3rKg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAWfSpcNICAr/Kmf01yPdpOCV85MctDwEehhLMj3lU6G2CPZU+24
	O2qmBykrgkYUj9XLGEnlgCAPJ2G8Ks+F3rWMUua3D7pRDoFT528HFZAa7Rl9f19eE6KBD9TZ1Zx
	KRiodACnOBswxfKJv7aXY6oV520XRH75kxELCdmvXgI/6cIzpSKRcVh83PmGI9F0=
X-Received: by 2002:adf:c543:: with SMTP id s3mr13058615wrf.192.1551729639788;
        Mon, 04 Mar 2019 12:00:39 -0800 (PST)
X-Google-Smtp-Source: APXvYqz3JDz2ydrQmWIb9NKMgW+yZhsRgU2EknZ07kRQcF8t7342P149FjWLxn85BmuKzxFNsGM2
X-Received: by 2002:adf:c543:: with SMTP id s3mr13058562wrf.192.1551729638566;
        Mon, 04 Mar 2019 12:00:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551729638; cv=none;
        d=google.com; s=arc-20160816;
        b=HilTUj/Hcb8hauHob5YrRg9wgEfR5PFIJ7AEqiG8v1Kj4RHw4F7QJZLQaSFv9eA8cP
         yurs0dP+w+FTOo+42zm+uRBcggxAvKV2lUBYiZG7VW5gT8IyttOaIM7/mf5XgMU8EEu/
         AUlz5HUR5d75gwcVrEgTCeAsK2eHGR94+5gXJV1tCLIaY/jrRTjSBC1AAerR/uF3euSB
         mYw6eQVn8EXagiYlArIOaTeKPJsKk1AQKoBroDA4lLxAiqTxrBvLOxkZb7gF6QN/AeOg
         zmJWQCjgMnAfRVxcJTUKoqaoQ0b43ubotcWSvsrZ04gOI2ZpFTIStoQQrT8HFheoLTre
         AhjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=ZfakE/CbS8xrs43Lrg/OoZsO+6PpNSqmllDKU14czno=;
        b=xCpkg7Ptv808+teOBGqbaIURmXX9LAiX9gd2+QP3a71aWs1DWHfuURofl5PcAjdkdJ
         NymsU6dS/Cr4LBlg5Z/tHb7Sg2xiQtYM3QYHSpsIzlxlNE2ku2oIv9Oc3Ogr9Qz6UX9q
         lrQR4jcTXvPT4R4XUXj2fqAWrva/VRsoBeQtcEeJtw/aCbqdMo674vXQ7rlMaHi+jMZS
         JgDG+BGtmnue94zzyEZxhxXi9zvlV4yBCRdWzhfNaU7nEtXHpwExiJJJHo6V5Z7r/vYL
         +hGmr+AOpG5acFfvSpOCvtXK6iq19vPJ0aNH5KTxS5G4vS1UCs8U3P6u319UM8OwE/uT
         Y4NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.13])
        by mx.google.com with ESMTPS id q16si4365487wrr.21.2019.03.04.12.00.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 12:00:38 -0800 (PST)
Received-SPF: neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=212.227.17.13;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from wuerfel.lan ([109.192.41.194]) by mrelayeu.kundenserver.de
 (mreue108 [212.227.15.145]) with ESMTPA (Nemesis) id
 1M6UVr-1gu34r0Gef-006t1z; Mon, 04 Mar 2019 21:00:32 +0100
From: Arnd Bergmann <arnd@arndb.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/hmm: fix unused variable warnings
Date: Mon,  4 Mar 2019 21:00:10 +0100
Message-Id: <20190304200026.1140281-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:oWsSM4Y3uyql69Hm+fLCuZ/Z86r27PiGHo7NAGMIgk4M3l90Nmy
 ydt8NvS6JaKV9VYNJVXLvscG9GMvo8XEdiR6O3sbiNSD7GDDpU1tE+T8tlNO8zQbwDD+k8E
 frU6qfqluZQZsGnwrwDOxAonBEvSxyVOmY9fmDQpIhagAGKEhh7UwYeUUNj89pMMdI1vMmz
 cLJYkuRg8vUOAfTEjf+Bw==
X-UI-Out-Filterresults: notjunk:1;V03:K0:LbCpmeYVQ1U=:XVRFS0l/dUFasWwUJgPIv1
 ToRudy+Iv+x7SApootlGef3ekqNy0FBxNQSrUS1m6HtV3vIVDE0SbbhpiTagwLoHowEOHWP/m
 pVsKzk9glXiv1wz8HBLU4ZIlonYcgQVnj5t+r/UYnxvG7BzVx7BLPSiEnq2UtCoxSgKm+9qNv
 VnuIIEZa6CV0WcjB2rJt3spS0GGwNYzY6CVvGKcDDS60UijVm9H1wWFUODOTAg/bdXp69StXl
 UvSk71BoH2XAVeQnHrZr5PL+hgOnmgjiZe/uuhasbIShcQwCObHpfOMDy3eSzmF8gWJMzH8Yo
 C5gRjXpqguAj/FJlY3J2OxCdYCZ660/Zp6fwaQkIQH5HumHTfM370DD3QbmszKGsWgJizbRTR
 ue9xQ+RiNntu+g+b8M07hhiZlGzH5XIkX4GOvHofQ9F4RauryZW4E4STvAoiAjpomwZSihthp
 5BbMWf34FGrKLMxAoidOLEVcRHkAqXHShXSZgOxGE5zd9Bjjx6IYXNuPU0dVqPSRTeYsfAx1j
 IMNEkTyMStC/EjzZrwCAOaWTf1cRT310OcHuj54g5YWs4SluXcRpjkXSrdljhWXKZsngfVHOX
 cfZVguTufmuAci5UNUwE2yFHGqSgulN2amAO2G1Jpjjn+xbvqspz9nQo1JDGlo9OjJNGyJqPR
 agdR/bQiwx1bTK6np7azeryTDA/FLrKJDmFlfvkkOgbSGFVnXyFO9dyV8e+/1BiA/lFPPddLZ
 4a91sSb12qpjgIIN5rgqj85y93y31rlswfP48w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When CONFIG_HUGETLB_PAGE is disabled, the only use of the variable 'h'
is compiled out, and the compiler thinks it is unnecessary:

mm/hmm.c: In function 'hmm_range_snapshot':
mm/hmm.c:1015:19: error: unused variable 'h' [-Werror=unused-variable]
    struct hstate *h = hstate_vma(vma);

Rephrase the code to avoid the temporary variable instead, so the
compiler stops warning.

Fixes: 5409a90d4212 ("mm/hmm: support hugetlbfs (snapshotting, faulting and DMA mapping)")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/hmm.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 3c9781037918..c4beb1628cad 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1012,9 +1012,8 @@ long hmm_range_snapshot(struct hmm_range *range)
 			return -EFAULT;
 
 		if (is_vm_hugetlb_page(vma)) {
-			struct hstate *h = hstate_vma(vma);
-
-			if (huge_page_shift(h) != range->page_shift &&
+			if (range->page_shift !=
+				huge_page_shift(hstate_vma(vma)) &&
 			    range->page_shift != PAGE_SHIFT)
 				return -EINVAL;
 		} else {
@@ -1115,9 +1114,8 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 			return -EFAULT;
 
 		if (is_vm_hugetlb_page(vma)) {
-			struct hstate *h = hstate_vma(vma);
-
-			if (huge_page_shift(h) != range->page_shift &&
+			if (range->page_shift !=
+				huge_page_shift(hstate_vma(vma)) &&
 			    range->page_shift != PAGE_SHIFT)
 				return -EINVAL;
 		} else {
-- 
2.20.0

