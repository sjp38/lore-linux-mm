Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0AD4C4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 13:42:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8908D208C0
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 13:42:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ellerman.id.au header.i=@ellerman.id.au header.b="paPlI2qJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8908D208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BD656B02BC; Wed, 18 Sep 2019 09:42:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36B866B02BE; Wed, 18 Sep 2019 09:42:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 281B46B02BF; Wed, 18 Sep 2019 09:42:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0079.hostedemail.com [216.40.44.79])
	by kanga.kvack.org (Postfix) with ESMTP id 05D2C6B02BC
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 09:42:51 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 97502282C
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:42:51 +0000 (UTC)
X-FDA: 75948156942.07.pull79_18d63c237a54d
X-HE-Tag: pull79_18d63c237a54d
X-Filterd-Recvd-Size: 7720
Received: from ozlabs.org (bilbo.ozlabs.org [203.11.71.1])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:42:50 +0000 (UTC)
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 46YLl50rVzz9sPn;
	Wed, 18 Sep 2019 23:42:41 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=ellerman.id.au;
	s=201909; t=1568814161;
	bh=D8YIHepWtPUot38WklW/7Wnlevl86vyDaDypmrulSRY=;
	h=From:To:Subject:In-Reply-To:References:Date:From;
	b=paPlI2qJr/e5wAY23txTv0pB73maGGVU6z3G30HEE1kCrJ2RTyYkgOcnn6KixcV6X
	 vUnhyN8qMoF6gn3h1/Ur12fBUyHUScZMlz/9w/ReJPT1nqzMSDqjw8DOwakLga/B98
	 DVdFEv0oSrNgchhwZXEtn0U1mLg4Igspm3ogSGlaSWV5LVc6FXEHCOqcMwo5ImPmXs
	 cHx5FSmYGXbSa6rl2usFDYCOxSVj68oMMupZE0I+GvT/zI5e9dTyQAoGh109yE297I
	 FqmIrSQEryZDKlpLlkCpVgBCNOMLGw7+z1ZHCEfHVCX7JDgovX5T+LkBTZVAUaxVHn
	 oKwAIGb9VBazw==
From: Michael Ellerman <mpe@ellerman.id.au>
To: Laurent Dufour <ldufour@linux.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, aneesh.kumar@linux.ibm.com, npiggin@gmail.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 2/2] powerpc/mm: call H_BLOCK_REMOVE when supported
In-Reply-To: <20190916095543.17496-3-ldufour@linux.ibm.com>
References: <20190916095543.17496-1-ldufour@linux.ibm.com> <20190916095543.17496-3-ldufour@linux.ibm.com>
Date: Wed, 18 Sep 2019 23:42:39 +1000
Message-ID: <87y2ylvhyo.fsf@mpe.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Laurent,

Few comments ...

Laurent Dufour <ldufour@linux.ibm.com> writes:
> Now we do not call _BLOCK_REMOVE all the time when the feature is
> exhibited.

This isn't true until after the patch is applied, ie. the tense is
wrong. The rest of the change log explains things fine, so just drop
that sentence I think.

Can you include the info about the oops in here.

> Depending on the hardware and the hypervisor, the hcall H_BLOCK_REMOVE may
> not be able to process all the page size for a segment base page size, as
                                      ^
                                      sizes
> reported by the TLB Invalidate Characteristics.o
                                                 ^
                                                 stray "o"
>
> For each couple base segment page size and actual page size, this
           ^
           "pair of"
> characteristic is telling the size of the block the hcall is supporting.
                 ^                                          ^
                 "tells us"                                 supports
>
> Due to the involve complexity in do_block_remove() and call_block_remove(),
             ^
             "required" is better I think
> and the fact currently a 8 size block is returned by the hypervisor,  we
              ^          ^
              that       "block of size 8"
> are only supporting 8 size block to the H_BLOCK_REMOVE hcall.
>
> Furthermore a warning message is displayed at boot time in the case of an
> unsupported block size.

I'm not sure we should be doing that? It could be unnecessarily spammy.

> In order to identify this limitation easily in the code,a local define
> HBLKR_SUPPORTED_SIZE defining the currently supported block size, and a
> dedicated checking helper is_supported_hlbkr() are introduced.
>
> For regular pages and hugetlb, the assumption is made that the page size is
> equal to the base page size. For THP the page size is assumed to be 16M.
>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> ---
>  arch/powerpc/platforms/pseries/lpar.c | 35 +++++++++++++++++++++++++--
>  1 file changed, 33 insertions(+), 2 deletions(-)
>
> diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platforms/pseries/lpar.c
> index 98a5c2ff9a0b..e2ad9b3b1097 100644
> --- a/arch/powerpc/platforms/pseries/lpar.c
> +++ b/arch/powerpc/platforms/pseries/lpar.c
> @@ -65,6 +65,13 @@ EXPORT_SYMBOL(plpar_hcall_norets);
>   */
>  static int hblkr_size[MMU_PAGE_COUNT][MMU_PAGE_COUNT];
>  
> +/*
> + * Due to the involved complexity, and that the current hypervisor is only
> + * returning this value or 0, we are limiting the support of the H_BLOCK_REMOVE
> + * buffer size to 8 size block.
> + */
> +#define HBLKR_SUPPORTED_BLOCK_SIZE 8
> +
>  #ifdef CONFIG_VIRT_CPU_ACCOUNTING_NATIVE
>  static u8 dtl_mask = DTL_LOG_PREEMPT;
>  #else
> @@ -993,6 +1000,15 @@ static void pSeries_lpar_hpte_invalidate(unsigned long slot, unsigned long vpn,
>  #define HBLKR_CTRL_ERRNOTFOUND	0x8800000000000000UL
>  #define HBLKR_CTRL_ERRBUSY	0xa000000000000000UL
>  
> +/*
> + * Returned true if we are supporting this block size for the specified segment
> + * base page size and actual page size.
> + */
> +static inline bool is_supported_hlbkr(int bpsize, int psize)
> +{
> +	return (hblkr_size[bpsize][psize] == HBLKR_SUPPORTED_BLOCK_SIZE);
> +}
> +
>  /**
>   * H_BLOCK_REMOVE caller.
>   * @idx should point to the latest @param entry set with a PTEX.
> @@ -1152,7 +1168,11 @@ static inline void __pSeries_lpar_hugepage_invalidate(unsigned long *slot,
>  	if (lock_tlbie)
>  		spin_lock_irqsave(&pSeries_lpar_tlbie_lock, flags);
>  
> -	if (firmware_has_feature(FW_FEATURE_BLOCK_REMOVE))
> +	/*
> +	 * Assuming THP size is 16M, and we only support 8 bytes size buffer
> +	 * for the momment.
> +	 */
> +	if (is_supported_hlbkr(psize, MMU_PAGE_16M))

It's not very clear that this is correct in all cases. ie. how do we
know we're being called for THP and not regular huge page?

I think we're only called via:
  flush_hash_hugepage()
  -> mmu_hash_ops.hugepage_invalidate()
     pSeries_lpar_hugepage_invalidate()
     -> __pSeries_lpar_hugepage_invalidate()

And flush_hash_hugepage() is called via:
  __hash_page_thp()
  and
  hpte_do_hugepage_flush()

The first is presumably fine, the 2nd is called in a few places:
  __flush_hash_table_range() under if (is_thp)
  hash__pmd_hugepage_update()


But it's a little bit fragile if the code ever evolves. Not sure if
there's a better solution, other than just documenting it.

>  		hugepage_block_invalidate(slot, vpn, count, psize, ssize);
>  	else
>  		hugepage_bulk_invalidate(slot, vpn, count, psize, ssize);
> @@ -1437,6 +1457,14 @@ void __init pseries_lpar_read_hblkr_characteristics(void)
>  
>  		block_size = 1 << block_size;
>  
> +		/*
> +		 * If the block size is not supported by the kernel, report it,
> +		 * but continue reading the values, and the following blocks.
> +		 */
> +		if (block_size != HBLKR_SUPPORTED_BLOCK_SIZE)
> +			pr_warn("Unsupported H_BLOCK_REMOVE block size : %d\n",
> +				block_size);

Does this need a printk? I'm worried it could end up triggering and
scaring people unnecessarily.

> +
>  		for (npsize = local_buffer[idx++];  npsize > 0; npsize--)
>  			check_lp_set_hblk((unsigned int) local_buffer[idx++],
>  					  block_size);
> @@ -1468,7 +1496,10 @@ static void pSeries_lpar_flush_hash_range(unsigned long number, int local)
>  	if (lock_tlbie)
>  		spin_lock_irqsave(&pSeries_lpar_tlbie_lock, flags);
>  
> -	if (firmware_has_feature(FW_FEATURE_BLOCK_REMOVE)) {
> +	/*
> +	 * Currently, we only support 8 bytes size buffer in do_block_remove().
> +	 */
> +	if (is_supported_hlbkr(batch->psize, batch->psize)) {
>  		do_block_remove(number, batch, param);
>  		goto out;
>  	}
> -- 
> 2.23.0

cheers

