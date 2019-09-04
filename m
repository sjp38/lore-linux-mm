Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73E52C3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 19:54:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12E2222CED
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 19:54:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aYpwCJlp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12E2222CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A21026B0006; Wed,  4 Sep 2019 15:54:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D12F6B000A; Wed,  4 Sep 2019 15:54:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E5F16B000C; Wed,  4 Sep 2019 15:54:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0076.hostedemail.com [216.40.44.76])
	by kanga.kvack.org (Postfix) with ESMTP id 6BDA96B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:54:22 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0B4D0A2B9
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:54:22 +0000 (UTC)
X-FDA: 75898289964.24.name97_7d5da57647841
X-HE-Tag: name97_7d5da57647841
X-Filterd-Recvd-Size: 9142
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:54:21 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id w22so5525744pfi.9
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 12:54:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:user-agent:mime-version;
        bh=/yqLrrEZ1jGCgctDjUkMs8Nl6CSrDL+V901mgKrrlLc=;
        b=aYpwCJlpggUi2FQ0+ApYB02dfO+53N9oMqyYZoiWyvmwYynDM/vkN4WH4vPpshrnjI
         /wEZ0BQozY9Vz3IYpgEpRlDoJKcfsl8jUIkBCP4EIkBsLmZROitGMvntgR+w/15fSe0l
         L1oCGWejuhYlxUmB7okIRI7/QG+P2H5ykBGYn0CrWi+dXqY9CxJ8dYWsQjCR+xnisFD+
         QPz3uj6A/rSJUXVv8HdQ1sQr7A6ZvAf4X42VuIbDJ2h0+jBSRqX+buEA5dQukQcDgj2f
         Re2Y4AhkhVEP57zS1Lhzch1D07VtGHmFyyjVhsHqhKGiSjKSfYNr+q6tlKwjWsiQG73L
         WkJg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:user-agent
         :mime-version;
        bh=/yqLrrEZ1jGCgctDjUkMs8Nl6CSrDL+V901mgKrrlLc=;
        b=bz1ZaeTR5ypVoJAdnnRpNoFaOh8kMGvHbUXC5YspZLMgalt52kNO31V1GmpHZNVFw4
         PFpUsp/lejoKJ22dtgOKML+BME1cC8hEB0Qtkoc0Le3JjUWuaZFPKRq78D4v4lRzAhjx
         MfQjHwJ8JKBi9ANw2YHBYt4GERnmnhwjSzA+NZ6gProDjKHZU0nw4M/LtkWik5Ktd/J/
         DovnQfzS13A0fmHVOFlaMi6LHkgJfv9Ke6TVC58z8u2DOsn3mJR9QLqUV6sjx5KWHGjQ
         DATLvSO/51VLwrGZXhDprmTsHzCkYBc58rwfuFUNhvOSPuxwLtwE0pM2q/0yxbSSP7Y+
         VleQ==
X-Gm-Message-State: APjAAAVvUEyMmzGw2MjVf+P4TaeRI3AbxdqZ1pP09tr4Slrh6G1k9xGP
	BaqPSVVBK/V4taEgrGhrmssB2g==
X-Google-Smtp-Source: APXvYqxY8g9k8sFXGaBUVsXS3uhCUUF/KrFeCPAt3bvfH1vh500utSbB+LJNNZ1FAUItgeRsAEEEYQ==
X-Received: by 2002:a17:90a:c715:: with SMTP id o21mr4798298pjt.55.1567626859752;
        Wed, 04 Sep 2019 12:54:19 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id g202sm32480208pfb.155.2019.09.04.12.54.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 12:54:19 -0700 (PDT)
Date: Wed, 4 Sep 2019 12:54:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Linus Torvalds <torvalds@linux-foundation.org>, 
    Andrew Morton <akpm@linux-foundation.org>
cc: Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, 
    Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org
Subject: [patch for-5.3 1/4] Revert "Revert "mm, thp: restore node-local
 hugepage allocations""
Message-ID: <alpine.DEB.2.21.1909041252590.94813@chino.kir.corp.google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This reverts commit a8282608c88e08b1782141026eab61204c1e533f.

The commit references the original intended semantic for MADV_HUGEPAGE
which has subsequently taken on three unique purposes:

 - enables or disables thp for a range of memory depending on the system's
   config (is thp "enabled" set to "always" or "madvise"),

 - determines the synchronous compaction behavior for thp allocations at
   fault (is thp "defrag" set to "always", "defer+madvise", or "madvise"),
   and

 - reverts a previous MADV_NOHUGEPAGE (there is no madvise mode to only
   clear previous hugepage advice).

These are the three purposes that currently exist in 5.2 and over the past
several years that userspace has been written around.  Adding a NUMA
locality preference adds a fourth dimension to an already conflated advice
mode.

Based on the semantic that MADV_HUGEPAGE has provided over the past
several years, there exist workloads that use the tunable based on these
principles: specifically that the allocation should attempt to defragment
a local node before falling back.  It is agreed that remote hugepages
typically (but not always) have a better access latency than remote native
pages, although on Naples this is at parity for intersocket.

The revert commit that this patch reverts allows hugepage allocation to
immediately allocate remotely when local memory is fragmented.  This is
contrary to the semantic of MADV_HUGEPAGE over the past several years:
that is, memory compaction should be attempted locally before falling
back.

The performance degradation of remote hugepages over local hugepages on
Rome, for example, is 53.5% increased access latency.  For this reason,
the goal is to revert back to the 5.2 and previous behavior that would
attempt local defragmentation before falling back.  With the patch that
is reverted by this patch, we see performance degradations at the tail
because the allocator happily allocates the remote hugepage rather than
even attempting to make a local hugepage available.

zone_reclaim_mode is not a solution to this problem since it does not
only impact hugepage allocations but rather changes the memory allocation
strategy for *all* page allocations.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mempolicy.h |  2 --
 mm/huge_memory.c          | 42 +++++++++++++++------------------------
 mm/mempolicy.c            |  2 +-
 3 files changed, 17 insertions(+), 29 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -139,8 +139,6 @@ struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
 struct mempolicy *get_task_policy(struct task_struct *p);
 struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
 		unsigned long addr);
-struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
-						unsigned long addr);
 bool vma_policy_mof(struct vm_area_struct *vma);
 
 extern void numa_default_policy(void);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -648,37 +648,27 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
 static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
 {
 	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
-	gfp_t this_node = 0;
-
-#ifdef CONFIG_NUMA
-	struct mempolicy *pol;
-	/*
-	 * __GFP_THISNODE is used only when __GFP_DIRECT_RECLAIM is not
-	 * specified, to express a general desire to stay on the current
-	 * node for optimistic allocation attempts. If the defrag mode
-	 * and/or madvise hint requires the direct reclaim then we prefer
-	 * to fallback to other node rather than node reclaim because that
-	 * can lead to excessive reclaim even though there is free memory
-	 * on other nodes. We expect that NUMA preferences are specified
-	 * by memory policies.
-	 */
-	pol = get_vma_policy(vma, addr);
-	if (pol->mode != MPOL_BIND)
-		this_node = __GFP_THISNODE;
-	mpol_cond_put(pol);
-#endif
+	const gfp_t gfp_mask = GFP_TRANSHUGE_LIGHT | __GFP_THISNODE;
 
+	/* Always do synchronous compaction */
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
+		return GFP_TRANSHUGE | __GFP_THISNODE |
+		       (vma_madvised ? 0 : __GFP_NORETRY);
+
+	/* Kick kcompactd and fail quickly */
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | this_node;
+		return gfp_mask | __GFP_KSWAPD_RECLAIM;
+
+	/* Synchronous compaction if madvised, otherwise kick kcompactd */
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
-							     __GFP_KSWAPD_RECLAIM | this_node);
+		return gfp_mask | (vma_madvised ? __GFP_DIRECT_RECLAIM :
+						  __GFP_KSWAPD_RECLAIM);
+
+	/* Only do synchronous compaction if madvised */
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
-							     this_node);
-	return GFP_TRANSHUGE_LIGHT | this_node;
+		return gfp_mask | (vma_madvised ? __GFP_DIRECT_RECLAIM : 0);
+
+	return gfp_mask;
 }
 
 /* Caller must hold page table lock. */
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1734,7 +1734,7 @@ struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
  * freeing by another task.  It is the caller's responsibility to free the
  * extra reference for shared policies.
  */
-struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
+static struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
 						unsigned long addr)
 {
 	struct mempolicy *pol = __get_vma_policy(vma, addr);

