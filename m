Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4AECC3A59B
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 10:10:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96D4222D6D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 10:10:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ujCadKEu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96D4222D6D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 302CD6B02B3; Wed, 21 Aug 2019 06:10:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B28F6B02B4; Wed, 21 Aug 2019 06:10:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EFD66B02B5; Wed, 21 Aug 2019 06:10:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0168.hostedemail.com [216.40.44.168])
	by kanga.kvack.org (Postfix) with ESMTP id EF82D6B02B3
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 06:10:23 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 66C8C55F90
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:10:23 +0000 (UTC)
X-FDA: 75846015126.29.vest56_205713f87393e
X-HE-Tag: vest56_205713f87393e
X-Filterd-Recvd-Size: 6398
Received: from merlin.infradead.org (merlin.infradead.org [205.233.59.134])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:10:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=fYbtPvqrUGygVEhVLuTCLW7Q83x6u7pjfVsDVHtGkUE=; b=ujCadKEuxRf4WAysr0rxQDISU
	VZ2WCquCrckfYicExLwIpuEe0xy3zev1OOFTBue4HIwt3lhADCDgYX4wTAzuoQSYSHnLzIkm0AopG
	xkEYZCEMlbH+TVgKHY1SAsEwN2cmSWounlz6b9fOmSWo8IFbqsjVUZ+Cip2y9QZlK2Zs4hGnA6t2p
	hDc4xPTWQ5sdTZfyIRoeDuZgfOgG9RGBDTxNlhJXEVFDusUwJtB2Nc/vMbe+HU6bmAL15mBXoqDni
	qKym6tfyCtX+Zka2iFHwXpRLHKG8sZbf+GID7BIoUh8O3VKsSlLWX5BcOkrNasQPXhOI0MTHy21Gx
	gkK8AYsfQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=noisy.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i0NZD-0004m9-8O; Wed, 21 Aug 2019 10:10:11 +0000
Received: from hirez.programming.kicks-ass.net (hirez.programming.kicks-ass.net [192.168.1.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by noisy.programming.kicks-ass.net (Postfix) with ESMTPS id 37519307456;
	Wed, 21 Aug 2019 12:09:37 +0200 (CEST)
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id C72D520C3BF31; Wed, 21 Aug 2019 12:10:08 +0200 (CEST)
Date: Wed, 21 Aug 2019 12:10:08 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com,
	stable@vger.kernel.org, Joerg Roedel <jroedel@suse.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH v2] x86/mm/pti: in pti_clone_pgtable(), increase addr
 properly
Message-ID: <20190821101008.GX2349@hirez.programming.kicks-ass.net>
References: <20190820202314.1083149-1-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190820202314.1083149-1-songliubraving@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 01:23:14PM -0700, Song Liu wrote:
> Before 32-bit support, pti_clone_pmds() always adds PMD_SIZE to addr.
> This behavior changes after the 32-bit support:  pti_clone_pgtable()
> increases addr by PUD_SIZE for pud_none(*pud) case, and increases addr by
> PMD_SIZE for pmd_none(*pmd) case. However, this is not accurate because
> addr may not be PUD_SIZE/PMD_SIZE aligned.
> 
> Fix this issue by properly rounding up addr to next PUD_SIZE/PMD_SIZE
> in these two cases.

So the patch is fine, ACK on that, but that still leaves us with the
puzzle of why this didn't explode mightily and the story needs a little
more work.

> The following explains how we debugged this issue:
> 
> We use huge page for hot text and thus reduces iTLB misses. As we
> benchmark 5.2 based kernel (vs. 4.16 based), we found ~2.5x more
> iTLB misses.
> 
> To figure out the issue, I use a debug patch that dumps page table for
> a pid. The following are information from the workload pid.
> 
> For the 4.16 based kernel:
> 
> host-4.16 # grep "x  pmd" /sys/kernel/debug/page_tables/dump_pid
> 0x0000000000600000-0x0000000000e00000           8M USR ro         PSE         x  pmd
> 0xffffffff81a00000-0xffffffff81c00000           2M     ro         PSE         x  pmd
> 
> For the 5.2 based kernel before this patch:
> 
> host-5.2-before # grep "x  pmd" /sys/kernel/debug/page_tables/dump_pid
> 0x0000000000600000-0x0000000000e00000           8M USR ro         PSE         x  pmd
> 
> The 8MB text in pmd is from user space. 4.16 kernel has 1 pmd for the
> irq entry table; while 4.16 kernel doesn't have it.
> 
> For the 5.2 based kernel after this patch:
> 
> host-5.2-after # grep "x  pmd" /sys/kernel/debug/page_tables/dump_pid
> 0x0000000000600000-0x0000000000e00000           8M USR ro         PSE         x  pmd
> 0xffffffff81000000-0xffffffff81e00000          14M     ro         PSE     GLB x  pmd
> 
> So after this patch, the 5.2 based kernel has 7 PMDs instead of 1 PMD
> in 4.16 kernel.

This basically gives rise to more questions than it provides answers.
You seem to have 'forgotten' to provide the equivalent mappings on the
two older kernels. The fact that they're not PMD is evident, but it
would be very good to know what is mapped, and what -- if anything --
lives in the holes we've (accidentally) created.

Can you please provide more complete mappings? Basically provide the
whole cpu_entry_area mapping.

> This further reduces iTLB miss rate

What you're saying is that by using PMDs, we reduce 4K iTLB usage. But
we increase 2M iTLB usage, but for your workload this works out
favourably (a quick look at the PMU event tables for SKL didn't show me
separate 4K/2M iTLB counters :/).

> Cc: stable@vger.kernel.org # v4.19+
> Fixes: 16a3fe634f6a ("x86/mm/pti: Clone kernel-image on PTE level for 32 bit")
> Reviewed-by: Rik van Riel <riel@surriel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>
> Cc: Joerg Roedel <jroedel@suse.de>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> ---
>  arch/x86/mm/pti.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
> index b196524759ec..1337494e22ef 100644
> --- a/arch/x86/mm/pti.c
> +++ b/arch/x86/mm/pti.c
> @@ -330,13 +330,13 @@ pti_clone_pgtable(unsigned long start, unsigned long end,
>  
>  		pud = pud_offset(p4d, addr);
>  		if (pud_none(*pud)) {
> -			addr += PUD_SIZE;
> +			addr = round_up(addr + 1, PUD_SIZE);
>  			continue;
>  		}
>  
>  		pmd = pmd_offset(pud, addr);
>  		if (pmd_none(*pmd)) {
> -			addr += PMD_SIZE;
> +			addr = round_up(addr + 1, PMD_SIZE);
>  			continue;
>  		}
>  
> -- 
> 2.17.1
> 

