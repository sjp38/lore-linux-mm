Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA3256B2A3E
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:13:42 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h40-v6so2283798edb.2
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:13:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y12-v6si1093137edm.280.2018.08.23.06.13.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 06:13:41 -0700 (PDT)
Date: Thu, 23 Aug 2018 15:13:39 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/3] mm/sparse: add likely to mem_section[root] check in
 sparse_index_init()
Message-ID: <20180823131339.GJ29735@dhcp22.suse.cz>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-2-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823130732.9489-2-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On Thu 23-08-18 21:07:30, Wei Yang wrote:
> Each time SECTIONS_PER_ROOT number of mem_section is allocated when
> mem_section[root] is null. This means only (1 / SECTIONS_PER_ROOT) chance
> of the mem_section[root] check is false.
> 
> This patch adds likely to the if check to optimize this a little.

Could you evaluate how much does this help if any? Does this have any
impact on the initialization path at all?

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/sparse.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 10b07eea9a6e..90bab7f03757 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -78,7 +78,7 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  	unsigned long root = SECTION_NR_TO_ROOT(section_nr);
>  	struct mem_section *section;
>  
> -	if (mem_section[root])
> +	if (likely(mem_section[root]))
>  		return -EEXIST;
>  
>  	section = sparse_index_alloc(nid);
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
