Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B345C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:30:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21DDD223BE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:30:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21DDD223BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0DB06B000A; Tue, 23 Jul 2019 04:30:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABE158E0003; Tue, 23 Jul 2019 04:30:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ACD38E0002; Tue, 23 Jul 2019 04:30:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 60BD16B000A
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:30:41 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e25so25720178pfn.5
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:30:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=zjM74c4aGRHdnuW1w9XfbSgKdUC6aAzDJD/UYno8R9I=;
        b=d/CkA4PlB56nccz5NmwODU0kzVjE8D8KPWlA2YGYl4qk21f+J1BU/5q3CSEzwgGnSc
         2ylTFHFqoYEkk4aGszhZ2PHeeagccGBWYstgjtBrLayBrVzsBAOIi8BljM4f9PJn9io+
         +T0Bv/Q/LTe6J1znOk9xqmRGOkaKDQuJ8NOI5MPnqp9pR+avVG3IZK5voWdV2CO6S4S3
         UXFP7DNaDJm6KzTo93j5m14pgYp94FlPu7iT7Mvu1lt5XS0dYXXfgfmtEX2mjZfGa9D0
         QfIQzYAQWQzrVVNbNocX9vhIJbxZWqno3cNbTqE7aZpv1LhxSKhsIxEuS9id2XF+JcXc
         BTig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVKFlm4AEfrTKhYgoDYGYH3durVBc5aEYgAJ1TirrXp6XZnm8Ti
	cpBuyB+q0vQgIXCspYSpNZKkZYYSlkOOg5JGkjnOQg+UuNaS+TRt2ewUd6k1U+J5bfWRxB0qy6j
	6lbQyJDblho4pT9Af6FJOuguA90cFgpevxodaXF07o8V+OyP5S9eJyckVUgP2DVKoRw==
X-Received: by 2002:a63:7c0d:: with SMTP id x13mr35909104pgc.360.1563870640898;
        Tue, 23 Jul 2019 01:30:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIWispILPJesyLZ+jFY4oH+nE8L59mgDeV8sh00fGN7xLscXPp6GdqbdwqVAY3qjSf2y+Y
X-Received: by 2002:a63:7c0d:: with SMTP id x13mr35909023pgc.360.1563870639836;
        Tue, 23 Jul 2019 01:30:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563870639; cv=none;
        d=google.com; s=arc-20160816;
        b=pMxY+kQiPmOxt296xzTx6zBLgn0qRy1ZBb5LUG2SWxg/XMkDl4B3glyGTM4MXb98Fa
         LX7o7aZDmqdoeRgSvE79ZQXyvoyn6psi9IrNXBnK0a4hMJwQ0UsynNeEwLPWKZyXH2pS
         7g3YkMkh0W/3cw2HT5btnnDzUSW1WH3vjPXhYGlUl3Coi3IxebablLs6ZpQnoy1Q7NVu
         09U12yfz0XcFU7z1Zk6KW2ys2Obe07Ey2kun/9pd2tAtE7gB34RoPGLHLAIO3xMBkoWt
         vbMtlAJwHDVEjNtQJo/z9GZuWTKVQgxPedly9HuBv33bDmU9vFkXOAwmb7+rwmmoUWpq
         oY8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=zjM74c4aGRHdnuW1w9XfbSgKdUC6aAzDJD/UYno8R9I=;
        b=vFSSVUPADvRZqeEAbNOMtgjnRxAEB51ji0dkvKUMjfp2kYoyTwo1MGnqUk7FuBDD9P
         Kf0pDgRbMFH9wiionwXspKoHpfMCjFPPjxUytY9eP7nN1DvHmr6jLWoo2WpPlHj1hmkl
         zdlpCxaCRr5tsSpvHJb0rNtLMIQzgJ8WC0cGHb26Ze4c5wj9Vm/eLf5RFlzJMi2o2N5l
         ZEM1mv/y5ZIGsRoiKysTF273Js/Cgxgaq26CH9V1KtKNp15Y49Uo/S7rNkIuaZ5uapDM
         9ukam11OdgkXe/Y+ETwaBpouizqptLjgR8mvV5ZZ2GKYysoIO7wKWRgl/z+ILFsjMvC8
         pu0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m19si13589686pgb.523.2019.07.23.01.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 01:30:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6N8RRe4103016
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:30:39 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2twvngw5yb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:30:38 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 23 Jul 2019 09:30:36 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 23 Jul 2019 09:30:31 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6N8UU0F33292752
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Jul 2019 08:30:30 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C6D34A4057;
	Tue, 23 Jul 2019 08:30:30 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BE3A7A4040;
	Tue, 23 Jul 2019 08:30:29 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 23 Jul 2019 08:30:29 +0000 (GMT)
Date: Tue, 23 Jul 2019 11:30:27 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Hanjun Guo <guohanjun@huawei.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Catalin Marinas <catalin.marinas@arm.com>, Jia He <hejianet@gmail.com>,
        Will Deacon <will@kernel.org>, linux-arm-kernel@lists.infradead.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v12 1/2] mm: page_alloc: introduce
 memblock_next_valid_pfn() (again) for arm64
References: <1563861073-47071-1-git-send-email-guohanjun@huawei.com>
 <1563861073-47071-2-git-send-email-guohanjun@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563861073-47071-2-git-send-email-guohanjun@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19072308-0008-0000-0000-000002FFFE8D
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072308-0009-0000-0000-0000226D8A71
Message-Id: <20190723083027.GB4896@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907230078
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 01:51:12PM +0800, Hanjun Guo wrote:
> From: Jia He <hejianet@gmail.com>
> 
> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> where possible") optimized the loop in memmap_init_zone(). But it causes
> possible panic on x86 due to specific memory mapping on x86_64 which will
> skip valid pfns as well, so Daniel Vacek reverted it later.
> 
> But as suggested by Daniel Vacek, it is fine to using memblock to skip
> gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.
> 
> Daniel said:
> "On arm and arm64, memblock is used by default. But generic version of
> pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
> not always return the next valid one but skips more resulting in some
> valid frames to be skipped (as if they were invalid). And that's why
> kernel was eventually crashing on some !arm machines."

I think that the crash on x86 was not related to CONFIG_HAVE_ARCH_PFN_VALID
but rather to the x86 way to setup memblock.  Some of the x86 reserved
memory areas were never added to memblock.memory, which makes memblock's
view of the physical memory incomplete and that's why
memblock_next_valid_pfn() could skip valid PFNs on x86.

> Introduce a new config option CONFIG_HAVE_MEMBLOCK_PFN_VALID and only
> selected for arm64, using the new config option to guard the
> memblock_next_valid_pfn().
 
As far as I can tell, the memblock_next_valid_pfn() should work on most
architectures and not only on ARM. For sure there is should be no
dependency between CONFIG_HAVE_ARCH_PFN_VALID and memblock_next_valid_pfn().

I believe that the configuration option to guard memblock_next_valid_pfn()
should be opt-out and that only x86 will require it.

> This was tested on a HiSilicon Kunpeng920 based ARM64 server, the speedup
> is pretty impressive for bootmem_init() at boot:
> 
> with 384G memory,
> before: 13310ms
> after:  1415ms
> 
> with 1T memory,
> before: 20s
> after:  2s
> 
> Suggested-by: Daniel Vacek <neelx@redhat.com>
> Signed-off-by: Jia He <hejianet@gmail.com>
> Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
> ---
>  arch/arm64/Kconfig     |  1 +
>  include/linux/mmzone.h |  9 +++++++++
>  mm/Kconfig             |  3 +++
>  mm/memblock.c          | 31 +++++++++++++++++++++++++++++++
>  mm/page_alloc.c        |  4 +++-
>  5 files changed, 47 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 697ea0510729..058eb26579be 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -893,6 +893,7 @@ config ARCH_FLATMEM_ENABLE
>  
>  config HAVE_ARCH_PFN_VALID
>  	def_bool y
> +	select HAVE_MEMBLOCK_PFN_VALID
>
>  config HW_PERF_EVENTS
>  	def_bool y
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 70394cabaf4e..24cb6bdb1759 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1325,6 +1325,10 @@ static inline int pfn_present(unsigned long pfn)
>  #endif
>  
>  #define early_pfn_valid(pfn)	pfn_valid(pfn)
> +#ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
> +extern unsigned long memblock_next_valid_pfn(unsigned long pfn);
> +#define next_valid_pfn(pfn)	memblock_next_valid_pfn(pfn)

Please make it 'static inline' and move out of '#ifdef CONFIG_SPARSEMEM'

> +#endif
>  void sparse_init(void);
>  #else
>  #define sparse_init()	do {} while (0)
> @@ -1347,6 +1351,11 @@ struct mminit_pfnnid_cache {
>  #define early_pfn_valid(pfn)	(1)
>  #endif
>  
> +/* fallback to default definitions */
> +#ifndef next_valid_pfn
> +#define next_valid_pfn(pfn)	(pfn + 1)

static inline as well.

> +#endif
> +
>  void memory_present(int nid, unsigned long start, unsigned long end);
>  
>  /*
> diff --git a/mm/Kconfig b/mm/Kconfig
> index f0c76ba47695..c578374b6413 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -132,6 +132,9 @@ config HAVE_MEMBLOCK_NODE_MAP
>  config HAVE_MEMBLOCK_PHYS_MAP
>  	bool
>  
> +config HAVE_MEMBLOCK_PFN_VALID
> +	bool
> +
>  config HAVE_GENERIC_GUP
>  	bool
>  
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7d4f61ae666a..d57ba51bb9cd 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1251,6 +1251,37 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>  	return 0;
>  }
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
> +
> +#ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
> +unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
> +{
> +	struct memblock_type *type = &memblock.memory;
> +	unsigned int right = type->cnt;
> +	unsigned int mid, left = 0;
> +	phys_addr_t addr = PFN_PHYS(++pfn);
> +
> +	do {
> +		mid = (right + left) / 2;
> +
> +		if (addr < type->regions[mid].base)
> +			right = mid;
> +		else if (addr >= (type->regions[mid].base +
> +				  type->regions[mid].size))
> +			left = mid + 1;
> +		else {
> +			/* addr is within the region, so pfn is valid */
> +			return pfn;
> +		}
> +	} while (left < right);
> +

We have memblock_search() for this.

> +	if (right == type->cnt)
> +		return -1UL;
> +	else
> +		return PHYS_PFN(type->regions[right].base);
> +}
> +EXPORT_SYMBOL(memblock_next_valid_pfn);
> +#endif /* CONFIG_HAVE_MEMBLOCK_PFN_VALID */
> +
>  #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>  /**
>   * __next_mem_pfn_range_in_zone - iterator for for_each_*_range_in_zone()
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d66bc8abe0af..70933c40380a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5811,8 +5811,10 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  		 * function.  They do not exist on hotplugged memory.
>  		 */
>  		if (context == MEMMAP_EARLY) {
> -			if (!early_pfn_valid(pfn))
> +			if (!early_pfn_valid(pfn)) {
> +				pfn = next_valid_pfn(pfn) - 1;
>  				continue;
> +			}
>  			if (!early_pfn_in_nid(pfn, nid))
>  				continue;
>  			if (overlap_memmap_init(zone, &pfn))
> -- 
> 2.19.1
> 

-- 
Sincerely yours,
Mike.

