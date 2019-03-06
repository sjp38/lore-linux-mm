Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54EA4C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 11:01:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D58120675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 11:01:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D58120675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1BD58E0004; Wed,  6 Mar 2019 06:01:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACB6F8E0002; Wed,  6 Mar 2019 06:01:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BA548E0004; Wed,  6 Mar 2019 06:01:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 446288E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 06:01:18 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id a5so6982807wrq.3
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 03:01:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=piVaYaAcibG6n/c30q7eQjxW7RAdxum94b1jVJAg8jM=;
        b=WWXo10XyJ5liSpah8i9gdLmiVk8pQqw/84Jn0Q5WtwJ3+EGGlUgXNZESfF0nbCC9Cv
         MDotl+LdqcOgDWRucUq99MPrmJK75pEdB8V46IPmjFJ+HNGD6GnIZs/Z3ALkpEp0kZjX
         omd8j3hAi1EQuxO1olhFukIkep7fPw+eO7AifHgjg5B0bDpu9dyDEj+cUfvD5hgTgUMc
         +4SEOgr7qTNspnAzHcihYF2vx/XqS3yXdmyYajm4Cr+LwF7fRBdCIazB0/pnhzY0ddDr
         BdJwCEGAgovqSMZQAOY41t2sof33zml1xJLj3Tt4vEyg3AGmdnKP0VE5mmc8e85/5TeN
         ixbQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.126.133 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAU7VSDKz3UJqnzA9JgHou1+rdlmaXMT9Li+NlNkoZyyHu1Bw1BD
	ptKDp1t8eWeCV3tyLvjHip7pakxnWsps3HXfxzcqT/WS1h5hjqnLbGBhg1CJWiNY81YU0gP3sjX
	9ECXrsaHgp+qG8LWe+5TJwUEW7ZeZ6eSeEVR9G6NqpRvk1WsqrWrtUBTOd2VuPXM=
X-Received: by 2002:a5d:500c:: with SMTP id e12mr2645521wrt.27.1551870077415;
        Wed, 06 Mar 2019 03:01:17 -0800 (PST)
X-Google-Smtp-Source: APXvYqzdGbXhd3WeuyVCcUkHSAK7ygKIL51IWtbiseKtsLa6JFB1yJb6lmc/8ysDj9Dv7UWZ6W2f
X-Received: by 2002:a5d:500c:: with SMTP id e12mr2645446wrt.27.1551870076125;
        Wed, 06 Mar 2019 03:01:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551870076; cv=none;
        d=google.com; s=arc-20160816;
        b=dG3nbLHo3cpo1lEqW265P37v0yNxB4LpqgRz4Q1GiYQlIKiludj0LXfuUYJ7NlIyA0
         GJ1ybsCINWFVhByAy38dTADZlFLoUr2UTUVVvaAMK2p0qY1qm7rxaSVq03VDcSciPl3T
         U/uUaTnGmoPZh3oxhOy3bZZDpEs09wuO7FKvjWoXVDYfkc3+hUhRu3AbNEOLAr/iaD4z
         suufTmvgvWibQdox+VtabfnDjKRF7RIgMS/pkoWhXFozRvzD+kej5D79sVkcVTaO0JtO
         IXrZKpZfev213nkQb15K1X1FUDtPJBTgset/Tw1DYUQ6gsVRVpptWGCMHj27PKvH8mUX
         uAAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=piVaYaAcibG6n/c30q7eQjxW7RAdxum94b1jVJAg8jM=;
        b=w4HyboiZ9fjDujPTYAFUemTylqRGxhmVrWMO9MEHJD2LlgQkKU0vJMaSlwrONxmjPq
         rxb2OCyGS90xb21cExo4qIw+Fcl6pzUwiAskzgT9qHr1t9n8EGm0l4om4uuT6zhH0gVh
         fISi4ywLOomMs2lh1uGnFXoI/VYdeJDPqMhZJqBiRSFF1mpIiCXR+5lJxzr9ZafoZGZf
         kJGVPxAAS+shPPHCsdiFSdLrIujlm86VvkYMOFVxw6+dbx1bODXFSCPuj+yVMmKcJlt3
         uCVLbzEwFJFgNyHYztcTV3OMyb64T2nugEMC8UGNrwG70Hq1dyRMporCkraFhsjWMihS
         ixZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.126.133 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.133])
        by mx.google.com with ESMTPS id y62si844337wmg.2.2019.03.06.03.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 03:01:16 -0800 (PST)
Received-SPF: neutral (google.com: 212.227.126.133 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=212.227.126.133;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.126.133 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from wuerfel.lan ([109.192.41.194]) by mrelayeu.kundenserver.de
 (mreue009 [212.227.15.129]) with ESMTPA (Nemesis) id
 1MRmsE-1gYMov1bac-00TFwb; Wed, 06 Mar 2019 12:01:11 +0100
From: Arnd Bergmann <arnd@arndb.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>,
	John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/hmm: fix unused variable warning in hmm_vma_walk_pud
Date: Wed,  6 Mar 2019 12:00:55 +0100
Message-Id: <20190306110109.2386057-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:xtKHG1cotgsAuNU1Bh1vZIBHyo9Waba/hnKI7aokdYdMmG9jdy9
 zH9VdScakVcGI7/TId/fO8MqEKIZf1ch2ZM2GM4nybKMMiz8gwKm7EsFVsbbBRVaxNloebZ
 8afArbe2cCMc7AFVB66+LlGjcdX4fIysCx2jXXnhY2OAN6AQ1w5FNFb5Yg1g1IhLWKStmTo
 DRx0Y565hgf0Y8OO9dBTg==
X-UI-Out-Filterresults: notjunk:1;V03:K0:yx9f28pAM/I=:LmhQn3gu0AVe24ypm4s4fC
 3gcoRijC1djG5MbSwcAYiYtF0ikuE7r6iiK1WBdlQ/rSYM0xFga6ZfDJzuw6Rx2/uZHfUxNlw
 56K4L/6owPUNVuu96ydKxBLUbJOCorQqgZLWYC+N2uoUChcIStaVVQYglLfeFEwnzgRWdXm3Y
 pWIpI8aX9Hz4D8ZTyRcz+LB3fxsCo229VCooikJ8pWWTei8ytU14DhWXMKEaT6vonU+rx2UTJ
 jfE9tZRCP1xGIxGqi1fubuPe6EEJekUZQpUi8/y/Fn81T3NrTfg159QobxPLgaMbo0sf6N3RR
 WMufqHg2daokoqY6V7GOxSqwrQuHpyClSp1bKiIYk0JhpilPt8Xxzlep04lvdSjYerAWUCt+8
 no+tp3dRMqNY/SJJuZPkJiseV9fhN0bjgYnnG7Q0ZV3HHsZpntL1vtvprfWh/UuQ0QH//l+II
 PLwtCCERbjmqeEODldUOZD/3PPLgktUF53GIv4wZFs1QXZQq/xDwD3H5Krq/1jcM61ZBKd0Kd
 JxZ4nN/1WjqNbyEnv0IAHospjVFWvKKE0girpwEqIfEB+Hq8r+riiLQ5g6Wn/wDTg0k0a5OoA
 7nRkax9tPYEvU83GXsLm5dR+2nuKK/vFg92NSaX4xXgrNpxraWjneQIRfrg+ptz1n9+ZV29/T
 I2tqfSbCee/b8J0+J7dOwmuhp2WfspcBhV+2TH8uWpEsUvnBhTg+rbEAPKPG4HzlyC1DvnwFP
 B6r9w1bPjR8k4VnH1WJutlkZ4QPpyOv4N/w2Xg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Without CONFIG_HUGETLB_PAGE, the 'vma' variable is never referenced
on x86, so we get this warning:

mm/hmm.c: In function 'hmm_vma_walk_pud':
mm/hmm.c:764:25: error: unused variable 'vma' [-Werror=unused-variable]

Remove the local variable by open-coding walk-vma in the only
place it is used.

Reported-by: John Hubbard <jhubbard@nvidia.com>
Suggested-by: John Hubbard <jhubbard@nvidia.com>
Fixes: 1bed8a07a556 ("mm/hmm: allow to mirror vma of a file on a DAX backed filesystem")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
Andrew, you already took a similar patch from me for a different
warning in the same file. Feel free to fold both patches into
one if you haven't already forwarded the first patch, or leave
them separate. Note that the warnings were introduced by different
patches from the same series originally.
---
 mm/hmm.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index c4beb1628cad..c1cbe82d12b5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -761,7 +761,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
-	struct vm_area_struct *vma = walk->vma;
 	unsigned long addr = start, next;
 	pmd_t *pmdp;
 	pud_t pud;
@@ -807,7 +806,7 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 		return 0;
 	}
 
-	split_huge_pud(vma, pudp, addr);
+	split_huge_pud(walk->vma, pudp, addr);
 	if (pud_none(*pudp))
 		goto again;
 
-- 
2.20.0

