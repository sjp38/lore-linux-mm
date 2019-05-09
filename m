Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B9FEC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 08:37:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE78221479
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 08:37:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE78221479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 615AB6B0003; Thu,  9 May 2019 04:37:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C5306B0006; Thu,  9 May 2019 04:37:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48F5D6B0007; Thu,  9 May 2019 04:37:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F1A0A6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 04:37:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d15so952821edm.7
        for <linux-mm@kvack.org>; Thu, 09 May 2019 01:37:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8D05hyS9oAyQyLoaXI8/N0JJ7WCT9mHRPb0wC8RZl4g=;
        b=eDtJbRFT24g6oPQR1auAl6Mlj8aAZBAG5Q8zBtcWxY2+n/fnWIBKGjc2cWtLUUdV66
         DwVE3EiyXxVzw3fYrjIvVmrEshBU+lIjvpS3G1UitxQm9grMPRY9v+MWgscVnH3mOPoY
         kzTAKt04keG/jUgPjVwOad/cIiAesP3pJ9lSDZ07CFN7W09DQn1NlCiD2gta3chQriKA
         dA8b1k2XAJ3XqTpesxTcNB6ag/5x+paoLDuEMOi05YNVBEQf0uZsrj23hQF+WBtTwrBO
         o5OfLz0FL2Cs3bokod46rg4NpKU+oUNNcje5qerbwrWkujTkPtbywoTOkhuwxoePzoaU
         HAPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAUIXaDIhsf4cyM7Pbk0e0rVQz/k022ITcbbRWZISVnjsIsXNWr+
	o8ugwe6GsWcXNqjk30LZZPM5DZ4yRt0k31GjUmwsAZVSUbUFn4U79/hqDyzR0cKXg0RMU2am0ch
	kV6JHlghsJ4bNz4Xps6ypOhZoBcRUpRWQJXuwmM0RoKEiud6bIIje+mDwXkFDShATuQ==
X-Received: by 2002:a50:aeaf:: with SMTP id e44mr2477783edd.239.1557391065555;
        Thu, 09 May 2019 01:37:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxW29gYT87xHXSP8Gn2+dXDJV9Po/BKPENJpcwMk4aEla8GLq8MD3snu/zBJfdLx7gPxmmW
X-Received: by 2002:a50:aeaf:: with SMTP id e44mr2477730edd.239.1557391064642;
        Thu, 09 May 2019 01:37:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557391064; cv=none;
        d=google.com; s=arc-20160816;
        b=aCepyGGav9ngIjttGo3yguw2KsiX/HuCP8JeSopDo8ixiVYgaDNopzsQVzTLHoCXPP
         yhAbkXdaWFA5573KI5wjvKrXA13yYiiX1bpGTT9gK69gGVcoWgDoRmGyX8AlsKJQfxij
         O6xDS1CInZ1oMT/ac4ttnavfT1fNhZAS7z2faSDXBXRDNLO+5XYdPaPfTQhFdRo1j0Lr
         0VRMi4uM3uGRGydBqV9K0qhf6MTmijS5fCX0JGy5nv+vasWkf8J0MpyOowwDLTCGn8o5
         DybIG6RS0xq3r5/EOlDkRyLAxYCqpYUr9OvuLV4G+oArIzwDk51UobnjXXFj7WkAokv0
         eE/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8D05hyS9oAyQyLoaXI8/N0JJ7WCT9mHRPb0wC8RZl4g=;
        b=pXIol5moRJL3r+VvgIsRCJ+UbjFhKeE77vo+HRuhbbmbI3MVRAiRVXtmFk8SkVu8ga
         y+Kn32+NJ/6HGywHm9oQFfI6RcWrYAKam2k3gyE54W6EbX5KMbYH2AWS3k9ULE3nSGLy
         886BzzfyyG4Ai9YAfmipfkav1RlICEmaP72mgVaplBAe6+e77cjH63adk5uIRNpmHzFP
         uChz6PV4AP+gyTlG0grVPYM4xwes51S1SnD//9KHU/BDYhxIR/V0SJEZWpdvLKpuDBvE
         MmWU39vybJhprOkLAIrPs8X/FT//Pw5s/cWX4PRniB5OJb4JikcPTcy9eH6gb138wLfv
         T5sw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c6si966908edb.238.2019.05.09.01.37.44
        for <linux-mm@kvack.org>;
        Thu, 09 May 2019 01:37:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1B800374;
	Thu,  9 May 2019 01:37:43 -0700 (PDT)
Received: from brain-police (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1D54E3F575;
	Thu,  9 May 2019 01:37:40 -0700 (PDT)
Date: Thu, 9 May 2019 09:37:26 +0100
From: Will Deacon <will.deacon@arm.com>
To: Yang Shi <yang.shi@linux.alibaba.com>, peterz@infradead.org
Cc: jstancek@redhat.com, akpm@linux-foundation.org, stable@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190509083726.GA2209@brain-police>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all, [+Peter]

Apologies for the delay; I'm attending a conference this week so it's tricky
to keep up with email.

On Wed, May 08, 2019 at 05:34:49AM +0800, Yang Shi wrote:
> A few new fields were added to mmu_gather to make TLB flush smarter for
> huge page by telling what level of page table is changed.
> 
> __tlb_reset_range() is used to reset all these page table state to
> unchanged, which is called by TLB flush for parallel mapping changes for
> the same range under non-exclusive lock (i.e. read mmap_sem).  Before
> commit dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in
> munmap"), MADV_DONTNEED is the only one who may do page zapping in
> parallel and it doesn't remove page tables.  But, the forementioned commit
> may do munmap() under read mmap_sem and free page tables.  This causes a
> bug [1] reported by Jan Stancek since __tlb_reset_range() may pass the
> wrong page table state to architecture specific TLB flush operations.

Yikes. Is it actually safe to run free_pgtables() concurrently for a given
mm?

> So, removing __tlb_reset_range() sounds sane.  This may cause more TLB
> flush for MADV_DONTNEED, but it should be not called very often, hence
> the impact should be negligible.
> 
> The original proposed fix came from Jan Stancek who mainly debugged this
> issue, I just wrapped up everything together.

I'm still paging the nested flush logic back in, but I have some comments on
the patch below.

> [1] https://lore.kernel.org/linux-mm/342bf1fd-f1bf-ed62-1127-e911b5032274@linux.alibaba.com/T/#m7a2ab6c878d5a256560650e56189cfae4e73217f
> 
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Tested-by: Jan Stancek <jstancek@redhat.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> ---
>  mm/mmu_gather.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> index 99740e1..9fd5272 100644
> --- a/mm/mmu_gather.c
> +++ b/mm/mmu_gather.c
> @@ -249,11 +249,12 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>  	 * flush by batching, a thread has stable TLB entry can fail to flush

Urgh, we should rewrite this comment while we're here so that it makes sense...

>  	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
>  	 * forcefully if we detect parallel PTE batching threads.
> +	 *
> +	 * munmap() may change mapping under non-excluse lock and also free
> +	 * page tables.  Do not call __tlb_reset_range() for it.
>  	 */
> -	if (mm_tlb_flush_nested(tlb->mm)) {
> -		__tlb_reset_range(tlb);
> +	if (mm_tlb_flush_nested(tlb->mm))
>  		__tlb_adjust_range(tlb, start, end - start);
> -	}

I don't think we can elide the call __tlb_reset_range() entirely, since I
think we do want to clear the freed_pXX bits to ensure that we walk the
range with the smallest mapping granule that we have. Otherwise couldn't we
have a problem if we hit a PMD that had been cleared, but the TLB
invalidation for the PTEs that used to be linked below it was still pending?

Perhaps we should just set fullmm if we see that here's a concurrent
unmapper rather than do a worst-case range invalidation. Do you have a feeling
for often the mm_tlb_flush_nested() triggers in practice?

Will

