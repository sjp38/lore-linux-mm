Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D65BC46499
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 06:13:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAE7F218BA
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 06:13:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAE7F218BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DCC56B0003; Fri,  5 Jul 2019 02:13:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28C3A8E0003; Fri,  5 Jul 2019 02:13:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17BB38E0001; Fri,  5 Jul 2019 02:13:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D31E06B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 02:13:00 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so4982274edv.16
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 23:13:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=4BJwBlxckkqgvvseHgV8h2tIQ6CX036Eth8PujYAJk8=;
        b=Ss28CU43Ckun6OW0slFE/yJESc3mvS2hpsiBq7fN26WBqCnVMKdB9HkT5kPxY1d5u0
         Wqc6acFD4Gv32k/7edLUsk1hbDFyXWLZYu0TE/btxQqXV39kwq1jQ0dG8Ot6iH7tGBcL
         LthKwgw3l4KYJLspLFzuIR6DZhYEX74us3YS1HdQd88OXNIBgUCbdN5yBUJCpgQNHQ3x
         4Dle1DAKUKLyL5KI62GW3cIneLPFXSiyzHe/1fz+W2OUCaJ5EJlxgv+9o392cF+8iIfg
         zZvnOqYR0E/ID9K47iyoMdc6m3/g5G9rf41PyXt++CHQYCnUBaS/JmMSG0A+IsAKM6gm
         IqGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWTKDwTx5DhgOeREHsPXOnfOYCCL1agnW9F5GUhEwVkDpuYmytc
	5inKuxxj4u7oCoLLaOj4QH1ffjZE1JasrevQEm4SnJQpSBQUmgo43hkcjhxJENhgqsE9uP/s2nM
	aPOi3EA2n6RmaXb+1AkdoDAjVYHU2ma3QpS09RFDMPct/XnD2nCylEdrIZcYzkmArPg==
X-Received: by 2002:a50:90af:: with SMTP id c44mr2443013eda.126.1562307180315;
        Thu, 04 Jul 2019 23:13:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyxYIyDcovTKMa6OTwhhEtet2kjzwl4taK6Ou5mBZn/mBfwVnoysupscBV+ZhC5C45eLYS
X-Received: by 2002:a50:90af:: with SMTP id c44mr2442952eda.126.1562307179533;
        Thu, 04 Jul 2019 23:12:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562307179; cv=none;
        d=google.com; s=arc-20160816;
        b=jONy4i7MjFWFdJdlMECbEtMDUcnDG5Jmtli4k9XCTxOVuxjoNIb5IAm4o7jc1kbSTb
         QtD7qKQ2GYWfK+6Jiy1ZslCXyZSfi5r0HwLVn0hdjGqLT40RSE7KM15KZ0RfScmQO24b
         ezWXa5ToJANwi648TZjiUEhICsBzEbJX/2jS/3jyxleU9mFQ7fH67T2VGnPUZB1/zrmJ
         R0kSNV6tYvLxRqTW2wVLikj1DGA7ztCaPiHECgQkY0MwiVzKBL2vGsGYi0WdV3n1EeM5
         DM7E7FKS+CHHsIbBsXK/ulhj+PeZMBaOji6GIUbxktTO2EkD367hVx6gPey+f4m9wsqM
         88KQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=4BJwBlxckkqgvvseHgV8h2tIQ6CX036Eth8PujYAJk8=;
        b=nmTGFZGaSG3ZOxApaP7YIgrpa0Bp8w7k1wplHF/32bvQQrMwUVz3pV57lvLIWf7fjt
         UDRI4Yzqd81FPymL7HNw49C950G8OXxGCA9maLJziYOYn0wAgsmlP6b+eol8KRp1T1zZ
         /KuGamBPl9mClu5rZILRNq6afwdiQWKTzfYfxWiK2h8f27y+DDxZOamAOQFlmHrD+xFH
         3bwp4Pt/Ogxr5KKaGqaTmyrtn7gELwuNyGGO7xGX16BvgHbXsMOiHRQwQvbYrBgYYZEh
         yVAMko1PbLJlphqELg2LBZC99P4Od3syJnNpZbvykGlaFp4NP2UNcbmBf2gLYqs8I6Ia
         Xnxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c50si6523936edc.412.2019.07.04.23.12.59
        for <linux-mm@kvack.org>;
        Thu, 04 Jul 2019 23:12:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AE148360;
	Thu,  4 Jul 2019 23:12:58 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.41.127])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 7B6353F246;
	Thu,  4 Jul 2019 23:14:50 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/isolate: Drop pre-validating migrate type in undo_isolate_page_range()
Date: Fri,  5 Jul 2019 11:42:41 +0530
Message-Id: <1562307161-30554-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

unset_migratetype_isolate() already validates under zone lock that a given
page has already been isolated as MIGRATE_ISOLATE. There is no need for
another check before. Hence just drop this redundant validation.

Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
Is there any particular reason to do this migratetype pre-check without zone
lock before calling unsert_migrate_isolate() ? If not this should be removed.

 mm/page_isolation.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index e3638a5bafff..f529d250c8a5 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -243,7 +243,7 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	     pfn < end_pfn;
 	     pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
-		if (!page || !is_migrate_isolate_page(page))
+		if (!page)
 			continue;
 		unset_migratetype_isolate(page, migratetype);
 	}
-- 
2.20.1

