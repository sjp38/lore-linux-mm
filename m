Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10AB4C3A59D
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 11:55:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCE892085A
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 11:55:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCE892085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63F2E6B000C; Mon, 19 Aug 2019 07:55:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F0126B000D; Mon, 19 Aug 2019 07:55:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 505FE6B000E; Mon, 19 Aug 2019 07:55:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0037.hostedemail.com [216.40.44.37])
	by kanga.kvack.org (Postfix) with ESMTP id 2FDA66B000C
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 07:55:58 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C50AA181AC9AE
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 11:55:57 +0000 (UTC)
X-FDA: 75839023554.10.title55_6e2e4523a5457
X-HE-Tag: title55_6e2e4523a5457
X-Filterd-Recvd-Size: 4869
Received: from mga14.intel.com (mga14.intel.com [192.55.52.115])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 11:55:56 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Aug 2019 04:55:55 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,403,1559545200"; 
   d="scan'208";a="261820515"
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga001.jf.intel.com with ESMTP; 19 Aug 2019 04:55:52 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 845AE128; Mon, 19 Aug 2019 14:55:51 +0300 (EEST)
Date: Mon, 19 Aug 2019 14:55:51 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/3] mm, page_owner: record page owner for each subpage
Message-ID: <20190819115551.xkgnpr7zmaqpuebi@black.fi.intel.com>
References:<20190816101401.32382-1-vbabka@suse.cz>
 <20190816101401.32382-2-vbabka@suse.cz>
 <20190816140430.aoya6k7qxxrls72h@box>
 <a9344bd6-cdb9-3ad6-5bb1-8eb81650c398@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To:<a9344bd6-cdb9-3ad6-5bb1-8eb81650c398@suse.cz>
User-Agent: NeoMutt/20170714-126-deb55f (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 11:46:37AM +0000, Vlastimil Babka wrote:
> 
> On 8/16/19 4:04 PM, Kirill A. Shutemov wrote:
> > On Fri, Aug 16, 2019 at 12:13:59PM +0200, Vlastimil Babka wrote:
> >> Currently, page owner info is only recorded for the first page of a high-order
> >> allocation, and copied to tail pages in the event of a split page. With the
> >> plan to keep previous owner info after freeing the page, it would be benefical
> >> to record page owner for each subpage upon allocation. This increases the
> >> overhead for high orders, but that should be acceptable for a debugging option.
> >>
> >> The order stored for each subpage is the order of the whole allocation. This
> >> makes it possible to calculate the "head" pfn and to recognize "tail" pages
> >> (quoted because not all high-order allocations are compound pages with true
> >> head and tail pages). When reading the page_owner debugfs file, keep skipping
> >> the "tail" pages so that stats gathered by existing scripts don't get inflated.
> >>
> >> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> > 
> > Hm. That's all reasonable, but I have a question: do you see how page
> > owner thing works for THP now?
> > 
> > I don't see anything in split_huge_page() path (do not confuse it with
> > split_page() path) that would copy the information to tail pages. Do you?
>  
> You're right, it's missing. This patch fixes that and can be added e.g.
> at the end of the series.

I would rather put it the first. Possbily with stable@.

> ----8<----
> From 56ac1b41559eecf52a2d453c49ce66dbbb227c64 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Mon, 19 Aug 2019 13:38:29 +0200
> Subject: [PATCH] mm, page_owner: handle THP splits correctly
> 
> THP splitting path is missing the split_page_owner() call that split_page()
> has. As a result, split THP pages are wrongly reported in the page_owner file
> as order-9 pages. Furthermore when the former head page is freed, the remaining
> former tail pages are not listed in the page_owner file at all. This patch
> fixes that by adding the split_page_owner() call into __split_huge_page().
> 
> Reported-by: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/huge_memory.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 738065f765ab..d727a0401484 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -32,6 +32,7 @@
>  #include <linux/shmem_fs.h>
>  #include <linux/oom.h>
>  #include <linux/numa.h>
> +#include <linux/page_owner.h>
>  
>  #include <asm/tlb.h>
>  #include <asm/pgalloc.h>
> @@ -2533,6 +2534,8 @@ static void __split_huge_page(struct page *page, struct list_head *list,
>  
>  	remap_page(head);
>  
> +	split_page_owner(head, HPAGE_PMD_ORDER);
> +

I think it has to be before remap_page(). This way nobody would be able to
mess with the page until it has valid page_owner.

>  	for (i = 0; i < HPAGE_PMD_NR; i++) {
>  		struct page *subpage = head + i;
>  		if (subpage == page)
> -- 
> 2.22.0
> 

-- 
 Kirill A. Shutemov

