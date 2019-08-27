Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC457C41514
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 06:25:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABAA22186A
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 06:25:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABAA22186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BF426B000C; Tue, 27 Aug 2019 02:25:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46F7B6B000D; Tue, 27 Aug 2019 02:25:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3860E6B000E; Tue, 27 Aug 2019 02:25:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id 1C72D6B000C
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 02:25:35 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BF79482437C9
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 06:25:34 +0000 (UTC)
X-FDA: 75867221388.10.use34_139154f6d7a0d
X-HE-Tag: use34_139154f6d7a0d
X-Filterd-Recvd-Size: 2330
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 06:25:34 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 340F7B04F;
	Tue, 27 Aug 2019 06:25:33 +0000 (UTC)
Date: Tue, 27 Aug 2019 08:25:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Dan Williams <dan.j.williams@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	David Hildenbrand <david@redhat.com>,
	Wei Yang <richardw.yang@linux.intel.com>, Qian Cai <cai@lca.pw>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] mm: Don't manually decrement num_poisoned_pages
Message-ID: <20190827062532.GP7538@dhcp22.suse.cz>
References: <20190827053656.32191-1-alastair@au1.ibm.com>
 <20190827053656.32191-2-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827053656.32191-2-alastair@au1.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 15:36:54, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> Use the function written to do it instead.
> 
> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/sparse.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 72f010d9bff5..e41917a7e844 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -11,6 +11,8 @@
>  #include <linux/export.h>
>  #include <linux/spinlock.h>
>  #include <linux/vmalloc.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
>  
>  #include "internal.h"
>  #include <asm/dma.h>
> @@ -898,7 +900,7 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  
>  	for (i = 0; i < nr_pages; i++) {
>  		if (PageHWPoison(&memmap[i])) {
> -			atomic_long_sub(1, &num_poisoned_pages);
> +			num_poisoned_pages_dec();
>  			ClearPageHWPoison(&memmap[i]);
>  		}
>  	}
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

