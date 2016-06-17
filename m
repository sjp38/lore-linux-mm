Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 472F46B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:32:25 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g18so39650870lfg.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 06:32:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j77si4806962wmj.33.2016.06.17.06.32.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 06:32:23 -0700 (PDT)
Subject: Re: [PATCH v3 7/9] mm/page_owner: avoid null pointer dereference
References: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1466150259-27727-8-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <09cfe295-87d0-16d9-36ed-458378b3bd05@suse.cz>
Date: Fri, 17 Jun 2016 15:32:20 +0200
MIME-Version: 1.0
In-Reply-To: <1466150259-27727-8-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 06/17/2016 09:57 AM, js1304@gmail.com wrote:
> From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
>
> We have dereferenced page_ext before checking it. Lets check it first
> and then used it.
>
> Link: http://lkml.kernel.org/r/1465249059-7883-1-git-send-email-sudipm.mukherjee@gmail.com
> Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hmm, this is already in mmotm as 
http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-page_owner-use-stackdepot-to-store-stacktrace-fix.patch

But imho it's fixing a problem not related to your patch, but something that the 
commit f86e4271978b missed. So it should separately go to 4.7 ASAP.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Fixes: f86e4271978b ("mm: check the return value of lookup_page_ext for all call 
sites")


> ---
>  mm/page_owner.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index dc92241..ec6dc18 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -295,13 +295,15 @@ void __dump_page_owner(struct page *page)
>  		.skip = 0
>  	};
>  	depot_stack_handle_t handle;
> -	gfp_t gfp_mask = page_ext->gfp_mask;
> -	int mt = gfpflags_to_migratetype(gfp_mask);
> +	gfp_t gfp_mask;
> +	int mt;
>
>  	if (unlikely(!page_ext)) {
>  		pr_alert("There is not page extension available.\n");
>  		return;
>  	}
> +	gfp_mask = page_ext->gfp_mask;
> +	mt = gfpflags_to_migratetype(gfp_mask);
>
>  	if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags)) {
>  		pr_alert("page_owner info is not active (free page?)\n");
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
