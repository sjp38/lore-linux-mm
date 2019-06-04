Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41A09C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:23:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 113C0243F6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:23:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 113C0243F6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D2BB6B026C; Tue,  4 Jun 2019 10:23:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9834F6B026E; Tue,  4 Jun 2019 10:23:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8992E6B0272; Tue,  4 Jun 2019 10:23:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8266B026C
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 10:23:45 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a21so615607edt.23
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 07:23:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vc7rfhl9mcfSYNUSIEYNBXnL4l/81GoOn3cs7pdaQ8s=;
        b=Bs59bPElqGApgwYzM35unJNHFaF8UhUwC16b8GrypbNFmm/P84qnCUIhd6JQ9fnUNG
         TO6Uy/7rbaJpTD6Y0LSfNodSm+Rq0WcjevJfp1y2Un1iRgABCp4PD/deFMe9ChjtbRDV
         bNkssUJgNDyZKfpEM1tnxJTqOLioPngkx3tesTwi1bx8TwsmLohsJxmp8LBvWQm8IIoc
         Jnv5iSvMvdGZqkeP4auo2Gy6zFXXkbZJiyUqa7xONQZ7Jyh9snB9II7cBm3tGWupuS7a
         pqB4MqkObfq/alfR9QPkEvXsASrq7kHlXNPV6iX5YIhk07Om16GdqTNWBcXLymOAgClK
         PLnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAWss4CkUbcGOJ8yykLCMJM9HFCeMJHYvLGXsZngvyol6BnbbpkD
	WZLjQ7kkV2U7YHgOBrYDV8TXJN/jWLTdi9kkkvIAjw9zPkZIzyCMIprBnVqxDwcZfhXdKnde8uS
	afibcI+bbqTwOlOdD+ztEbvcBKA/mryaNekBkuGt1SYP/zg98Glikhum5KB8UXNK1PA==
X-Received: by 2002:a50:fa4b:: with SMTP id c11mr35969315edq.154.1559658224815;
        Tue, 04 Jun 2019 07:23:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNTXZTZv2qClKwPmqa/qWjaC+chbp9s5+Wg4hsk4IjBoRcAsNGuSPI2p8E/RQ96Pog1PBw
X-Received: by 2002:a50:fa4b:: with SMTP id c11mr35969235edq.154.1559658224125;
        Tue, 04 Jun 2019 07:23:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559658224; cv=none;
        d=google.com; s=arc-20160816;
        b=M2IOopxmk4ncQOgn+6h32O4wcIOYOzGz1ttrJvFFNiot2JqcFhHqXVKNrnly20DLGi
         YQsOR3WSw6Nj5tyYh10vXpDc6AXJ81618WKlInYOn8dbah/up5/feqsNNV6CjBL0aBId
         54KwuGEEKJB/wsoyp2UyYg4eoUbhTRm+guOlzHRHfPdAsmWI2dr3tIFOO+Pi1/tlQnYr
         ABmN2UoJuWd+HryggY/NJotvGdfQ4eWWCPXhlecxHuqtGDmtl91FeC8K4gAo1CiP5CZN
         jBc/+iNAcKe+0b+WsYih9exxJqMKUkVdZL1MRQ3uD2X839soYFe9+DwIOCDdqVFSFc/3
         GSPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vc7rfhl9mcfSYNUSIEYNBXnL4l/81GoOn3cs7pdaQ8s=;
        b=WHjcKOMDw01oZ7rBmNKXWuIt//TIA7+DASl03f6NiiaDvnHgjSL3F21o1X/HSTX0EC
         1fbxf546wJiPFOOIVNhbxDdOFy6JXGTwBzxOZ36yTt0s9u4EdWdvE3ujetA1oKGx1xrt
         GLEJ32g67936jkEmz4wyRNZfqLOaFsHVUgFrdc4ERaEfN1M12Lx6rsdd1YU0HeaHHGXn
         mPgfe8mboPwayZFoufbwPRG4j8iCa9q07zm1WvnMX48TqLd8IQZH1yCiUgFp81qRv2hz
         DtGqv8lhegKfEVVqS9QjfA7vcKmM3kFXc1NlPQdIaPoKikULoLTySZhYCEgu7gGCA721
         nBCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c1si10902417ejf.45.2019.06.04.07.23.43
        for <linux-mm@kvack.org>;
        Tue, 04 Jun 2019 07:23:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0E423341;
	Tue,  4 Jun 2019 07:23:43 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EDBD23F690;
	Tue,  4 Jun 2019 07:23:40 -0700 (PDT)
Date: Tue, 4 Jun 2019 15:23:38 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Qian Cai <cai@lca.pw>, rppt@linux.ibm.com
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, will.deacon@arm.com,
	linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org,
	vdavydov.dev@gmail.com, hannes@cmpxchg.org, cgroups@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
Message-ID: <20190604142338.GC24467@lakrids.cambridge.arm.com>
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559656836-24940-1-git-send-email-cai@lca.pw>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 10:00:36AM -0400, Qian Cai wrote:
> The commit "arm64: switch to generic version of pte allocation"
> introduced endless failures during boot like,
> 
> kobject_add_internal failed for pgd_cache(285:chronyd.service) (error:
> -2 parent: cgroup)
> 
> It turns out __GFP_ACCOUNT is passed to kernel page table allocations
> and then later memcg finds out those don't belong to any cgroup.

Mike, I understood from [1] that this wasn't expected to be a problem,
as the accounting should bypass kernel threads.

Was that assumption wrong, or is something different happening here?

> 
> backtrace:
>   kobject_add_internal
>   kobject_init_and_add
>   sysfs_slab_add+0x1a8
>   __kmem_cache_create
>   create_cache
>   memcg_create_kmem_cache
>   memcg_kmem_cache_create_func
>   process_one_work
>   worker_thread
>   kthread
> 
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  arch/arm64/mm/pgd.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
> index 769516cb6677..53c48f5c8765 100644
> --- a/arch/arm64/mm/pgd.c
> +++ b/arch/arm64/mm/pgd.c
> @@ -38,7 +38,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
>  	if (PGD_SIZE == PAGE_SIZE)
>  		return (pgd_t *)__get_free_page(gfp);
>  	else
> -		return kmem_cache_alloc(pgd_cache, gfp);
> +		return kmem_cache_alloc(pgd_cache, GFP_PGTABLE_KERNEL);

This is used to allocate PGDs for both user and kernel pagetables (e.g.
for the efi runtime services), so while this may fix the regression, I'm
not sure it's the right fix.

Do we need a separate pgd_alloc_kernel()?

Thanks,
Mark.

[1] https://lkml.kernel.org/r/20190505061956.GE15755@rapoport-lnx

