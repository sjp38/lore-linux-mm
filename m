Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08463C3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 05:38:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B35BD2186A
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 05:38:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B35BD2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B0E26B0006; Fri, 30 Aug 2019 01:38:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1610C6B0008; Fri, 30 Aug 2019 01:38:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04FC66B000A; Fri, 30 Aug 2019 01:38:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0182.hostedemail.com [216.40.44.182])
	by kanga.kvack.org (Postfix) with ESMTP id D6F946B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 01:38:12 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 61E71824CA3D
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 05:38:12 +0000 (UTC)
X-FDA: 75877988424.17.field92_479accf1ea803
X-HE-Tag: field92_479accf1ea803
X-Filterd-Recvd-Size: 2135
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 05:38:11 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DB987ACA0;
	Fri, 30 Aug 2019 05:38:09 +0000 (UTC)
Date: Fri, 30 Aug 2019 07:38:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Austin Kim <austindh.kim@gmail.com>
Cc: akpm@linux-foundation.org, urezki@gmail.com, guro@fb.com,
	rpenyaev@suse.de, rick.p.edgecombe@intel.com, rppt@linux.ibm.com,
	aryabinin@virtuozzo.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/vmalloc: move 'area->pages' after if statement
Message-ID: <20190830053808.GM28313@dhcp22.suse.cz>
References: <20190830035716.GA190684@LGEARND20B15>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190830035716.GA190684@LGEARND20B15>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 30-08-19 12:57:16, Austin Kim wrote:
> If !area->pages statement is true where memory allocation fails, 
> area is freed.
> 
> In this case 'area->pages = pages' should not executed.
> So move 'area->pages = pages' after if statement.
> 
> Signed-off-by: Austin Kim <austindh.kim@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
> ---
>  mm/vmalloc.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index b810103..af93ba6 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2416,13 +2416,15 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  	} else {
>  		pages = kmalloc_node(array_size, nested_gfp, node);
>  	}
> -	area->pages = pages;
> -	if (!area->pages) {
> +
> +	if (!pages) {
>  		remove_vm_area(area->addr);
>  		kfree(area);
>  		return NULL;
>  	}
>  
> +	area->pages = pages;
> +
>  	for (i = 0; i < area->nr_pages; i++) {
>  		struct page *page;
>  
> -- 
> 2.6.2
> 

-- 
Michal Hocko
SUSE Labs

