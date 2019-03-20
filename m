Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55A05C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:27:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31DDD2175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:27:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31DDD2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8E3D6B0003; Tue, 19 Mar 2019 20:27:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D404F6B0006; Tue, 19 Mar 2019 20:27:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C07146B0007; Tue, 19 Mar 2019 20:27:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4A26B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:27:49 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id o67so640156pfa.20
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:27:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=JeGgaLyrLn5b58j5Jx1d9osvKNIbH6YEUhGnXPPvLZw=;
        b=edge9jjOmtfIky3Cg28kJQhEdeGE4CeE6FkP2CzO7ng77MEIX7uf/sQ7+IRiHAlRFX
         93a0FwnVoKxWsSZSqXvGekXQ/s+QR7kf669DJ9cDn9OiCQNvGNqYaudfYjpdQco++UP6
         HUmGxGtgfaMVCs/j4qwFcjq+bvPT6HkBRZ+s9twuqVvWT3YPnLXXBK5YBUe5RUsfHA/T
         fezh2mxJBWpapmpiWY8qWVAthwAekwkOpla8jq3eB33Srm6ukqx5zVWbNVW4qo+Ir4ge
         vQbHMi3TXCN3tOtsrK6UqCbRYLj0w3QdbC6QZuYOz28vMsTzryBzPwsZGkp/iqQH97D0
         6bWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUkAs7Z96oiFwKdqWts82GbmLgjsgSK9q7Jc1JQ2spXZatZns31
	VBamJ4OTZSUCikjZDtwtSQKzOeR5g6Rr/GYrjRpN9AA0qNC6L7rcFoJYXO3/eahCHhX4UxEUnFF
	9knDotPScmz6RzjzPZalZt6bYlkbXxmz3HaE8WA01k1fjgjnxaHPgMbgnfPmcJykOPA==
X-Received: by 2002:a65:64cc:: with SMTP id t12mr4583197pgv.438.1553041668953;
        Tue, 19 Mar 2019 17:27:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJZEh9OK7ZmxS5RAHAuvDZSdESUEo5FCalo92oG5jcA67jNQANovq1ougaggnHcJC//w2R
X-Received: by 2002:a65:64cc:: with SMTP id t12mr4583098pgv.438.1553041667295;
        Tue, 19 Mar 2019 17:27:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553041667; cv=none;
        d=google.com; s=arc-20160816;
        b=IOdFCBX2ZPGcwOsdFSiaUEDWbJTFgbxw1fnY1+4UrKfkaZuBsmUA57eaNQnfwbZhPj
         4Olqh95zSg/xK/7k/HnwCxbIAPEh+M8N0vSvPr2lbWQ3bUfKENkuMZKE7cQi8J7q9Qqr
         GC113oZ1ipIUYSrCODejfI3AfY+uAaQCt/ylYOu0Nw/4bmXtvBCojcjOHnedntXp1uwW
         pq/Xf8EonJCeDkGVD6t7hMR7Gjv0U+00+GsGXt0+5je6wUbfMxmE14BggckqohUhsa32
         y/Lp0KLK89j6Fzs6RougRPGgaJLeYW5FlMc16+2UjpDr/8k827Inq5nHQtlq1n4x9VIE
         7Hbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=JeGgaLyrLn5b58j5Jx1d9osvKNIbH6YEUhGnXPPvLZw=;
        b=pZhpa1J+oSP9ywM1SEWBEQs01YYecoXjuPxtZHBNSNTdlssGVKZ6SisIAUEQpjQ5He
         dgZg1Dz5cHop6MOKqCl0hZqO50lBM6JoM1KD7aegStZfzPm0MdFBSk2yWKVf3bSGOpf9
         nDVJVII4+81O+Sh7DsHheSc7WxC1uYLX9ZPivFPA7mFwE5sw1oujpWZrnC1Ur+JRpAmr
         scrVO0w7DGKtdQzZVdl73I8QXgZ1gtpYUEYB/BXlxoBcMajZ+CA+y9eLg2RTKM8uvl1l
         VzFy6U+MGSL9aHY3e1YxHR3V7lkb8MJ0TSHI0rg5uhMu5aAEPRWqM4eMKg1qhC+9OwQX
         CzAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id o15si258347pgv.435.2019.03.19.17.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 17:27:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R561e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04452;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TN9thOz_1553041659;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TN9thOz_1553041659)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 20 Mar 2019 08:27:45 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mgorman@techsingularity.net,
	mhocko@suse.com,
	vbabka@suse.cz,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH] mm: mempolicy: remove MPOL_MF_LAZY
Date: Wed, 20 Mar 2019 08:27:39 +0800
Message-Id: <1553041659-46787-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

MPOL_MF_LAZY was added by commit b24f53a0bea3 ("mm: mempolicy: Add
MPOL_MF_LAZY"), then it was disabled by commit a720094ded8c ("mm:
mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now")
right away in 2012.  So, it is never ever exported to userspace.

And, it looks nobody is interested in revisiting it since it was
disabled 7 years ago.  So, it sounds pointless to still keep it around.

Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
Hi folks,
I'm not sure if you still would like to revisit it later. And, I may be
not the first one to try to remvoe it. IMHO, it sounds pointless to still
keep it around if nobody is interested in it.

 include/uapi/linux/mempolicy.h |  3 +--
 mm/mempolicy.c                 | 13 -------------
 2 files changed, 1 insertion(+), 15 deletions(-)

diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 3354774..eb52a7a 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -45,8 +45,7 @@ enum {
 #define MPOL_MF_MOVE	 (1<<1)	/* Move pages owned by this process to conform
 				   to policy */
 #define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to policy */
-#define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
-#define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
+#define MPOL_MF_INTERNAL (1<<3)	/* Internal flags start here */
 
 #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
 			 MPOL_MF_MOVE     | 	\
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index af171cc..67886f4 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -593,15 +593,6 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 
 	qp->prev = vma;
 
-	if (flags & MPOL_MF_LAZY) {
-		/* Similar to task_numa_work, skip inaccessible VMAs */
-		if (!is_vm_hugetlb_page(vma) &&
-			(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)) &&
-			!(vma->vm_flags & VM_MIXEDMAP))
-			change_prot_numa(vma, start, endvma);
-		return 1;
-	}
-
 	/* queue pages from current vma */
 	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
 		return 0;
@@ -1181,9 +1172,6 @@ static long do_mbind(unsigned long start, unsigned long len,
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
-	if (flags & MPOL_MF_LAZY)
-		new->flags |= MPOL_F_MOF;
-
 	/*
 	 * If we are using the default policy then operation
 	 * on discontinuous address spaces is okay after all
@@ -1226,7 +1214,6 @@ static long do_mbind(unsigned long start, unsigned long len,
 		int nr_failed = 0;
 
 		if (!list_empty(&pagelist)) {
-			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
 			nr_failed = migrate_pages(&pagelist, new_page, NULL,
 				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
 			if (nr_failed)
-- 
1.8.3.1

