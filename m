Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8033AC73C56
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 19:32:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BDF82080C
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 19:32:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BDF82080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB7238E0057; Tue,  9 Jul 2019 15:32:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B40DC8E0032; Tue,  9 Jul 2019 15:32:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E1168E0057; Tue,  9 Jul 2019 15:32:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5258E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 15:32:39 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k20so13269357pgg.15
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 12:32:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:organization
         :reply-to:mail-reply-to:in-reply-to:references:message-id:user-agent;
        bh=W/Fw+cjTu5U6LCkhzfLszMFMjz4cfzV+msNOUtKAzTU=;
        b=gEjVue3drVHkGSzFEh438FPQq02b9KwaCiBKCnGyagnIKM8/fqhptZT+EtKKqpm5jD
         S6qP8EBDUgz1fJrFaBfj6vx5l88P1nXwsnv3ab7qsAYigzmYh8N4I8vT9RIfJ+fJ2+nR
         csdCnzyPxEhfrUChLtA1HiYDetCwRmMUkiu2mCapQ+BX4r37IYV1uFvFOdT2wTnGtwgU
         Up8InWmvAt0EK3S28yQhs3H+zihB+hssfzCJxqqJph9QhfY5HL//jAcbTXEXRPBwcY+7
         7USbzEi1PUq/C3tzx3k1T4KkWbKrm00DO/QI4bWa5ys4iDgQzWg5s6XFABlFjIEt85+7
         T1CA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVHOI/ZfbDSi/89qkotbx7fYEic13Hv8+961I59wha+7A8GFp93
	JMvMKobKB5pGnCMD+bEDCZBMfLouY3Hsai0nf3PLg//KslMByE68WSw60omDnFwfc/0AgVzkqgk
	K6VCcqh99mUd5vltSN4USXRVSuSanb8ziXNGqDsUSpIbocOLJyPXbNplm3fePp3JffQ==
X-Received: by 2002:a17:902:ba96:: with SMTP id k22mr29615271pls.44.1562700759031;
        Tue, 09 Jul 2019 12:32:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRSF4fEHr5OGEukpeggFkdAsbN0hCZ2q7s22lx9MnF3d7XuNZJ3F4bWRNKbX9jIW5PJ4kr
X-Received: by 2002:a17:902:ba96:: with SMTP id k22mr29615199pls.44.1562700758269;
        Tue, 09 Jul 2019 12:32:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562700758; cv=none;
        d=google.com; s=arc-20160816;
        b=ST7VbmrLRx467sb8apKDfDEcReXdzsZO2iWW1XbM6dxxwa6DCC65AVRLXy3N9PZdVx
         q6KsZhXD681hHV3eiTZjKmg9CdnQAZenB/hz+vHBtowDwrltCZ7Ena3w5GwAph4eGLCk
         9FkvDmznVOHpcuEEHc7gd4Pw9iHWk/kh2mmOUcoyWRqQreuESQohHlsCwfBom3hPyCP9
         OBrz+Gaf0uZbbi1YP0VqG/JcUmDkZkv4MAiXgMGWIKJQ9J5FBGwGGoTd1UuosJEOJAiy
         I5nj7y5j96L5zXkUIaotuMITILcDHlMmcvghIPbSYRu6pYbyKo/gT+zMUyjfGjv+xwJJ
         lQDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:references:in-reply-to:mail-reply-to:reply-to
         :organization:subject:cc:to:from:date:content-transfer-encoding
         :mime-version;
        bh=W/Fw+cjTu5U6LCkhzfLszMFMjz4cfzV+msNOUtKAzTU=;
        b=hlikHfv43MK5HckWNPrswbByY/rD2FscebxqZ6fZHus3PF48CjMx9uUW8w9d7kioiH
         I3jpzGmd3+JPW+yasu2UNmG2BxcsokW4wnLvps1MXGUNqclYqhuonXmZGp8uPrGlQxPN
         FJnX+G3URL9qgcVKBr5A4a1fRLqf+aavHJgtjX+LQIUKfaXCI3kXRdyVT5e94FM2OETN
         kc9vGJAAVB2uZW1I5PH3ULX8cuzVhBk48BHEIMXwU/IykRPgQ4sQ0Vl+vj3Uywh9wmUl
         p/SaaFBaOvVtsShEqnxl5pNmtlD3aXMDGpLvwbfR8asGwivDDz91gc3BvW+DE3Pniyu4
         htJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u9si96740pgb.148.2019.07.09.12.32.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 12:32:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69JVdNh029136;
	Tue, 9 Jul 2019 15:32:37 -0400
Received: from ppma01wdc.us.ibm.com (fd.55.37a9.ip4.static.sl-reverse.com [169.55.85.253])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tmy5dcykc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 09 Jul 2019 15:32:37 -0400
Received: from pps.filterd (ppma01wdc.us.ibm.com [127.0.0.1])
	by ppma01wdc.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x69JTtWu004783;
	Tue, 9 Jul 2019 19:32:36 GMT
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by ppma01wdc.us.ibm.com with ESMTP id 2tjk96f7gu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 09 Jul 2019 19:32:36 +0000
Received: from b03ledav002.gho.boulder.ibm.com (b03ledav002.gho.boulder.ibm.com [9.17.130.233])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69JWYFc53019068
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 19:32:34 GMT
Received: from b03ledav002.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8D99B136053;
	Tue,  9 Jul 2019 19:32:34 +0000 (GMT)
Received: from b03ledav002.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 39B3313604F;
	Tue,  9 Jul 2019 19:32:34 +0000 (GMT)
Received: from ltc.linux.ibm.com (unknown [9.16.170.189])
	by b03ledav002.gho.boulder.ibm.com (Postfix) with ESMTP;
	Tue,  9 Jul 2019 19:32:34 +0000 (GMT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 09 Jul 2019 14:35:02 -0500
From: janani <janani@linux.ibm.com>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linuxram@us.ibm.com, cclaudio@linux.ibm.com,
        kvm-ppc@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com,
        aneesh.kumar@linux.vnet.ibm.com, paulus@au1.ibm.com,
        sukadev@linux.vnet.ibm.com,
        Linuxppc-dev
 <linuxppc-dev-bounces+janani=linux.ibm.com@lists.ozlabs.org>
Subject: Re: [PATCH v5 2/7] kvmppc: Shared pages support for secure guests
Organization: IBM
Reply-To: janani@linux.ibm.com
Mail-Reply-To: janani@linux.ibm.com
In-Reply-To: <20190709102545.9187-3-bharata@linux.ibm.com>
References: <20190709102545.9187-1-bharata@linux.ibm.com>
 <20190709102545.9187-3-bharata@linux.ibm.com>
Message-ID: <e73fbe2bb6617da8245c1164aa7c8b57@linux.vnet.ibm.com>
X-Sender: janani@linux.ibm.com
User-Agent: Roundcube Webmail/1.0.1
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-09_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907090231
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-09 05:25, Bharata B Rao wrote:
> A secure guest will share some of its pages with hypervisor (Eg. virtio
> bounce buffers etc). Support shared pages in HMM driver.
> 
> Once a secure page is converted to shared page, HMM driver will stop
> tracking that page.
> 
> Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
  Reviewed-by: Janani Janakiraman <janani@linux.ibm.com>
> ---
>  arch/powerpc/include/asm/hvcall.h |  3 ++
>  arch/powerpc/kvm/book3s_hv_hmm.c  | 66 +++++++++++++++++++++++++++++--
>  2 files changed, 66 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/hvcall.h
> b/arch/powerpc/include/asm/hvcall.h
> index 2f6b952deb0f..05b8536f6653 100644
> --- a/arch/powerpc/include/asm/hvcall.h
> +++ b/arch/powerpc/include/asm/hvcall.h
> @@ -337,6 +337,9 @@
>  #define H_TLB_INVALIDATE	0xF808
>  #define H_COPY_TOFROM_GUEST	0xF80C
> 
> +/* Flags for H_SVM_PAGE_IN */
> +#define H_PAGE_IN_SHARED        0x1
> +
>  /* Platform-specific hcalls used by the Ultravisor */
>  #define H_SVM_PAGE_IN		0xEF00
>  #define H_SVM_PAGE_OUT		0xEF04
> diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c 
> b/arch/powerpc/kvm/book3s_hv_hmm.c
> index cd34323888b6..36562b382e70 100644
> --- a/arch/powerpc/kvm/book3s_hv_hmm.c
> +++ b/arch/powerpc/kvm/book3s_hv_hmm.c
> @@ -52,6 +52,7 @@ struct kvmppc_hmm_page_pvt {
>  	unsigned long *rmap;
>  	unsigned int lpid;
>  	unsigned long gpa;
> +	bool skip_page_out;
>  };
> 
>  struct kvmppc_hmm_migrate_args {
> @@ -215,6 +216,53 @@ static const struct migrate_vma_ops
> kvmppc_hmm_migrate_ops = {
>  	.finalize_and_map = kvmppc_hmm_migrate_finalize_and_map,
>  };
> 
> +/*
> + * Shares the page with HV, thus making it a normal page.
> + *
> + * - If the page is already secure, then provision a new page and 
> share
> + * - If the page is a normal page, share the existing page
> + *
> + * In the former case, uses the HMM fault handler to release the HMM 
> page.
> + */
> +static unsigned long
> +kvmppc_share_page(struct kvm *kvm, unsigned long gpa, unsigned long 
> page_shift)
> +{
> +
> +	int ret;
> +	struct page *hmm_page;
> +	struct kvmppc_hmm_page_pvt *pvt;
> +	unsigned long pfn;
> +	unsigned long *rmap;
> +	struct kvm_memory_slot *slot;
> +	unsigned long gfn = gpa >> page_shift;
> +	int srcu_idx;
> +
> +	srcu_idx = srcu_read_lock(&kvm->srcu);
> +	slot = gfn_to_memslot(kvm, gfn);
> +	if (!slot) {
> +		srcu_read_unlock(&kvm->srcu, srcu_idx);
> +		return H_PARAMETER;
> +	}
> +	rmap = &slot->arch.rmap[gfn - slot->base_gfn];
> +	srcu_read_unlock(&kvm->srcu, srcu_idx);
> +
> +	if (kvmppc_is_hmm_pfn(*rmap)) {
> +		hmm_page = pfn_to_page(*rmap & ~KVMPPC_PFN_HMM);
> +		pvt = (struct kvmppc_hmm_page_pvt *)
> +			hmm_devmem_page_get_drvdata(hmm_page);
> +		pvt->skip_page_out = true;
> +	}
> +
> +	pfn = gfn_to_pfn(kvm, gpa >> page_shift);
> +	if (is_error_noslot_pfn(pfn))
> +		return H_PARAMETER;
> +
> +	ret = uv_page_in(kvm->arch.lpid, pfn << page_shift, gpa, 0, 
> page_shift);
> +	kvm_release_pfn_clean(pfn);
> +
> +	return (ret == U_SUCCESS) ? H_SUCCESS : H_PARAMETER;
> +}
> +
>  /*
>   * Move page from normal memory to secure memory.
>   */
> @@ -235,9 +283,12 @@ kvmppc_h_svm_page_in(struct kvm *kvm, unsigned 
> long gpa,
>  	if (page_shift != PAGE_SHIFT)
>  		return H_P3;
> 
> -	if (flags)
> +	if (flags & ~H_PAGE_IN_SHARED)
>  		return H_P2;
> 
> +	if (flags & H_PAGE_IN_SHARED)
> +		return kvmppc_share_page(kvm, gpa, page_shift);
> +
>  	down_read(&kvm->mm->mmap_sem);
>  	srcu_idx = srcu_read_lock(&kvm->srcu);
>  	slot = gfn_to_memslot(kvm, gfn);
> @@ -299,8 +350,17 @@ kvmppc_hmm_fault_migrate_alloc_and_copy(struct
> vm_area_struct *vma,
>  	       hmm_devmem_page_get_drvdata(spage);
> 
>  	pfn = page_to_pfn(dpage);
> -	ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
> -			  pvt->gpa, 0, PAGE_SHIFT);
> +
> +	/*
> +	 * This same alloc_and_copy() callback is used in two cases:
> +	 * - When HV touches a secure page, for which we do page-out
> +	 * - When a secure page is converted to shared page, we touch
> +	 *   the page to essentially discard the HMM page. In this case we
> +	 *   skip page-out.
> +	 */
> +	if (!pvt->skip_page_out)
> +		ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
> +				  pvt->gpa, 0, PAGE_SHIFT);
>  	if (ret == U_SUCCESS)
>  		*dst_pfn = migrate_pfn(pfn) | MIGRATE_PFN_LOCKED;
>  }

