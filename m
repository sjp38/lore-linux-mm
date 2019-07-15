Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00A88C7618A
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 06:17:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6BD520644
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 06:17:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6BD520644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6460E6B0007; Mon, 15 Jul 2019 02:17:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CEFC6B0008; Mon, 15 Jul 2019 02:17:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 497E16B000A; Mon, 15 Jul 2019 02:17:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F1D036B0007
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 02:17:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so12896464eds.14
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 23:17:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=GlOBlEcIXkjl+TiR1o4jafzqgo8fD8vSAH8C3FJFjlA=;
        b=ailewWR/Y8pJF7+2BkzApYFh/DMJfSanJGbLd7pjPKdyJ9SWk8W7jx9UB53F60oyDf
         iuodoUD8AgGelqch6pqkoucVOfuklAdxdY4wBj3gjVsDeR4oEvKnmQ4zmvkzXHQFyWb0
         2IoUtbM4/nppLvtv7ID+Y/r8vuReFgK0uM/Cbl8ahhGw9iNUNch8b6SMnuH/w0RYHPkv
         QYBsAWjviHkKrW6Nhp9Ts2D+85+TbmZ/iv9Ea5xyPnjL2I3yZh2fCSYwXS/J8fyb8FT1
         iIXRbju/rl1kmGLoahr65B9vItsjf+stZaZeCDNuifBRUwuu4ZhUNHRH2iPYd3GuaKLY
         u72w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVYHUBvCSF8WraWZJCtorucGLA3fnoAE/GEXOzCl/d5B1hO+pUm
	9QAH5/p4Slc6xQu2DFT/YrQuuoTJdvo+xFZ4yOFrIR/zqr11uZKno2r1/iJ+C8XIXlIQEnPkO3H
	eJRSZ/1MzUc/XomS5y3dZcql+Y3fHPJ7e5EqNFgcl5P+TQax6zbC9r7xCfXbguoDCMw==
X-Received: by 2002:a17:906:4e92:: with SMTP id v18mr19429697eju.57.1563171458558;
        Sun, 14 Jul 2019 23:17:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRtEX/OGE5p3ySSv5ryBlTQoRYJftPFJmutFcabpFXE0eN5rKz8t70w+dwhroiZB9lNGGY
X-Received: by 2002:a17:906:4e92:: with SMTP id v18mr19429660eju.57.1563171457801;
        Sun, 14 Jul 2019 23:17:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563171457; cv=none;
        d=google.com; s=arc-20160816;
        b=EnSRHOgEPwHKxeYUsWbQenYsGaMdrZrar6AMdoN+IyUJGmq7SzEGviwzSf46jT2Uay
         4u7JQIfUDyLSgYE0LbMlPbkGazQc0+Lf9lhekgnVQFanWVlvqny5Ux+Xfhsb3fF/o4iy
         m8uXcAVero/xPm9H/P/TCfPjSq4fx8vxXal1pw1l+G/LyajZ/+gJehG5AUZQ/hEz8/RA
         mXxEtANGLoqyzwfZa5KlMvAhkLCBeQvWSly+hfrFwD1De5+t3wuxFIrME7ncR3k5WKfM
         5d+GDTBOZ+0ou41ykm152ukOwwk9uIIvZTfcZR+fXoqE5fFvezHAb+wQijQvFhhj5poJ
         Qasw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=GlOBlEcIXkjl+TiR1o4jafzqgo8fD8vSAH8C3FJFjlA=;
        b=TdUU1y8AerlO4ttSzMGx6i1jpQGP75jYz0y57YNQtnobSsWImttFiGkS/VgAmFwg+w
         pCvlf0hLJiP8LLDakPS0uDzTjonfF4zAzyDT3858mt5a4GbYA0b7cZZP0dqVZc9nel81
         HWRJdUZg1ZmD/zNlgqtSsdSQKsfCG+dv5h3wNz7YCsd1luT8kugGuceVS2A0CkiLiVpd
         c3PAhWhrPjuw0UdBcEw5OaBJXg/kaDmCQAJhL/GRMb84JzGb828iZKmWHEzlS+00RvD3
         +i8phgHkhgrMPHGJZvdrC6Z5vTEPzPGVpMpNjlPpQkkRwLHr4ZwaBNU2WIXbBx4FGoqV
         TeIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w21si6955929ejb.254.2019.07.14.23.17.37
        for <linux-mm@kvack.org>;
        Sun, 14 Jul 2019 23:17:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9BEA0337;
	Sun, 14 Jul 2019 23:17:36 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.143])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 6BE9F3F71F;
	Sun, 14 Jul 2019 23:19:30 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	catalin.marinas@arm.com,
	will.deacon@arm.com
Cc: mark.rutland@arm.com,
	mhocko@suse.com,
	ira.weiny@intel.com,
	david@redhat.com,
	cai@lca.pw,
	logang@deltatee.com,
	james.morse@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	mgorman@techsingularity.net,
	osalvador@suse.de,
	ard.biesheuvel@arm.com,
	steve.capper@arm.com
Subject: [PATCH V6 RESEND 2/3] arm64/mm: Hold memory hotplug lock while walking for kernel page table dump
Date: Mon, 15 Jul 2019 11:47:49 +0530
Message-Id: <1563171470-3117-3-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1563171470-3117-1-git-send-email-anshuman.khandual@arm.com>
References: <1563171470-3117-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The arm64 page table dump code can race with concurrent modification of the
kernel page tables. When a leaf entries are modified concurrently, the dump
code may log stale or inconsistent information for a VA range, but this is
otherwise not harmful.

When intermediate levels of table are freed, the dump code will continue to
use memory which has been freed and potentially reallocated for another
purpose. In such cases, the dump code may dereference bogus addresses,
leading to a number of potential problems.

Intermediate levels of table may by freed during memory hot-remove,
which will be enabled by a subsequent patch. To avoid racing with
this, take the memory hotplug lock when walking the kernel page table.

Acked-by: David Hildenbrand <david@redhat.com>
Acked-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/mm/ptdump_debugfs.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/arm64/mm/ptdump_debugfs.c b/arch/arm64/mm/ptdump_debugfs.c
index 064163f..b5eebc8 100644
--- a/arch/arm64/mm/ptdump_debugfs.c
+++ b/arch/arm64/mm/ptdump_debugfs.c
@@ -1,5 +1,6 @@
 // SPDX-License-Identifier: GPL-2.0
 #include <linux/debugfs.h>
+#include <linux/memory_hotplug.h>
 #include <linux/seq_file.h>
 
 #include <asm/ptdump.h>
@@ -7,7 +8,10 @@
 static int ptdump_show(struct seq_file *m, void *v)
 {
 	struct ptdump_info *info = m->private;
+
+	get_online_mems();
 	ptdump_walk_pgd(m, info);
+	put_online_mems();
 	return 0;
 }
 DEFINE_SHOW_ATTRIBUTE(ptdump);
-- 
2.7.4

