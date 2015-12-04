Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id B16CD6B025B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 11:01:37 -0500 (EST)
Received: by wmec201 with SMTP id c201so71001100wme.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 08:01:37 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z2si19366060wjx.135.2015.12.04.08.01.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 08:01:36 -0800 (PST)
Date: Fri, 4 Dec 2015 11:01:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: memcg uncharge page counter mismatch
Message-ID: <20151204160128.GA24431@cmpxchg.org>
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
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 03, 2015 at 04:47:29PM +0100, Michal Hocko wrote:
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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

The charge moving concept is fundamentally flawed and its
implementation here is incomplete and races with reclaim.

Really, nobody should be using this. Absent any actual regression
reports, a minimal fix to stop this code from generating warnings
should be enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
