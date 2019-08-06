Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 031DAC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 03:08:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4F67214C6
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 03:08:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4F67214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E0036B0003; Mon,  5 Aug 2019 23:08:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5905E6B0005; Mon,  5 Aug 2019 23:08:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A7016B0006; Mon,  5 Aug 2019 23:08:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 132466B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 23:08:43 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g18so47434804plj.19
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 20:08:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=IscKUNC/tUfe05zT8fDwZ8+8yxegkCQx+SviNtvePb4=;
        b=BK6OpqI/gFx9Jh+dejSGcCDl5zG615khxtqGk3ZWB2UfA2Bu2jLe1jWKseYcAbUzYw
         T5pw5Fgh0hB5E+OLHkcTz0tuJlBK35gbw2RYVPXk/aQd8ZhlqS2JzziHTCcQKhpUPra9
         GjjWq5u5wHDm5BIseOx4JFOC3qH6snyjdH9MP7CCRU1L4NVTjxliIjb+x8ZDPSYFMJEF
         0Zsr09rzUeZADgRSUo2ZK4VWoMApbd2QexsVpccjT/xjsPYdcEFeB5/NgXjkPQJXAs1u
         aga1ieZkwiQUrOxLoNjPTOGhmhVrVIxQbT2qvCqTuoykwloaFFwdukmJVdOMCizC8MRK
         78VQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUc0oVHP1xEORbHbgz9ImdLBt2nJ/r7UAuImAJzND72gn8Rws0V
	9kfV7Q3xvpOTz3Cdj68pMykLKhPeShmUO+MedsniPx/Akdcyhscgj3kWFg6+jbHnisBglmNSbOO
	/rW42V+FNie3k+qwnztofJR+3++TXHU2aAL0s9iQgTeKOZjE1OsF2/eV6aJLePV9DCg==
X-Received: by 2002:a65:4b8b:: with SMTP id t11mr991718pgq.130.1565060922554;
        Mon, 05 Aug 2019 20:08:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUOcbDZtR9Hmc7GWjcZ4Mix0lkGpApGNheZKykH4rKSYHgvJTAfo974g54wZllYqp9M4OT
X-Received: by 2002:a65:4b8b:: with SMTP id t11mr991672pgq.130.1565060921573;
        Mon, 05 Aug 2019 20:08:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565060921; cv=none;
        d=google.com; s=arc-20160816;
        b=Of9YlPpeHiFCp1W/h0w78cDmoyQvOP2dCOYPKoZa9XLxNpSXVRI/BBjwTQ+37guaYf
         NbrdmTN/Xj+bd7Ma2fvZsyu47xm62v9l1iNR7LqXR8l/8/aOs0z8mYfm2w4Sk7bmS5GN
         rcKjQq9hcp63qy/oo+HFoGMxa6kmkbciUHu/jSJPJ+1659VFipbb3OmBashwd6cl+SrZ
         eHWs65eS8WtlzdeEY2lmsndO7uQdrnyghxlmVsPeRqtCH65/uUCP6+XuBTzA4Y1OcU31
         26nD0Bb6fNdv78RLdx6naSy1vt1fB98jJEJwhJ+am5MoWJ0LNrXjQfgfSxZykPikMgRH
         wtiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=IscKUNC/tUfe05zT8fDwZ8+8yxegkCQx+SviNtvePb4=;
        b=FtuChzsDZqZb1hJqmxXXTBg0djIhO1WzaMvYkM+ifEYNuIhbFnjCCHkHtZoqIcYjwZ
         /tGBOHJ5m4SPory3pu9t3oub54Y7Y6MTmQicd9VXKD6LK+Ges8I/GAX8yhm+W1/okfjr
         hIztSyxySc67jJZCKYs2wgaBFb7a6Cszv/X6sOM02TnplibMQAasCbrybZdIhWMCvMBp
         hjLqigm30vMYpK9pLkqu+KfhTwKYiSZ1+2Dg9TdboBNK9HRhcbX9zK4uwNdjI0zD5Bq1
         cQSzY748RDtX20Xqs4c48ZL08vbztWuk/6KMOdxIqIyTYS53H6al2AeFTXXJpAKUf7al
         HJQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id r190si44767128pfr.102.2019.08.05.20.08.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 20:08:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Aug 2019 20:08:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,352,1559545200"; 
   d="scan'208";a="168166998"
Received: from sai-dev-mach.sc.intel.com ([143.183.140.153])
  by orsmga008.jf.intel.com with ESMTP; 05 Aug 2019 20:08:40 -0700
From: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Cc: dave.hansen@intel.com,
	Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>,
	Ingo Molnar <mingo@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH V2] fork: Improve error message for corrupted page tables
Date: Mon,  5 Aug 2019 20:05:27 -0700
Message-Id: <3ef8a340deb1c87b725d44edb163073e2b6eca5a.1565059496.git.sai.praneeth.prakhya@intel.com>
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
file mapping pages vs Resident shared memory pages). The loop index in
check_mm() is used to index rss_stat[] which represents individual memory
type stats. Hence, instead of printing index, print memory type, thereby
improving error message.

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

Also, change print function (from printk(KERN_ALERT, ..) to pr_alert()) so
that it matches the other print statement.

Cc: Ingo Molnar <mingo@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>
Acked-by: Dave Hansen <dave.hansen@intel.com>
Suggested-by: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
---

Changes from V1 to V2:
----------------------
1. Move struct definition from header file to fork.c file, so that it won't be
   included in every compilation unit. As this struct is used *only* in fork.c,
   include the definition in fork.c itself.
2. Index the struct to match respective macros.
3. Mention about print function change in commit message.

 kernel/fork.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index d8ae0f1b4148..f34f441c50c0 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -125,6 +125,13 @@ int nr_threads;			/* The idle threads do not count.. */
 
 static int max_threads;		/* tunable limit on nr_threads */
 
+static const char * const resident_page_types[NR_MM_COUNTERS] = {
+	[MM_FILEPAGES]		= "MM_FILEPAGES",
+	[MM_ANONPAGES]		= "MM_ANONPAGES",
+	[MM_SWAPENTS]		= "MM_SWAPENTS",
+	[MM_SHMEMPAGES]		= "MM_SHMEMPAGES",
+};
+
 DEFINE_PER_CPU(unsigned long, process_counts) = 0;
 
 __cacheline_aligned DEFINE_RWLOCK(tasklist_lock);  /* outer */
@@ -649,8 +656,8 @@ static void check_mm(struct mm_struct *mm)
 		long x = atomic_long_read(&mm->rss_stat.count[i]);
 
 		if (unlikely(x))
-			printk(KERN_ALERT "BUG: Bad rss-counter state "
-					  "mm:%p idx:%d val:%ld\n", mm, i, x);
+			pr_alert("BUG: Bad rss-counter state mm:%p type:%s val:%ld\n",
+				 mm, resident_page_types[i], x);
 	}
 
 	if (mm_pgtables_bytes(mm))
-- 
2.7.4

