Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20AC4C282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:32:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFA38217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:32:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFA38217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CE636B0006; Fri, 24 May 2019 11:32:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AF516B000A; Fri, 24 May 2019 11:32:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66F8B6B000C; Fri, 24 May 2019 11:32:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 186226B0006
	for <linux-mm@kvack.org>; Fri, 24 May 2019 11:32:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h2so14701623edi.13
        for <linux-mm@kvack.org>; Fri, 24 May 2019 08:32:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=RnqC/4aATsfnryRf2O1Equd0/Sj7rMOmnZ1JksNvb0w=;
        b=CnxbbdZ5dffTXG3fQ1UMCG6l2h7kYdqFPQr8rTC3LCoXB65KZBCAf7gQ/zqcV+DM3V
         Z1jNLXY9qV6iSjTuEPuJdxt8629olp7GDojocp9UzdItf5mf5C39VhpFJGEAB4I8pRVS
         +vf40nEYqxYpp7WiaP6XpYYTBUE6tUGtxqI4ktuqocB2JfL6L2Mi6cHT+83fFXgtVlVn
         rJPcxbaGNjmIr+HctbVxtZjYm4X3s6Pwz/mALu2f1bxItyXU/XTZgFOFMwfseEzn2Nk9
         tnzZj7zRoWxF7oe7cZN6EyhFX/I2X9o1GmZ54yYH4/uk86IP+e/UzIDsah5kzwpAV+b6
         sPKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
X-Gm-Message-State: APjAAAWmJ6ggp2gVKFL67CAqNVlvcN2w/5fFGT7PlxPU78sW5Yh4qU4d
	NP1ekR4Oq60WXrePsNZ0eUOzkm+HiMQX3H4A5C36IMS2OvA3iiFg5XrNL4EK/xYTTrtgn5OYQ/O
	m8iczOj6qLhLJFBMFyLFmFJOvN+pHWsoldU7QpRjC6wZj1xtxO+vi1Q+ydU9SZ4gjbA==
X-Received: by 2002:aa7:c645:: with SMTP id z5mr69985454edr.43.1558711925477;
        Fri, 24 May 2019 08:32:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTzqg8SW7g4RJhQwSXkpmPwRnsJRM1xzko4AfXeW4GuJIyBxaEvNhg7XeNxdTxUwuq8V54
X-Received: by 2002:aa7:c645:: with SMTP id z5mr69985326edr.43.1558711924509;
        Fri, 24 May 2019 08:32:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558711924; cv=none;
        d=google.com; s=arc-20160816;
        b=u81/MVLehEcBHyzGxnJgW1QyJxh0lsgsCJE1Uqkc8CM0b7YAJMmiZzV+LA+14NhNgl
         MOujFtJtwAUCd3ysNzjrGemzMxnzreuWxR/1031IGCVbUthbWUMeDVTDlETfZ4Rgi9HX
         L3b+87Ab1udoDh0HB2wlEN5YDtSfR+v/IPRBsnSO5mT558OwNxF5Lbt4XxkHSHkGqFLT
         XxkZBh8lOXFnsvWRCu28wfdbJdxO0GAUUh7eV+oh1Z2Ba8qk3X2j7l69oqteKb7ktBvm
         rvR/wy5v2tfdpxQLnrHdLe+UTufLkHu31A5qAbJqMCy2qZQ1OkGtTUy85x37t7V0He+2
         NJxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=RnqC/4aATsfnryRf2O1Equd0/Sj7rMOmnZ1JksNvb0w=;
        b=kztVQrHJ4GiU9p/3iWRU2Ti4x2ipnwKuGoixypzm8abH7Ye03a9gQBdCM/c0z1Z72C
         cYLiYC2m/PMzh1UgzKD4zkkmvvBOhrIKn58Nrn06c731W3b6/kRy2j5+SfWJSQjAR+m4
         MYAlYkS3pjqjTMT2usHwxIwezPAwM2BFzHb4+6diaMyKmByiaw7AUHzdmo8opcRj82Tk
         viKCH024SewzYacxiusDND1Ub7ih+xY8D+7qHVF5dzcFUK/xf7QXg17GCl+iDGvu+b/o
         9nuIg8v36DIn10NjkG6GegNxktb3++YWai6Zhn5eHHRHAtse3qTKxCLEzc6hCvjgiX5r
         VziA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k25si1949322ejz.258.2019.05.24.08.32.03
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 08:32:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 11F4180D;
	Fri, 24 May 2019 08:32:03 -0700 (PDT)
Received: from en101.cambridge.arm.com (en101.cambridge.arm.com [10.1.196.93])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 429663F575;
	Fri, 24 May 2019 08:32:01 -0700 (PDT)
From: Suzuki K Poulose <suzuki.poulose@arm.com>
To: linux-mm@kvack.org
Cc: mgorman@techsingularity.net,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	cai@lca.pw,
	linux-kernel@vger.kernel.org,
	marc.zyngier@arm.com,
	kvmarm@lists.cs.columbia.edu,
	kvm@vger.kernel.org,
	suzuki.poulose@arm.com
Subject: [PATCH] mm, compaction: Make sure we isolate a valid PFN
Date: Fri, 24 May 2019 16:31:48 +0100
Message-Id: <1558711908-15688-1-git-send-email-suzuki.poulose@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <20190524103924.GN18914@techsingularity.net>
References: <20190524103924.GN18914@techsingularity.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When we have holes in a normal memory zone, we could endup having
cached_migrate_pfns which may not necessarily be valid, under heavy memory
pressure with swapping enabled ( via __reset_isolation_suitable(), triggered
by kswapd).

Later if we fail to find a page via fast_isolate_freepages(), we may
end up using the migrate_pfn we started the search with, as valid
page. This could lead to accessing NULL pointer derefernces like below,
due to an invalid mem_section pointer.

Unable to handle kernel NULL pointer dereference at virtual address 0000000000000008 [47/1825]
 Mem abort info:
   ESR = 0x96000004
   Exception class = DABT (current EL), IL = 32 bits
   SET = 0, FnV = 0
   EA = 0, S1PTW = 0
 Data abort info:
   ISV = 0, ISS = 0x00000004
   CM = 0, WnR = 0
 user pgtable: 4k pages, 48-bit VAs, pgdp = 0000000082f94ae9
 [0000000000000008] pgd=0000000000000000
 Internal error: Oops: 96000004 [#1] SMP
 ...
 CPU: 10 PID: 6080 Comm: qemu-system-aar Not tainted 510-rc1+ #6
 Hardware name: AmpereComputing(R) OSPREY EV-883832-X3-0001/OSPREY, BIOS 4819 09/25/2018
 pstate: 60000005 (nZCv daif -PAN -UAO)
 pc : set_pfnblock_flags_mask+0x58/0xe8
 lr : compaction_alloc+0x300/0x950
 [...]
 Process qemu-system-aar (pid: 6080, stack limit = 0x0000000095070da5)
 Call trace:
  set_pfnblock_flags_mask+0x58/0xe8
  compaction_alloc+0x300/0x950
  migrate_pages+0x1a4/0xbb0
  compact_zone+0x750/0xde8
  compact_zone_order+0xd8/0x118
  try_to_compact_pages+0xb4/0x290
  __alloc_pages_direct_compact+0x84/0x1e0
  __alloc_pages_nodemask+0x5e0/0xe18
  alloc_pages_vma+0x1cc/0x210
  do_huge_pmd_anonymous_page+0x108/0x7c8
  __handle_mm_fault+0xdd4/0x1190
  handle_mm_fault+0x114/0x1c0
  __get_user_pages+0x198/0x3c0
  get_user_pages_unlocked+0xb4/0x1d8
  __gfn_to_pfn_memslot+0x12c/0x3b8
  gfn_to_pfn_prot+0x4c/0x60
  kvm_handle_guest_abort+0x4b0/0xcd8
  handle_exit+0x140/0x1b8
  kvm_arch_vcpu_ioctl_run+0x260/0x768
  kvm_vcpu_ioctl+0x490/0x898
  do_vfs_ioctl+0xc4/0x898
  ksys_ioctl+0x8c/0xa0
  __arm64_sys_ioctl+0x28/0x38
  el0_svc_common+0x74/0x118
  el0_svc_handler+0x38/0x78
  el0_svc+0x8/0xc
 Code: f8607840 f100001f 8b011401 9a801020 (f9400400)
 ---[ end trace af6a35219325a9b6 ]---

The issue was reported on an arm64 server with 128GB with holes in the zone
(e.g, [32GB@4GB, 96GB@544GB]), with a swap device enabled, while running 100 KVM
guest instances.

This patch fixes the issue by ensuring that the page belongs to a valid PFN
when we fallback to using the lower limit of the scan range upon failure in
fast_isolate_freepages().

Fixes: 5a811889de10f1eb ("mm, compaction: use free lists to quickly locate a migration target")
Reported-by: Marc Zyngier <marc.zyngier@arm.com>
Signed-off-by: Suzuki K Poulose <suzuki.poulose@arm.com>
---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9febc8c..9e1b9ac 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1399,7 +1399,7 @@ fast_isolate_freepages(struct compact_control *cc)
 				page = pfn_to_page(highest);
 				cc->free_pfn = highest;
 			} else {
-				if (cc->direct_compaction) {
+				if (cc->direct_compaction && pfn_valid(min_pfn)) {
 					page = pfn_to_page(min_pfn);
 					cc->free_pfn = min_pfn;
 				}
-- 
2.7.4

