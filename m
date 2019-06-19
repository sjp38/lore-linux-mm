Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11B9BC31E5F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 04:17:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D807A2082C
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 04:17:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D807A2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D94C6B0006; Wed, 19 Jun 2019 00:17:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58A238E0002; Wed, 19 Jun 2019 00:17:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A0108E0001; Wed, 19 Jun 2019 00:17:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 00F186B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 00:17:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s5so24272198eda.10
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 21:17:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=GlOBlEcIXkjl+TiR1o4jafzqgo8fD8vSAH8C3FJFjlA=;
        b=CGHcc9q/M58rN9uO+x47XFkf/Na4Rl2522QW5yIXQRXJjnZoOuda7GnKSSv0wsByU3
         U2Lsu29AUoxKe/KwVDJgHIqwwokYNLgq7RvxhBtXekn88foqnpVcGz7+fB9G/GRSPrlZ
         WEeCEeIkMBGojcy44q/FqyUZB0Z17hXpslDnNzTrWLY5/FoM0Kpme+LQb6hv2FhcDueY
         eF9tTk3m1EsFnKSJ9w22AON0hEKyMSzPy9nKjqG5nHf6p+LO7kNrU3PTAfTJBKT2baoS
         IIW43pZaeXeE5zO3EuUxNQoY8WoefYszGGCQuox/k4+Mbgpk+iwUiisiUjjGzH0pncAr
         jSXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVLMZzGCZB/UqrQ9kguC8AAvd3KCOogyiou7yJOgyzVd7v38LKA
	mMf02bW+lzdYJj2F/1d26K5sYd+xOi/SLLukvMBWPZot5h1mLLaLrlzvLKwuhRjG793i1/mivpO
	AkVlF0SomjnyMvzzuH+hcJkR1qPAqf073W3P3kCfUE/FaHQqWGVwEHfGD7jSRI9tKhw==
X-Received: by 2002:a17:906:69c4:: with SMTP id g4mr16601777ejs.9.1560917867503;
        Tue, 18 Jun 2019 21:17:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZAoK1bquDBAoeDeSF4zRSvg0TGFe0/X8r5dzICgfrGN/8XhJyJ6BjssScCMvSBEAhhbVh
X-Received: by 2002:a17:906:69c4:: with SMTP id g4mr16601730ejs.9.1560917866624;
        Tue, 18 Jun 2019 21:17:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560917866; cv=none;
        d=google.com; s=arc-20160816;
        b=NDT+p8ee7xJiVjO6NK72HYxiYyDROCZQ4PNZcW1hCClb5rg+p27sF9oknIVW3PUkmO
         Ev8gQ/gSyg1A52O6um05XCFaUOltoioxA7w3dugJJYH3RNZ3C0F6RlwfTJAQpxmv//NQ
         pYy/IVuN+C8EjoOSrzJG7L02wfh51SKlMHTEu6LlpQcluGCAcXx2JGjXu65hR5+Y+UR+
         Bx0JxrR8c7rMuZwrFUPsnGEyqySgeYE5xzEffZ4ebC5TqmKAYStjFviHdHU+KV3KMD42
         37ZyCyrQWEBDKCvcgN2YODeGrvtA/pVjIkLdOyaPmVLphwowfoopV3VufQog93TmJ7m9
         9A2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=GlOBlEcIXkjl+TiR1o4jafzqgo8fD8vSAH8C3FJFjlA=;
        b=k2hi54eeJRL0sXoOnqB3c8GGe/Y25RQdte7kpR2livg3TEF3l+TBW9FDg8S5GGzHsz
         YJhfFSujCPmETfnDuZDvMlqSXidkSi234xVPtb51Gj+0iepl6XUEGcsWkRymxdrkOAC7
         PcUoFmF+AaPv4qdIzICwNmFbtAO/b91jroRqmwa76cG8z2xHNJnY/8aNyRoq9wj9Uqtg
         /dDSBFYd9bWQckcVz7J9CULyLTG39ZZJ8USCQvYIoNRaHmyd8f2zwfMYkg70xuY7zlOl
         B3boiiNr4bJkSnYeZ9o/TsxZkGfrC5bFA8kgUTK5Aw9tXPvb5jpEwiIaTW2eO/khMDib
         jdQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id u12si3093775ejz.73.2019.06.18.21.17.46
        for <linux-mm@kvack.org>;
        Tue, 18 Jun 2019 21:17:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C36CA360;
	Tue, 18 Jun 2019 21:17:45 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.43.130])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id BEC413F718;
	Tue, 18 Jun 2019 21:17:39 -0700 (PDT)
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
Subject: [PATCH V6 2/3] arm64/mm: Hold memory hotplug lock while walking for kernel page table dump
Date: Wed, 19 Jun 2019 09:47:39 +0530
Message-Id: <1560917860-26169-3-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1560917860-26169-1-git-send-email-anshuman.khandual@arm.com>
References: <1560917860-26169-1-git-send-email-anshuman.khandual@arm.com>
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

