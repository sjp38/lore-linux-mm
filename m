Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9E6FC10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 14:46:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96CD02171F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 14:46:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96CD02171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2862F6B0007; Thu,  4 Apr 2019 10:46:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20D2B6B0008; Thu,  4 Apr 2019 10:46:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 087D06B000A; Thu,  4 Apr 2019 10:46:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A7E326B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 10:46:54 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id j3so1566190edb.14
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 07:46:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=by+qc73PFufYAJcEzQJv2SX/8Vxa3BKPss43cTpMvFU=;
        b=rsxGgGpsYP1iquj/MBc1dt24zWtX1IlfCTikxgKRrMVyX+/NdjV7vu75IPrhHP/AaR
         I0fgzY+ShD8TJMzUL9XRX/Jdk5wn0+I6WTgwWN9nrfO2nMd6dOzVb680FMRleODK041e
         NaC9d+aOboqvzSsZwRlI+hJKEjhFD48b1rcEMCT8m/ZOXMFnmLQbH7GG85fG1BoeFqXi
         y5DiU86HYwpvhQYyhkObVRRHw0KhYMZFD2RzazX860t2ZJewxv3YHnY9CMvkWqZhBH3L
         3pl6ZU0qs8MZMjeO4FtZpo2u67d4/7AaWURWjEvKwRUO5Hz3T/cFTYY56fxZyWoWj3u5
         bSVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXmKOLC54v8A3naT8U+cewpyb8fp1+Jutrrm/OyzKWdj7nSB+XG
	Zo1lc7/8PqHF5+L8ANrPUfu6JJkwEygk9Bmf+zi1wBOdvGG2N/IciiwEH+JrrOUgN0GPI6Nl8TJ
	M5yGKN1jDrrT4VuzWGKysPqO4EdEaSybb0E29+rDln1Mw5xuybLZJdTPbTTMqFFoQRA==
X-Received: by 2002:a50:e609:: with SMTP id y9mr4043518edm.81.1554389214232;
        Thu, 04 Apr 2019 07:46:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5Q1KpdP6OCvx1/5FtAsvHU1/zmTZUzysznHbE/z1Jme/k13ntnepilRz+F4kKk+owUHbW
X-Received: by 2002:a50:e609:: with SMTP id y9mr4043470edm.81.1554389213390;
        Thu, 04 Apr 2019 07:46:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554389213; cv=none;
        d=google.com; s=arc-20160816;
        b=u6Rm//oO9mu5lwSgPB6IiU0wo/Cj026FR6t4OlCJawJewSqrrHxWMOjSt6I4zsV3GZ
         RJpGUPHdoqJ/wXAK6hBqBS6kNHGa7Lnfks6sQtBTtbEVWWNH1B9/+0zB6Uoy9O8OQ8Zd
         GmxSrUkJQePFFQj9h9gqZUHBda26jioduKhuJSjh9yh6OcJaseSrM0XY4LlnoqpzoXAN
         Emw2HeSVPXqRk1mOAvKupXpuq8y2DRacj5SLCMy+UgGdggtozoLKePpf44Xjd7MnYM6H
         Xu1FFfBo/9tNSGSsR88023YkkMRuzVuHDZDdLSuQ2RsLMv1t6f6ORYj1bp0gmCyvo4XS
         D4EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=by+qc73PFufYAJcEzQJv2SX/8Vxa3BKPss43cTpMvFU=;
        b=Cj3n89XXTHoEE8l5x36z2rJ8ujcZH9dKJ2px/sqoComB4Cx0Iu/IQRdUNktYjw9zGP
         zbc63dOZPuRbmdcj22aqOsbUc59C1bRVceJTa7qs0FgH4A1L4nZQ7+kXdaOwRKk/OHJM
         hmlnzS4z4D0d1kLU2FegTHydNeEmsSdQ+iT0sIAdVz2wm6nT68b+rZnB4+5qyGGgUu9j
         U6CJ+U41nsI9lUICc8250s+Lbdd5TmI4aN+/pti3u5j8lrM2b5jVO9STIkf+bTCQLN57
         uqsuJEEv7g0hxcdeqwI3BCE9qs3jOAjlJnSpRO1Yjii20NqqQpu4/6FtrrxlpNOzRkpf
         rsSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q2si5552311edn.429.2019.04.04.07.46.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 07:46:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x34EjH7e106967
	for <linux-mm@kvack.org>; Thu, 4 Apr 2019 10:46:52 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rnjrevk9n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Apr 2019 10:46:47 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 4 Apr 2019 15:46:28 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 4 Apr 2019 15:46:24 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x34EkNON60031206
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 4 Apr 2019 14:46:23 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2BDEAA405B;
	Thu,  4 Apr 2019 14:46:23 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B260BA4060;
	Thu,  4 Apr 2019 14:46:21 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.215])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  4 Apr 2019 14:46:21 +0000 (GMT)
Date: Thu, 4 Apr 2019 17:46:19 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Chen Zhou <chenzhou10@huawei.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org,
        ard.biesheuvel@linaro.org, takahiro.akashi@linaro.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        kexec@lists.infradead.org, linux-mm@kvack.org,
        wangkefeng.wang@huawei.com
Subject: Re: [PATCH 1/3] arm64: kdump: support reserving crashkernel above 4G
References: <20190403030546.23718-1-chenzhou10@huawei.com>
 <20190403030546.23718-2-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403030546.23718-2-chenzhou10@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19040414-0012-0000-0000-0000030B47C8
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19040414-0013-0000-0000-000021435741
Message-Id: <20190404144618.GB6433@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-04_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904040095
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 03, 2019 at 11:05:44AM +0800, Chen Zhou wrote:
> When crashkernel is reserved above 4G in memory, kernel should
> reserve some amount of low memory for swiotlb and some DMA buffers.
> 
> Kernel would try to allocate at least 256M below 4G automatically
> as x86_64 if crashkernel is above 4G. Meanwhile, support
> crashkernel=X,[high,low] in arm64.
> 
> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
> ---
>  arch/arm64/kernel/setup.c |  3 ++
>  arch/arm64/mm/init.c      | 71 +++++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 71 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
> index 413d566..82cd9a0 100644
> --- a/arch/arm64/kernel/setup.c
> +++ b/arch/arm64/kernel/setup.c
> @@ -243,6 +243,9 @@ static void __init request_standard_resources(void)
>  			request_resource(res, &kernel_data);
>  #ifdef CONFIG_KEXEC_CORE
>  		/* Userspace will find "Crash kernel" region in /proc/iomem. */
> +		if (crashk_low_res.end && crashk_low_res.start >= res->start &&
> +		    crashk_low_res.end <= res->end)
> +			request_resource(res, &crashk_low_res);
>  		if (crashk_res.end && crashk_res.start >= res->start &&
>  		    crashk_res.end <= res->end)
>  			request_resource(res, &crashk_res);
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 6bc1350..ceb2a25 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -64,6 +64,57 @@ EXPORT_SYMBOL(memstart_addr);
>  phys_addr_t arm64_dma_phys_limit __ro_after_init;
>  
>  #ifdef CONFIG_KEXEC_CORE
> +static int __init reserve_crashkernel_low(void)
> +{
> +	unsigned long long base, low_base = 0, low_size = 0;
> +	unsigned long total_low_mem;
> +	int ret;
> +
> +	total_low_mem = memblock_mem_size(1UL << (32 - PAGE_SHIFT));
> +
> +	/* crashkernel=Y,low */
> +	ret = parse_crashkernel_low(boot_command_line, total_low_mem, &low_size, &base);
> +	if (ret) {
> +		/*
> +		 * two parts from lib/swiotlb.c:
> +		 * -swiotlb size: user-specified with swiotlb= or default.
> +		 *
> +		 * -swiotlb overflow buffer: now hardcoded to 32k. We round it
> +		 * to 8M for other buffers that may need to stay low too. Also
> +		 * make sure we allocate enough extra low memory so that we
> +		 * don't run out of DMA buffers for 32-bit devices.
> +		 */
> +		low_size = max(swiotlb_size_or_default() + (8UL << 20), 256UL << 20);
> +	} else {
> +		/* passed with crashkernel=0,low ? */
> +		if (!low_size)
> +			return 0;
> +	}
> +
> +	low_base = memblock_find_in_range(0, 1ULL << 32, low_size, SZ_2M);
> +	if (!low_base) {
> +		pr_err("Cannot reserve %ldMB crashkernel low memory, please try smaller size.\n",
> +				(unsigned long)(low_size >> 20));
> +		return -ENOMEM;
> +	}
> +
> +	ret = memblock_reserve(low_base, low_size);
> +	if (ret) {
> +		pr_err("%s: Error reserving crashkernel low memblock.\n", __func__);
> +		return ret;
> +	}
> +
> +	pr_info("Reserving %ldMB of low memory at %ldMB for crashkernel (System RAM: %ldMB)\n",
> +			(unsigned long)(low_size >> 20),
> +			(unsigned long)(low_base >> 20),
> +			(unsigned long)(total_low_mem >> 20));
> +
> +	crashk_low_res.start = low_base;
> +	crashk_low_res.end   = low_base + low_size - 1;
> +
> +	return 0;
> +}
> +
>  /*
>   * reserve_crashkernel() - reserves memory for crash kernel
>   *
> @@ -74,19 +125,28 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
>  static void __init reserve_crashkernel(void)
>  {
>  	unsigned long long crash_base, crash_size;
> +	bool high = false;
>  	int ret;
>  
>  	ret = parse_crashkernel(boot_command_line, memblock_phys_mem_size(),
>  				&crash_size, &crash_base);
>  	/* no crashkernel= or invalid value specified */
> -	if (ret || !crash_size)
> -		return;
> +	if (ret || !crash_size) {
> +		/* crashkernel=X,high */
> +		ret = parse_crashkernel_high(boot_command_line, memblock_phys_mem_size(),
> +				&crash_size, &crash_base);
> +		if (ret || !crash_size)
> +			return;
> +		high = true;
> +	}
>  
>  	crash_size = PAGE_ALIGN(crash_size);
>  
>  	if (crash_base == 0) {
>  		/* Current arm64 boot protocol requires 2MB alignment */
> -		crash_base = memblock_find_in_range(0, ARCH_LOW_ADDRESS_LIMIT,
> +		crash_base = memblock_find_in_range(0,
> +				high ? memblock_end_of_DRAM()
> +				: ARCH_LOW_ADDRESS_LIMIT,
>  				crash_size, SZ_2M);
>  		if (crash_base == 0) {
>  			pr_warn("cannot allocate crashkernel (size:0x%llx)\n",
> @@ -112,6 +172,11 @@ static void __init reserve_crashkernel(void)
>  	}
>  	memblock_reserve(crash_base, crash_size);
>  
> +	if (crash_base >= SZ_4G && reserve_crashkernel_low()) {
> +		memblock_free(crash_base, crash_size);
> +		return;
> +	}
> +

This very reminds what x86 does. Any chance some of the code can be reused
rather than duplicated?

>  	pr_info("crashkernel reserved: 0x%016llx - 0x%016llx (%lld MB)\n",
>  		crash_base, crash_base + crash_size, crash_size >> 20);
>  
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

