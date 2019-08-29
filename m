Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4059FC3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:27:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EDD7233A1
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:27:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EDD7233A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 792CD6B0005; Thu, 29 Aug 2019 03:27:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71C516B0006; Thu, 29 Aug 2019 03:27:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60A4A6B0266; Thu, 29 Aug 2019 03:27:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0178.hostedemail.com [216.40.44.178])
	by kanga.kvack.org (Postfix) with ESMTP id 37E336B0005
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:27:16 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E2693181AC9B4
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:27:15 +0000 (UTC)
X-FDA: 75874634430.16.love95_5c7e7bf851352
X-HE-Tag: love95_5c7e7bf851352
X-Filterd-Recvd-Size: 2627
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:27:15 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 405D2AFCB;
	Thu, 29 Aug 2019 07:27:14 +0000 (UTC)
Date: Thu, 29 Aug 2019 09:27:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@d-silva.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Logan Gunthorpe <logang@deltatee.com>, Baoquan He <bhe@redhat.com>,
	Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Remove NULL check in clear_hwpoisoned_pages()
Message-ID: <20190829072712.GS28313@dhcp22.suse.cz>
References: <20190829035151.20975-1-alastair@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190829035151.20975-1-alastair@d-silva.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 29-08-19 13:51:50, Alastair D'Silva wrote:
> There is no possibility for memmap to be NULL in the current
> codebase.
> 
> This check was added in commit 95a4774d055c ("memory-hotplug:
> update mce_bad_pages when removing the memory")
> where memmap was originally inited to NULL, and only conditionally
> given a value.
> 
> The code that could have passed a NULL has been removed, so there

removed by  ba72b4c8cf60 ("mm/sparsemem: support sub-section hotplug")
> is no longer a possibility that memmap can be NULL.

I haven't studied whether section_mem_map could have been NULL before
then but the important part is that NULL is not possible anymore as
pfn_to_page shouldn't ever return NULL.
 
> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/sparse.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 78979c142b7d..9f7e3682cdcb 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -754,9 +754,6 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  {
>  	int i;
>  
> -	if (!memmap)
> -		return;
> -
>  	/*
>  	 * A further optimization is to have per section refcounted
>  	 * num_poisoned_pages.  But that would need more space per memmap, so
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

