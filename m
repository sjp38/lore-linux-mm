Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 070FAC7618E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:34:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C01CF223D1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:34:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C01CF223D1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EC6C6B000A; Tue, 23 Jul 2019 04:34:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69DEC8E0003; Tue, 23 Jul 2019 04:34:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58D8A8E0002; Tue, 23 Jul 2019 04:34:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 246336B000A
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:34:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e25so25726294pfn.5
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:34:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=jvZLcPj1x13Zq3XLl0Lugu0KLBHWkAwrxGVpAhFMIXc=;
        b=CMp4MwxJqcoXXX/YBWI47/oY/+Ce1NI6L/5vIeqYcT+HUyI+XBYO53WfD3+6ADQMoj
         K/azdbhsu3P99HRXewAxSnZrQLQmuGrDHqVq1xwRCRIe3v/nBI6u9WfkhpVdvwiQX/Qd
         eKSdXQQqrjo6juZaxnDBimNJ2RN0bRtSGR8FBHbADjdGBGiQjvnZREq4GFaGpdTQ0R5f
         U+bl64MUkjftn2cnRz8zzFvalQonD20/RT5CpNKZe6GiXsdGssPCfeEPnRYztF871Rno
         XGc4WRRQg5LmBjSfU6/i4cG39oYBRg3nk4AzgtZx9+SvZUZBJNbl+onDDDLp8Qca01jF
         aE3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUegvotddMiA5OwEnMqEjTzPFiB6UCkM6COt+a9ZqsomGpgxLKy
	Sggw2DCPEtayeks+J5gnu7ZCScMYhUpsyLjEjL+LQtgvupWVOY3ar3I+tgOfOuw7upln1ojBubI
	39Ire366j0sQy9JJR4kT9CqQq/bYZEVDaOkKc0WbyZ+GowKiw12e5lbeeVaThJlv+DA==
X-Received: by 2002:a17:90a:b908:: with SMTP id p8mr81020758pjr.94.1563870848794;
        Tue, 23 Jul 2019 01:34:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQ8Vr2zx5kHDGBgZJzs4985JLvA+DH9S9hx32F1c5paUxL+EloveAaTVU9uxdDTce/eeWX
X-Received: by 2002:a17:90a:b908:: with SMTP id p8mr81020714pjr.94.1563870848099;
        Tue, 23 Jul 2019 01:34:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563870848; cv=none;
        d=google.com; s=arc-20160816;
        b=NrXWZq4IsxlquFuNe2WAR4t5qCnClH+ZdbcCmgbC+/BRQqdAzEuB4/q95UGYtonikH
         MqBtoimoV3qT3ty3/z7U2sx8SB7Bhbm9EQGYiSvwD6o25ihvXMn294ejC7ChXfGUVgVk
         1epe/qWG2ZmcRmqbSBUIhN0AUCA7fkMtx71WcWkTXItCVg+5eTintF1kQ++5i0laC7Lv
         84M+faEg9uik/0NrDfcR6cwZtquA2+E4BJHRM8RA+AtSNE+8IMAAM05bWjnaPvxT8cy2
         6fwgAwu5pDPXL9VpYmdS5AbfrhCU+rID+faIqXHh8YRN748bu0WneQV3rH4EPW6SXNwL
         na4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=jvZLcPj1x13Zq3XLl0Lugu0KLBHWkAwrxGVpAhFMIXc=;
        b=Glg7+VoqLoXrYCdb9DoHXZOCmTaMisIJkfZ70CS6rTp5DrKHtsoe2QfjReL4SGSDQt
         bGAUZyrq91eT0Vk1Vx1pFLVVHAjYn0Ytf1CYZAZ8m7bkbjP8JT34COGKcW1ng9z5025H
         e1JfaDkw/wt1pEnt7HDwwCvdt0HWaD8aNcWvhlJ8k8hert6QYzdS/OmCyZOWdfvh6NSF
         JjKRWSnYFGXVa/fdICYmAaMWkCf+ci7chTCz7xoJxii5fZsAHgKYMDoxRqwJamzIiD3T
         XXF6+I97KlaSqn9H+Hw0BZ1/SLxGr2ZJLrz6wxFY33JliwGPrGcwnquyL740WH7vRTNY
         9bIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g8si12320059pjp.57.2019.07.23.01.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 01:34:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6N8Xl3P129280
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:34:07 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2twxptrc1q-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:34:06 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 23 Jul 2019 09:34:01 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 23 Jul 2019 09:33:58 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6N8XveP43909290
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Jul 2019 08:33:57 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 01C1352051;
	Tue, 23 Jul 2019 08:33:57 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 47CAC5205F;
	Tue, 23 Jul 2019 08:33:56 +0000 (GMT)
Date: Tue, 23 Jul 2019 11:33:54 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Hanjun Guo <guohanjun@huawei.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Catalin Marinas <catalin.marinas@arm.com>, Jia He <hejianet@gmail.com>,
        Will Deacon <will@kernel.org>, linux-arm-kernel@lists.infradead.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v12 2/2] mm: page_alloc: reduce unnecessary binary search
 in memblock_next_valid_pfn
References: <1563861073-47071-1-git-send-email-guohanjun@huawei.com>
 <1563861073-47071-3-git-send-email-guohanjun@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563861073-47071-3-git-send-email-guohanjun@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19072308-0012-0000-0000-000003356235
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072308-0013-0000-0000-0000216EF17F
Message-Id: <20190723083353.GC4896@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=986 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907230079
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 01:51:13PM +0800, Hanjun Guo wrote:
> From: Jia He <hejianet@gmail.com>
> 
> After skipping some invalid pfns in memmap_init_zone(), there is still
> some room for improvement.
> 
> E.g. if pfn and pfn+1 are in the same memblock region, we can simply pfn++
> instead of doing the binary search in memblock_next_valid_pfn.
> 
> Furthermore, if the pfn is in a gap of two memory region, skip to next
> region directly to speedup the binary search.

How much speed up do you see with this improvements relatively to simple
binary search in memblock_next_valid_pfn()?
  
> Signed-off-by: Jia He <hejianet@gmail.com>
> Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
> ---
>  mm/memblock.c | 37 +++++++++++++++++++++++++++++++------
>  1 file changed, 31 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index d57ba51bb9cd..95d5916716a0 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1256,28 +1256,53 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>  unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
>  {
>  	struct memblock_type *type = &memblock.memory;
> +	struct memblock_region *regions = type->regions;
>  	unsigned int right = type->cnt;
>  	unsigned int mid, left = 0;
> +	unsigned long start_pfn, end_pfn, next_start_pfn;
>  	phys_addr_t addr = PFN_PHYS(++pfn);
> +	static int early_region_idx __initdata_memblock = -1;
>  
> +	/* fast path, return pfn+1 if next pfn is in the same region */
> +	if (early_region_idx != -1) {
> +		start_pfn = PFN_DOWN(regions[early_region_idx].base);
> +		end_pfn = PFN_DOWN(regions[early_region_idx].base +
> +				regions[early_region_idx].size);
> +
> +		if (pfn >= start_pfn && pfn < end_pfn)
> +			return pfn;
> +
> +		/* try slow path */
> +		if (++early_region_idx == type->cnt)
> +			goto slow_path;
> +
> +		next_start_pfn = PFN_DOWN(regions[early_region_idx].base);
> +
> +		if (pfn >= end_pfn && pfn <= next_start_pfn)
> +			return next_start_pfn;
> +	}
> +
> +slow_path:
> +	/* slow path, do the binary searching */
>  	do {
>  		mid = (right + left) / 2;
>  
> -		if (addr < type->regions[mid].base)
> +		if (addr < regions[mid].base)
>  			right = mid;
> -		else if (addr >= (type->regions[mid].base +
> -				  type->regions[mid].size))
> +		else if (addr >= (regions[mid].base + regions[mid].size))
>  			left = mid + 1;
>  		else {
> -			/* addr is within the region, so pfn is valid */
> +			early_region_idx = mid;
>  			return pfn;
>  		}
>  	} while (left < right);
>  
>  	if (right == type->cnt)
>  		return -1UL;
> -	else
> -		return PHYS_PFN(type->regions[right].base);
> +
> +	early_region_idx = right;
> +
> +	return PHYS_PFN(regions[early_region_idx].base);
>  }
>  EXPORT_SYMBOL(memblock_next_valid_pfn);
>  #endif /* CONFIG_HAVE_MEMBLOCK_PFN_VALID */
> -- 
> 2.19.1
> 

-- 
Sincerely yours,
Mike.

