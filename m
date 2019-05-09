Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0A2DC46460
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 08:38:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6913221744
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 08:38:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6913221744
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 022FC6B0006; Thu,  9 May 2019 04:38:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F14306B0007; Thu,  9 May 2019 04:38:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDD356B0008; Thu,  9 May 2019 04:38:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 90A496B0006
	for <linux-mm@kvack.org>; Thu,  9 May 2019 04:38:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n23so956927edv.9
        for <linux-mm@kvack.org>; Thu, 09 May 2019 01:38:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=O2KShyBqSJLCxUT3fi/0YWuS/rV8/KBo3iJoQxI4XfU=;
        b=kThTlmhxAQt/9QhpCDNEW4oUnomujtnpjXJZucZiTCH5xxeYMjBw1GFz9CFYYduwdu
         jdoaE3hoRaEOn0vEnfXvv4l+cuTN+FoYMVXHzQDAOY64TFSeWcgAMUeskb+lcsQXDk/g
         di8+Z6g+bN+Wtv7PpsmoguYMM1Lpg/p5qeZ4eF+n5yoDKzUeMNtTxy3QQhYEERo3ic+x
         emY7M+oGedm5ivXEZmpBdNduSU/rspURD0Vja0sEH8T1emPQvhxt55LdjSm5vPLKtoKI
         FiGWSfS/GqIco6HAYw5WOJG6263AC8MXAbYumtR/cWWjjsjOF2KM68GXdiNBSBjcpCJn
         /fcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAUPgxOoIDgviQ6dtlkmELXjfnWcIUKOVEzp1gC4YHW0NHXBxR3+
	F47vSrrZKZSACspSd+Znc/gP8Q52H36lhVQNbDHBK7FlswYFAGrlpyt3AIas4j8k20eXLZ0drQv
	cyQ4Bc5aeAdqJnwLdnRySqvDHrABM2tFPEk3zmSTlE4aQBkyoN23ZH0D47ZwSOSYmMg==
X-Received: by 2002:a50:8ed8:: with SMTP id x24mr2489984edx.183.1557391095164;
        Thu, 09 May 2019 01:38:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqznECippNQL+8vKDyup1Sk0PuIFTEN7KU8JxS6GkVKLctl2KXBGM1DqKTs4jaobyCo+XQ
X-Received: by 2002:a50:8ed8:: with SMTP id x24mr2489921edx.183.1557391094051;
        Thu, 09 May 2019 01:38:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557391094; cv=none;
        d=google.com; s=arc-20160816;
        b=V+9UZ4E2FZdggksGgufQ/uM+sBIinUoZtzLdZ1COqFw2nZFSd6VzNSap4zVOfgihm4
         nntJMGnSDy+HxgOGlRvynn9E0GHAuTOzVBP1GXckQGBhRX2BNhrugTACOYjTW3YDKCB3
         o3EaspIjZgvaQi9A3zfxQVVMRahWBTHweHVVqEkoRC1Stvx3c3TNFq4A6yW5NEQLQrg2
         r8DWj9zvJdGux0sW8XUFs7vh7w+swHMBMRFMFPsT93pXYf65mjohCNYiuFIVkWP0H3h7
         GQJHksJgUdebMH8c8bsyc5Y5hcQ2lbirsDobTCAnx3YyGEQGy9YXHQLagtXHhsnDDTLY
         tK4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=O2KShyBqSJLCxUT3fi/0YWuS/rV8/KBo3iJoQxI4XfU=;
        b=Z1z09kH6XqbjyWma1moSfK4AFF3d/4qhnAjr8e/M+M5Mh9Lel6K0OkXUhZ+pqTMqSU
         LQjZpebM7crUKbW/RKA5b7tbOUaZnl7irnb+LGq3Onh4Kd4GxMOVmcmDMnxWXrgfSK73
         0Jx2M+8a0V5voecNqXmTsTsG6kNAj315nXZybovy5rKdBwPxmsvq8jAF5TYXXpCNfY6V
         9XJ3+TJcD0Tysyb/hgmyjjh3xZ6USbTnF8c9hQ1h6wUXhGLn60RUp1c0P4HUnNVDJ8WV
         2RAkeCEm/dYQloth6Y84pSvhMSGP0SJNcAFq68LBi3QUdW5u0lDdeUqxqpqBwCHWcFz2
         UzgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3si856447edi.91.2019.05.09.01.38.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 01:38:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 39F3EAC10;
	Thu,  9 May 2019 08:38:13 +0000 (UTC)
Date: Thu, 9 May 2019 09:38:10 +0100
From: Mel Gorman <mgorman@suse.de>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>,
	Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
Message-ID: <20190509083810.GH14242@suse.de>
References: <20190503223146.2312-1-aarcange@redhat.com>
 <20190503223146.2312-3-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190503223146.2312-3-aarcange@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 03, 2019 at 06:31:46PM -0400, Andrea Arcangeli wrote:
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
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

