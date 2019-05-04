Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3336FC04AAA
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 12:11:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D90392084A
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 12:11:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D90392084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5569A6B0003; Sat,  4 May 2019 08:11:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E0ED6B0006; Sat,  4 May 2019 08:11:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 382E76B0007; Sat,  4 May 2019 08:11:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D602F6B0003
	for <linux-mm@kvack.org>; Sat,  4 May 2019 08:11:50 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z5so6672666edz.3
        for <linux-mm@kvack.org>; Sat, 04 May 2019 05:11:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZMFj2O6sbVuBeZi88r4Y7bOvyB0ASCzW2vDaWRcSPGc=;
        b=rgoSPBqRKw4xrcMKvFE4Er5MFrBvVv3bXxhsveUCfFG/7ufgTqIzoIpr1ycQfyNgKg
         WjziuaHJVbB+g2mml5Vz8kfrTAgA9j86kFVABgjAiw9LECPd4QPT4zCrtLX7NAzbK76T
         TUIu7iOkjzCzteWm9GIuY839Xzh+jRnKRedv06mGTfrJ5y6JOzrGzHVOQ6u1U4ySIqjz
         LTYEPoYHpee/UOJTXSxEb/89AihC+AHDlV8go3qwUaSwDiIrtp4DQhJ8aJkUWedJw3TQ
         Rf10UqPg1gytlTG6udbxT+BmKZvb3t+9vALVTeXYsY5PdFemF56AL7mjs31pdL0WnHil
         5hTQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUjvZWBcLyHiv3+Hkh0ZQtOvNhozGsrbxgvXNIt7JvDlorl0XI8
	NZytcLuCqaQFai8e5fmyz6Pjff2x0+S+TLc0JbgNR1XchGDTUh98V97s2m7zYMu9rTVjloDVGjG
	gCrBG6QwyJWouA+ctC/tulPQSNV3R3Ma3wfc4OsVQtNguHN28MQlvMGqlcbet+2c=
X-Received: by 2002:a50:b835:: with SMTP id j50mr14259330ede.63.1556971910339;
        Sat, 04 May 2019 05:11:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEtIgUfoRshiJsX+5D+AxKfIH6qZKFyBVqpBEQj2KwG9opHxK2IYXdyepTU4ZbXAEFEC9R
X-Received: by 2002:a50:b835:: with SMTP id j50mr14259232ede.63.1556971909225;
        Sat, 04 May 2019 05:11:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556971909; cv=none;
        d=google.com; s=arc-20160816;
        b=L1/ZYMbEF3Wv4ofP4ttQ4ep9eAwtYU7i5HLqG1Oatw022aldQfQUpleMFRTu/GupdO
         RjMudsXNLFzbaPvDuJaWNcNOFboHiWvFy0OYglBO3S13n3LDGp1MnuNXKyUQ0xG0ZkrO
         IeLlkc6yjC+NZLUc+fuARxF8zDiNrrZCxu7/csq/cXWomT0z6Um4NDOieClwzIDWCu3z
         NmftanSxkRXd2amqMI6AXYeBfMpwxHct5f/GokBwrRkpG4x2hOXDSqPytVy/GKVyobPd
         QaWTcO2em7FZxJcb1uig4tr7N1P6u3s+2hvF9BaYw3nBMaLLZByPt/kT42LAWG/RJTTk
         6CRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZMFj2O6sbVuBeZi88r4Y7bOvyB0ASCzW2vDaWRcSPGc=;
        b=PS1MxDbGeiRM9BdTvmOOHmL9lYh8SVXMNehOgr/Inpc8y451yos1J9Gq0YL91cVRMz
         v73Go4FQ3qU1I3DdFdA8NPl9775S0KJRC/2txMkQbdbTJtHWdi/Y9JV+DOqFsXW32HKf
         K26r4iMsirOpW/1GppXDxKwSNHtUDzTtUjZu77On++BkwFl9j8pchaRyK0kSCaC8Gd6w
         H3H25h4Jw6jsyyKW8bvitl2XV3tPBSvXkSopT4bNDDKzcDUxREg8ul5WwvBBm1rHZCQn
         9K3E2Knh2Icxomkv6tsmxsrJxWYOzMMRnH48ofVMx7xoxJUP3FOaKsXAVAxh24Y28xh8
         fCkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f29si3798365eda.310.2019.05.04.05.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 May 2019 05:11:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5CED8AD8D;
	Sat,  4 May 2019 12:11:48 +0000 (UTC)
Date: Sat, 4 May 2019 08:11:44 -0400
From: Michal Hocko <mhocko@kernel.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>,
	Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
Message-ID: <20190504121144.GR29835@dhcp22.suse.cz>
References: <20190503223146.2312-1-aarcange@redhat.com>
 <20190503223146.2312-3-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190503223146.2312-3-aarcange@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 03-05-19 18:31:46, Andrea Arcangeli wrote:
> This reverts commit 2f0799a0ffc033bf3cc82d5032acc3ec633464c2.
> 
> commit 2f0799a0ffc033bf3cc82d5032acc3ec633464c2 was rightfully applied
> to avoid the risk of a severe regression that was reported by the
> kernel test robot at the end of the merge window. Now we understood
> the regression was a false positive and was caused by a significant
> increase in fairness during a swap trashing benchmark. So it's safe to
> re-apply the fix and continue improving the code from there. The
> benchmark that reported the regression is very useful, but it provides
> a meaningful result only when there is no significant alteration in
> fairness during the workload. The removal of __GFP_THISNODE increased
> fairness.
> 
> __GFP_THISNODE cannot be used in the generic page faults path for new
> memory allocations under the MPOL_DEFAULT mempolicy, or the allocation
> behavior significantly deviates from what the MPOL_DEFAULT semantics
> are supposed to be for THP and 4k allocations alike.
> 
> Setting THP defrag to "always" or using MADV_HUGEPAGE (with THP defrag
> set to "madvise") has never meant to provide an implicit MPOL_BIND on
> the "current" node the task is running on, causing swap storms and
> providing a much more aggressive behavior than even zone_reclaim_node
> = 3.
> 
> Any workload who could have benefited from __GFP_THISNODE has now to
> enable zone_reclaim_mode=1||2||3. __GFP_THISNODE implicitly provided
> the zone_reclaim_mode behavior, but it only did so if THP was enabled:
> if THP was disabled, there would have been no chance to get any 4k
> page from the current node if the current node was full of pagecache,
> which further shows how this __GFP_THISNODE was misplaced in
> MADV_HUGEPAGE. MADV_HUGEPAGE has never been intended to provide any
> zone_reclaim_mode semantics, in fact the two are orthogonal,
> zone_reclaim_mode = 1|2|3 must work exactly the same with
> MADV_HUGEPAGE set or not.
> 
> The performance characteristic of memory depends on the hardware
> details. The numbers below are obtained on Naples/EPYC architecture
> and the N/A projection extends them to show what we should aim for in
> the future as a good THP NUMA locality default. The benchmark used
> exercises random memory seeks (note: the cost of the page faults is
> not part of the measurement).
> 
> D0 THP | D0 4k | D1 THP | D1 4k | D2 THP | D2 4k | D3 THP | D3 4k | ...
> 0%     | +43%  | +45%   | +106% | +131%  | +224% | N/A    | N/A
> 
> D0 means distance zero (i.e. local memory), D1 means distance
> one (i.e. intra socket memory), D2 means distance two (i.e. inter
> socket memory), etc...
> 
> For the guest physical memory allocated by qemu and for guest mode kernel
> the performance characteristic of RAM is more complex and an ideal
> default could be:
> 
> D0 THP | D1 THP | D0 4k | D2 THP | D1 4k | D3 THP | D2 4k | D3 4k | ...
> 0%     | +58%   | +101% | N/A    | +222% | N/A    | N/A   | N/A
> 
> NOTE: the N/A are projections and haven't been measured yet, the
> measurement in this case is done on a 1950x with only two NUMA nodes.
> The THP case here means THP was used both in the host and in the
> guest.
> 
> After applying this commit the THP NUMA locality order that we'll get
> out of MADV_HUGEPAGE is this:
> 
> D0 THP | D1 THP | D2 THP | D3 THP | ... | D0 4k | D1 4k | D2 4k | D3 4k | ...
> 
> Before this commit it was:
> 
> D0 THP | D0 4k | D1 4k | D2 4k | D3 4k | ...
> 
> Even if we ignore the breakage of large workloads that can't fit in a
> single node that the __GFP_THISNODE implicit "current node" mbind
> caused, the THP NUMA locality order provided by __GFP_THISNODE was
> still not the one we shall aim for in the long term (i.e. the first
> one at the top).
> 
> After this commit is applied, we can introduce a new allocator multi
> order API and to replace those two alloc_pages_vmas calls in the page
> fault path, with a single multi order call:
> 
> 	unsigned int order = (1 << HPAGE_PMD_ORDER) | (1 << 0);
> 	page = alloc_pages_multi_order(..., &order);
> 	if (!page)
> 		goto out;
> 	if (!(order & (1 << 0))) {
> 		VM_WARN_ON(order != 1 << HPAGE_PMD_ORDER);
> 		/* THP fault */
> 	} else {
> 		VM_WARN_ON(order != 1 << 0);
> 		/* 4k fallback */
> 	}
> 
> The page allocator logic has to be altered so that when it fails on
> any zone with order 9, it has to try again with a order 0 before
> falling back to the next zone in the zonelist.
> 
> After that we need to do more measurements and evaluate if adding an
> opt-in feature for guest mode is worth it, to swap "DN 4k | DN+1 THP"
> with "DN+1 THP | DN 4k" at every NUMA distance crossing.

I do agree with your reasoning. Future plans should be discussed
carefully because any iWmplicit NUMA placing might turned out simply
wrong with the future HW. I still believe we need a sort of _enforce_
intrasocet placement numa policy API. Something resembling node reclaim
mode for particular mappings. MPOL_CLOSE_NODE or similar sounds like a
way to go. But a new API really begs for real world usecases and I still
hope to get a reproducer for the problem David is running into.
 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mempolicy.h |  2 ++
>  mm/huge_memory.c          | 42 ++++++++++++++++++++++++---------------
>  mm/mempolicy.c            |  2 +-
>  3 files changed, 29 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 5228c62af416..bac395f1d00a 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -139,6 +139,8 @@ struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
>  struct mempolicy *get_task_policy(struct task_struct *p);
>  struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
>  		unsigned long addr);
> +struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
> +						unsigned long addr);
>  bool vma_policy_mof(struct vm_area_struct *vma);
>  
>  extern void numa_default_policy(void);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 7efe68ba052a..784fd63800a2 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -644,27 +644,37 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
>  static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
>  {
>  	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
> -	const gfp_t gfp_mask = GFP_TRANSHUGE_LIGHT | __GFP_THISNODE;
> +	gfp_t this_node = 0;
>  
> -	/* Always do synchronous compaction */
> -	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
> -		return GFP_TRANSHUGE | __GFP_THISNODE |
> -		       (vma_madvised ? 0 : __GFP_NORETRY);
> +#ifdef CONFIG_NUMA
> +	struct mempolicy *pol;
> +	/*
> +	 * __GFP_THISNODE is used only when __GFP_DIRECT_RECLAIM is not
> +	 * specified, to express a general desire to stay on the current
> +	 * node for optimistic allocation attempts. If the defrag mode
> +	 * and/or madvise hint requires the direct reclaim then we prefer
> +	 * to fallback to other node rather than node reclaim because that
> +	 * can lead to excessive reclaim even though there is free memory
> +	 * on other nodes. We expect that NUMA preferences are specified
> +	 * by memory policies.
> +	 */
> +	pol = get_vma_policy(vma, addr);
> +	if (pol->mode != MPOL_BIND)
> +		this_node = __GFP_THISNODE;
> +	mpol_cond_put(pol);
> +#endif
>  
> -	/* Kick kcompactd and fail quickly */
> +	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
> +		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
> -		return gfp_mask | __GFP_KSWAPD_RECLAIM;
> -
> -	/* Synchronous compaction if madvised, otherwise kick kcompactd */
> +		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | this_node;
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
> -		return gfp_mask | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> -						  __GFP_KSWAPD_RECLAIM);
> -
> -	/* Only do synchronous compaction if madvised */
> +		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> +							     __GFP_KSWAPD_RECLAIM | this_node);
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
> -		return gfp_mask | (vma_madvised ? __GFP_DIRECT_RECLAIM : 0);
> -
> -	return gfp_mask;
> +		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
> +							     this_node);
> +	return GFP_TRANSHUGE_LIGHT | this_node;
>  }
>  
>  /* Caller must hold page table lock. */
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 74e44000ad61..341e3d56d0a6 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1688,7 +1688,7 @@ struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
>   * freeing by another task.  It is the caller's responsibility to free the
>   * extra reference for shared policies.
>   */
> -static struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
> +struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
>  						unsigned long addr)
>  {
>  	struct mempolicy *pol = __get_vma_policy(vma, addr);

-- 
Michal Hocko
SUSE Labs

