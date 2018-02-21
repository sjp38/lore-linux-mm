Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3FC66B000E
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 11:19:17 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id t192so2056471iof.6
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 08:19:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q67sor6648410itg.134.2018.02.21.08.19.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 08:19:16 -0800 (PST)
Date: Wed, 21 Feb 2018 10:19:14 -0600
From: Dan Rue <dan.rue@linaro.org>
Subject: Re: [PATCH 5/6] mm, hugetlb: further simplify hugetlb allocation API
Message-ID: <20180221161914.ltssyoumwpyiwca6@xps>
References: <20180103093213.26329-1-mhocko@kernel.org>
 <20180103093213.26329-6-mhocko@kernel.org>
 <20180221042457.uolmhlmv5je5dqx7@xps>
 <20180221095526.GB2231@dhcp22.suse.cz>
 <20180221100107.GC2231@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180221100107.GC2231@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 21, 2018 at 11:01:07AM +0100, Michal Hocko wrote:
> On Wed 21-02-18 10:55:26, Michal Hocko wrote:
> > On Tue 20-02-18 22:24:57, Dan Rue wrote:
> [...]
> > > I bisected the failure to this commit. The problem is seen on multiple
> > > architectures (tested x86-64 and arm64).
> > 
> > The patch shouldn't have introduced any functional changes IIRC. But let
> > me have a look
> 
> Hmm, I guess I can see it. Does the following help?
> ---
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7c204e3d132b..a963f2034dfc 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1583,7 +1583,7 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
>  		page = NULL;
>  	} else {
>  		h->surplus_huge_pages++;
> -		h->nr_huge_pages_node[page_to_nid(page)]++;
> +		h->surplus_huge_pages_node[page_to_nid(page)]++;
>  	}
>  
>  out_unlock:

That did the trick. Confirmed fixed on v4.15-3389-g0c397daea1d4 and
v4.16-rc2 with the above patch.

Dan

> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
