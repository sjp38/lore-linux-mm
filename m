Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CBDAC4360F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 08:52:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4546220823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 08:52:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4546220823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF7C98E0005; Mon,  4 Mar 2019 03:52:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA9198E0001; Mon,  4 Mar 2019 03:52:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE8188E0005; Mon,  4 Mar 2019 03:52:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5B88E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 03:52:13 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i20so2291627edv.21
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 00:52:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=/MtcrrLV8TMVmie7tM6t1qu010MnpiuDWUBJSXqmRRY=;
        b=jyUyWFjuo6YYyG2oLOnVPJVZWw9Ow4HvTEw+wQ2vUBLzlcXOrcbzeU0VgUEFs0YNfp
         wVyzzfJl7hivR7A5snGbwf37pQVlfA9t22QQdxfw8SkLPEJ0O83X40Xb3SVBt2sJ87KC
         h6TVfT7AmrSWAqIWbOJnIwWvVMz4VVHqXjg9o4KpR1nNqQevMAL/ISNMDOTtWZlSWqx5
         lGoHSQK1CWWEMFah8tFuHwijqWxZoh5D07epMeapnaHgE/mK7Yeb78uRnhNxW8JtEtKP
         dD/syv2TWp7K4QkB62APPVQQd0fbWcPHSWUyIp4L+7k3pBCBlQwXKJ+mMJWNukyHkCSx
         dnWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWgmQacKUWc+ZHSsntAIzvKuQE9khygh5c+y2RfqKKnHgwvLfnI
	MY19ylFBKceFhYzSOJ0J068lbikYyfneBgNsQo6v4MhlbUWvWn7JJeJ6gxzv7phfxtwzLYOljlz
	N0WeogaKPs6Nnc7D13VJvthzcjALQPYR9UNaCxTlHUZdwF/wKXQ/ONbvuYEPO0ktQGg==
X-Received: by 2002:a17:906:7f88:: with SMTP id f8mr12088952ejr.108.1551689533049;
        Mon, 04 Mar 2019 00:52:13 -0800 (PST)
X-Google-Smtp-Source: APXvYqzKJFdEuGI5xjE6myf9HVGJn2xXVT3ft7JAApZcEV0I6Ju5SxnHPRT2YeUr2Vd2yTeFUyPM
X-Received: by 2002:a17:906:7f88:: with SMTP id f8mr12088904ejr.108.1551689531998;
        Mon, 04 Mar 2019 00:52:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551689531; cv=none;
        d=google.com; s=arc-20160816;
        b=RurPDcbPVkbMdoRPZH14dTB037xI/2rvGqCrlgPwSg5KbwMF8ZpgOfjY9HDplX2p69
         kG6RmN3sERo9S8uiqLWpr75ncBG5IuoTxMM3NQPjixSUVHh3LnU1A+rYiwk8+Sp4lR+k
         tJHvrrTEyMl71uzwhkGF/5Hx+whRMkDU6O9a9siIkQ1LoiFYwJ0ByeVnX3Bcgx530g3z
         RWFemEJDUPW0zSDl/Y2CBSr1vBPSCP92CmBkFDr58C3g++vJsyqisJdvfRkaeZ61TxiR
         jKKDp4ltnO4qFMsHdpT2cEJ+4Rahb+UJsTgIoccbd7RGGy96r8wkhb65viUwVwNK0s8F
         p9sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=/MtcrrLV8TMVmie7tM6t1qu010MnpiuDWUBJSXqmRRY=;
        b=i72JnI6YagZCfYI+woiOtK4H4Z9DwmcbQoCSI6LeZMAAwMEPDjngpltn8pHB7rqYe+
         /QvQitXcaK5UrRTaxZlocEvoQgCtMM8J4iGyID/nPS5reDawZQX/knGbBctoSjsE2q/s
         25ieJbM8QztoOibGjj9IVtncO6MkNt2NrLx5Ka9co56HkGy0uxQMlob6eYfppNzF+t3o
         a132a8cFRwmv2dqYJrO+IuIZCLJPeHA7D6xbkMYdtvM0kuSZF9r5FJVenq48rP/WxclM
         4luM/m7VZNomxUInc9niWAcaBAs4DbXHYqY5Zia4tFwzPaz4S+r3VFj0UdpK+ezLK8DH
         cc8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id o21si1656633ejh.13.2019.03.04.00.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 00:52:11 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Mon, 04 Mar 2019 09:52:11 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Mon, 04 Mar 2019 08:52:01 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	mike.kravetz@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 2/2] mm,memory_hotplug: Drop redundant hugepage_migration_supported check
Date: Mon,  4 Mar 2019 09:51:47 +0100
Message-Id: <20190304085147.556-3-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190304085147.556-1-osalvador@suse.de>
References: <20190304085147.556-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

has_unmovable_pages() does alreay check whether the hugetlb page supports
migration, so all non-migrateable hugetlb pages should have been caught there.
Let us drop the check from scan_movable_pages() as is redundant.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0f479c710615..2dfd9a0b0832 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1346,8 +1346,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 		if (!PageHuge(page))
 			continue;
 		head = compound_head(page);
-		if (hugepage_migration_supported(page_hstate(head)) &&
-		    page_huge_active(head))
+		if (page_huge_active(head))
 			return pfn;
 		skip = (1 << compound_order(head)) - (page - head);
 		pfn += skip - 1;
-- 
2.13.7

