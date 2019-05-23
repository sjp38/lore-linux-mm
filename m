Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2756BC282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 22:37:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E74FE21773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 22:37:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E74FE21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BA0C6B0005; Thu, 23 May 2019 18:37:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76C176B0006; Thu, 23 May 2019 18:37:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 659BC6B0007; Thu, 23 May 2019 18:37:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4616B0005
	for <linux-mm@kvack.org>; Thu, 23 May 2019 18:37:12 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 93so4432277plf.14
        for <linux-mm@kvack.org>; Thu, 23 May 2019 15:37:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=aEUSCD8oUwdNA+wDHvf2bEMUzgevpJ47LSjaa1fj8TI=;
        b=QO2CMTL7liWe1tAm2h/vFxdXIKzgCAqqwmwDSml0ZvDWp3X4CQDcN8sVH6e0q7TOdc
         9630UbbpRypJawR1h7MEpndfpGZbpV6bPcwbXtOKH5FGpXBdbd8rIeIzC6r9VZc42ZRq
         brOW9xEDfYJqHvZPTkQiHSEbEAARlaTN37zXFVFkVuekMTb2JGA46r5AftUcBZj14CJc
         L4R9UAn5SFCaZBaO+kDr9PDF0F7cfp2evRI2nYoIOGItjqaSBxEpvSOMa6HFbQh7LTkC
         j9YzYFbZ2+SnsbMYHpyQBZgxkZWV1/dA1DYUU30NnFGL1kPgp+kvzrPtfkDKimFvEsaq
         fKOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUamLjWKm8FjMPVx3ttaO0HR+I5zrxNyENCegPlMhzIVpr2RNNV
	AdvkOiZnqjSKvQcmrdVvEpEAU0Sn5dIfV0x90RFkSGSLkNoFCXr6mIqQtzPoKsUp2ww52BcUVjh
	VIKaquJDY8zuVlIwcQ7YnTWJQCqQGOK+SK/Vs3wlgIcGr8/0Sc9C7pEPgq6KL1uwMYw==
X-Received: by 2002:a62:1846:: with SMTP id 67mr89153010pfy.33.1558651031874;
        Thu, 23 May 2019 15:37:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyELYQYf1pRWtH0llUmn+KAIqp/OrCi7CYN9plIbywY/95tIMgkTa6Y8URcHzcdOg+x45kx
X-Received: by 2002:a62:1846:: with SMTP id 67mr89152941pfy.33.1558651031228;
        Thu, 23 May 2019 15:37:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558651031; cv=none;
        d=google.com; s=arc-20160816;
        b=rt9ot2I1fQGmR8lYOwMUxpVGNfR3lsIPGgDGb2B7poiZDtltklD8OjZDSCkUagwG4z
         kuJmfBhDA5mI2j0/b25hDsIRz2STwb5rIdAHH3L678D7ZFpgTBJ3DpUdKirMqI35/KZQ
         8QnAbdXGfT6eJuZHJKtMmbh4x0YzS1XW6OXcugaoTnt+9dcjSHxOA/SAwoYT6FmBc2uj
         HqrzbPg7toE7Lfo4JVA5Y+GqDMznPXVt3QAmOfjjT+C3WhR6FYRtm5Kr0zSM6viDQHd2
         uTfLa74F+kDZSmnEEdbK9LF1HqQvQ1b+Cdb0GhpzTXgss5OAK4nBbyOq9gGvmMSf4a5B
         v7+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=aEUSCD8oUwdNA+wDHvf2bEMUzgevpJ47LSjaa1fj8TI=;
        b=CUG2OYfxUjcy59TxHE4937QVZe/m32W836X3icvtE2Eiy2bjmJc+N4T0ja5eqXuN4E
         btzBHH93G4gQ/LQ/EYKJ4EwEcHJRvD9wOg8cSYms1QKLcav2ZFJBvoyOWoaKkUIXAzTO
         ncaJ4HA6BwUVC+Cg9RbvMVh7Fvy1O4/mB2lP7KNLcJdsQ0UVXyaKTGRfKXGEB7tfqNyS
         U6vOjyHpvf7+ACwt7XqFr9Ul+aevDN0BTpYGMp4jJKOCPh0Cp8FFVHbqLhqr9PPjvv7I
         FrKyjsYlpr2aiNm7R3ayvYi4sK1QAod4e7LN8Jzk87kqGkseNogwiKy0gkiZiin5TftO
         3Xig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id p8si1399541pgc.362.2019.05.23.15.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 15:37:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 May 2019 15:37:10 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 23 May 2019 15:37:10 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Ira Weiny <ira.weiny@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH] mm/swap: Fix release_pages() when releasing devmap pages
Date: Thu, 23 May 2019 15:37:46 -0700
Message-Id: <20190523223746.4982-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Device pages can be more than type MEMORY_DEVICE_PUBLIC.

Handle all device pages within release_pages()

This was found via code inspection while determining if release_pages()
and the new put_user_pages() could be interchangeable.

Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 mm/swap.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 3a75722e68a9..d1e8122568d0 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -739,15 +739,14 @@ void release_pages(struct page **pages, int nr)
 		if (is_huge_zero_page(page))
 			continue;
 
-		/* Device public page can not be huge page */
-		if (is_device_public_page(page)) {
+		if (is_zone_device_page(page)) {
 			if (locked_pgdat) {
 				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
 						       flags);
 				locked_pgdat = NULL;
 			}
-			put_devmap_managed_page(page);
-			continue;
+			if (put_devmap_managed_page(page))
+				continue;
 		}
 
 		page = compound_head(page);
-- 
2.20.1

