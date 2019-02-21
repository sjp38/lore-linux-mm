Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 546DFC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 09:08:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D5A22086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 09:08:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D5A22086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 984128E0067; Thu, 21 Feb 2019 04:08:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 933908E0002; Thu, 21 Feb 2019 04:08:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FAEA8E0067; Thu, 21 Feb 2019 04:08:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FF4F8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 04:08:02 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id s8so11536196qth.18
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 01:08:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=m5u9A8ghRuS228Hywlqaerk+ira0HfmP2NU+LeoBgfU=;
        b=tqj/2Z6WYLd2j0k2B0Pl2DiDj/osoqPICCi0VmmJPehgG/y3A0tuOCIqpo1fj67qkN
         9FUCKjvxVe4ANI83aGRL/Ysd7UMS5V0CMZFAmOrRnyIPrCtibcxqOuk6Qh93fOKHQZLN
         QvKRtFeS5PfR4e4w+ur3L3veMukg92czfXLjjhVQOkKCi1XrQEfkgGEJyrHFxtQY37VH
         clvufoULMQdOqNjxOCAX6LRyVq/VfE8lwHIEH1orzd44OK7VJbC2WxW9RB/SfFKbGCRX
         6edWVcXCycoqXHVZSOxnsfbAVQiXATBbxiiQLNa/91F23hDwJmTIIor1UXLHPMwWfBfZ
         SubA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZ9vQBm/ZOD4nvMu5k5sk6KobcLsQRD+iZT2lUYWEQS5kR4PSwE
	U/77afLAn40sLCKdPokTGTAvwdiXraRwSFaicJ0mSiT0duNCptKKQGFEVISRVWtw+FP0kjUF0xz
	Tps/ytg9p3LzA0vzwlCkX3X0wwudU5BK9BJGVPNavxdGvvD1qhFVdAFowCVkBWqM95A==
X-Received: by 2002:a37:96c4:: with SMTP id y187mr26842914qkd.149.1550740082046;
        Thu, 21 Feb 2019 01:08:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbfAdP37ZWjOr75PMqZ5aabBap7wQ/DC6HTjYATVAM+QfSs/47yKjaPY4gtjap+ecUIigWQ
X-Received: by 2002:a37:96c4:: with SMTP id y187mr26842889qkd.149.1550740081385;
        Thu, 21 Feb 2019 01:08:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550740081; cv=none;
        d=google.com; s=arc-20160816;
        b=PzRmPdN7aqEy6Z46xPqsxhbxnaIcRYlbriSf+EjmA/w90aPKipVmlRefeigPfR4JBM
         X85kUXvLsE1X0Oha5sVE/+1Wd4HhXdxpbwcYpUtkicABGhuftRO2iv5OUItPOjbS41Pb
         tqbyHFNzGExnkTFUeFt+QxGhiBnxa2vqmmi6gqZ8Ua7cVuDoi5ha7Mmx0UJY2kOakW18
         jjFf7WoWb4/itDTd3M2d+RtY6QLhQAwNgkSJU2Wx6L6XbsTy5mt6ug25SDZCrin8BaCY
         fOWalv4VWvIQza0XQY9RGBu8P4kpv+kHI+KhBmf/unD3+rAwBqfrAh2Q9jH5IPOtB0Fr
         z3fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=m5u9A8ghRuS228Hywlqaerk+ira0HfmP2NU+LeoBgfU=;
        b=bDJAvBeOqREnyAbD7P5t5C+sZ7/vjhexwp4F7+KCRiU70RG3VS95BOd5tM1ihCGJHd
         EIstnJ+yYEX8PBownjWCx8HEuFPeZzNMtkd7scRgIC6lpOa2uyvx77feRNDy9DYEulvj
         +k/4OoY9pWKcjpmaLGlnG9J+Ox80CcYi3wKMxupAIPsJv1jhNsZSwCPtoQ6zZVGXf805
         UkvyfuY2EjxkvLTvWlX68VazFHmuFuuQE+MrHdDJ6n+QPg0NeaTDiCSlHRTKjTwxWlPG
         J3zWBgmeqfJingsmH+rL/sSzOG6smGk/7JmrIpOpjm5wFjDz/TcNyHTYFsosqUgHhx0N
         Dj9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e5si4557696qkd.22.2019.02.21.01.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 01:08:01 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1L96Jfm108480
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 04:08:00 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qsqgv43t4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 04:08:00 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 21 Feb 2019 09:07:58 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 21 Feb 2019 09:07:56 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1L97tnk21823630
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 21 Feb 2019 09:07:55 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3CFD2AE051;
	Thu, 21 Feb 2019 09:07:55 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AC4DFAE045;
	Thu, 21 Feb 2019 09:07:54 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 21 Feb 2019 09:07:54 +0000 (GMT)
Date: Thu, 21 Feb 2019 11:07:53 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
        Helge Deller <deller@gmx.de>
Cc: Matthew Wilcox <willy@infradead.org>, linux-parisc@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] parisc: use memblock_alloc() instead of custom
 get_memblock()
References: <1549984572-10867-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1549984572-10867-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022109-0008-0000-0000-000002C31B7F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022109-0009-0000-0000-0000222F5556
Message-Id: <20190221090752.GA32004@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-21_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902210068
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Any comments on this?

On Tue, Feb 12, 2019 at 05:16:12PM +0200, Mike Rapoport wrote:
> The get_memblock() function implements custom bottom-up memblock allocator.
> Setting 'memblock_bottom_up = true' before any memblock allocation is done
> allows replacing get_memblock() calls with memblock_alloc().
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
> v2: fix allocation alignment
> 
>  arch/parisc/mm/init.c | 52 +++++++++++++++++++--------------------------------
>  1 file changed, 19 insertions(+), 33 deletions(-)
> 
> diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
> index 059187a..d0b1662 100644
> --- a/arch/parisc/mm/init.c
> +++ b/arch/parisc/mm/init.c
> @@ -79,36 +79,6 @@ static struct resource sysram_resources[MAX_PHYSMEM_RANGES] __read_mostly;
>  physmem_range_t pmem_ranges[MAX_PHYSMEM_RANGES] __read_mostly;
>  int npmem_ranges __read_mostly;
>  
> -/*
> - * get_memblock() allocates pages via memblock.
> - * We can't use memblock_find_in_range(0, KERNEL_INITIAL_SIZE) here since it
> - * doesn't allocate from bottom to top which is needed because we only created
> - * the initial mapping up to KERNEL_INITIAL_SIZE in the assembly bootup code.
> - */
> -static void * __init get_memblock(unsigned long size)
> -{
> -	static phys_addr_t search_addr __initdata;
> -	phys_addr_t phys;
> -
> -	if (!search_addr)
> -		search_addr = PAGE_ALIGN(__pa((unsigned long) &_end));
> -	search_addr = ALIGN(search_addr, size);
> -	while (!memblock_is_region_memory(search_addr, size) ||
> -		memblock_is_region_reserved(search_addr, size)) {
> -		search_addr += size;
> -	}
> -	phys = search_addr;
> -
> -	if (phys)
> -		memblock_reserve(phys, size);
> -	else
> -		panic("get_memblock() failed.\n");
> -
> -	memset(__va(phys), 0, size);
> -
> -	return __va(phys);
> -}
> -
>  #ifdef CONFIG_64BIT
>  #define MAX_MEM         (~0UL)
>  #else /* !CONFIG_64BIT */
> @@ -321,6 +291,13 @@ static void __init setup_bootmem(void)
>  			max_pfn = start_pfn + npages;
>  	}
>  
> +	/*
> +	 * We can't use memblock top-down allocations because we only
> +	 * created the initial mapping up to KERNEL_INITIAL_SIZE in
> +	 * the assembly bootup code.
> +	 */
> +	memblock_set_bottom_up(true);
> +
>  	/* IOMMU is always used to access "high mem" on those boxes
>  	 * that can support enough mem that a PCI device couldn't
>  	 * directly DMA to any physical addresses.
> @@ -442,7 +419,10 @@ static void __init map_pages(unsigned long start_vaddr,
>  		 */
>  
>  		if (!pmd) {
> -			pmd = (pmd_t *) get_memblock(PAGE_SIZE << PMD_ORDER);
> +			pmd = memblock_alloc(PAGE_SIZE << PMD_ORDER,
> +					     PAGE_SIZE << PMD_ORDER);
> +			if (!pmd)
> +				panic("pmd allocation failed.\n");
>  			pmd = (pmd_t *) __pa(pmd);
>  		}
>  
> @@ -461,7 +441,10 @@ static void __init map_pages(unsigned long start_vaddr,
>  
>  			pg_table = (pte_t *)pmd_address(*pmd);
>  			if (!pg_table) {
> -				pg_table = (pte_t *) get_memblock(PAGE_SIZE);
> +				pg_table = memblock_alloc(PAGE_SIZE,
> +							  PAGE_SIZE);
> +				if (!pg_table)
> +					panic("page table allocation failed\n");
>  				pg_table = (pte_t *) __pa(pg_table);
>  			}
>  
> @@ -700,7 +683,10 @@ static void __init pagetable_init(void)
>  	}
>  #endif
>  
> -	empty_zero_page = get_memblock(PAGE_SIZE);
> +	empty_zero_page = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
> +	if (!empty_zero_page)
> +		panic("zero page allocation failed.\n");
> +
>  }
>  
>  static void __init gateway_init(void)
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

