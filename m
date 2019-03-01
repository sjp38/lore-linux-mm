Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9024C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 15:02:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA2A620850
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 15:02:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA2A620850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 479318E0003; Fri,  1 Mar 2019 10:02:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 429968E0001; Fri,  1 Mar 2019 10:02:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31B0F8E0003; Fri,  1 Mar 2019 10:02:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 01CBB8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 10:02:12 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id n84so7979688oia.14
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 07:02:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=s+sCWyYnRIXgxAfwQFJvRrfhtgzEfkchMzNzAFOSSLg=;
        b=HaC3xPneHeDftcJ3GJ8h8knxY839zgwV6RWUAYqN2DUks36JA8GxXwJ0dpxWgoJjJ7
         4HCSfl8CzRyYe9xxBHpZFVSxNB+UEkHcTVq0CVXGAHdNOBiCi878ZRkWSgDVue3qrUum
         62mUOIMD+AkXZueTCyhx+CmBntm78154j3ZrI+eE0Y7Fp2bQZdA0bfkf954PRPclZRti
         2bSLy+AhHAfidRp6rIs4cIegNcil1/VnTbCmjfUxGp3fJfIHoFE4zxSqLLrkf9LHO417
         kFq08JpJ1vcAn6weC0+8ZSJcEd7t9T6oo9LXSuw6Rgzc9oYvGWSHMwOZ3igTr5CuoHPR
         qk+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAWyat4Ti0x1AS8lnrW1eUiLPo8j1FL81gHM+4gkpEUMAn03fM+U
	4+coKFgZcTw3BQClclh0GGllVURje9Bt5pKBLzipiN7QaL9GsBJClsJWeJqW4/zKRd2vLTxfeGv
	xuIzJtQIeHnlwKnVLEygIc+RiATeS0rhJt2qOlScmhB3calQVkrSdghM6LthiDvh5JQ==
X-Received: by 2002:a9d:7d05:: with SMTP id v5mr3684556otn.201.1551452532636;
        Fri, 01 Mar 2019 07:02:12 -0800 (PST)
X-Google-Smtp-Source: APXvYqw9i/x77LOcs3zivcbdVfgezouSmvPClDpDvbcr4r0oG3wOoWAp2W1bSc2Nk7duRhd2c07y
X-Received: by 2002:a9d:7d05:: with SMTP id v5mr3684489otn.201.1551452531745;
        Fri, 01 Mar 2019 07:02:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551452531; cv=none;
        d=google.com; s=arc-20160816;
        b=yWeJcsjQaq21gDx585DMpbPGKn4SANw6mrYEaiIrmEwPqd9Bq2ytenKlxttvUM5y9/
         kyY5H4bdWq8cD65muqEjwqlszmidG2zy3C/83nxeD8Zn3OeRoE/w4bAiDCAXiterFhsN
         D9fUdt3/a09NOpex5lRP3orqBObEsRxVQtnqVJDbOBXm+JwrLnz+0NLDWuV5Ce0kmfM1
         oXEEgZUFlBdVNMXK+brZ69wdjiogEe9W1uWJJELbjkiNDFyJfWcUkKXkICdF6ZO1wtnu
         szm31g0hsv+MEybTguQUs4HnaZ4ScWAhBolxNDNf3X7yVGxrqXSBXXUUkfpbdJSR2FfW
         50lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=s+sCWyYnRIXgxAfwQFJvRrfhtgzEfkchMzNzAFOSSLg=;
        b=yLnj78YbyhO18xtBittatheKdsnARXD8N9WfaijbPqdDw/DnOEvMQXotQN8t/yGWAa
         D8xSI7Xfrbto9U99NEHVO9gLaO5rx8l46oEHVcWVsH31u3RHLEJazKCBcfcK2DVPOH5J
         rR4ARZMlIsCTyP4CHQevxbKAMCccsaAXbtevHoy7ez8d3NKKe3d1DWWs+tZMOY7Pjok0
         zsCCb/N48wY8QOlOM52TzwU3dzcsYnVraVbnF1AZixVNGWSUzZL4JXYw1JfV7MuwvmuJ
         wub83Uy7F6NCKTBXwMqUSGDZAGt5uR2K2NagSW8OnapAXvPl8+oMkRrVQSzstGFkWCv2
         HhSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id p10si8238846otk.187.2019.03.01.07.02.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 07:02:11 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 16ECFC80CDE381FF75ED;
	Fri,  1 Mar 2019 23:02:06 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.408.0; Fri, 1 Mar 2019 23:02:04 +0800
From: zhong jiang <zhongjiang@huawei.com>
To: <akpm@linux-foundation.org>, <n-horiguchi@ah.jp.nec.com>
CC: <linux-mm@kvack.org>, <mhocko@suse.com>, <hughd@google.com>,
	<kirill@shutemov.name>
Subject: [PATCH v2] mm: hwpoison: fix thp split handing in soft_offline_in_use_page()
Date: Fri, 1 Mar 2019 23:01:16 +0800
Message-ID: <1551452476-24000-1-git-send-email-zhongjiang@huawei.com>
X-Mailer: git-send-email 1.7.12.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.175.102.37]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: zhongjiang <zhongjiang@huawei.com>

When soft_offline_in_use_page() runs on a thp tail page after pmd is split,
we trigger the following VM_BUG_ON_PAGE():

Memory failure: 0x3755ff: non anonymous thp
__get_any_page: 0x3755ff: unknown zero refcount page type 2fffff80000000
Soft offlining pfn 0x34d805 at process virtual address 0x20fff000
page:ffffea000d360140 count:0 mapcount:0 mapping:0000000000000000 index:0x1
flags: 0x2fffff80000000()
raw: 002fffff80000000 ffffea000d360108 ffffea000d360188 0000000000000000
raw: 0000000000000001 0000000000000000 00000000ffffffff 0000000000000000
page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
------------[ cut here ]------------
kernel BUG at ./include/linux/mm.h:519!

soft_offline_in_use_page() passed refcount and page lock from tail page to
head page, which is not needed because we can pass any subpage to
split_huge_page().

Naoya had fixed the similar issue in the commit c3901e722b29 ("
mm: hwpoison: fix thp split handling in memory_failure()"). But he missed
fixing soft offline.

Fixes: 61f5d698cc97 ("mm: re-enable THP")
Cc: <stable@vger.kernel.org>        [4.5+]
Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: zhongjiang <zhongjiang@huawei.com>
---
 mm/memory-failure.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d9b8a24..6edc6db 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1823,19 +1823,17 @@ static int soft_offline_in_use_page(struct page *page, int flags)
 	struct page *hpage = compound_head(page);
 
 	if (!PageHuge(page) && PageTransHuge(hpage)) {
-		lock_page(hpage);
-		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
-			unlock_page(hpage);
-			if (!PageAnon(hpage))
+		lock_page(page);
+		if (!PageAnon(page) || unlikely(split_huge_page(page))) {
+			unlock_page(page);
+			if (!PageAnon(page))
 				pr_info("soft offline: %#lx: non anonymous thp\n", page_to_pfn(page));
 			else
 				pr_info("soft offline: %#lx: thp split failed\n", page_to_pfn(page));
-			put_hwpoison_page(hpage);
+			put_hwpoison_page(page);
 			return -EBUSY;
 		}
-		unlock_page(hpage);
-		get_hwpoison_page(page);
-		put_hwpoison_page(hpage);
+		unlock_page(page);
 	}
 
 	/*
-- 
1.7.12.4

