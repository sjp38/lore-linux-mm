Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91285C4CEC5
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 14:44:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50016206A5
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 14:44:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50016206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 006446B0005; Thu, 12 Sep 2019 10:44:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF7FC6B0006; Thu, 12 Sep 2019 10:44:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE79E6B0007; Thu, 12 Sep 2019 10:44:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0098.hostedemail.com [216.40.44.98])
	by kanga.kvack.org (Postfix) with ESMTP id B7F026B0005
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 10:44:28 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 553A5824376C
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 14:44:28 +0000 (UTC)
X-FDA: 75926539416.28.alley62_441649e933160
X-HE-Tag: alley62_441649e933160
X-Filterd-Recvd-Size: 9220
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 14:44:27 +0000 (UTC)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8CEghO6171498;
	Thu, 12 Sep 2019 10:44:21 -0400
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2uyptmkc9x-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 12 Sep 2019 10:44:21 -0400
Received: from m0098416.ppops.net (m0098416.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x8CEgkJi171841;
	Thu, 12 Sep 2019 10:44:21 -0400
Received: from ppma03wdc.us.ibm.com (ba.79.3fa9.ip4.static.sl-reverse.com [169.63.121.186])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2uyptmkc9n-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 12 Sep 2019 10:44:21 -0400
Received: from pps.filterd (ppma03wdc.us.ibm.com [127.0.0.1])
	by ppma03wdc.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x8CEKCS5007268;
	Thu, 12 Sep 2019 14:44:20 GMT
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by ppma03wdc.us.ibm.com with ESMTP id 2uy87jxbwx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 12 Sep 2019 14:44:20 +0000
Received: from b01ledav002.gho.pok.ibm.com (b01ledav002.gho.pok.ibm.com [9.57.199.107])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8CEiKEX54854024
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 12 Sep 2019 14:44:20 GMT
Received: from b01ledav002.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 339CA124053;
	Thu, 12 Sep 2019 14:44:20 +0000 (GMT)
Received: from b01ledav002.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B9BDF124052;
	Thu, 12 Sep 2019 14:44:17 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.32.243])
	by b01ledav002.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 12 Sep 2019 14:44:17 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Laurent Dufour <ldufour@linux.ibm.com>, mpe@ellerman.id.au,
        benh@kernel.crashing.org, paulus@samba.org, npiggin@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3] powperc/mm: read TLB Block Invalidate Characteristics
In-Reply-To: <20190830120712.22971-3-ldufour@linux.ibm.com>
References: <20190830120712.22971-1-ldufour@linux.ibm.com> <20190830120712.22971-3-ldufour@linux.ibm.com>
Date: Thu, 12 Sep 2019 20:14:15 +0530
Message-ID: <87impxshfk.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-12_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909120151
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Laurent Dufour <ldufour@linux.ibm.com> writes:

> The PAPR document specifies the TLB Block Invalidate Characteristics which
> is telling which couple base page size / page size is supported by the
> H_BLOCK_REMOVE hcall.
>
> A new set of feature is added to the mmu_psize_def structure to record per
> base page size which page size is supported by H_BLOCK_REMOVE.
>
> A new init service is added to read the characteristics. The size of the
> buffer is set to twice the number of known page size, plus 10 bytes to
> ensure we have enough place.
>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/mmu.h |   3 +
>  arch/powerpc/platforms/pseries/lpar.c    | 107 +++++++++++++++++++++++
>  2 files changed, 110 insertions(+)
>
> diff --git a/arch/powerpc/include/asm/book3s/64/mmu.h b/arch/powerpc/include/asm/book3s/64/mmu.h
> index 23b83d3593e2..675895dfe39f 100644
> --- a/arch/powerpc/include/asm/book3s/64/mmu.h
> +++ b/arch/powerpc/include/asm/book3s/64/mmu.h
> @@ -12,11 +12,14 @@
>   *    sllp  : is a bit mask with the value of SLB L || LP to be or'ed
>   *            directly to a slbmte "vsid" value
>   *    penc  : is the HPTE encoding mask for the "LP" field:
> + *    hblk  : H_BLOCK_REMOVE supported block size for this page size in
> + *            segment who's base page size is that page size.
>   *
>   */
>  struct mmu_psize_def {
>  	unsigned int	shift;	/* number of bits */
>  	int		penc[MMU_PAGE_COUNT];	/* HPTE encoding */
> +	int		hblk[MMU_PAGE_COUNT];	/* H_BLOCK_REMOVE support */
>  	unsigned int	tlbiel;	/* tlbiel supported for that page size */
>  	unsigned long	avpnm;	/* bits to mask out in AVPN in the HPTE */
>  	union {
> diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platforms/pseries/lpar.c
> index 4f76e5f30c97..375e19b3cf53 100644
> --- a/arch/powerpc/platforms/pseries/lpar.c
> +++ b/arch/powerpc/platforms/pseries/lpar.c
> @@ -1311,6 +1311,113 @@ static void do_block_remove(unsigned long number, struct ppc64_tlb_batch *batch,
>  		(void)call_block_remove(pix, param, true);
>  }
>  
> +static inline void __init set_hblk_bloc_size(int bpsize, int psize,
> +					     unsigned int block_size)
> +{
> +	struct mmu_psize_def *def = &mmu_psize_defs[bpsize];
> +
> +	if (block_size > def->hblk[psize])
> +		def->hblk[psize] = block_size;
> +}
> +
> +static inline void __init check_lp_set_hblk(unsigned int lp,
> +					    unsigned int block_size)
> +{
> +	unsigned int bpsize, psize;
> +
> +
> +	/* First, check the L bit, if not set, this means 4K */
> +	if ((lp & 0x80) == 0) {
> +		set_hblk_bloc_size(MMU_PAGE_4K, MMU_PAGE_4K, block_size);
> +		return;
> +	}
> +
> +	/* PAPR says to look at bits 2-7 (0 = MSB) */
> +	lp &= 0x3f;
> +	for (bpsize = 0; bpsize < MMU_PAGE_COUNT; bpsize++) {
> +		struct mmu_psize_def *def =  &mmu_psize_defs[bpsize];
> +
> +		for (psize = 0; psize < MMU_PAGE_COUNT; psize++) {
> +			if (def->penc[psize] == lp) {
> +				set_hblk_bloc_size(bpsize, psize, block_size);
> +				return;
> +			}
> +		}
> +	}
> +}
> +
> +#define SPLPAR_TLB_BIC_TOKEN		50
> +#define SPLPAR_TLB_BIC_MAXLENGTH	(MMU_PAGE_COUNT*2 + 10)
> +static int __init read_tlbbi_characteristics(void)
> +{
> +	int call_status;
> +	unsigned char local_buffer[SPLPAR_TLB_BIC_MAXLENGTH];
> +	int len, idx, bpsize;
> +
> +	if (!firmware_has_feature(FW_FEATURE_BLOCK_REMOVE)) {
> +		pr_info("H_BLOCK_REMOVE is not supported");
> +		return 0;
> +	}
> +
> +	memset(local_buffer, 0, SPLPAR_TLB_BIC_MAXLENGTH);
> +
> +	spin_lock(&rtas_data_buf_lock);
> +	memset(rtas_data_buf, 0, RTAS_DATA_BUF_SIZE);
> +	call_status = rtas_call(rtas_token("ibm,get-system-parameter"), 3, 1,
> +				NULL,
> +				SPLPAR_TLB_BIC_TOKEN,
> +				__pa(rtas_data_buf),
> +				RTAS_DATA_BUF_SIZE);
> +	memcpy(local_buffer, rtas_data_buf, SPLPAR_TLB_BIC_MAXLENGTH);
> +	local_buffer[SPLPAR_TLB_BIC_MAXLENGTH - 1] = '\0';
> +	spin_unlock(&rtas_data_buf_lock);
> +
> +	if (call_status != 0) {
> +		pr_warn("%s %s Error calling get-system-parameter (0x%x)\n",
> +			__FILE__, __func__, call_status);
> +		return 0;
> +	}
> +
> +	/*
> +	 * The first two (2) bytes of the data in the buffer are the length of
> +	 * the returned data, not counting these first two (2) bytes.
> +	 */
> +	len = local_buffer[0] * 256 + local_buffer[1] + 2;
> +	if (len >= SPLPAR_TLB_BIC_MAXLENGTH) {
> +		pr_warn("%s too large returned buffer %d", __func__, len);
> +		return 0;
> +	}
> +
> +	idx = 2;
> +	while (idx < len) {
> +		unsigned int block_size = local_buffer[idx++];
> +		unsigned int npsize;
> +
> +		if (!block_size)
> +			break;
> +
> +		block_size = 1 << block_size;
> +		if (block_size != 8)
> +			/* We only support 8 bytes size TLB invalidate buffer */
> +			pr_warn("Unsupported H_BLOCK_REMOVE block size : %d\n",
> +				block_size);

Should we skip setting block size if we find block_size != 8? Also can
we avoid doing that pr_warn in loop and only warn if we don't find
block_size 8 in the invalidate characteristics array? 

> +
> +		for (npsize = local_buffer[idx++];  npsize > 0; npsize--)
> +			check_lp_set_hblk((unsigned int) local_buffer[idx++],
> +					  block_size);
> +	}
> +
> +	for (bpsize = 0; bpsize < MMU_PAGE_COUNT; bpsize++)
> +		for (idx = 0; idx < MMU_PAGE_COUNT; idx++)
> +			if (mmu_psize_defs[bpsize].hblk[idx])
> +				pr_info("H_BLOCK_REMOVE supports base psize:%d psize:%d block size:%d",
> +					bpsize, idx,
> +					mmu_psize_defs[bpsize].hblk[idx]);
> +
> +	return 0;
> +}
> +machine_arch_initcall(pseries, read_tlbbi_characteristics);
> +
>  /*
>   * Take a spinlock around flushes to avoid bouncing the hypervisor tlbie
>   * lock.
> -- 
> 2.23.0

