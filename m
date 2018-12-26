Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71986C43444
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 05:37:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 399FB21720
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 05:37:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 399FB21720
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA24F8E0002; Wed, 26 Dec 2018 00:37:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B28488E0001; Wed, 26 Dec 2018 00:37:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FD3C8E0002; Wed, 26 Dec 2018 00:37:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57F718E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 00:37:26 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 82so16795478pfs.20
        for <linux-mm@kvack.org>; Tue, 25 Dec 2018 21:37:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=bKJbc/ii/JoGkC3fD23RWg46TjxzRL8cJogN9Cr9Mnc=;
        b=UYvMT24qyu9LVmpiKTIB7JCy35MXTCYMdVdDyQkQpidvse1mkkbN/u8s4oi9cxPXKN
         rbyVKCg8lKdMj0b2BN3qOnuyPTlDMAJlr2bRxIbD4htMrCNrmdD5QPMHMTfktciVYkPm
         8JeeCcgHUQUucMAFvlm3h/Q06IhTBbypJvrX3x5QlkNl0RA4R/KnqErpQCjrzu2KD2pE
         Yt8vXtjzO7fqf4f/ph4eRMowttF8ulH+iDOv7aftKsNNqc3LoMi49mfRqS8GWi0/4min
         Yjsq49PGXTqZ3z/0u+rA6W8sBXF/X272800G35aI+stAiYewbwL9LChYMA6mZpvP5E2i
         qjxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcoerjVnJBcD/m8IgxLpc1kALySMehz2nQJsXsd8tKcgbh6gg+9
	JKAW18EalMIIU3tKJOIoeKYQTxXugZkZDFINr1s2NJwhqJzM8d4q5yNbisoaF0ymvjdk9UnMpvi
	JfMf4BnpYSSuuLXg46ktQwYWZOiYg88fBrJSUGtXtuGeCHoHHMp3NrL4krjMh0BjJHA==
X-Received: by 2002:a63:a91a:: with SMTP id u26mr17507143pge.349.1545802645994;
        Tue, 25 Dec 2018 21:37:25 -0800 (PST)
X-Google-Smtp-Source: ALg8bN59iOsfWX/LiF3egNG1sP5BU+kF2tUSxpkmnzlpYn1RqTjd4P4gK65qmb1JBglbsgxgiVXM
X-Received: by 2002:a63:a91a:: with SMTP id u26mr17507106pge.349.1545802645162;
        Tue, 25 Dec 2018 21:37:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545802645; cv=none;
        d=google.com; s=arc-20160816;
        b=CAvWvGEgHFGpFquB3WfMc75TBn97i8y6bNMOm7rIZ2YjUeqlaPNKDMxycHpnUsDPnw
         ldvhAWlemsQk8773M9kbgWb9bhNtS0gBTVfyW6Jfe2vOUs+T0ArxzZRCI25lcqnkXaCD
         vPB0+3BZ+TfFucKEZgtD18K6wgv0h33e1/YgIGKcMOIf1aCW7vudXzO59nE80HKT3NIM
         OXzb1/Le6qiSr37HUuxqCj8Iho8jbVPQ/0eoOOfThYoCTRTGUlQKiZEHB86dwIfwXLv1
         40d8zWSQtO4zU+VUS8727Jl90tMIjKOmhKVfF/+EXqV6RCRyReQw3htRjhva073hocrp
         P5Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=bKJbc/ii/JoGkC3fD23RWg46TjxzRL8cJogN9Cr9Mnc=;
        b=RrjnhCyBpoucSE++0BMyl3xSwo6GfuXg7jfPpkmB1C6J6FxZEq7nybRFrrVNsm9wSW
         DyGk89Zgzw+SidyOWfnpZu+Hdmo3nE3GPRcpNZSunzVmLx4Ms3wSe9dTUPpf6o4jPqdW
         JoxZyQdsCjHisn5hjAHZvrrikxDvvV1niK5T35k3al80WLP2kVy7tjsnj00T9inaRr0T
         PBl93KIYXsMQ/zo5zAJLsmswtBEvQhcZCgVmoFtMcUEMxspVzTp1hGA+VKwDR4OBfQID
         RJE41m/a1+On3BZwnR+KGVporwtB5ZY+iNFCArf5nIWQ/CvZMTlxmDh+FPwAXC/hjhiJ
         vr/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w15si32157833plk.357.2018.12.25.21.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Dec 2018 21:37:25 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Dec 2018 21:37:24 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,399,1539673200"; 
   d="scan'208";a="109980284"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.13.10])
  by fmsmga007.fm.intel.com with ESMTP; 25 Dec 2018 21:37:22 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Rik van Riel <riel@redhat.com>,  Johannes Weiner <hannes@cmpxchg.org>,  Minchan Kim <minchan@kernel.org>,  Shaohua Li <shli@kernel.org>,  Daniel Jordan <daniel.m.jordan@oracle.com>,  Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm, swap: Fix swapoff with KSM pages
References: <20181226051522.28442-1-ying.huang@intel.com>
Date: Wed, 26 Dec 2018 13:37:22 +0800
In-Reply-To: <20181226051522.28442-1-ying.huang@intel.com> (Huang Ying's
	message of "Wed, 26 Dec 2018 13:15:22 +0800")
Message-ID: <8736qku9v1.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/25.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226053722.Jpe4-o_q1gCb4O7MvSqQbK_R9rmwrmO-FhVnj_yXqBk@z>

Hi, Andrew,

This patch is based on linus' tree instead of the head of mmotm tree
because it is to fix a bug there.

The bug is introduced by commit e07098294adf ("mm, THP, swap: support to
reclaim swap space for THP swapped out"), which is merged by v4.14-rc1.
So I think we should backport the fix to from 4.14 on.  But Hugh thinks
it may be rare for the KSM pages being in the swap device when swapoff,
so nobody reports the bug so far.

Best Regards,
Huang, Ying

Huang Ying <ying.huang@intel.com> writes:

> KSM pages may be mapped to the multiple VMAs that cannot be reached
> from one anon_vma.  So during swapin, a new copy of the page need to
> be generated if a different anon_vma is needed, please refer to
> comments of ksm_might_need_to_copy() for details.
>
> During swapoff, unuse_vma() uses anon_vma (if available) to locate VMA
> and virtual address mapped to the page, so not all mappings to a
> swapped out KSM page could be found.  So in try_to_unuse(), even if
> the swap count of a swap entry isn't zero, the page needs to be
> deleted from swap cache, so that, in the next round a new page could
> be allocated and swapin for the other mappings of the swapped out KSM
> page.
>
> But this contradicts with the THP swap support.  Where the THP could
> be deleted from swap cache only after the swap count of every swap
> entry in the huge swap cluster backing the THP has reach 0.  So
> try_to_unuse() is changed in commit e07098294adf ("mm, THP, swap:
> support to reclaim swap space for THP swapped out") to check that
> before delete a page from swap cache, but this has broken KSM swapoff
> too.
>
> Fortunately, KSM is for the normal pages only, so the original
> behavior for KSM pages could be restored easily via checking
> PageTransCompound().  That is how this patch works.
>
> Fixes: e07098294adf ("mm, THP, swap: support to reclaim swap space for THP swapped out")
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Reported-and-Tested-and-Acked-by: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
> ---
>  mm/swapfile.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 8688ae65ef58..20d3c0f47a5f 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -2197,7 +2197,8 @@ int try_to_unuse(unsigned int type, bool frontswap,
>  		 */
>  		if (PageSwapCache(page) &&
>  		    likely(page_private(page) == entry.val) &&
> -		    !page_swapped(page))
> +		    (!PageTransCompound(page) ||
> +		     !swap_page_trans_huge_swapped(si, entry)))
>  			delete_from_swap_cache(compound_head(page));
>  
>  		/*

