Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26E08C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 12:57:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0CB62067D
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 12:57:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0CB62067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D4BB6B0007; Fri, 26 Apr 2019 08:57:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75BFC6B0008; Fri, 26 Apr 2019 08:57:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FF586B000A; Fri, 26 Apr 2019 08:57:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0BD6B0007
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 08:57:48 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 18so1500867eds.5
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 05:57:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mwVF5MbOjOAoXZNvN0KeADNRVdw01NC901P/StXJpkY=;
        b=hkMyYopbWS+rrcuJV778zpjGSd/Ur6xoEDEb/rpkw0wKFRnHbtwTOvgJue6qJLn64k
         LyALKQpT8rTDkXVm13DVvxS+ucOtQYwgFUP6xvQaxSOHmAeFTr6gIyP3HYDUzjhYk7PS
         mbTmoy9bkb9NqJ3aFKnHWShwyy2cUftcMqj5+Idmy36t1eqi6arigElyFmJacASUIi4w
         dnH22oldpjqrKSbC1dzmCjIVcDGchrTvT8ZjobcQA9M3MO3ewe3p49JNzrVdKvElUXRQ
         Qj6LGA6eVBxC8YY98rBfdeOXBYxSh/C0Odi4C06H2Z7nYnD5y7tTxNM95Ezo39LZYAzH
         MeTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWQImpmTUEIJz8wv2xn+R22flJbiiAPlz7DCrJ7HHR+eeVGjuSr
	EtUxu/P1WEfCpNEVm6KRJ31bC2N8P8spHBYLhju1QsHi5XRJ6kGrnk3p1CJ+YvkcuD9eVu64+7m
	fqvGXRprqe41wJ5Rzbb9B+R7kXRLRLLoij7ia7Ab+Ywmw2cqZsKEG4LaXgpudbi9s5A==
X-Received: by 2002:a17:906:4d85:: with SMTP id s5mr22756982eju.18.1556283467514;
        Fri, 26 Apr 2019 05:57:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvzmrUD2Q8FmLWuBTAjj9KUG7ahXxSuZSKtki9jT3A9Fy+gFGHBL0DVtwgBF4u8tfYBLST
X-Received: by 2002:a17:906:4d85:: with SMTP id s5mr22756947eju.18.1556283466573;
        Fri, 26 Apr 2019 05:57:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556283466; cv=none;
        d=google.com; s=arc-20160816;
        b=s3rTR7W7+AuNX9UEnFeIIfp/aIDLoiVfK/y9cXa+CGYSfTywoJ/BICq56FwoP8hTu/
         qpMev9Hv8IpCWJuRBZwjnZd9hrSZ9S51IEprU3J4J/24jONgn/pds+lxwQQcuA2Tsgyv
         O9Pv/lD77OwLtWumZWw8XgoWTYlTjYYNNXhKQoQHS7ORXriR4stWsZL6bR7sxkP2QDY6
         qKRtd6dCf2aJQ7tCoFWNiDu4Ssu3DAuz+1kTOHHigvBX3ZjCsRcbnPOzb6FFCm5Az5RN
         Kn96q28I7WXzY5EVv6snXOuiPOD76R7T/gAp4xejtAC40FJosEuH1dh45GzWfJirMPhS
         dYWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mwVF5MbOjOAoXZNvN0KeADNRVdw01NC901P/StXJpkY=;
        b=M0Kd+7F/0zjrzYuukI4SMgQ2Nicyt9Qq2oqUW55XXSRUpI4sEynS2TAVmHFklULmj8
         msbvm4WVbLI5qlqJXsHKwmXV4euXuHa55QYD9O1yFiZOgjdiS+WCjfNnOANskP5crmJA
         pQiT9Qk9Io27oe0Zfxp3GUstEv9+aPr1sUkf1zTA+Obgv0o+N0Ur1PqUPcrvYrSakp8P
         wKGVXckcAy6amFfGiQ0nVpsF4wVn3St1W5IlEqAEqXavUGfzEO5cpgqxYxuD7rmW0H9Z
         kk2S0GQPQit7gkMcS6jqTDP2Ddfb03ZwyMpfN0iaoItLwEKuFHmShzDwc6yMDV5ImGex
         jUYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v18si1636341edl.312.2019.04.26.05.57.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 05:57:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D89D3AE07;
	Fri, 26 Apr 2019 12:57:44 +0000 (UTC)
Date: Fri, 26 Apr 2019 14:57:41 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
	david@redhat.com
Subject: Re: [PATCH v6 03/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
Message-ID: <20190426125741.GB28583@linux>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552635098.2015392.5460028594173939000.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155552635098.2015392.5460028594173939000.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 11:39:11AM -0700, Dan Williams wrote:
> Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> section active bitmask, each bit representing 2MB (SECTION_SIZE (128M) /
> map_active bitmask length (64)). If it turns out that 2MB is too large
> of an active tracking granularity it is trivial to increase the size of
> the map_active bitmap.
> 
> The implications of a partially populated section is that pfn_valid()
> needs to go beyond a valid_section() check and read the sub-section
> active ranges from the bitmask.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
[...]  
> +static unsigned long section_active_mask(unsigned long pfn,
> +		unsigned long nr_pages)
> +{
> +	int idx_start, idx_size;
> +	phys_addr_t start, size;
> +
> +	if (!nr_pages)
> +		return 0;
> +
> +	start = PFN_PHYS(pfn);
> +	size = PFN_PHYS(min(nr_pages, PAGES_PER_SECTION
> +				- (pfn & ~PAGE_SECTION_MASK)));
> +	size = ALIGN(size, SECTION_ACTIVE_SIZE);

I am probably missing something, and this is more a question than anything else, but:
is there a reason for shifting pfn and pages to get the size and the address?
Could not we operate on pfn/pages, so we do not have to shift every time?
(even for pfn_section_valid() calls)

Something like:

#define SUB_SECTION_ACTIVE_PAGES        (SECTION_ACTIVE_SIZE / PAGE_SIZE)

static inline int section_active_index(unsigned long pfn)
{
	return (pfn & ~(PAGE_SECTION_MASK)) / SUB_SECTION_ACTIVE_PAGES;
}

> +
> +	idx_start = section_active_index(start);
> +	idx_size = section_active_index(size);
> +
> +	if (idx_size == 0)
> +		return -1;

What about turning that into something more intuitive?
Since -1 represents here a full section, we could define something like:

#define FULL_SECTION	(-1UL)

Or a better name, it is just that I find "-1" not really easy to interpret.

> +	return ((1UL << idx_size) - 1) << idx_start;
> +}
> +
> +void section_active_init(unsigned long pfn, unsigned long nr_pages)
> +{
> +	int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
> +	int i, start_sec = pfn_to_section_nr(pfn);
> +
> +	if (!nr_pages)
> +		return;
> +
> +	for (i = start_sec; i <= end_sec; i++) {
> +		struct mem_section *ms;
> +		unsigned long mask;
> +		unsigned long pfns;
> +
> +		pfns = min(nr_pages, PAGES_PER_SECTION
> +				- (pfn & ~PAGE_SECTION_MASK));
> +		mask = section_active_mask(pfn, pfns);
> +
> +		ms = __nr_to_section(i);
> +		pr_debug("%s: sec: %d mask: %#018lx\n", __func__, i, mask);
> +		ms->usage->map_active = mask;
> +
> +		pfn += pfns;
> +		nr_pages -= pfns;
> +	}
> +}
> +
>  /* Record a memory area against a node. */
>  void __init memory_present(int nid, unsigned long start, unsigned long end)
>  {
> 

-- 
Oscar Salvador
SUSE L3

