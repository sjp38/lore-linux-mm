Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED11D8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:34:49 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id g12so4597263pll.22
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:34:49 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 2si21770188pla.156.2018.12.21.10.34.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 10:34:48 -0800 (PST)
Subject: Re: [v2 PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
References: <1545351679-23596-1-git-send-email-yang.shi@linux.alibaba.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <c3c77f08-f7af-7633-636d-c467759fbf20@linux.intel.com>
Date: Fri, 21 Dec 2018 10:34:47 -0800
MIME-Version: 1.0
In-Reply-To: <1545351679-23596-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/20/18 4:21 PM, Yang Shi wrote:

> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -538,11 +538,17 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  	bool do_poll = true, page_allocated;
>  	struct vm_area_struct *vma = vmf->vma;
>  	unsigned long addr = vmf->address;
> +	struct inode *inode = si->swap_file->f_mapping->host;
>  
>  	mask = swapin_nr_pages(offset) - 1;
>  	if (!mask)
>  		goto skip;
>  
> +	if (si->flags & (SWP_BLKDEV | SWP_FS)) {

Maybe move the inode dereference here: 

		inode = si->swap_file->f_mapping->host;

> +		if (inode_read_congested(inode))
> +			goto skip;
> +	}
> +

Thanks.

Tim
