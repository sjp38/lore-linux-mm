Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBE62C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:08:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C835206C1
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:08:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C835206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3742C6B0006; Wed, 14 Aug 2019 10:08:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 324A76B0007; Wed, 14 Aug 2019 10:08:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 213E66B000A; Wed, 14 Aug 2019 10:08:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0137.hostedemail.com [216.40.44.137])
	by kanga.kvack.org (Postfix) with ESMTP id 009D16B0006
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:08:07 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 950DF3AB7
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:08:07 +0000 (UTC)
X-FDA: 75821212614.08.store60_63fa68880e70f
X-HE-Tag: store60_63fa68880e70f
X-Filterd-Recvd-Size: 2958
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:08:06 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8A6B0ADCC;
	Wed, 14 Aug 2019 14:08:05 +0000 (UTC)
Date: Wed, 14 Aug 2019 16:08:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Arun KS <arunks@codeaurora.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v1 2/4] mm/memory_hotplug: Handle unaligned start and
 nr_pages in online_pages_blocks()
Message-ID: <20190814140805.GA17933@dhcp22.suse.cz>
References: <20190809125701.3316-1-david@redhat.com>
 <20190809125701.3316-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809125701.3316-3-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 09-08-19 14:56:59, David Hildenbrand wrote:
> Take care of nr_pages not being a power of two and start not being
> properly aligned. Essentially, what walk_system_ram_range() could provide
> to us. get_order() will round-up in case it's not a power of two.
> 
> This should only apply to memory blocks that contain strange memory
> resources (especially with holes), not to ordinary DIMMs.

I would really like to see an example of such setup before making the
code hard to read. Because I am not really sure something like that
exists at all.

> Fixes: a9cd410a3d29 ("mm/page_alloc.c: memory hotplug: free pages as higher order")
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  mm/memory_hotplug.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 3706a137d880..2abd938c8c45 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -640,6 +640,10 @@ static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
>  	while (start < end) {
>  		order = min(MAX_ORDER - 1,
>  			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
> +		/* make sure the PFN is aligned and we don't exceed the range */
> +		while (!IS_ALIGNED(start, 1ul << order) ||
> +		       (1ul << order) > end - start)
> +			order--;
>  		(*online_page_callback)(pfn_to_page(start), order);
>  
>  		onlined_pages += (1UL << order);
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

