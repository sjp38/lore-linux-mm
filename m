Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C642C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 11:59:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4501621852
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 11:59:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4501621852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D715E8E0003; Tue, 26 Feb 2019 06:58:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D21568E0001; Tue, 26 Feb 2019 06:58:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC2E08E0003; Tue, 26 Feb 2019 06:58:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD328E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:58:59 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id x134so10275693pfd.18
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:58:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=8DjPxbDx0/UpaVBElzkElXeOMCcBl75Zr/zeSSEP1pM=;
        b=er2f77k1xgBnWm+BMAjgYUY9D82musnxI+pX6u5duUw6Tk/Q7P2o7d57XEfRiJMar+
         aHofflTuhhY7Jq/QzE7qhQPYKvA4rEhFeqRjAgvB+TVU9DQPxCkGDb+5+J1QV8V3+DgX
         zfE95HVkcXRaf285Jnh6GeeIXarjh9oNKjASZBeUsv5B6+6XHJhyzR5uzvsJKvn+xHfI
         hVkQYu2+1+ittCW5KVMDNjH+vQKECBN45dlhLclb4JMRF8NfNDfEAgfKFHnOsJB/nvKu
         ++dMGlErTGFsg+fq5NuS3rK4NNEGjpTwPA1+AaF6Y5TcxVSOFgiYY7JwOmw0laPCFGBW
         AZKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZv+9CPA56eK/xzNikTZz9AYE9/dq319TTDMEfhQ0zBTQINRT7O
	yxXM8UlHJNxdLsDDmuwb50O41pZG80JoIMM3OPI54BrSin7KnJbK9eC1ZWRUDC61hcu7p0lTRVj
	bRnNORdX0PCCiCLoM3djvkZY/IzapboXJ1Pm23ZFww4bUzm91FpYmuxYQ98hGqd7lUg==
X-Received: by 2002:a65:6489:: with SMTP id e9mr24042552pgv.260.1551182339188;
        Tue, 26 Feb 2019 03:58:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZMHWWUIZ42KtnrMYDmJrXWVh+wFBDoGoGK+7/sPozYIiY2sA4Oznwqag3KCfyp4p99AxFX
X-Received: by 2002:a65:6489:: with SMTP id e9mr24042490pgv.260.1551182338202;
        Tue, 26 Feb 2019 03:58:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551182338; cv=none;
        d=google.com; s=arc-20160816;
        b=Hm+ROyX705sSNpxAlygS85I6ksqwvtM9k5cpY5g0PwNl+iYWomiqTmJv2XgqlskW6x
         rNMsGf3bLAv+iFV8BKduSYRua7tgWMayfR0Dts31s6LROaVAtQiNz1jdJcAtPWijW5wJ
         wG5E8Tp8NFc6VOObst3D+P3bfaVnJJ6F5sNf45uLOWL2Ioqb6tTF1xnzQwCHYuFnRw8p
         gTo238jkGXXF5vv9UDkLNMhUvFJb+0rsoYWPOOM5kl5e5nH6AYN+0aOrlelUgvW8uBCy
         rLsz52XZRBKGBfZ3vpEGz4TF6eA8vRCCvQMIxWv+iCHhYMMeiReohV9A03vTkeY3nViU
         dfdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=8DjPxbDx0/UpaVBElzkElXeOMCcBl75Zr/zeSSEP1pM=;
        b=Lrl9Ideq/0H3zIHLWOeT2qR+4L/md2yosZLj4yXJ6fjJLuzGWK9qsZ64hbQdLZSsHr
         e9k7c8LOmZHY7iVl+8VxLsTsrDGdJOn2ZTWhh5SShJpnnqgwS1jh9sqTzmYc1MXqOj50
         /l9xC986ERobwcgXegp9bkdUPw/m5YHN9TS9i9SKt0FDnQ3Feh+u3ZaXPmkJesrv9qIz
         VlxglTss5U7mzZQCVQ48ZiO08MV1/NRUma8kaYRHAL2jY7q1dfozG2Ny49mQFHn4T+bi
         MRvb+I111I36Z8RgUb69O+wpAQAMTbm9OEzjQ0a1mnBSzmuj6xmjUmghbmHRaQ+Z7Tpq
         MrzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b9si11622530plr.66.2019.02.26.03.58.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 03:58:58 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1QBsfBO095899
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:58:57 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qw3fr5s0r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:58:57 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 11:58:55 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 11:58:48 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1QBwlTR32505948
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 26 Feb 2019 11:58:47 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A8096A4055;
	Tue, 26 Feb 2019 11:58:47 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 24D46A404D;
	Tue, 26 Feb 2019 11:58:46 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Feb 2019 11:58:46 +0000 (GMT)
Date: Tue, 26 Feb 2019 13:58:44 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Vlastimil Babka <vbabka@suse.cz>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Andy Lutomirski <luto@kernel.org>, Andi Kleen <ak@linux.intel.com>,
        Petr Tesarik <ptesarik@suse.cz>, Michal Hocko <mhocko@suse.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Jonathan Corbet <corbet@lwn.net>, Nicholas Piggin <npiggin@gmail.com>,
        Daniel Vacek <neelx@redhat.com>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/6] mm/memblock: make full utilization of numa info
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
 <1551011649-30103-3-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551011649-30103-3-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022611-0016-0000-0000-0000025B0F93
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022611-0017-0000-0000-000032B57194
Message-Id: <20190226115844.GG11981@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260089
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 24, 2019 at 08:34:05PM +0800, Pingfan Liu wrote:
> There are numa machines with memory-less node. When allocating memory for
> the memory-less node, memblock allocator falls back to 'Node 0' without fully
> utilizing the nearest node. This hurts the performance, especially for per
> cpu section. Suppressing this defect by building the full node fall back
> info for memblock allocator, like what we have done for page allocator.

Is it really necessary to build full node fallback info for memblock and
then rebuild it again for the page allocator?

I think it should be possible to split parts of build_all_zonelists_init()
that do not touch per-cpu areas into a separate function and call that
function after topology detection. Then it would be possible to use
local_memory_node() when calling memblock.
 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> CC: Thomas Gleixner <tglx@linutronix.de>
> CC: Ingo Molnar <mingo@redhat.com>
> CC: Borislav Petkov <bp@alien8.de>
> CC: "H. Peter Anvin" <hpa@zytor.com>
> CC: Dave Hansen <dave.hansen@linux.intel.com>
> CC: Vlastimil Babka <vbabka@suse.cz>
> CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> CC: Andy Lutomirski <luto@kernel.org>
> CC: Andi Kleen <ak@linux.intel.com>
> CC: Petr Tesarik <ptesarik@suse.cz>
> CC: Michal Hocko <mhocko@suse.com>
> CC: Stephen Rothwell <sfr@canb.auug.org.au>
> CC: Jonathan Corbet <corbet@lwn.net>
> CC: Nicholas Piggin <npiggin@gmail.com>
> CC: Daniel Vacek <neelx@redhat.com>
> CC: linux-kernel@vger.kernel.org
> ---
>  include/linux/memblock.h |  3 +++
>  mm/memblock.c            | 68 ++++++++++++++++++++++++++++++++++++++++++++----
>  2 files changed, 66 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 64c41cf..ee999c5 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -342,6 +342,9 @@ void *memblock_alloc_try_nid_nopanic(phys_addr_t size, phys_addr_t align,
>  void *memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align,
>  			     phys_addr_t min_addr, phys_addr_t max_addr,
>  			     int nid);
> +extern int build_node_order(int *node_oder_array, int sz,
> +	int local_node, nodemask_t *used_mask);
> +void memblock_build_node_order(void);
> 
>  static inline void * __init memblock_alloc(phys_addr_t size,  phys_addr_t align)
>  {
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 022d4cb..cf78850 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1338,6 +1338,47 @@ phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t ali
>  	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
>  }
> 
> +static int **node_fallback __initdata;
> +
> +/*
> + * build_node_order() relies on cpumask_of_node(), hence arch should set up
> + * cpumask before calling this func.
> + */
> +void __init memblock_build_node_order(void)
> +{
> +	int nid, i;
> +	nodemask_t used_mask;
> +
> +	node_fallback = memblock_alloc(MAX_NUMNODES * sizeof(int *),
> +		sizeof(int *));
> +	for_each_online_node(nid) {
> +		node_fallback[nid] = memblock_alloc(
> +			num_online_nodes() * sizeof(int), sizeof(int));
> +		for (i = 0; i < num_online_nodes(); i++)
> +			node_fallback[nid][i] = NUMA_NO_NODE;
> +	}
> +
> +	for_each_online_node(nid) {
> +		nodes_clear(used_mask);
> +		node_set(nid, used_mask);
> +		build_node_order(node_fallback[nid], num_online_nodes(),
> +			nid, &used_mask);
> +	}
> +}
> +
> +static void __init memblock_free_node_order(void)
> +{
> +	int nid;
> +
> +	if (!node_fallback)
> +		return;
> +	for_each_online_node(nid)
> +		memblock_free(__pa(node_fallback[nid]),
> +			num_online_nodes() * sizeof(int));
> +	memblock_free(__pa(node_fallback), MAX_NUMNODES * sizeof(int *));
> +	node_fallback = NULL;
> +}
> +
>  /**
>   * memblock_alloc_internal - allocate boot memory block
>   * @size: size of memory block to be allocated in bytes
> @@ -1370,6 +1411,7 @@ static void * __init memblock_alloc_internal(
>  {
>  	phys_addr_t alloc;
>  	void *ptr;
> +	int node;
>  	enum memblock_flags flags = choose_memblock_flags();
> 
>  	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
> @@ -1397,11 +1439,26 @@ static void * __init memblock_alloc_internal(
>  		goto done;
> 
>  	if (nid != NUMA_NO_NODE) {
> -		alloc = memblock_find_in_range_node(size, align, min_addr,
> -						    max_addr, NUMA_NO_NODE,
> -						    flags);
> -		if (alloc && !memblock_reserve(alloc, size))
> -			goto done;
> +		if (!node_fallback) {
> +			alloc = memblock_find_in_range_node(size, align,
> +					min_addr, max_addr,
> +					NUMA_NO_NODE, flags);
> +			if (alloc && !memblock_reserve(alloc, size))
> +				goto done;
> +		} else {
> +			int i;
> +			for (i = 0; i < num_online_nodes(); i++) {
> +				node = node_fallback[nid][i];
> +				/* fallback list has all memory nodes */
> +				if (node == NUMA_NO_NODE)
> +					break;
> +				alloc = memblock_find_in_range_node(size,
> +						align, min_addr, max_addr,
> +						node, flags);
> +				if (alloc && !memblock_reserve(alloc, size))
> +					goto done;
> +			}
> +		}
>  	}
> 
>  	if (min_addr) {
> @@ -1969,6 +2026,7 @@ unsigned long __init memblock_free_all(void)
> 
>  	reset_all_zones_managed_pages();
> 
> +	memblock_free_node_order();
>  	pages = free_low_memory_core_early();
>  	totalram_pages_add(pages);
> 
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

