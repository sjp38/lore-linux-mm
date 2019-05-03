Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01217C43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 22:31:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4AD2206C1
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 22:31:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4AD2206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E9026B0006; Fri,  3 May 2019 18:31:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74E4F6B000C; Fri,  3 May 2019 18:31:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43AD76B0008; Fri,  3 May 2019 18:31:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1646B0007
	for <linux-mm@kvack.org>; Fri,  3 May 2019 18:31:50 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f14so184645qtq.19
        for <linux-mm@kvack.org>; Fri, 03 May 2019 15:31:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=42P5Q9aXXRvDn/1t9JAekMHw5FEeJqcmQNa5ch4ON70=;
        b=O4N8+qpTg0K/pthmW0LdCIRoH9UinmPtegvWh17U3KetjZ5eHw0QpLA+lKtoDbhRI0
         xtgKud0IFMKq/Xo8dkQM6Rz7stojo3HR+1lGMZ2sRsljgmer7OCHWvUFnPNeZW+Mf18W
         W6PzbAPQ80yEa0MZyEldMmidFZIAgjyfnowiiHGlhhdwqJ/T0KTMskxCwOOBfpa94vCJ
         1Bt469TbzI27Zfjm78s7WlT8QmFmVHEg6JMDcerzrGtY3Q3P//viCYpSw96ZO1mfKHNH
         YsHCZ2MVp4QfdikCbYG2OMtbyJ2CzKdTHQrmGfENS27/0klSJw69WtJVLY63/JRC+Glc
         ADHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWS1N6cl0fdwXzxPc2SBxlG+AAnag3vrw6dMUKnsNMPettH/vnN
	/2MQWezJswatOEva9XGpQlQNhkOxu/wYk+/0Vspqj6frBzjIcxLxuGg0ypqC/4blJUSg5wbCHvu
	YWYCS57072oCPAs9lWKhg8GnFbCr1Eu3ELcoQ1mjDxTPGDYidGdkMD4Hj1Rb5qLgiXg==
X-Received: by 2002:ac8:807:: with SMTP id u7mr11124072qth.78.1556922709803;
        Fri, 03 May 2019 15:31:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyP6dgWHCZ59QvEStjfGLM5MP/epRyHjcZfso2mRKd+/z15F+gpGALYZUcJXGG+PBkuQw2
X-Received: by 2002:ac8:807:: with SMTP id u7mr11123983qth.78.1556922708527;
        Fri, 03 May 2019 15:31:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556922708; cv=none;
        d=google.com; s=arc-20160816;
        b=NJGXFAad1FPFUedmCbjZOHbYdsjvg1JsD9AIA47TrQKHQ6hY73YLiPQXU3f/AbkAck
         AbpFZGHDVn6l8nmJo3g+BjY+FBaylC4SvEmH5cLG5XQmsev9px7Wps7vtyOHvR7kcx3W
         Yz8nZpWRNBXDu/8vKiTP6dbnTLzMd04vebZJ1xUtboGmqW+e69FhVH+PksXAbCdPCGX2
         AaXIDUTJLNjDMVQAH65ZGMuXa26c+SZJ5VBF04C6WtUnu5UT+pDh2XlkcuZ6e8Yq6OCW
         NdaC3rkNGtfSs9APB4zNdN+mrmw2JjpXGhAEwviUEhH8vqpLyotTpjEHHZdA+L4cXJ4W
         nCVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=42P5Q9aXXRvDn/1t9JAekMHw5FEeJqcmQNa5ch4ON70=;
        b=vPqVr9k1u660Z35eTrIz0+xDCuuFYvwUvsL3l/V8347yHHPF++zu/vM4d/mAEHfP2Z
         VQQoZpvZ8SKWgaasG1Osf7iHJLAN9npUr2+fe/ehYyccp78qKhC0JiBRQwAGo8XX52xo
         dgLtyVkPfdd1AnVZ9GY1B7gYTSi69pSdgMqvXgwMhApYsXquRjH+wXOj5be2eubIZkZC
         TxazOTViaPAOGHXIHgpFm/aI6WzoWJElPuSYg3qBYVJD6qZZDWF7ONjDBbi4/Hnri7Be
         ur6Qb5did6FZFEP9zbvIypvVMi1wxHxBQGF0/YkRl0j/zAvCC37Ikepw3odVURQgfLv4
         eplg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u50si1088879qtu.345.2019.05.03.15.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 15:31:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A7E56C05CDFC;
	Fri,  3 May 2019 22:31:47 +0000 (UTC)
Received: from ultra.random (ovpn-122-217.rdu2.redhat.com [10.10.122.217])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 474675C231;
	Fri,  3 May 2019 22:31:47 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>,
	Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage allocations"
Date: Fri,  3 May 2019 18:31:46 -0400
Message-Id: <20190503223146.2312-3-aarcange@redhat.com>
In-Reply-To: <20190503223146.2312-1-aarcange@redhat.com>
References: <20190503223146.2312-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 03 May 2019 22:31:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This reverts commit 2f0799a0ffc033bf3cc82d5032acc3ec633464c2.

commit 2f0799a0ffc033bf3cc82d5032acc3ec633464c2 was rightfully applied
to avoid the risk of a severe regression that was reported by the
kernel test robot at the end of the merge window. Now we understood
the regression was a false positive and was caused by a significant
increase in fairness during a swap trashing benchmark. So it's safe to
re-apply the fix and continue improving the code from there. The
benchmark that reported the regression is very useful, but it provides
a meaningful result only when there is no significant alteration in
fairness during the workload. The removal of __GFP_THISNODE increased
fairness.

__GFP_THISNODE cannot be used in the generic page faults path for new
memory allocations under the MPOL_DEFAULT mempolicy, or the allocation
behavior significantly deviates from what the MPOL_DEFAULT semantics
are supposed to be for THP and 4k allocations alike.

Setting THP defrag to "always" or using MADV_HUGEPAGE (with THP defrag
set to "madvise") has never meant to provide an implicit MPOL_BIND on
the "current" node the task is running on, causing swap storms and
providing a much more aggressive behavior than even zone_reclaim_node
= 3.

Any workload who could have benefited from __GFP_THISNODE has now to
enable zone_reclaim_mode=1||2||3. __GFP_THISNODE implicitly provided
the zone_reclaim_mode behavior, but it only did so if THP was enabled:
if THP was disabled, there would have been no chance to get any 4k
page from the current node if the current node was full of pagecache,
which further shows how this __GFP_THISNODE was misplaced in
MADV_HUGEPAGE. MADV_HUGEPAGE has never been intended to provide any
zone_reclaim_mode semantics, in fact the two are orthogonal,
zone_reclaim_mode = 1|2|3 must work exactly the same with
MADV_HUGEPAGE set or not.

The performance characteristic of memory depends on the hardware
details. The numbers below are obtained on Naples/EPYC architecture
and the N/A projection extends them to show what we should aim for in
the future as a good THP NUMA locality default. The benchmark used
exercises random memory seeks (note: the cost of the page faults is
not part of the measurement).

D0 THP | D0 4k | D1 THP | D1 4k | D2 THP | D2 4k | D3 THP | D3 4k | ...
0%     | +43%  | +45%   | +106% | +131%  | +224% | N/A    | N/A

D0 means distance zero (i.e. local memory), D1 means distance
one (i.e. intra socket memory), D2 means distance two (i.e. inter
socket memory), etc...

For the guest physical memory allocated by qemu and for guest mode kernel
the performance characteristic of RAM is more complex and an ideal
default could be:

D0 THP | D1 THP | D0 4k | D2 THP | D1 4k | D3 THP | D2 4k | D3 4k | ...
0%     | +58%   | +101% | N/A    | +222% | N/A    | N/A   | N/A

NOTE: the N/A are projections and haven't been measured yet, the
measurement in this case is done on a 1950x with only two NUMA nodes.
The THP case here means THP was used both in the host and in the
guest.

After applying this commit the THP NUMA locality order that we'll get
out of MADV_HUGEPAGE is this:

D0 THP | D1 THP | D2 THP | D3 THP | ... | D0 4k | D1 4k | D2 4k | D3 4k | ...

Before this commit it was:

D0 THP | D0 4k | D1 4k | D2 4k | D3 4k | ...

Even if we ignore the breakage of large workloads that can't fit in a
single node that the __GFP_THISNODE implicit "current node" mbind
caused, the THP NUMA locality order provided by __GFP_THISNODE was
still not the one we shall aim for in the long term (i.e. the first
one at the top).

After this commit is applied, we can introduce a new allocator multi
order API and to replace those two alloc_pages_vmas calls in the page
fault path, with a single multi order call:

	unsigned int order = (1 << HPAGE_PMD_ORDER) | (1 << 0);
	page = alloc_pages_multi_order(..., &order);
	if (!page)
		goto out;
	if (!(order & (1 << 0))) {
		VM_WARN_ON(order != 1 << HPAGE_PMD_ORDER);
		/* THP fault */
	} else {
		VM_WARN_ON(order != 1 << 0);
		/* 4k fallback */
	}

The page allocator logic has to be altered so that when it fails on
any zone with order 9, it has to try again with a order 0 before
falling back to the next zone in the zonelist.

After that we need to do more measurements and evaluate if adding an
opt-in feature for guest mode is worth it, to swap "DN 4k | DN+1 THP"
with "DN+1 THP | DN 4k" at every NUMA distance crossing.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mempolicy.h |  2 ++
 mm/huge_memory.c          | 42 ++++++++++++++++++++++++---------------
 mm/mempolicy.c            |  2 +-
 3 files changed, 29 insertions(+), 17 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 5228c62af416..bac395f1d00a 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -139,6 +139,8 @@ struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
 struct mempolicy *get_task_policy(struct task_struct *p);
 struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
 		unsigned long addr);
+struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
+						unsigned long addr);
 bool vma_policy_mof(struct vm_area_struct *vma);
 
 extern void numa_default_policy(void);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7efe68ba052a..784fd63800a2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -644,27 +644,37 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
 static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
 {
 	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
-	const gfp_t gfp_mask = GFP_TRANSHUGE_LIGHT | __GFP_THISNODE;
+	gfp_t this_node = 0;
 
-	/* Always do synchronous compaction */
-	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE | __GFP_THISNODE |
-		       (vma_madvised ? 0 : __GFP_NORETRY);
+#ifdef CONFIG_NUMA
+	struct mempolicy *pol;
+	/*
+	 * __GFP_THISNODE is used only when __GFP_DIRECT_RECLAIM is not
+	 * specified, to express a general desire to stay on the current
+	 * node for optimistic allocation attempts. If the defrag mode
+	 * and/or madvise hint requires the direct reclaim then we prefer
+	 * to fallback to other node rather than node reclaim because that
+	 * can lead to excessive reclaim even though there is free memory
+	 * on other nodes. We expect that NUMA preferences are specified
+	 * by memory policies.
+	 */
+	pol = get_vma_policy(vma, addr);
+	if (pol->mode != MPOL_BIND)
+		this_node = __GFP_THISNODE;
+	mpol_cond_put(pol);
+#endif
 
-	/* Kick kcompactd and fail quickly */
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
+		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
-		return gfp_mask | __GFP_KSWAPD_RECLAIM;
-
-	/* Synchronous compaction if madvised, otherwise kick kcompactd */
+		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | this_node;
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
-		return gfp_mask | (vma_madvised ? __GFP_DIRECT_RECLAIM :
-						  __GFP_KSWAPD_RECLAIM);
-
-	/* Only do synchronous compaction if madvised */
+		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
+							     __GFP_KSWAPD_RECLAIM | this_node);
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
-		return gfp_mask | (vma_madvised ? __GFP_DIRECT_RECLAIM : 0);
-
-	return gfp_mask;
+		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
+							     this_node);
+	return GFP_TRANSHUGE_LIGHT | this_node;
 }
 
 /* Caller must hold page table lock. */
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 74e44000ad61..341e3d56d0a6 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1688,7 +1688,7 @@ struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
  * freeing by another task.  It is the caller's responsibility to free the
  * extra reference for shared policies.
  */
-static struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
+struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
 						unsigned long addr)
 {
 	struct mempolicy *pol = __get_vma_policy(vma, addr);

