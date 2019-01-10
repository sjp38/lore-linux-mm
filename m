Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20B3A8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:31:50 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q64so8875098pfa.18
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 15:31:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f81si19831324pfh.33.2019.01.10.15.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 15:31:48 -0800 (PST)
Date: Thu, 10 Jan 2019 15:31:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [v5 PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
Message-Id: <20190110153147.1baf4c88bf0dd3b8a78aad08@linux-foundation.org>
In-Reply-To: <1546543673-108536-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1546543673-108536-1-git-send-email-yang.shi@linux.alibaba.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, daniel.m.jordan@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri,  4 Jan 2019 03:27:52 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> Swap readahead would read in a few pages regardless if the underlying
> device is busy or not.  It may incur long waiting time if the device is
> congested, and it may also exacerbate the congestion.
> 
> Use inode_read_congested() to check if the underlying device is busy or
> not like what file page readahead does.  Get inode from swap_info_struct.
> Although we can add inode information in swap_address_space
> (address_space->host), it may lead some unexpected side effect, i.e.
> it may break mapping_cap_account_dirty().  Using inode from
> swap_info_struct seems simple and good enough.
> 
> ...
>
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -538,11 +538,18 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  	bool do_poll = true, page_allocated;
>  	struct vm_area_struct *vma = vmf->vma;
>  	unsigned long addr = vmf->address;
> +	struct inode *inode = NULL;
>  
>  	mask = swapin_nr_pages(offset) - 1;
>  	if (!mask)
>  		goto skip;
>  
> +	if (si->flags & (SWP_BLKDEV | SWP_FS)) {

I re-read your discussion with Tim and I must say the reasoning behind
this test remain foggy.

What goes wrong if we just remove it?

What is the status of shmem swap readahead?

Can we at least get a comment in here which explains the reasoning?

Thanks.

> +		inode = si->swap_file->f_mapping->host;
> +		if (inode_read_congested(inode))
> +			goto skip;
> +	}
> +
>  	do_poll = false;
>  	/* Read a page_cluster sized and aligned cluster around offset. */
