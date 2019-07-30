Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 208EFC32751
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 22:21:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3CA6205C9
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 22:21:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3CA6205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E0008E0003; Tue, 30 Jul 2019 18:21:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 690558E0001; Tue, 30 Jul 2019 18:21:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A5D18E0003; Tue, 30 Jul 2019 18:21:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 28A588E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 18:21:52 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j12so36112946pll.14
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 15:21:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=23TEN+YXtE4R+00+FApfVXLpAqmgpsW2vc7wymoqapM=;
        b=DrgwCL6y/PI0RABuj1iqE6K/9pqFGvaJNDkQX3BCyir7G0u7DMzQGu1qrWQU0lD/m0
         tQJii7IPOh/G3IDNLxG1rICc74wJbsscbiaCZeM0v5af7tz4uQIDUtNHRTEXXcz+Abex
         VczkBVIgZGgj+V0KSQ3RUMECswYjk4k5eWNtRnsIarCHe6kjaGaT8b309Qmsf2cviawe
         OtDhwdocetKQ7h0LPa9OTFK3NiUd6Eh4/vRAY6YcQ8+3/BpTPQc3G8c7HF8DX7TTKhXk
         6zbn9elNbNL75hTVmUI25x9+Py8ggntqdBE5zFZh4/pqEkgmf38I5DtBcZt2Y7jR95Gx
         37XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVJHuZX76EYNB3QqttGPgcUaZRgNKmxd0crnXAe2awaPBiS2Ob6
	fzdr8ew9UCO/sFC7hPF7yn503TCuuBinNQLRfzGMwLqquqf+6I5UEk/Be4iZyvSzhGpBnLyu5vI
	KRXDyQSAMq8mfPRpPD7gy42lYtdioYkNS5EtkgYVP3J5qJDt/8GevqppiawyyTkZLzA==
X-Received: by 2002:a17:902:8547:: with SMTP id d7mr119368823plo.171.1564525311785;
        Tue, 30 Jul 2019 15:21:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnuMoxoCtJycj5UqXWcNmDNQjeBqdtTYcn+r0zjsbSPUx1aYkr43IC7+t5iIi6K3aUUv45
X-Received: by 2002:a17:902:8547:: with SMTP id d7mr119368779plo.171.1564525311017;
        Tue, 30 Jul 2019 15:21:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564525311; cv=none;
        d=google.com; s=arc-20160816;
        b=09OtdovGucZCqLR37fGz1d9EIm8DBSIae1U7RRNEbhLGlcqRFqgn4Qc52G8kRtarSg
         IUyFb7SKf7YLMpzL4jKsafbLafy/QF6IU6wnOMyDRzl+PTTBaxNuD1kcICiXS3PuLa39
         XQY50zeJ8+1mtYYaNEPoMImPPBWWTy0t+oKrf1KsNX08WZRxH8Ma5zpdI0gbQJTyb5SH
         LnG/njJV3t8/V7YICWRZX3I0oI80TLj+UQf+ZVKBwzwl4mD2rJXtVLNxzx/FYdNE24I5
         3QuDIMuzic64WWuGwwTX72xNI9B5ndM7607iyO7pwAalUu45isDmWZ7hta54iJM/27kU
         JHDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=23TEN+YXtE4R+00+FApfVXLpAqmgpsW2vc7wymoqapM=;
        b=cyenCkeX0NXakMCS1Gt28f9ZrG2JARBvCp5l7iBAJ42Sxu0qMfFUGv1GZTNuy/n9Wz
         Qtk9BmpdgEydzOf4Ny/r5rHjr8KBuFC29CfqS5H5nITlkn2CQuFGqthYgESx775xXxfT
         B9jaUeo6gv5NE/BiHkzWE0xPBQMBnCErjX5vJccz0DWup4kW79yIkbAOUqre68JBU+t4
         9cq7+aXZNTCxhEVVvxhTE4109Y1SFU0+BPhzW6YdufZn7iTd7t+DaeoRyYSJbY7udG0B
         zvjHo3J5LFo0XiPQLLQ2OotffBpN5HpPMBq3T3scRSQgywftMzKdtV3Yw7whIqh7US9x
         6WGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y4si30092103pfq.222.2019.07.30.15.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 15:21:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 Jul 2019 15:21:50 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,327,1559545200"; 
   d="scan'208";a="347277138"
Received: from sai-dev-mach.sc.intel.com ([143.183.140.153])
  by orsmga005.jf.intel.com with ESMTP; 30 Jul 2019 15:21:49 -0700
From: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Cc: dave.hansen@intel.com,
	Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>,
	Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH] fork: Improve error message for corrupted page tables
Date: Tue, 30 Jul 2019 15:18:20 -0700
Message-Id: <20190730221820.7738-1-sai.praneeth.prakhya@intel.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a user process exits, the kernel cleans up the mm_struct of the user
process and during cleanup, check_mm() checks the page tables of the user
process for corruption (E.g: unexpected page flags set/cleared). For
corrupted page tables, the error message printed by check_mm() isn't very
clear as it prints the loop index instead of page table type (E.g: Resident
file mapping pages vs Resident shared memory pages). Hence, improve the
error message so that it's more informative.

Without patch:
--------------
[  204.836425] mm/pgtable-generic.c:29: bad p4d 0000000089eb4e92(800000025f941467)
[  204.836544] BUG: Bad rss-counter state mm:00000000f75895ea idx:0 val:2
[  204.836615] BUG: Bad rss-counter state mm:00000000f75895ea idx:1 val:5
[  204.836685] BUG: non-zero pgtables_bytes on freeing mm: 20480

With patch:
-----------
[   69.815453] mm/pgtable-generic.c:29: bad p4d 0000000084653642(800000025ca37467)
[   69.815872] BUG: Bad rss-counter state mm:00000000014a6c03 type:MM_FILEPAGES val:2
[   69.815962] BUG: Bad rss-counter state mm:00000000014a6c03 type:MM_ANONPAGES val:5
[   69.816050] BUG: non-zero pgtables_bytes on freeing mm: 20480

Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Suggested-by/Acked-by: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
---
 include/linux/mm_types_task.h | 7 +++++++
 kernel/fork.c                 | 4 ++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm_types_task.h b/include/linux/mm_types_task.h
index d7016dcb245e..881f4ea3a1b5 100644
--- a/include/linux/mm_types_task.h
+++ b/include/linux/mm_types_task.h
@@ -44,6 +44,13 @@ enum {
 	NR_MM_COUNTERS
 };
 
+static const char * const resident_page_types[NR_MM_COUNTERS] = {
+	"MM_FILEPAGES",
+	"MM_ANONPAGES",
+	"MM_SWAPENTS",
+	"MM_SHMEMPAGES",
+};
+
 #if USE_SPLIT_PTE_PTLOCKS && defined(CONFIG_MMU)
 #define SPLIT_RSS_COUNTING
 /* per-thread cached information, */
diff --git a/kernel/fork.c b/kernel/fork.c
index 2852d0e76ea3..6aef5842d4e0 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -649,8 +649,8 @@ static void check_mm(struct mm_struct *mm)
 		long x = atomic_long_read(&mm->rss_stat.count[i]);
 
 		if (unlikely(x))
-			printk(KERN_ALERT "BUG: Bad rss-counter state "
-					  "mm:%p idx:%d val:%ld\n", mm, i, x);
+			pr_alert("BUG: Bad rss-counter state mm:%p type:%s val:%ld\n",
+				 mm, resident_page_types[i], x);
 	}
 
 	if (mm_pgtables_bytes(mm))
-- 
2.19.1

