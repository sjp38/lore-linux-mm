Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5A96B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 00:35:27 -0500 (EST)
Received: by pfbg73 with SMTP id g73so21107684pfb.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 21:35:27 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id 5si16939193pfo.235.2015.12.03.21.35.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 21:35:26 -0800 (PST)
Received: by pfbg73 with SMTP id g73so21107540pfb.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 21:35:26 -0800 (PST)
Date: Fri, 4 Dec 2015 14:35:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: memcg uncharge page counter mismatch
Message-ID: <20151204053515.GA5174@blaptop>
References: <20151201133455.GB27574@bbox>
 <20151202101643.GC25284@dhcp22.suse.cz>
 <20151203013404.GA30779@bbox>
 <20151203021006.GA31041@bbox>
 <20151203085451.GC9264@dhcp22.suse.cz>
 <20151203125950.GA1428@bbox>
 <20151203133719.GF9264@dhcp22.suse.cz>
 <20151203134326.GG9264@dhcp22.suse.cz>
 <20151203145850.GH9264@dhcp22.suse.cz>
 <20151203154729.GI9264@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151203154729.GI9264@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 03, 2015 at 04:47:29PM +0100, Michal Hocko wrote:
> On Thu 03-12-15 15:58:50, Michal Hocko wrote:
> [....]
> > Warning, this looks ugly as hell.
> 
> I was thinking about it some more and it seems that we should rather not
> bother with partial thp at all and keep it in the original memcg
> instead. It is way much less code and I do not think this will be too
> disruptive. Somebody should be holding the thp head, right?
> 
> Minchan, does this fix the issue you are seeing.

This patch solves the issue but not sure it's right approach.
I think it could make regression that in old, we could charge
a THP page but we can't now. Whether it's trivial or not, it depends
on memcg guys.

Thanks.


> ---
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 79a29d564bff..143c933f0b81 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4895,6 +4895,14 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
>  		switch (get_mctgt_type(vma, addr, ptent, &target)) {
>  		case MC_TARGET_PAGE:
>  			page = target.page;
> +			/*
> +			 * We can have a part of the split pmd here. Moving it
> +			 * can be done but it would be too convoluted so simply
> +			 * ignore such a partial THP and keep it in original
> +			 * memcg. There should be somebody mapping the head.
> +			 */
> +			if (PageCompound(page))
> +				goto put;
>  			if (isolate_lru_page(page))
>  				goto put;
>  			if (!mem_cgroup_move_account(page, false,
> -- 
> Michal Hocko
> SUSE Labs

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
