Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BA35C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:06:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 374F22084F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:06:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 374F22084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2CAB6B0007; Wed, 14 Aug 2019 10:06:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DC276B000A; Wed, 14 Aug 2019 10:06:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F3396B000C; Wed, 14 Aug 2019 10:06:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0157.hostedemail.com [216.40.44.157])
	by kanga.kvack.org (Postfix) with ESMTP id 699EC6B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:06:11 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 013FA180AD801
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:06:11 +0000 (UTC)
X-FDA: 75821207742.30.range25_53036b4d57527
X-HE-Tag: range25_53036b4d57527
X-Filterd-Recvd-Size: 2836
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:06:10 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 28850AFA9;
	Wed, 14 Aug 2019 14:06:09 +0000 (UTC)
Date: Wed, 14 Aug 2019 16:06:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Dan Williams <dan.j.williams@intel.com>,
	Borislav Petkov <bp@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Bjorn Helgaas <bhelgaas@google.com>, Ingo Molnar <mingo@kernel.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Nadav Amit <namit@vmware.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1 1/4] resource: Use PFN_UP / PFN_DOWN in
 walk_system_ram_range()
Message-ID: <20190814140608.GZ17933@dhcp22.suse.cz>
References: <20190809125701.3316-1-david@redhat.com>
 <20190809125701.3316-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809125701.3316-2-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 09-08-19 14:56:58, David Hildenbrand wrote:
> This makes it clearer that we will never call func() with duplicate PFNs
> in case we have multiple sub-page memory resources. All unaligned parts
> of PFNs are completely discarded.
> 
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Nadav Amit <namit@vmware.com>
> Cc: Wei Yang <richardw.yang@linux.intel.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  kernel/resource.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/resource.c b/kernel/resource.c
> index 7ea4306503c5..88ee39fa9103 100644
> --- a/kernel/resource.c
> +++ b/kernel/resource.c
> @@ -487,8 +487,8 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
>  	while (start < end &&
>  	       !find_next_iomem_res(start, end, flags, IORES_DESC_NONE,
>  				    false, &res)) {
> -		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
> -		end_pfn = (res.end + 1) >> PAGE_SHIFT;
> +		pfn = PFN_UP(res.start);
> +		end_pfn = PFN_DOWN(res.end + 1);
>  		if (end_pfn > pfn)
>  			ret = (*func)(pfn, end_pfn - pfn, arg);
>  		if (ret)
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

