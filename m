Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F06CC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:05:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE52D2083B
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:05:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE52D2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6773F6B000A; Wed, 14 Aug 2019 12:05:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 600626B000C; Wed, 14 Aug 2019 12:05:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CD236B000D; Wed, 14 Aug 2019 12:05:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0197.hostedemail.com [216.40.44.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2273D6B000A
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:05:02 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C3BCB181AC9B4
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:05:01 +0000 (UTC)
X-FDA: 75821507202.21.verse05_660b0d694b627
X-HE-Tag: verse05_660b0d694b627
X-Filterd-Recvd-Size: 2930
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:05:01 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 01A52AB92;
	Wed, 14 Aug 2019 16:05:00 +0000 (UTC)
Date: Wed, 14 Aug 2019 18:04:58 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 2/5] mm/memory_hotplug: Drop PageReserved() check in
 online_pages_range()
Message-ID: <20190814160458.GH17933@dhcp22.suse.cz>
References: <20190814154109.3448-1-david@redhat.com>
 <20190814154109.3448-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814154109.3448-3-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 14-08-19 17:41:06, David Hildenbrand wrote:
> move_pfn_range_to_zone() will set all pages to PG_reserved via
> memmap_init_zone(). The only way a page could no longer be reserved
> would be if a MEM_GOING_ONLINE notifier would clear PG_reserved - which
> is not done (the online_page callback is used for that purpose by
> e.g., Hyper-V instead). walk_system_ram_range() will never call
> online_pages_range() with duplicate PFNs, so drop the PageReserved() check.
> 
> This seems to be a leftover from ancient times where the memmap was
> initialized when adding memory and we wanted to check for already
> onlined memory.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Thanks for spliting that up.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 3706a137d880..10ad970f3f14 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -653,9 +653,7 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>  {
>  	unsigned long onlined_pages = *(unsigned long *)arg;
>  
> -	if (PageReserved(pfn_to_page(start_pfn)))
> -		onlined_pages += online_pages_blocks(start_pfn, nr_pages);
> -
> +	onlined_pages += online_pages_blocks(start_pfn, nr_pages);
>  	online_mem_sections(start_pfn, start_pfn + nr_pages);
>  
>  	*(unsigned long *)arg = onlined_pages;
> -- 
> 2.21.0
> 

-- 
Michal Hocko
SUSE Labs

