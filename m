Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5EFFC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:38:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98C9921473
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:38:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98C9921473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BED66B0008; Mon, 13 May 2019 12:38:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46D6C6B0010; Mon, 13 May 2019 12:38:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3357C6B0266; Mon, 13 May 2019 12:38:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC8A26B0008
	for <linux-mm@kvack.org>; Mon, 13 May 2019 12:38:10 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h2so18788724edi.13
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:38:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hR+x75yFnxWSSQ3HkVBuqCFEZqW52ul8KC7kecUXy1w=;
        b=ZlQLSGsyghnWtnHe7s6UA4BfNIbZ+gpgymTGyeDHdsct2ZzlibLnGNFzRi1aBEoh5D
         dQ7mmsMfYVs/t62OtOcARaMbakeAI77A9u6tzE9TVIIgRM2CTNyIefGTSh4rKf2LVKUY
         wB3xakfV3NYoaAtwWyCr2tc0zx5u22NbgbFjoAfAh/NmlgzNOCbWS6hc5EOuOuHFZkMp
         WeK30AFKwl9NCcEFD/HYPzyjHphqVHwSf8Oou9FOA2rvxesMFxZRkAgOnROIl/j6oYmj
         4XVWZD27cw6peg2dwY5hfLYHu8pl9YzhGR4gq83Lx9c9z/WW0k/IUMYOFf6Bo8ub1Ug0
         rgSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAU76OWDfOTvMW8fjG/GPyzYsrrm/Q4d1YoRtpnenUVelA7HkzJU
	rmTIIflexpdq9ur/yqkbzenlaq8Qpiv4VV44FhV1T21oZS2c1RKTpifu4KVYPEPKIQO0fpVcNk9
	CnQ4tfGGgee6KZPPiZ7Dus/HwbZmaoNGvfpy5zH9ahrDPvoI0m/hWmPO5i/utPo1cvg==
X-Received: by 2002:a50:919d:: with SMTP id g29mr30298806eda.146.1557765490468;
        Mon, 13 May 2019 09:38:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbHcpj4OylVwzQlheNekG9FlBaDmHSP4BxRpn2kKe2lhrjdcHe6U0v/fG8YVCx//IYu/av
X-Received: by 2002:a50:919d:: with SMTP id g29mr30298685eda.146.1557765489367;
        Mon, 13 May 2019 09:38:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557765489; cv=none;
        d=google.com; s=arc-20160816;
        b=G2eDqaJCfyL3YxwCOguTzaAlS7O5YWQlzyNhFSozol9fJLZEa/bR9yJQR0RVo8TNdz
         7etIOJM1jvtqBjPMHlogEcNCcdozzMhnYoS8qJMrKl7LhKQy9dLpRys0/mTn0OGFBfhx
         YXqEZ3YNVh6tIpJelvcvV+Bwx1/LrfZzOznlFuj0KkYQ51NBmgvGASNt/8hCRil44LMp
         zuWE1hLm5ukVau/7PC5SI9o9ehDf1jTWivIMquWDR//zDeptKKWUsXBimOE0KKWk7boi
         qlDpAP4EQ+Z+J0E5R9B+0Vq4rNxsXG+8iO0c///VfpGmUOQkTRiSB3PjrFUQWo8AA0Ld
         v1Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hR+x75yFnxWSSQ3HkVBuqCFEZqW52ul8KC7kecUXy1w=;
        b=qk+ncOda4n6o3vxRCAPrwMpN4jYDjgslJg4oEKoOUjw2KjPNvg3wX6+4rdaSF9Ny6B
         tZlaJYGxSyGPFe05TT3jCpv4PRguFW9d6Jtls0mYujgeGTwU8gfSsICg1f6gq5I+Sh1y
         KUVQe50yXD37WLG+KdaGwB+y8oepAi4exEnbL4ISSylzpOZ4LAslRmkm+CZErKhUvQZM
         uw4MJFkGcQjBxGBV5raJRNr9TvNNuIr9o8W3HzUiQ8C8JkcdCS4yGWAAQP3VJGs9ijud
         v0TfyM41vdc/B7geRu9yr5HX4cPJJz4nlm+QJ7Ica0XU/tq7OK3ttP4WhVaoAkYjgrjI
         CNiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id pg1si2785417ejb.285.2019.05.13.09.38.09
        for <linux-mm@kvack.org>;
        Mon, 13 May 2019 09:38:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 609C0341;
	Mon, 13 May 2019 09:38:08 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B73A03F71E;
	Mon, 13 May 2019 09:38:06 -0700 (PDT)
Date: Mon, 13 May 2019 17:38:04 +0100
From: Will Deacon <will.deacon@arm.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: jstancek@redhat.com, peterz@infradead.org, namit@vmware.com,
	minchan@kernel.org, mgorman@suse.de, stable@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190513163804.GB10754@fuggles.cambridge.arm.com>
References: <1557444414-12090-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557444414-12090-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 07:26:54AM +0800, Yang Shi wrote:
> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> index 99740e1..469492d 100644
> --- a/mm/mmu_gather.c
> +++ b/mm/mmu_gather.c
> @@ -245,14 +245,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>  {
>  	/*
>  	 * If there are parallel threads are doing PTE changes on same range
> -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> -	 * flush by batching, a thread has stable TLB entry can fail to flush
> -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> -	 * forcefully if we detect parallel PTE batching threads.
> +	 * under non-exclusive lock (e.g., mmap_sem read-side) but defer TLB
> +	 * flush by batching, one thread may end up seeing inconsistent PTEs
> +	 * and result in having stale TLB entries.  So flush TLB forcefully
> +	 * if we detect parallel PTE batching threads.
> +	 *
> +	 * However, some syscalls, e.g. munmap(), may free page tables, this
> +	 * needs force flush everything in the given range. Otherwise this
> +	 * may result in having stale TLB entries for some architectures,
> +	 * e.g. aarch64, that could specify flush what level TLB.
>  	 */
> -	if (mm_tlb_flush_nested(tlb->mm)) {
> -		__tlb_reset_range(tlb);
> -		__tlb_adjust_range(tlb, start, end - start);
> +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->fullmm) {
> +		/*
> +		 * Since we can't tell what we actually should have
> +		 * flushed, flush everything in the given range.
> +		 */
> +		tlb->freed_tables = 1;
> +		tlb->cleared_ptes = 1;
> +		tlb->cleared_pmds = 1;
> +		tlb->cleared_puds = 1;
> +		tlb->cleared_p4ds = 1;
> +
> +		/*
> +		 * Some architectures, e.g. ARM, that have range invalidation
> +		 * and care about VM_EXEC for I-Cache invalidation, need force
> +		 * vma_exec set.
> +		 */
> +		tlb->vma_exec = 1;
> +
> +		/* Force vma_huge clear to guarantee safer flush */
> +		tlb->vma_huge = 0;
> +
> +		tlb->start = start;
> +		tlb->end = end;
>  	}

Whilst I think this is correct, it would be interesting to see whether
or not it's actually faster than just nuking the whole mm, as I mentioned
before.

At least in terms of getting a short-term fix, I'd prefer the diff below
if it's not measurably worse.

Will

--->8

diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
index 99740e1dd273..cc251422d307 100644
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -251,8 +251,9 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
 	 * forcefully if we detect parallel PTE batching threads.
 	 */
 	if (mm_tlb_flush_nested(tlb->mm)) {
+		tlb->fullmm = 1;
 		__tlb_reset_range(tlb);
-		__tlb_adjust_range(tlb, start, end - start);
+		tlb->freed_tables = 1;
 	}
 
 	tlb_flush_mmu(tlb);

