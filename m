Return-Path: <SRS0=nlaJ=SI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A87BC10F06
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 13:03:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AB25213A2
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 13:03:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AB25213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E1096B000E; Sat,  6 Apr 2019 09:03:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 890FA6B0266; Sat,  6 Apr 2019 09:03:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75A706B0269; Sat,  6 Apr 2019 09:03:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 523106B000E
	for <linux-mm@kvack.org>; Sat,  6 Apr 2019 09:03:07 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id s65so5928805ywf.10
        for <linux-mm@kvack.org>; Sat, 06 Apr 2019 06:03:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=NLxWdZJtAr+sYCLF6uvhFplWN6cIh4BELsLF+iNWCw8=;
        b=J5KTBkp96Rm1DbL4luKKRiQ8wIE/6bktRs57ujkOHJ/DSn23mk98VYPvoE8BlbJP3L
         pvvmdKECKBxjWv3HJOFkyZ5XE0QR/v22//M2JXQ90SQT+82bczECi+GtisGbGkGulLT5
         aR9VDI3hyV9fKKP6SpNDR59YXLtEW2g2uwdJruQLuB3k+umSc5uYGJLclj3+aJTcSgcq
         b1n2TdgMpSjj6RwM9qricB8hirgmjwfamIe4mHh33SviIgg4WXgC9cqAlP/FoZWxS9yP
         NpYu3Oya/Z7dM2kYEiI5irNoFHTH3Xuo24eDa4L8Inf7wFofikSPGPpxv6ks9LPDcR+D
         JXNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVG6UOkB+pVePsQILpkPAhIOUs2Z0LJ7hbrGmZyplnxz4geannf
	SSSQDJ4r5HueKJVoLR0IjdJ9egUhs2wBYqmNocp8X0pVew2ddONrPXFr2nKHJvOCA9Dsy4C5hvb
	CqUKgOSAUF6WJXtItn9BodbmzYe/sdB7VannISr0Ri3MPFpKPHxNsxWoBcYxMh6qtnA==
X-Received: by 2002:a25:6994:: with SMTP id e142mr4674144ybc.318.1554555787015;
        Sat, 06 Apr 2019 06:03:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWM3Nz+51f2aPU85FmgBbfLLuHmsTpF9Zxg/SDdGD3SfHLS86l3QVnzhqFBvkFLOuNCCB1
X-Received: by 2002:a25:6994:: with SMTP id e142mr4674043ybc.318.1554555785894;
        Sat, 06 Apr 2019 06:03:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554555785; cv=none;
        d=google.com; s=arc-20160816;
        b=GtHN/tuAt+gATqw5+MZEoOh7z0ciSVZWYUeyA6hdt8k4HtsrfGOQEhBTqu26CIdsZG
         DkNb5zmeA7X3aM5ZSpKcxkTIPYb6k9DlAzMsT3q7Adcf5KdLVEU6droIZwxQGw7eaL7C
         D1WRTNbsErCZ0QZag1K5wYUfmWNayuSQCgA43nA6ZzGcyM4J2/dNAJ2l12udNYTN0hO1
         rjtDVEQMedBUv45t+wKoSBHUEuSu+BJPrZGuNPSy2nmzCLJXxDEUWfbHp1nzA7MMnTZU
         y6gqjp5cKdUAFSHp48K+5PThvLfqONh88I6Ee6BBr40Tz00v7UdKvmQXWbsqHkOxpazz
         tRMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=NLxWdZJtAr+sYCLF6uvhFplWN6cIh4BELsLF+iNWCw8=;
        b=vtBDRvciUVncQpTFNCwSfKmom6Z7Lxd3b80OJkghIQpwiy1Z90q5u8ugblrpZfRKgp
         LoSg8jlzj2bJW6A4zvTqyPRbVllGtSKC3gbOIDHQXoIG4BeOyS6DahFJfCh3Z/YIs6+T
         zn8FwHSlrY0x/m8ULNatpkEPUBqK8fIAi9R+xqYkC0scK/JIkug5c3tE4uautmvhWOE6
         pO4nnUiEvwWigl0kf/oRLPhg/eJTNp5yDP95Msrjj8d5axu0RE7/9Y4Vr4Lt2IX91xHm
         ekSamA7K2y2VjnEpC7+GH1MemykJd00GowT34fCzdsaSx7wBvEcKP8bUSU70lPNXT5bz
         PgqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s7si15372173ybg.310.2019.04.06.06.03.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Apr 2019 06:03:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x36Crotf007688
	for <linux-mm@kvack.org>; Sat, 6 Apr 2019 09:03:04 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rpr98guay-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 06 Apr 2019 09:03:04 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sat, 6 Apr 2019 14:03:01 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sat, 6 Apr 2019 14:02:55 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x36D2s7759900032
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 6 Apr 2019 13:02:54 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 823FAA405C;
	Sat,  6 Apr 2019 13:02:54 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9411BA4054;
	Sat,  6 Apr 2019 13:02:52 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.206.46])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sat,  6 Apr 2019 13:02:52 +0000 (GMT)
Date: Sat, 6 Apr 2019 16:02:50 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org,
        pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com,
        linux-nvdimm@lists.01.org, alexander.h.duyck@linux.intel.com,
        linux-kernel@vger.kernel.org, willy@infradead.org, mingo@kernel.org,
        yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com,
        rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org,
        dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com,
        mgorman@techsingularity.net, davem@davemloft.net,
        kirill.shutemov@linux.intel.com
Subject: Re: [mm PATCH v7 3/4] mm: Implement new zone specific memblock
 iterator
References: <20190405221043.12227.19679.stgit@localhost.localdomain>
 <20190405221225.12227.22573.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190405221225.12227.22573.stgit@localhost.localdomain>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19040613-4275-0000-0000-00000324EFAB
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19040613-4276-0000-0000-000038340213
Message-Id: <20190406130249.GA5470@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-06_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904060079
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 05, 2019 at 03:12:25PM -0700, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Introduce a new iterator for_each_free_mem_pfn_range_in_zone.
> 
> This iterator will take care of making sure a given memory range provided
> is in fact contained within a zone. It takes are of all the bounds checking
> we were doing in deferred_grow_zone, and deferred_init_memmap. In addition
> it should help to speed up the search a bit by iterating until the end of a
> range is greater than the start of the zone pfn range, and will exit
> completely if the start is beyond the end of the zone.
> 
> Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  include/linux/memblock.h |   25 ++++++++++++++++++
>  mm/memblock.c            |   64 ++++++++++++++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c          |   31 +++++++++-------------
>  3 files changed, 101 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 294d5d80e150..f8b78892b977 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -240,6 +240,31 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
>  	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
> 
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +void __next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
> +				  unsigned long *out_spfn,
> +				  unsigned long *out_epfn);
> +/**
> + * for_each_free_mem_range_in_zone - iterate through zone specific free
> + * memblock areas
> + * @i: u64 used as loop variable
> + * @zone: zone in which all of the memory blocks reside
> + * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
> + * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
> + *
> + * Walks over free (memory && !reserved) areas of memblock in a specific
> + * zone. Available once memblock and an empty zone is initialized. The main
> + * assumption is that the zone start, end, and pgdat have been associated.
> + * This way we can use the zone to determine NUMA node, and if a given part
> + * of the memblock is valid for the zone.
> + */
> +#define for_each_free_mem_pfn_range_in_zone(i, zone, p_start, p_end)	\
> +	for (i = 0,							\
> +	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end);	\
> +	     i != U64_MAX;					\
> +	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end))
> +#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
> +
>  /**
>   * for_each_free_mem_range - iterate through free memblock areas
>   * @i: u64 used as loop variable
> diff --git a/mm/memblock.c b/mm/memblock.c
> index e7665cf914b1..28fa8926d9f8 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1255,6 +1255,70 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>  	return 0;
>  }
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +/**
> + * __next_mem_pfn_range_in_zone - iterator for for_each_*_range_in_zone()
> + *
> + * @idx: pointer to u64 loop variable
> + * @zone: zone in which all of the memory blocks reside
> + * @out_spfn: ptr to ulong for start pfn of the range, can be %NULL
> + * @out_epfn: ptr to ulong for end pfn of the range, can be %NULL
> + *
> + * This function is meant to be a zone/pfn specific wrapper for the
> + * for_each_mem_range type iterators. Specifically they are used in the
> + * deferred memory init routines and as such we were duplicating much of
> + * this logic throughout the code. So instead of having it in multiple
> + * locations it seemed like it would make more sense to centralize this to
> + * one new iterator that does everything they need.
> + */
> +void __init_memblock
> +__next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
> +			     unsigned long *out_spfn, unsigned long *out_epfn)
> +{
> +	int zone_nid = zone_to_nid(zone);
> +	phys_addr_t spa, epa;
> +	int nid;
> +
> +	__next_mem_range(idx, zone_nid, MEMBLOCK_NONE,
> +			 &memblock.memory, &memblock.reserved,
> +			 &spa, &epa, &nid);
> +
> +	while (*idx != U64_MAX) {
> +		unsigned long epfn = PFN_DOWN(epa);
> +		unsigned long spfn = PFN_UP(spa);
> +
> +		/*
> +		 * Verify the end is at least past the start of the zone and
> +		 * that we have at least one PFN to initialize.
> +		 */
> +		if (zone->zone_start_pfn < epfn && spfn < epfn) {
> +			/* if we went too far just stop searching */
> +			if (zone_end_pfn(zone) <= spfn) {
> +				*idx = U64_MAX;
> +				break;
> +			}
> +
> +			if (out_spfn)
> +				*out_spfn = max(zone->zone_start_pfn, spfn);
> +			if (out_epfn)
> +				*out_epfn = min(zone_end_pfn(zone), epfn);
> +
> +			return;
> +		}
> +
> +		__next_mem_range(idx, zone_nid, MEMBLOCK_NONE,
> +				 &memblock.memory, &memblock.reserved,
> +				 &spa, &epa, &nid);
> +	}
> +
> +	/* signal end of iteration */
> +	if (out_spfn)
> +		*out_spfn = ULONG_MAX;
> +	if (out_epfn)
> +		*out_epfn = 0;
> +}
> +
> +#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
> 
>  /**
>   * memblock_alloc_range_nid - allocate boot memory block
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2d2bca9803d2..61467e28c966 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1613,11 +1613,9 @@ static unsigned long  __init deferred_init_pages(struct zone *zone,
>  static int __init deferred_init_memmap(void *data)
>  {
>  	pg_data_t *pgdat = data;
> -	int nid = pgdat->node_id;
>  	unsigned long start = jiffies;
>  	unsigned long nr_pages = 0;
>  	unsigned long spfn, epfn, first_init_pfn, flags;
> -	phys_addr_t spa, epa;
>  	int zid;
>  	struct zone *zone;
>  	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
> @@ -1654,14 +1652,12 @@ static int __init deferred_init_memmap(void *data)
>  	 * freeing pages we can access pages that are ahead (computing buddy
>  	 * page in __free_one_page()).
>  	 */
> -	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
> -		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
> -		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
> +	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
> +		spfn = max_t(unsigned long, first_init_pfn, spfn);
>  		nr_pages += deferred_init_pages(zone, spfn, epfn);
>  	}
> -	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
> -		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
> -		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
> +	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
> +		spfn = max_t(unsigned long, first_init_pfn, spfn);
>  		deferred_free_pages(spfn, epfn);
>  	}
>  	pgdat_resize_unlock(pgdat, &flags);
> @@ -1669,8 +1665,8 @@ static int __init deferred_init_memmap(void *data)
>  	/* Sanity check that the next zone really is unpopulated */
>  	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
> 
> -	pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
> -					jiffies_to_msecs(jiffies - start));
> +	pr_info("node %d initialised, %lu pages in %ums\n",
> +		pgdat->node_id,	nr_pages, jiffies_to_msecs(jiffies - start));
> 
>  	pgdat_init_report_one_done();
>  	return 0;
> @@ -1694,13 +1690,11 @@ static int __init deferred_init_memmap(void *data)
>  static noinline bool __init
>  deferred_grow_zone(struct zone *zone, unsigned int order)
>  {
> -	int nid = zone_to_nid(zone);
> -	pg_data_t *pgdat = NODE_DATA(nid);
>  	unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
> +	pg_data_t *pgdat = zone->zone_pgdat;
>  	unsigned long nr_pages = 0;
>  	unsigned long first_init_pfn, spfn, epfn, t, flags;
>  	unsigned long first_deferred_pfn = pgdat->first_deferred_pfn;
> -	phys_addr_t spa, epa;
>  	u64 i;
> 
>  	/* Only the last zone may have deferred pages */
> @@ -1736,9 +1730,8 @@ static int __init deferred_init_memmap(void *data)
>  		return false;
>  	}
> 
> -	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
> -		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
> -		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
> +	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
> +		spfn = max_t(unsigned long, first_init_pfn, spfn);
> 
>  		while (spfn < epfn && nr_pages < nr_pages_needed) {
>  			t = ALIGN(spfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
> @@ -1752,9 +1745,9 @@ static int __init deferred_init_memmap(void *data)
>  			break;
>  	}
> 
> -	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
> -		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
> -		epfn = min_t(unsigned long, first_deferred_pfn, PFN_DOWN(epa));
> +	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
> +		spfn = max_t(unsigned long, first_init_pfn, spfn);
> +		epfn = min_t(unsigned long, first_deferred_pfn, epfn);
>  		deferred_free_pages(spfn, epfn);
> 
>  		if (first_deferred_pfn == epfn)
> 

-- 
Sincerely yours,
Mike.

