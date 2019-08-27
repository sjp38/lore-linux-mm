Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9EF1C3A5A6
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 06:24:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7996320828
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 06:24:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7996320828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 005006B000A; Tue, 27 Aug 2019 02:24:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF7A56B000C; Tue, 27 Aug 2019 02:24:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E35556B000D; Tue, 27 Aug 2019 02:24:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0185.hostedemail.com [216.40.44.185])
	by kanga.kvack.org (Postfix) with ESMTP id C36BE6B000A
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 02:24:49 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 770A6181AC9B4
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 06:24:49 +0000 (UTC)
X-FDA: 75867219498.29.blood27_cf959e4f1c42
X-HE-Tag: blood27_cf959e4f1c42
X-Filterd-Recvd-Size: 3889
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 06:24:49 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 491DDADB3;
	Tue, 27 Aug 2019 06:24:47 +0000 (UTC)
Date: Tue, 27 Aug 2019 08:24:45 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	David Hildenbrand <david@redhat.com>, Qian Cai <cai@lca.pw>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] mm: don't hide potentially null memmap pointer in
 sparse_remove_section
Message-ID: <20190827062445.GO7538@dhcp22.suse.cz>
References: <20190827053656.32191-1-alastair@au1.ibm.com>
 <20190827053656.32191-3-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827053656.32191-3-alastair@au1.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 15:36:55, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> By adding offset to memmap before passing it in to clear_hwpoisoned_pages,
> we hide a theoretically null memmap from the null check inside
> clear_hwpoisoned_pages.

Isn't that other way around? Calculating the offset struct page pointer
will actually make the null check effective. Besides that I cannot
really see how pfn_to_page would return NULL. I have to confess that I
cannot really see how offset could lead to a NULL struct page either and
I strongly suspect that the NULL check is not really needed. Maybe it
used to be in the past.

> This patch passes the offset to clear_hwpoisoned_pages instead, allowing
> memmap to successfully perform it's null check.

I do not see any improvement in this patch. It just adds a new argument
unnecessarily.

> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> ---
>  mm/sparse.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index e41917a7e844..3ff84e627e58 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -882,7 +882,7 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
>  }
>  
>  #ifdef CONFIG_MEMORY_FAILURE
> -static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> +static void clear_hwpoisoned_pages(struct page *memmap, int start, int count)
>  {
>  	int i;
>  
> @@ -898,7 +898,7 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  	if (atomic_long_read(&num_poisoned_pages) == 0)
>  		return;
>  
> -	for (i = 0; i < nr_pages; i++) {
> +	for (i = start; i < start + count; i++) {
>  		if (PageHWPoison(&memmap[i])) {
>  			num_poisoned_pages_dec();
>  			ClearPageHWPoison(&memmap[i]);
> @@ -906,7 +906,8 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  	}
>  }
>  #else
> -static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> +static inline void clear_hwpoisoned_pages(struct page *memmap, int start,
> +		int count)
>  {
>  }
>  #endif
> @@ -915,7 +916,7 @@ void sparse_remove_section(struct mem_section *ms, unsigned long pfn,
>  		unsigned long nr_pages, unsigned long map_offset,
>  		struct vmem_altmap *altmap)
>  {
> -	clear_hwpoisoned_pages(pfn_to_page(pfn) + map_offset,
> +	clear_hwpoisoned_pages(pfn_to_page(pfn), map_offset,
>  			nr_pages - map_offset);
>  	section_deactivate(pfn, nr_pages, altmap);
>  }
> -- 
> 2.21.0
> 

-- 
Michal Hocko
SUSE Labs

